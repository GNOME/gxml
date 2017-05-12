project('gxml', [ 'vala', 'c'])

PROJECT_NAME = 'gxml'
API_VERSION = '0.14'
PROJECT_VERSION = '0.15.0'
VERSIONED_PROJECT_NAME = PROJECT_NAME+'-'+API_VERSION
CAMEL_CASE_NAME = 'GXml'
VERSIONED_CAMEL_CASE_NAME = CAMEL_CASE_NAME +'-'+ API_VERSION

xml = dependency('libxml-2.0')
gio = dependency('gio-2.0')
gee = dependency('gee-0.8')

VALADEPS = 'gee-0.8\ngio-2.0\nlibxml-2.0'
PCDEPS = 'gee-0.8 gio-2.0 libxml-2.0'

subdir('po')
subdir('vapi')
subdir('gxml')
subdir('docs')
subdir('test')
