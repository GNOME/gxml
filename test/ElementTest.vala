/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class ElementTest {
	// public static int main (string[] args) {
	// 	Test.init (ref args);
	// 	add_tests ();
	// 	Test.run ();

	// 	// TODO: want to change Node to something less generic, conflicts with GLib
	// 	// TODO: stop having Attribute and DomNode implement the same iface

	// 	try {
	// 		// test_element_get_attribute ();
	// 		// test_element_set_attribute ();
	// 		// test_element_remove_attribute ();
	// 		// test_element_get_attribute_node ();
	// 		// test_element_set_attribute_node ();
	// 		// test_element_remove_attribute_node ();
	// 		// test_element_get_elements_by_tag_name ();
	// 		// test_element_normalize ();
	// 	} catch (DomError e) {
	// 		// TODO: handle
	// 	}

	// 	return 1;
	// }

	private static Element get_elem (string name) {
		Document doc;
		Element elem = null;

		try {
			doc = new Document.for_path ("test.xml");
			elem = doc.create_element (name);
		} catch (DomError e) {
		}

		return elem;		
	}

	public static void add_element_tests () {
		Test.add_func ("/gdom/element/get_set_attribute", () => {
				Element elem = get_elem ("student");

				assert ("" == elem.get_attribute ("name"));
				elem.set_attribute ("name", "Malfoy");

				assert ("Malfoy" == elem.get_attribute ("name"));
			});
		Test.add_func ("/gdom/element/remove_attribute", () => {
				Element elem = get_elem ("tagname");

				elem.set_attribute ("name", "Malfoy");
				assert ("Malfoy" == elem.get_attribute ("name"));
				elem.remove_attribute ("name");
				assert ("" == elem.get_attribute ("name"));
			});
		Test.add_func ("/gdom/element/get_attribute_node", () => {
				Element elem = get_elem ("tagname");

				elem.get_attribute_node ("name");
			});


		Test.add_func ("/gdom/element/set_attribute_node", () => {
				Element elem = get_elem ("tagname");
				Attr attr = elem.owner_document.create_attribute ("name");
				// TODO: does this indicate that we don't want to add attributes using the NamedNodeMap?
		
				elem.set_attribute_node (attr);
			});


		Test.add_func ("/gdom/element/remove_attribute_node", () => {
				Element elem = get_elem ("tagname");
				// TODO: does this indicate that we don't want to add attributes using the NamedNodeMap?
				Attr attr = elem.owner_document.create_attribute ("name");
				elem.set_attribute_node (attr);
				elem.remove_attribute_node (attr);
			});
	

		Test.add_func ("/gdom/element/get_elements_by_tag_name", () => {
				Element elem = get_elem ("tagname");
				// TODO: does this indicate that we don't want to add attributes using the NamedNodeMap?
				elem.get_elements_by_tag_name ("name");
			});

		Test.add_func ("/gdom/element/normalize", () => {
				Element elem = get_elem ("tagname");
				// TODO: does this indicate that we don't want to add attributes using the NamedNodeMap?
				elem.normalize ();
			});
	}

}