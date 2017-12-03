vapidir = join_paths (get_option('datadir'),'vala','vapi')
GIR_NAME= VERSIONED_CAMEL_CASE_NAME+'.gir'
TYPELIB_NAME= VERSIONED_CAMEL_CASE_NAME+'.typelib'
VAPI_NAME = VERSIONED_PROJECT_NAME+'.vapi'

conf = configuration_data()
conf.set('prefix', get_option('prefix'))
conf.set('libdir', '${exec_prefix}/'+get_option ('libdir'))
conf.set('VALADEPS', VALADEPS)
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
	'CssSelectorParser.vala',
	'Attribute.vala',
	'CDATA.vala',
	'Character.vala',
	'Comment.vala',
	'Document.vala',
	'DocumentType.vala',
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
	'Element.vala',
	'Enumeration.vala',
	'GHtml.vala',
	'GomAttr.vala',
	'GomCollections.vala',
	'GomDocument.vala',
	'GomElement.vala',
	'GomNode.vala',
	'GomObject.vala',
	'GomProperty.vala',
	'GomSchema.vala',
	'GomText.vala',
	'GXmlAttribute.vala',
	'GXmlCDATA.vala',
	'GXmlCharacter.vala',
	'GXmlChildNode.vala',
	'GXmlComment.vala',
	'GXmlDocument.vala',
	'GXmlDomCollections.vala',
	'GXmlDomEvents.vala',
	'GXmlDomRange.vala',
	'GXmlElement.vala',
	'GXmlHashMapAttr.vala',
	'gxml-init.vala',
	'GXmlListChildren.vala',
	'GXmlListNamespaces.vala',
	'GXmlNamespace.vala',
	'GXmlNode.vala',
	'GXmlProcessingInstruction.vala',
	'GXmlText.vala',
	'GXPathObject.vala',
	'Namespace.vala',
	'Node.vala',
	'NodeType.vala',
	'Notation.vala',
	'Parser.vala',
	'ProcessingInstruction.vala',
	'Schema.vala',
	'Serializable.vala',
	'SerializableBool.vala',
	'SerializableContainer.vala',
	'SerializableDouble.vala',
	'SerializableEnum.vala',
	'SerializableFloat.vala',
	'SerializableGeeArrayList.vala',
	'SerializableGeeDualKeyMap.vala',
	'SerializableGeeHashMap.vala',
	'SerializableGeeTreeMap.vala',
	'SerializableInt.vala',
	'SerializableMapDualKey.vala',
	'SerializableMapKey.vala',
	'SerializableObjectModel.vala',
	'SerializableProperty.vala',
	'SerializableValueList.vala',
	'TAttribute.vala',
	'TCDATA.vala',
	'TComment.vala',
	'TDocument.vala',
	'TElement.vala',
	'Text.vala',
	'TNamespace.vala',
	'TNode.vala',
	'TProcessingInstruction.vala',
	'TText.vala',
	'XParser.vala',
	'XPath.vala'
])

sources = files ([
	'xlibxml.c',
	'xlibxml.h'
])

inc_libh = include_directories ('.')
inc_libh_dep = declare_dependency (include_directories : inc_libh)

#   If public symbols have been removed or changed since last release,
#     increment current and set revision and age to 0
#   If library source has changed since last release, increment revision
#   If public symbols have been added since last release, increment age
LT_CURRENT='15'
LT_REVISION='0'
LT_AGE='0'
lib = library(VERSIONED_PROJECT_NAME,
	valasources+sources+configvapi,
	version : LT_CURRENT+'.'+LT_REVISION+'.'+LT_AGE,
	soversion : LT_CURRENT,
	vala_header : PROJECT_NAME+'.h',
	vala_vapi : VAPI_NAME,
	vala_gir : GIR_NAME,
	dependencies : [ gee, gio, xml, namespaceinfo_dep, inc_libh_dep, inc_rooth_dep ],
	c_args : [
		'-include',
		meson.current_build_dir() + '/config.h',
		xlibxml_cflags
	],
	install : true,
	install_dir : [
		true,
		join_paths (get_option('includedir'), 'gxml-@0@'.format (API_VERSION), 'gxml'),
		vapidir,
		true
	])

g_ir_compiler = find_program('g-ir-compiler')
custom_target('typelib',
	command: [
		g_ir_compiler,
		'--shared-library', 'lib'+PROJECT_NAME+'-@0@.so'.format (API_VERSION),
		'--output', '@OUTPUT@',
		join_paths(meson.current_build_dir(), GIR_NAME)
	],
	output: TYPELIB_NAME,
	depends: lib,
	install: true,
	install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))
