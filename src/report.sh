# kw keeps track of some data operations; the most prominent example is the
# Pomodoro feature. This file intends to keep all procedures related to data
# processing that will end up as a report for the user.

include "$KW_LIB_DIR/kw_config_loader.sh"
include "$KW_LIB_DIR/kw_time_and_date.sh"
include "$KW_LIB_DIR/kwlib.sh"
include "$KW_LIB_DIR/kw_string.sh"
include "$KW_LIB_DIR/statistics.sh"

declare -g KW_POMODORO_DATA="$KW_DATA_DIR/pomodoro"
declare -gA options_values
declare -gA tags_details
declare -gA tags_metadata

function report_main()
{
  local target_time
  local ret

  parse_report_options "$@"
  if [[ "$?" -gt 0 ]]; then
    complain "${options_values['ERROR']}"
    return 22 # EINVAL
  fi

  if [[ -n "${options_values['DAY']}" ]]; then
    grouping_day_data "${options_values['DAY']}"
    target_time="${options_values['DAY']}"
  elif [[ -n "${options_values['WEEK']}" ]]; then
    target_time="${options_values['WEEK']}"
    grouping_week_data "${options_values['WEEK']}"
  elif [[ -n "${options_values['MONTH']}" ]]; then
    target_time="${options_values['MONTH']}"
    grouping_month_data "${options_values['MONTH']}"
  elif [[ -n "${options_values['YEAR']}" ]]; then
    target_time="${options_values['YEAR']}"
    grouping_year_data "${options_values['YEAR']}"
  fi

  if [[ -z "${options_values['OUTPUT']}" ]]; then
    show_data "$target_time"
  else
    save_data_to "${options_values['OUTPUT']}"
  fi
}

# Convert time labels in the format INTEGER[s|m|h] to an entire label that can
# be used inside the command date.
#
# @timebox Time box in the format INTEGER[s|m|h]
#
# Return:
# Expanded label in the format INTEGER [seconds|minutes|hours].
function expand_time_labels()
{
  local timebox="$1"
  local time_type
  local time_value
  local time_label

  timebox=$(str_strip "$timebox")

  [[ -z "$timebox" ]] && return 22 # EINVAL

  time_type=$(last_char "$timebox")
  if [[ ! "$time_type" =~ h|m|s ]]; then
    time_type='s'
    timebox="$timebox$time_type"
  fi

  time_value=$(chop "$timebox")
  if ! str_is_a_number "$time_value"; then
    return 22 # EINVAL
  fi

  case "$time_type" in
    h)
      time_label="$time_value hours"
      ;;
    m)
      time_label="$time_value minutes"
      ;;
    s)
      time_label="$time_value seconds"
      ;;
  esac

  printf '%s\n' "$time_label"
}

function timebox_to_sec()
{
  local timebox="$1"
  local time_type
  local time_value

  time_type=$(last_char "$timebox")
  time_value=$(chop "$timebox")

  case "$time_type" in
    h)
      time_value=$((3600 * time_value))
      ;;
    m)
      time_value=$((60 * time_value))
      ;;
    s)
      true # Do nothing
      ;;
  esac

  printf '%s\n' "$time_value"
}

# Group day data in the tags_details and tags_metadata. Part of the process
# includes pre-processing raw data in something good to be displayed for users.
#
# @day: Day in the format YYYY/MM/DD
function grouping_day_data()
{
  local day="$*"
  local day_path
  local details
  local start_time
  local end_time
  local timebox
  local time_label
  local timebox_sec
  local total_time_box_sec=0
  local total_repetition=0

  day_path=$(join_path "$KW_POMODORO_DATA" "$day")
  if [[ ! -f "$day_path" ]]; then
    return 2 # ENOENT
  fi

  # details, total focus time
  while read -r line; do
    tag=$(printf '%s\n' "$line" | cut -d ',' -f1)
    timebox=$(printf '%s\n' "$line" | cut -d ',' -f2)
    start_time=$(printf '%s\n' "$line" | cut -d ',' -f3)
    details=$(printf '%s\n' "$line" | cut -d ',' -f4)

    time_label=$(expand_time_labels "$timebox")
    [[ "$?" != 0 ]] && continue

    end_time=$(date --date="$start_time $time_label" +%H:%M:%S)

    [[ -n "$details" ]] && details=": $details"
    tags_details["$tag"]+=" * [$start_time-$end_time][$timebox]$details"$'\n'

    # Preparing metadata: total timebox in sec, total repetition
    timebox_sec=$(timebox_to_sec "$timebox")
    total_time_box_sec=$(printf '%s\n' "${tags_metadata["$tag"]}" | cut -d ',' -f1)
    total_repetition=$(printf '%s\n' "${tags_metadata["$tag"]}" | cut -d ',' -f2)

    timebox_sec=$((timebox_sec + total_time_box_sec))
    total_repetition=$((total_repetition + 1))

    tags_metadata["$tag"]="$timebox_sec,$total_repetition"
  done < "$day_path"
}

