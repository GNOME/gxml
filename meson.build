project(
  'gxml',
  ['c', 'vala'],
  version: '0.20.5',
  meson_version: '>=1.2.0',
  default_options: [
    'buildtype=debugoptimized',
    'warning_level=2',
    'b_ndebug=if-release',
  ],
)

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

c_compiler = meson.get_compiler('c')
intl_dep = declare_dependency()
if not c_compiler.has_function('bindtextdomain', prefix : '#include <libintl.h>')
	intl_dep = c_compiler.find_library('intl', required: true)
endif

libgxml_deps = [
	dependency('libxml-2.0', version: '>=2.9.14'),
	dependency('gio-2.0', version: '>=2.80'),
	intl_dep,
	gee
	]

VALADEPS = 'gee-0.8\ngio-2.0\nlibxml-2.0'
PCDEPS = 'gee-0.8 gio-2.0 libxml-2.0'

inc_rooth = include_directories ('.')
inc_rooth_dep = declare_dependency (include_directories : inc_rooth)

docs_requested = not get_option('docs').disabled()
docs_enabled = false
introspection_requested = not get_option('introspection').disabled()
introspection_enabled = false

subdir('po')
subdir('vapi')
subdir('gxml')
if docs_requested
  subdir('docs')
endif
subdir('test')
subdir('examples')

summary({
  'API docs requested': docs_requested,
  'API docs available': docs_enabled,
  'Introspection requested': introspection_requested,
  'Introspection available': introspection_enabled,
  'Experimental classes': get_option('experimental'),
}, section: 'gxml build')
