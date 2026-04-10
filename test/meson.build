testdirs_dep = declare_dependency (compile_args : [
	'-DTEST_DIR="'+meson.current_source_dir()+'"',
	'-DTEST_SAVE_DIR="'+meson.current_build_dir()+'"',
])

tests_cargs = []
tests_common_sources = configvapi + configtestvapi
tests_common_deps = [ libgxml_deps, inc_libh_dep, testdirs_dep, inc_rooth_dep ]

unit_test_specs = [
	['document', 'DocumentTest.vala'],
	['element', 'ElementTest.vala'],
	['serialization', 'SerializationTest.vala'],
	['css', 'CssSelectorTest.vala'],
]

unit_test_libxml_specs = [
	['xdocument', 'XDocumentTest.vala'],
	['htmlxdocument', 'XHtmlDocumentTest.vala'],
	['xelement', 'XElementTest.vala'],
	['xxpath', 'XPathTest.vala'],
	['xsd', 'XsdSchemaTest.vala'],
	['html', 'HtmlDocumentTest.vala'],
]

foreach spec : unit_test_specs
	exe = executable(spec[0], files(spec[1]) + tests_common_sources,
		vala_args : [],
		c_args: tests_cargs,
		dependencies : tests_common_deps,
		link_with: libgxml
	)

	test(spec[0], exe, suite: ['unit'])
endforeach

if get_option('experimental')
	foreach spec : [
		['stream-reader', 'StreamReaderTest.vala'],
	]
		exe = executable(spec[0], files(spec[1]) + tests_common_sources,
			vala_args : [],
			c_args: tests_cargs,
			dependencies : tests_common_deps,
			link_with: libgxml
		)

		test(spec[0], exe, suite: ['unit', 'experimental'])
	endforeach
endif

feedreadert = executable('feedreader_tests', files('feedreader-test.vala') + tests_common_sources,
	vala_args : [],
	c_args: tests_cargs,
	dependencies : tests_common_deps,
	link_with: libgxml
)

# test ('feedreader_tests', feedreadert)

benchmark_specs = [
	['performance-load', 'DocumentPerformanceTest.vala'],
	['performance-iterate', 'DocumentPerformanceIterateTest.vala'],
]

benchmark_libxml_specs = [
	['performance-load', 'DocumentPerformanceTest.vala'],
	['performance-iterate', 'DocumentPerformanceIterateTest.vala'],
]

foreach spec : benchmark_specs
	exe = executable(spec[0], files(spec[1]) + tests_common_sources,
		vala_args : [],
		c_args: tests_cargs,
		dependencies : tests_common_deps,
		link_with: libgxml
	)

	benchmark(spec[0], exe, suite: ['performance'])
endforeach

if get_option('experimental')
	foreach spec : [
		['stream-reader-performance-load', 'StreamReaderPerformanceTest.vala'],
		['stream-reader-performance-iterate', 'StreamReaderPerformanceIterateTest.vala'],
		['stream-reader-performance-unparsed', 'StreamReaderPerformanceIterateReadUnparsedTest.vala'],
		['stream-reader-performance-async', 'StreamReaderPerformanceAsyncReadUnparsedTest.vala'],
	]
		exe = executable(spec[0], files(spec[1]) + tests_common_sources,
			vala_args : [],
			c_args: tests_cargs,
			dependencies : tests_common_deps,
			link_with: libgxml
		)

		benchmark(spec[0], exe, suite: ['performance', 'experimental'])
	endforeach
endif
