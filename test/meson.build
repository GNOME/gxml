testdirs_dep = declare_dependency (compile_args : [
	'-DTEST_DIR="'+meson.current_source_dir()+'"',
	'-DTEST_SAVE_DIR="'+meson.current_build_dir()+'"',
])

files_tests = files ([
		'GXmlTest.vala',
		'CssSelectorTest.vala',
		'NodeListTest.vala',
		'ValaLibxml2Test.vala',
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

tests_cargs = []
if get_option('enable-tnode-tests')
files_tests += files ([

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
	])
tests_cargs += [
	'-DENABLE_TNODE_TESTS',
	'-DENABLE_PERFORMANCE_TESTS'
	]
endif

t = executable('tests', files_tests + configvapi + configtestvapi,
	vala_args : [],
	c_args: tests_cargs,
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

test ('tests', t)

feedreader_files = ([
	'feedreader-test.vala'
])


feedreadert = executable('feedreader_tests', feedreader_files + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

# test ('feedreader_tests', feedreadert)


files_gom_performance = files ([
		'GomDocumentPerformanceTest.vala'
	])

gom_performance = executable('gom-performance-load', files_gom_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('gom-performance-load', gom_performance)


files_gom_performance_iterate = files ([
		'GomDocumentPerformanceIterateTest.vala'
	])

gom_performance_iterate = executable('gom-performance-iterate', files_gom_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('gom-performance-iterate', gom_performance_iterate)


files_libxml_performance = files ([
		'GXmlDocumentPerformanceTest.vala'
	])
libxml_performance = executable('libxml-performance-load', files_libxml_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('libxml-performance', libxml_performance)

files_libxml_performance_iterate = files ([
		'GXmlDocumentPerformanceIterateTest.vala'
	])

libxml_performance_iterate = executable('libxml-performance-iterate', files_gom_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('libxml-performance-iterate', libxml_performance_iterate)
		
