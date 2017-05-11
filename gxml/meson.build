vapidir = join_paths (get_option('datadir'),'vala','vapi')

conf = configuration_data()
conf.set('prefix', get_option('prefix'))
conf.set('exec_prefix', get_option('prefix'))
conf.set('libdir', join_paths (get_option ('prefix'),get_option ('libdir')))
conf.set('includedir', get_option ('includedir'))
conf.set('VALADEPS', VALADEPS)
conf.set('PCDEPS', PCDEPS)
conf.set('GXML_VERSION', GXML_VERSION)
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

conf = configuration_data()
conf.set_quoted('PACKAGE_LOCALE_DIR', join_paths(get_option('prefix'), get_option('datadir'), 'locale'))
conf.set_quoted('GETTEXT_PACKAGE', 'gxml')
configure_file(output : 'config.h',
	configuration : conf)

nsinfo = configure_file(input : 'namespace-info.vala.in',
	output : 'namespace-info.vala',
	configuration : conf)
namespaceinfo_dep = declare_dependency (sources : nsinfo)

valasources = files ([
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

inc_gxmlh = include_directories ('.')

gxml = library('gxml-@0@'.format(API_VERSION),
	valasources+sources+configvapi,
	version : GXML_VERSION,
	vala_header : 'gxml.h',
	vala_vapi : 'gxml-@0@.vapi'.format(API_VERSION),
	vala_gir : 'GXml-@0@.gir'.format(API_VERSION),
	dependencies : [ gee, gio, xml, namespaceinfo_dep ],
	c_args : [
		'-include',
		meson.current_build_dir() + '/config.h',
		xlibxml_cflags
	],
	install : true,
	install_dir : [
		get_option('libdir'),
		join_paths (get_option('includedir'),'gxml-@0@'.format (API_VERSION)),
		vapidir,
		true
	])

g_ir_compiler = find_program('g-ir-compiler')
custom_target('gxml-typelib',
	command: [
		g_ir_compiler,
		'--shared-library', 'libgxml-@0@.so.@1@'.format (API_VERSION, GXML_VERSION),
		'--output', '@OUTPUT@',
		join_paths(meson.current_build_dir(), 'GXml-@0@.gir'.format(API_VERSION))
	],
	output: 'GXml-@0@.typelib'.format(API_VERSION),
	depends: gxml,
	install: true,
	install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))
