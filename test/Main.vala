class Main {
	public static int main (string[] args) {
		Test.init (ref args); // TODO: why ref?  what if I just pass args?
		DocumentTest.add_document_tests ();
		DomNodeTest.add_dom_node_tests ();
		ElementTest.add_element_tests ();
		Test.run ();
		
		// TODO: want to change Node to something less generic, conflicts with GLib
		// TODO: stop having Attribute and DomNode implement the same iface

		// try {
		// 	Document doc = new Document.for_path ("test.xml");
		// 	print_node (doc);

		// 	test_document_construct_for_path ();
		// 	test_document_construct_stream ();
		// 	test_document_construct_from_string ();
		// 	test_document_create_element ();
		// 	test_document_create_document_fragment ();
		// 	test_document_create_text_node ();
		// 	test_document_create_comment ();
		// 	test_document_create_cdata_section ();
		// 	test_document_create_processing_instruction ();
		// 	test_document_create_attribute ();
		// 	test_document_create_entity_reference ();
		// } catch (DomError e) {
		// 	// TODO: handle
		// }

		return 1;
	}
}