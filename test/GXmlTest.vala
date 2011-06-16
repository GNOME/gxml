/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class GXmlTest {
	public static int main (string[] args) {
		Test.init (ref args); // TODO: why ref?  what if I just pass args?
		DocumentTest.add_document_tests ();
		DomNodeTest.add_dom_node_tests ();
		ElementTest.add_element_tests ();
		AttrTest.add_attribute_tests ();
		Test.run ();

		return 1;
	}

	internal static Document get_doc () {
		Document doc = null;
		try {
			doc = new Document.for_path ("test.xml");
		} catch (DomError e) {
		}
		return doc;
	}

	internal static Attr get_attr_new_doc (string name, string value) {
		return get_attr (name, value, get_doc ());
	}

	internal static Attr get_attr (string name, string value, Document doc) {
		Attr attr = doc.create_attribute (name);
		attr.value = value;
		return attr;
	}

	internal static Element get_elem_new_doc (string name) {
		return get_elem (name, get_doc ());
	}

	internal static Element get_elem (string name, Document doc) {
		Element elem = doc.create_element (name);
		return elem;
	}
}