# This function groups all week days data.
#
# @first_day_of_the_week: First day of the target week
function grouping_week_data()
{
  local first_day_of_the_week="$*"
  local day_path

  for ((i = 0; i < 7; i++)); do
    day=$(date --date="${first_day_of_the_week} +${i} day" +%Y/%m/%d)
    day_path=$(join_path "$KW_POMODORO_DATA" "$day")
    [[ ! -f "$day_path" ]] && continue
    grouping_day_data "$day"
  done
}

# This function groups all month days data.
#
# @target_month: First day of the target month
function grouping_month_data()
{
  local target_month="$*"
  local month_total_days
  local day_path
  local year
  local month
  local current_day

  year=$(printf '%s\n' "$target_month" | cut -d '/' -f1)
  month=$(printf '%s\n' "$target_month" | cut -d '/' -f2)
  month_total_days=$(days_in_the_month "$month" "$year")

  for ((day = 1; day <= month_total_days; day++)); do
    current_day="$target_month/"$(printf '%02d\n' "$day")
    day_path=$(join_path "$KW_POMODORO_DATA" "$current_day")
    [[ ! -f "$day_path" ]] && continue
    grouping_day_data "$current_day"
  done
}

# This function groups data for an entire year.
#
# @target_year: Target year
function grouping_year_data()
{
  local target_year="$*"
  local month_path
  local target_day
  local current_day
  local current_month
  local full_day_path
  local month_total_days

  for ((month = 1; month <= 12; month++)); do
    current_month=$(printf '%02d\n' "$month")
    month_total_days=$(days_in_the_month "$month" "$target_year")
    month_path=$(join_path "$target_year" "$current_month")
    for ((day = 1; day <= month_total_days; day++)); do
      current_day=$(printf '%02d\n' "$day")
      target_day=$(join_path "$month_path" "$current_day")
      full_day_path=$(join_path "$KW_POMODORO_DATA" "$target_day")
      [[ ! -f "$full_day_path" ]] && continue
      grouping_day_data "$target_day"
    done
  done
}

function show_total_work_hours()
{
  local work_hours_sec="$1"
  local hours
  local minutes
  local seconds

  hours=$((work_hours_sec / 3600))
  minutes=$((work_hours_sec % 3600 / 60))
  seconds=$((work_hours_sec % 60))

  printf ' * Total hours of focus: %02d:%02d:%02d\n' "$hours" "$minutes" "$seconds"
}

# Show report data after processing.
function show_data
{
  local date="$*"
  local total_time=0
  local total_repetition
  local tag_time
  local tag_repetition=0
  local total_focus_time=0

  printf '%s\n' "# Report: $date"

  for tag in "${!tags_metadata[@]}"; do
    tag_time=$(printf '%s\n' "${tags_metadata[$tag]}" | cut -d ',' -f1)
    tag_repetition=$(printf '%s\n' "${tags_metadata[$tag]}" | cut -d ',' -f2)

    total_focus_time=$((tag_time + total_focus_time))
    total_repetition=$((total_repetition + tag_repetition))
  done

  show_total_work_hours "$total_focus_time"
  printf '%s\n\n' " * Total focus session(s): $total_repetition"

  for tag in "${!tags_details[@]}"; do
    printf '%s\n' "## $tag"
    total_time=$(printf '%s\n' "${tags_metadata[$tag]}" | cut -d ',' -f1)
    total_repetition=$(printf '%s\n' "${tags_metadata[$tag]}" | cut -d ',' -f2)

    total_time=$(sec_to_format "$total_time")
    printf '%s\n' " - Total focus time: $total_time" \
      " - Total repetitions: $total_repetition" \
      '' \
      'Summary:' \
      "${tags_details[$tag]}"
  done
}

