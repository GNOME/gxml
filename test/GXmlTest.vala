/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXmlDom;

class GXmlTest {
	public static int main (string[] args) {
		Test.init (ref args); // TODO: why ref?  what if I just pass args?
		DocumentTest.add_tests ();
		XNodeTest.add_tests ();
		ElementTest.add_tests ();
		AttrTest.add_tests ();
		NodeListTest.add_tests ();
		TextTest.add_tests ();
		CharacterDataTest.add_tests ();
		ValaLibxml2Test.add_tests ();
		Test.run ();

		return 1;
	}

	internal static Document get_doc () throws DomError {
		Document doc = null;
		try {
			doc = new Document.from_path ("test.xml");
		} catch (DomError e) {
		}
		return doc;
	}

	// internal static Attr get_attr_new_doc (string name, string value) throws DomError {
	// 	return get_attr (name, value, get_doc ());
	// }

	internal static Attr get_attr (string name, string value, Document doc) throws DomError {
		Attr attr = doc.create_attribute (name);
		attr.value = value;
		return attr;
	}

	internal static Element get_elem_new_doc (string name) throws DomError {
		return get_elem (name, get_doc ());
	}

	internal static Element get_elem (string name, Document doc) throws DomError {
		Element elem = doc.create_element (name);
		return elem;
	}

	internal static Text get_text_new_doc (string data) throws DomError {
		return get_text (data, get_doc ());
	}

	internal static Text get_text (string data, Document doc) {
		Text txt = doc.create_text_node (data);
		return txt;
	}
}