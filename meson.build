project('gxml', [ 'vala', 'c'], version : '0.20.5')

pkgconfig = import('pkgconfig')

PROJECT_NAME = meson.project_name ()
API_VERSION = '0.20'
PROJECT_VERSION = meson.project_version ()
VERSIONED_PROJECT_NAME = PROJECT_NAME+'-'+API_VERSION
CAMEL_CASE_NAME = 'GXml'
VERSIONED_CAMEL_CASE_NAME = CAMEL_CASE_NAME +'-'+ API_VERSION

gee = dependency('gee-0.8', version:'>=0.20.5')
gee_girdir = gee.get_variable('datadir') / 'gir-1.0'
gee_vapidir = gee.get_variable('datadir') / 'vala' / 'vapi'
add_project_arguments(['--vapidir', gee_vapidir], language: 'vala')

libgxml_deps = [
	dependency('libxml-2.0', version: '>=2.9.13'),
	dependency('gio-2.0', version: '>=2.72'),
	meson.get_compiler('c').find_library('intl', required: false),
	gee
	]

VALADEPS = 'gee-0.8\ngio-2.0\nlibxml-2.0'
PCDEPS = 'gee-0.8 gio-2.0 libxml-2.0'

inc_rooth = include_directories ('.')
inc_rooth_dep = declare_dependency (include_directories : inc_rooth)

subdir('po')
subdir('vapi')
subdir('gxml')
if get_option('docs')
subdir('docs')
endif
subdir('test')
subdir('examples')