# Save report output to a file.
#
# @path: Where to save
#
# Return:
# In case of error, return an error code.
function save_data_to()
{
  local path="$1"
  local ret

  touch "$path" 2> /dev/null
  ret="$?"
  if [[ "$ret" != 0 ]]; then
    complain "Failed to create $path, please check if this is a valid path"
    exit "$ret"
  fi

  show_data > "$path"
}

function parse_report_options()
{
  local output
  local reference='DAY'
  local reference_count=0
  local options
  local long_options='day,week,month,year,output'
  local short_options='o'

  options="$(kw_parse "$short_options" "$long_options" "$@")"

  if [[ "$?" != 0 ]]; then
    options_values['ERROR']="$(kw_parse_get_errors 'kw report' "$short_options" \
      "$long_options" "$@")"
    return 22 # EINVAL
  fi

  options_values['DAY']=''
  options_values['WEEK']=''
  options_values['MONTH']=''
  options_values['YEAR']=''
  options_values['OUTPUT']=''

  eval "set -- $options"

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --day)
        options_values['DAY']=$(get_today_info '+%Y/%m/%d')
        reference='DAY'
        reference_count+=1
        shift
        ;;
      --week)
        options_values['WEEK']=$(get_week_beginning_day)
        reference='WEEK'
        reference_count+=1
        shift
        ;;
      --month)
        options_values['MONTH']=$(get_today_info '+%Y/%m')
        reference='MONTH'
        reference_count+=1
        shift
        ;;
      --year)
        options_values['YEAR']=$(date +%Y)
        reference='YEAR'
        reference_count+=1
        shift
        ;;
      --output)
        options_values['OUTPUT']=""
        output=1
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        options_values['ERROR']="Unrecognized argument: $1"
        return 22 # EINVAL
        shift
        ;;
    esac
  done

  if [[ "$reference_count" -gt 1 ]]; then
    complain 'Please, only use a single time reference'
    return 22
  fi

  if [[ "$output" == 1 ]]; then
    if [[ "$#" == 1 ]]; then
      options_values['OUTPUT']="$1"
      shift
    elif [[ "$#" == 2 ]]; then
      options_values['OUTPUT']="$2"
    else
      options_values['ERROR']="Invalid path for the --output argument."
      return 22 # EINVAL
    fi
  fi

  if [[ "$#" == 0 && "$reference" == 'DAY' ]]; then
    options_values['DAY']=$(get_today_info '+%Y/%m/%d')
  elif [[ -n $1 ]]; then
    case "$reference" in
      'DAY')
        options_values['DAY']=$(date_to_format "$1" '+%Y/%m/%d')
        ;;
      'WEEK')
        options_values['WEEK']=$(get_week_beginning_day "$1")
        ;;
      'MONTH')
        options_values['MONTH']=$(date_to_format "$1/01" '+%Y/%m')
        ;;
      'YEAR')
        options_values['YEAR']=$(date_to_format "$1/01/01" +%Y)
        ;;
    esac

    if [[ "$?" != 0 ]]; then
      complain "Invalid parameter: $1"
      return 22 # EINVAL
    fi
    shift
  fi
}

function report_help()
{
  if [[ "$1" == --help ]]; then
    include "$KW_LIB_DIR/help.sh"
    kworkflow_man 'report'
    return
  fi
  printf '%s\n' 'kw report:' \
    '  report [--day [<year>/<month>/<day>]] - Report of the day' \
    '  report [--week [<year>/<month>/<day>]] - Report of the week' \
    '  report [--month [<year>/<month>]] - Report of the month' \
    '  report [--year [<year>]] - Report fo the year' \
    '  report [--output <path>] - Save report to <path>'
}
