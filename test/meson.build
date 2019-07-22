testdirs_dep = declare_dependency (compile_args : [
	'-DTEST_DIR="'+meson.current_source_dir()+'"',
	'-DTEST_SAVE_DIR="'+meson.current_build_dir()+'"',
])

files_tests = files ([
		'GXmlTest.vala',
		'CssSelectorTest.vala',
		'ValaLibxml2Test.vala',
		'XHtmlDocumentTest.vala',
		'DomXDocumentTest.vala',
		'DocumentTest.vala',
		'ElementTest.vala',
		'SerializationTest.vala',
		'XsdSchemaTest.vala',
		'XElementTest.vala',
		'XPathTest.vala',
	])

tests_cargs = []

t = executable('tests', files_tests + configvapi + configtestvapi,
	vala_args : [],
	c_args: tests_cargs,
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

test ('tests', t)

stream_tests = files ([
		'StreamReaderTest.vala',
	])

tstream = executable('stream-reader', stream_tests + configvapi + configtestvapi,
	vala_args : [],
	c_args: tests_cargs,
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

test ('stream-reader', tstream)

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
		'DocumentPerformanceTest.vala'
	])

gom_performance = executable('performance-load', files_gom_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('performance-load', gom_performance)


files_gom_performance_iterate = files ([
		'DocumentPerformanceIterateTest.vala'
	])

gom_performance_iterate = executable('performance-iterate', files_gom_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('performance-iterate', gom_performance_iterate)


files_libxml_performance = files ([
		'XDocumentPerformanceTest.vala'
	])
libxml_performance = executable('libxml-performance-load', files_libxml_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('libxml-performance-load', libxml_performance)

files_libxml_performance_iterate = files ([
		'XDocumentPerformanceIterateTest.vala'
	])

libxml_performance_iterate = executable('libxml-performance-iterate', files_gom_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('libxml-performance-iterate', libxml_performance_iterate)
		
