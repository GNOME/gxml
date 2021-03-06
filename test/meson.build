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

html_tests = files ([
		'HtmlDocumentTest.vala',
	])

thtml = executable('html', html_tests + configvapi + configtestvapi,
	vala_args : [],
	c_args: tests_cargs,
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

test ('html', thtml)

if get_option('experimental')
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
endif

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

gom_performance_iterate = executable('performance-iterate', files_gom_performance_iterate + configvapi + configtestvapi,
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

libxml_performance_iterate = executable('libxml-performance-iterate', files_libxml_performance_iterate + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('libxml-performance-iterate', libxml_performance_iterate)

if get_option('experimental')
files_stream_reader_performance = files ([
		'StreamReaderPerformanceTest.vala'
	])

stream_reader_performance_iterate = executable('stream-reader-performance-load', files_stream_reader_performance + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('stream-reader-performance-load', stream_reader_performance_iterate)


files_stream_reader_performance_iterate = files ([
		'StreamReaderPerformanceIterateTest.vala'
	])

stream_reader_performance_iterate = executable('stream-reader-performance-iterate', files_stream_reader_performance_iterate + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('stream-reader-performance-iterate', stream_reader_performance_iterate)


files_stream_reader_performance_unparsed = files ([
		'StreamReaderPerformanceIterateReadUnparsedTest.vala'
	])

stream_reader_performance_unparsed = executable('stream-reader-performance-unparsed', files_stream_reader_performance_unparsed + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('stream-reader-performance-unparsed', stream_reader_performance_unparsed)


files_stream_reader_performance_async_read = files ([
		'StreamReaderPerformanceAsyncReadUnparsedTest.vala'
	])

stream_reader_performance_async_read = executable('stream-reader-performance-async', files_stream_reader_performance_async_read + configvapi + configtestvapi,
	vala_args : [],
	dependencies : [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep],
	link_with: libgxml
)

benchmark ('stream-reader-performance-async', stream_reader_performance_async_read)
endif
