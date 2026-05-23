# Configuration file for the Sphinx documentation builder.
# https://www.sphinx-doc.org/en/master/usage/configuration.html
import subprocess

project = 'Simple-rfsoc-4x2-Example'
author = 'SLAC National Accelerator Laboratory'
copyright = '2026, SLAC National Accelerator Laboratory'

try:
    release = subprocess.check_output(
        ['git', 'describe', '--tags', '--abbrev=0'],
        stderr=subprocess.DEVNULL,
    ).decode().strip()
except Exception:
    release = 'dev'
version = release

extensions = [
    'sphinx.ext.extlinks',
    'sphinx_copybutton',
]

extlinks = {
    'repo': ('https://github.com/slaclab/Simple-rfsoc-4x2-Example/blob/main/%s', '%s'),
    'hub': ('https://slaclab.github.io/axi-soc-ultra-plus-core/%s', '%s'),
}

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

source_suffix = '.rst'
master_doc = 'index'
language = 'en'

html_theme = 'sphinx_rtd_theme'
html_theme_options = {'titles_only': True, 'navigation_depth': -1}
html_title = 'Simple-rfsoc-4x2-Example'
html_baseurl = 'https://slaclab.github.io/Simple-rfsoc-4x2-Example/'
html_static_path = ['_static']
