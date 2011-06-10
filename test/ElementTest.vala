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

	private static Document get_doc () {
		Document doc = null;
		try {
			doc = new Document.for_path ("test.xml");
		} catch (DomError e) {
		}
		return doc;
	}

	private static Element get_elem (string name) {
		return get_doc ().create_element (name);
	}

	public static void add_element_tests () {
		Test.add_func ("/gdom/element/attributes", () => {
				HashTable<string,Attr> attributes;

				Document doc;
				DomNode elem;

				doc = get_doc ();

				elem = doc.create_element ("alphanumeric");

				attributes = elem.attributes;
				assert (attributes != null);
				assert (attributes.size () == 0);

				elem.set_attribute ("alley", "Diagon");
				elem.set_attribute ("train", "Hogwarts Express");

				assert (attributes == elem.attributes);
				assert (attributes.size () == 2);
				assert (attributes.lookup ("alley") == "Diagon");
				assert (attributes.lookup ("train") == "Hogwarts Express");

				attributes.insert ("owl", "Hedwig");

				assert (attributes.size () == 3);
				assert (elem.get_attribute ("owl", "Hedwig"));

				attributes.remove ("alley");
				elem.get_attribute ("alley" == "");

			});
		Test.add_func ("/gdom/element/get_set_attribute", () => {
				Element elem = get_elem ("student");

				assert ("" == elem.get_attribute ("name"));

				elem.set_attribute ("name", "Malfoy");
				assert ("Malfoy" == elem.get_attribute ("name"));
				elem.set_attribute ("name", "Lovegood");
				assert ("Lovegood" == elem.get_attribute ("name"));
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

				assert (elem.get_attribute_node ("name") == null);
				elem.set_attribute ("name", "Severus");
				assert (elem.get_attribute_node ("name").value == "Severus");
			});
		Test.add_func ("/gdom/element/set_attribute_node", () => {
				Element elem = get_elem ("tagname");
				Attr attr = elem.owner_document.create_attribute ("name");

				assert (elem.get_attribute_node ("name") == null);
				elem.set_attribute_node (attr);
				assert (elem.get_attribute_node ("name") != null);
			});


		Test.add_func ("/gdom/element/remove_attribute_node", () => {
				Element elem = get_elem ("tagname");
				Attr attr;
				// TODO: does this indicate that we don't want to add attributes using the NamedNodeMap?
				attr = elem.owner_document.create_attribute ("name");
				attr.value = "Luna";

				elem.set_attribute_node (attr);
				assert (elem.get_attribute_node ("name").value == "Luna");
				elem.remove_attribute_node (attr);
				assert (elem.get_attribute_node ("name") == null);
				assert (elem.get_attribute ("name") == "");
			});


		Test.add_func ("/gdom/element/get_elements_by_tag_name", () => {
				Document doc;
				DomNode root;
				Element elem;
				List<DomNode> emails;
				Element email;
				Text text;

				doc = get_doc ();

				root = doc.document_element; // child_nodes.nth_data (0);
				assert (root.node_name == "Sentences");

				elem = (Element)root;
				emails = elem.get_elements_by_tag_name ("Email");
				assert (emails.length () == 2);

				email = (Element)emails.nth_data (0);
				assert (email.tag_name == "Email");
				assert (email.child_nodes.length () == 1);

				text = (Text)email.child_nodes.nth_data (0);
				assert (text.node_name == "#text");
				assert (text.node_value == "fweasley@hogwarts.co.uk");

				email = (Element)emails.nth_data (1);
				assert (email.tag_name == "Email");
				assert (email.child_nodes.length () == 1);

				text = (Text)email.child_nodes.nth_data (0);
				assert (text.node_name == "#text");
				assert (text.node_value == "gweasley@hogwarts.co.uk");
			});
		Test.add_func ("/gdom/element/normalize", () => {
				Element elem = get_elem ("tagname");
				elem.normalize ();

				// STUB
			});
	}

}