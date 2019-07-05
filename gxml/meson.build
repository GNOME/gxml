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

configure_file(input : 'gxml.pc.in',
	output : 'gxml-@0@.pc'.format(API_VERSION),
	configuration : conf,
	install : true,
	install_dir : join_paths(get_option('libdir'), 'pkgconfig'))

configure_file(input : 'gxml.deps.in',
	output : 'gxml-@0@.deps'.format(API_VERSION),
	configuration : conf,
	install : true,
	install_dir : vapidir)

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
	'Collections.vala',
	'CssSelectorParser.vala',
	'DomAttr.vala',
	'DomCharacter.vala',
	'DomCollections.vala',
	'DomDocument.vala',
	'DomHtml.vala',
	'DomElement.vala',
	'DomEvents.vala',
	'DomMutationObservers.vala',
	'DomNode.vala',
	'DomRange.vala',
	'Enumeration.vala',
	'GDomEvents.vala',
	'GDomRange.vala',
	'GomArrayList.vala',
	'GomAttr.vala',
	'GomBaseCollection.vala',
	'GomDocument.vala',
	'GomElement.vala',
	'GomHashMap.vala',
	'GomHashPairedMap.vala',
	'GomHashThreeMap.vala',
	'GomNode.vala',
	'GomObject.vala',
	'GomProperty.vala',
	'GomSchema.vala',
	'GomStringRef.vala',
	'GomText.vala',
	'gxml-init.vala',
	'HTMLCollection.vala',
	'LXPathObject.vala',
	'NodeType.vala',
	'Parser.vala',
	'SettableTokenList.vala',
	'Schema.vala',
	'TokenList.vala',
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
	'XText.vala',
])

sources = files ([
])

inc_libh = include_directories ('.')
inc_libh_dep = declare_dependency (include_directories : inc_libh)

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
	c_args : [
		'-include',
		meson.current_build_dir() + '/config.h',
	],
	install : true,
	install_dir : [
		true,
		join_paths (get_option('includedir'), 'gxml-@0@'.format (API_VERSION), 'gxml'),
		vapidir,
		not get_option('disable-introspection')
	])

if not get_option('disable-introspection')
g_ir_compiler = find_program('g-ir-compiler', required: false)
if g_ir_compiler.found()
custom_target('typelib',
	command: [
		g_ir_compiler,
		'--shared-library', 'lib'+PROJECT_NAME+'-@0@.so'.format (API_VERSION),
		'--output', '@OUTPUT@',
		join_paths(meson.current_build_dir(), GIR_NAME)
	],
	output: TYPELIB_NAME,
	depends: libgxml,
	install: true,
	install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))
endif
endif

libgxml_build_dir = meson.current_build_dir ()
libgxml_src_dir = meson.current_source_dir ()
libgxml_dep = declare_dependency(include_directories : inc_rooth,
  link_with : libgxml,
  dependencies: libgxml_deps,
  )
