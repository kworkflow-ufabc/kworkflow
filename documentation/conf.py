# -*- coding: utf-8 -*-
#
# Configuration file for the Sphinx documentation builder.
#
# This file does only contain a selection of the most common options. For a
# full list see the documentation:
# http://www.sphinx-doc.org/en/master/config

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
sys.path.insert(0, os.path.abspath('..'))


# -- Project information -----------------------------------------------------

project = 'kw'
copyright = '2019, Rodrigo Siqueira, Matheus Tavares'
author = 'Rodrigo Siqueira, Matheus Tavares'

# The short X.Y version
version = ''
# The full version, including alpha/beta/rc tags
release = ''


# -- General configuration ---------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.doctest',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    # Not needed for now, and it's not supported on older versions of Sphinx
    #'sphinx.ext.imgmath',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx.ext.graphviz',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
#
# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = None

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
try:
    import sphinx_book_theme
    html_theme = 'sphinx_book_theme'
except ImportError:
    sys.stdout.write('We could not find the book theme used on our website. You can install it using: pip install sphinx-book-theme.\n')
    sys.stdout.write('For now, kw will assume the default theme - Alabaster\n')
    html_theme = 'alabaster'

html_favicon = 'favicon.ico'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
# html_theme_options = {}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = []

# Custom sidebar templates, must be a dictionary that maps document names
# to template names.
#
# The default sidebars (for documents that don't match any pattern) are
# defined by theme itself.  Builtin themes are using these templates by
# default: ``['localtoc.html', 'relations.html', 'sourcelink.html',
# 'searchbox.html']``.
#
# html_sidebars = {}


# -- Options for HTMLHelp output ---------------------------------------------

# Output file base name for HTML help builder.
htmlhelp_basename = 'KernelWorkflowdoc'


# -- Options for LaTeX output ------------------------------------------------

latex_elements = {
    # The paper size ('letterpaper' or 'a4paper').
    #
    # 'papersize': 'letterpaper',

    # The font size ('10pt', '11pt' or '12pt').
    #
    # 'pointsize': '10pt',

    # Additional stuff for the LaTeX preamble.
    #
    # 'preamble': '',

    # Latex figure (float) alignment
    #
    # 'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, 'KernelWorkflow.tex', 'KernelWorkflow Documentation',
     'Rodrigo Siqueira, Matheus Tavares', 'manual'),
]


# -- Options for manual page output ------------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    ('man/kw', 'kw', 'KernelWorkflow Documentation', [author], 1),
    ('man/features/backup', 'backup', 'save and restore kw data', [author], 1),
    ('man/features/build', 'build', 'build the kernel', [author], 1),
    ('man/features/codestyle', 'codestyle', 'checkpatch wrapper', [author], 1),
    ('man/features/configm', 'configm', 'config manager', [author], 1),
    ('man/features/debug', 'debug', 'kernel debug', [author], 1),
    ('man/features/deploy', 'deploy', 'deploy the kernel', [author], 1),
    ('man/features/device', 'device', 'hardware information', [author], 1),
    ('man/features/diff', 'diff', 'useful diff wrapper', [author], 1),
    ('man/features/drm', 'drm', 'drm subsystem support', [author], 1),
    ('man/features/explore', 'explore', 'git grep wrapper', [author], 1),
    ('man/features/init', 'init', 'initialize kworkflow.config', [author], 1),
    ('man/features/maintainers', 'maintainers', 'display module maintainers', [author], 1),
    ('man/features/mount', 'mount', 'command for mounting a QEMU VM', [author], 1),
    ('man/features/pomodoro', 'pomodoro', 'pomodoro style time management', [author], 1),
    ('man/features/report', 'report', 'user data report support', [author], 1),
    ('man/features/ssh', 'ssh', 'ssh access', [author], 1),
    ('man/features/statistics', 'statistics', 'statistics about kw', [author], 1),
    ('man/features/umount', 'umount', 'command for unmounting a QEMU VM', [author], 1),
    ('man/features/up', 'up', 'command for starting a QEMU VM', [author], 1),
    ('man/features/vars', 'vars', 'view kw config values', [author], 1),
]


# -- Options for Texinfo output ----------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
    (master_doc, 'KernelWorkflow', 'KernelWorkflow Documentation',
     author, 'KernelWorkflow',
    'Inglorious kernel developer workflow tool', 'Miscellaneous'),
]


# -- Options for Epub output -------------------------------------------------

# Bibliographic Dublin Core info.
epub_title = project

# The unique identifier of the text. This can be a ISBN number
# or the project homepage.
#
# epub_identifier = ''

# A unique identification for the text.
#
# epub_uid = ''

# A list of files that should not be packed into the epub file.
epub_exclude_files = ['search.html']


# -- Extension configuration -------------------------------------------------

# -- Options for todo extension ----------------------------------------------

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True
