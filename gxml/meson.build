vapidir = join_paths (get_option('datadir'),'vala','vapi')
GIR_NAME= VERSIONED_CAMEL_CASE_NAME+'.gir'
TYPELIB_NAME= VERSIONED_CAMEL_CASE_NAME+'.typelib'
VAPI_NAME = VERSIONED_PROJECT_NAME+'.vapi'

conf = configuration_data()
conf.set('prefix', get_option('prefix'))
conf.set('libdir', '${exec_prefix}/'+get_option ('libdir'))
conf.set('PCDEPS', PCDEPS)
conf.set('PROJECT_NAME', PROJECT_NAME)
conf.set('PROJECT_VERSION', PROJECT_VERSION)
conf.set('API_VERSION', API_VERSION)

nsinfo = configure_file(input : 'namespace-info.vala.in',
	output : 'namespace-info.vala',
	configuration : conf)
namespaceinfo_dep = declare_dependency (sources : nsinfo)

confh = configuration_data ()
confh.set_quoted('PACKAGE_LOCALE_DIR', join_paths(get_option('prefix'), get_option('datadir'), 'locale'))
confh.set_quoted('GETTEXT_PACKAGE', 'GXml')
configure_file(output : 'config.h',
	configuration : confh)


valasources = files ([
	'ArrayList.vala',
	'Attr.vala',
	'BaseCollection.vala',
	'Collections.vala',
	'CssSelectorParser.vala',
	'Document.vala',
	'DomAttr.vala',
	'DomCharacter.vala',
	'DomCollections.vala',
	'DomDocument.vala',
	'DomHtmlDocument.vala',
	'DomElement.vala',
	'DomEvents.vala',
	'DomMutationObservers.vala',
	'DomNode.vala',
	'DomRange.vala',
	'Element.vala',
	'Enumeration.vala',
	'Event.vala',
	'gxml-init.vala',
	'HashMap.vala',
	'HashPairedMap.vala',
	'HashThreeMap.vala',
	'HTMLCollection.vala',
	'HtmlDocument.vala',
	'IXsdSchema.vala',
	'LXPathObject.vala',
	'Node.vala',
	'NodeIterator.vala',
	'NodeType.vala',
	'Object.vala',
	'Parser.vala',
	'Property.vala',
	'Range.vala',
	'SettableTokenList.vala',
	'StringRef.vala',
	'Text.vala',
	'TokenList.vala',
	'TreeWalker.vala',
	'XAttribute.vala',
	'XCharacter.vala',
	'XChildNode.vala',
	'XComment.vala',
	'XDocument.vala',
	'XdParser.vala',
	'XElement.vala',
	'XHashMapAttr.vala',
	'XHtmlDocument.vala',
	'XListChildren.vala',
	'XNode.vala',
	'XParser.vala',
	'XPath.vala',
	'XProcessingInstruction.vala',
	'XsdSchema.vala',
	'XText.vala',
])

if get_option('experimental')
valasources += files([
	'StreamReader.vala'
	])
endif

sources = files ([
])

inc_libh = include_directories ('.')
inc_libh_dep = declare_dependency (include_directories : inc_libh)

cc_args = [
	'-include',
	meson.current_build_dir() + '/config.h',
]

cc = meson.get_compiler('c')
if cc.get_id() == 'clang'
	cc_args += '-Wno-error=incompatible-function-pointer-types'
endif

# LT_VERSION for ABI related changes
# From: https://autotools.io/libtool/version.html
# This rules applies to Meson 0.43 and newer
# Increase the current value whenever an interface has been added, removed or changed.
# Always increase revision value whenever an interface has been added, removed or changed.
# Increase the age value only if the changes made to the ABI are backward compatible.
# Set version to the value of subtract age from current
# Reset current and version to 1 and, age and version to 0 if library's name is changed
LT_CURRENT='3'
LT_REVISION='2'
LT_AGE='0'
LT_VERSION='2'
libgxml = library(VERSIONED_PROJECT_NAME,
	valasources+sources+configvapi,
	version : LT_VERSION,
	soversion : LT_VERSION+'.'+LT_AGE+'.'+LT_REVISION,
	darwin_versions : [LT_CURRENT.to_int() + 1, '@0@.@1@'.format(LT_CURRENT.to_int() + 1, LT_REVISION)],
	vala_header : PROJECT_NAME+'.h',
	vala_vapi : VAPI_NAME,
	vala_gir : GIR_NAME,
	dependencies : [ libgxml_deps, namespaceinfo_dep, inc_libh_dep, inc_rooth_dep ],
	vala_args: [
		'--abi-stability'
	],
	c_args : cc_args,
	install : true,
	install_dir : [
		true,
		join_paths (get_option('includedir'), 'gxml-@0@'.format (API_VERSION), 'gxml'),
		vapidir,
		get_option('introspection')
	])

if get_option('introspection')
g_ir_compiler = find_program('g-ir-compiler', required: false)
if g_ir_compiler.found()
custom_target('libgxml-typelib',
	command: [
		g_ir_compiler,
		'--shared-library', 'lib'+PROJECT_NAME+'-@0@.so'.format (API_VERSION),
		'--output', '@OUTPUT@', '--includedir', gee_girdir,
		join_paths(meson.current_build_dir(), GIR_NAME)
	],
	output: TYPELIB_NAME,
	depends: libgxml,
	install: true,
	install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))
endif
endif

pkgconfig.generate(libgxml,
  name: 'libgxml',
  filebase: 'gxml-@0@'.format (API_VERSION),
  description: 'GObject API for XML manipulation and serialization library',
  url: 'http://live.gnome.org/GXml',
  version: PROJECT_VERSION,
  subdirs: 'gxml-@0@'.format (API_VERSION),
  requires: [])

libgxml_build_dir = meson.current_build_dir ()
libgxml_src_dir = meson.current_source_dir ()
libgxml_dep = declare_dependency(include_directories : inc_rooth,
  link_with : libgxml,
  dependencies: libgxml_deps,
  )

