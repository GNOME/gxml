class Main {
	public static int main (string[] args) {
		Test.init (ref args); // TODO: why ref?  what if I just pass args?
		DocumentTest.add_document_tests ();
		DomNodeTest.add_dom_node_tests ();
		ElementTest.add_element_tests ();
		AttrTest.add_attribute_tests ();
		Test.run ();

		// TODO: want to change Node to something less generic, conflicts with GLib
		// TODO: stop having Attribute and DomNode implement the same iface



		return 1;
	}
}