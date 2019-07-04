project('gxml', [ 'vala', 'c'], version : '0.18.0')

PROJECT_NAME = meson.project_name ()
API_VERSION = '0.18'
PROJECT_VERSION = meson.project_version ()
VERSIONED_PROJECT_NAME = PROJECT_NAME+'-'+API_VERSION
CAMEL_CASE_NAME = 'GXml'
VERSIONED_CAMEL_CASE_NAME = CAMEL_CASE_NAME +'-'+ API_VERSION

libgxml_deps = [
	dependency('libxml-2.0'),
	dependency('gio-2.0'),
	dependency('gee-0.8')
	]

VALADEPS = 'gee-0.8\ngio-2.0\nlibxml-2.0'
PCDEPS = 'gee-0.8 gio-2.0 libxml-2.0'

inc_rooth = include_directories ('.')
inc_rooth_dep = declare_dependency (include_directories : inc_rooth)

subdir('po')
subdir('vapi')
subdir('gxml')
if not get_option('disable-valadocs')
subdir('docs')
endif
subdir('test')
subdir('examples')
