project('gxml', [ 'vala', 'c'])

xml = dependency('libxml-2.0')
gio = dependency('gio-2.0')
gee = dependency('gee-0.8')

VALADEPS = 'gee-0.8\ngio-2.0\nlibxml-2.0'
PCDEPS = 'gee-0.8 gio-2.0 libxml-2.0'

API_VERSION = '0.14'
GXML_VERSION = '0.15.0'

xlibxml_cflags = '-I' + meson.current_source_dir()

conf = configuration_data()
conf.set('API_VERSION', API_VERSION)

configure_file(input : 'gxml/namespace-info.vala.in',
	output : 'namespace-info.vala',
	configuration : conf)

subdir('po')
subdir('vapi')
subdir('gxml')
subdir('docs')
