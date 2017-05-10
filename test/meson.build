glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gio_dep = dependency('gio-2.0')
gee_dep = dependency('gee-0.8')
lxml_dep = dependency('libxml-2.0')
gxmlh_dep = declare_dependency (include_directories : inc_gxmlh)
testdirs_dep = declare_dependency (compile_args : [
	'-DTEST_DIR="'+join_paths (meson.source_root (),'test')+'"',
	'-DTEST_SAVE_DIR="'+join_paths (meson.build_root (),'test')+'"',
])
envtestdir = environment ()
envtestdir.set ('TEST_DIR',meson.source_root ())
envtestdir.set ('TEST_SAVE_DIR',meson.build_root ())

t = executable('gxml_test', [
	'GXmlTest.vala',
	'NodeListTest.vala',
	'ValaLibxml2Test.vala',
	'EnumerationTest.vala',
	'SerializableTest.vala',
	'SerializablePropertyBoolTest.vala',
	'SerializablePropertyDoubleTest.vala',
	'SerializablePropertyFloatTest.vala',
	'SerializablePropertyEnumTest.vala',
	'SerializablePropertyIntTest.vala',
	'SerializablePropertyValueListTest.vala',
	'SerializableObjectModelTest.vala',
	'SerializableObjectModel-TDocument-Test.vala',
	'SerializableGeeTreeMapTest.vala',
	'SerializableGeeDualKeyMapTest.vala',
	'SerializableGeeArrayListTest.vala',
	'SerializableGeeHashMapTest.vala',
	'SerializableGeeCollectionsTest.vala',
	'SerializableGeeCollections-TDocument-Test.vala',
	'SerializableBasicTypesTest.vala',
	'gxml-performance.vala',
	'TElementTest.vala',
	'TDocumentTest.vala',
	'TCDATATest.vala',
	'TCommentTest.vala',
	'TProcessingInstructionTest.vala',
	'GDocumentTest.vala',
	'GElementTest.vala',
	'GAttributeTest.vala',
	'HtmlDocumentTest.vala',
	'DomGDocumentTest.vala',
	'XPathTest.vala',
	'GomDocumentTest.vala',
	'GomElementTest.vala',
	'GomSerializationTest.vala',
	'GomSchemaTest.vala'
] + configvapi + configtestvapi,
vala_args : [],
dependencies : [glib_dep, gobject_dep, gio_dep, gee_dep, lxml_dep, gxmlh_dep, testdirs_dep],
link_with: gxml
)

test ('gxml', t)
