testdirs_dep = declare_dependency (compile_args : [
	'-DTEST_DIR="'+join_paths (meson.source_root (),'test')+'"',
	'-DTEST_SAVE_DIR="'+join_paths (meson.build_root (),'test')+'"',
])

files_tests = ([
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
		'GHtmlDocumentTest.vala',
		'DomGDocumentTest.vala',
		'XPathTest.vala',
		'GomDocumentTest.vala',
		'GomElementTest.vala',
		'GomSerializationTest.vala',
		'GomSchemaTest.vala'
	])

t = executable('tests', files_tests + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ gio, gee, xml, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: lib
)

test ('tests', t)

feedreader_files = ([
	'feedreader-test.vala'
])


feedreadert = executable('feedreader_tests', feedreader_files + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ gio, gee, xml, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: lib
)

# test ('feedreader_tests', feedreadert)
