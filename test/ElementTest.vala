/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class ElementTest : GXmlTest  {
	public static void add_element_tests () {
		Test.add_func ("/gxml/element/attributes", () => {
				HashTable<string,Attr> attributes;

				Document doc;
				Element elem;

				doc = get_doc ();

				elem = doc.create_element ("alphanumeric");

				attributes = elem.attributes;
				assert (attributes != null);
				assert (attributes.size () == 0);

				elem.set_attribute ("alley", "Diagon");
				elem.set_attribute ("train", "Hogwarts Express");

				assert (attributes == elem.attributes);
				assert (attributes.size () == 2);
				assert (attributes.lookup ("alley").value == "Diagon");
				assert (attributes.lookup ("train").value == "Hogwarts Express");

				Attr attr = doc.create_attribute ("owl");
				attr.value = "Hedwig";

				attributes.insert ("owl", attr);

				assert (attributes.size () == 3);
				assert (elem.get_attribute ("owl") == "Hedwig");

				attributes.remove ("alley");
				assert (elem.get_attribute ("alley") == "");

			});
		Test.add_func ("/gxml/element/get_set_attribute", () => {
				Element elem = get_elem_new_doc ("student");

				assert ("" == elem.get_attribute ("name"));

				elem.set_attribute ("name", "Malfoy");
				assert ("Malfoy" == elem.get_attribute ("name"));
				elem.set_attribute ("name", "Lovegood");
				assert ("Lovegood" == elem.get_attribute ("name"));
			});
		Test.add_func ("/gxml/element/remove_attribute", () => {
				Element elem = get_elem_new_doc ("tagname");

				elem.set_attribute ("name", "Malfoy");
				assert ("Malfoy" == elem.get_attribute ("name"));
				assert ("Malfoy" == elem.get_attribute_node ("name").value);
				elem.remove_attribute ("name");
				assert ("" == elem.get_attribute ("name"));
				assert (null == elem.get_attribute_node ("name"));

				// Consider testing default attributes (see Attr and specified)
			});
		Test.add_func ("/gxml/element/get_attribute_node", () => {
				Element elem = get_elem_new_doc ("tagname");

				assert (elem.get_attribute_node ("name") == null);
				elem.set_attribute ("name", "Severus");
				assert (elem.get_attribute_node ("name").value == "Severus");
			});
		Test.add_func ("/gxml/element/set_attribute_node", () => {
				Element elem = get_elem_new_doc ("tagname");
				Attr attr1 = elem.owner_document.create_attribute ("name");
				Attr attr2 = elem.owner_document.create_attribute ("name");
				Attr returned;

				attr1.value = "Snape";
				attr2.value = "Moody";

				/* We test to make sure that the current value in the node after being set is correct,
				   and that the old node gets correctly returned when replaced. */
				assert (elem.get_attribute_node ("name") == null);
				assert (elem.set_attribute_node (attr1) == null);
				assert (elem.get_attribute_node ("name").value == "Snape");
				assert (elem.set_attribute_node (attr2).value == "Snape");
				assert (elem.get_attribute_node ("name").value == "Moody");
			});


		Test.add_func ("/gxml/element/remove_attribute_node", () => {
				Element elem = get_elem_new_doc ("tagname");
				Attr attr;

				attr = elem.owner_document.create_attribute ("name");
				attr.value = "Luna";

				/* Test to make sure the current value ends up empty/reset after removal
				   and that removal returns the removed node. */
				elem.set_attribute_node (attr);
				assert (elem.get_attribute_node ("name").value == "Luna");
				assert (elem.remove_attribute_node (attr) == attr);
				assert (elem.get_attribute_node ("name") == null);
				assert (elem.get_attribute ("name") == "");
			});


		Test.add_func ("/gxml/element/get_elements_by_tag_name", () => {
				Document doc;
				XNode root;
				Element elem;
				List<XNode> emails;
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
				assert (email.child_nodes.length == 1);

				text = (Text)email.child_nodes.nth_data (0);
				assert (text.node_name == "#text");
				assert (text.node_value == "fweasley@hogwarts.co.uk");

				email = (Element)emails.nth_data (1);
				assert (email.tag_name == "Email");
				assert (email.child_nodes.length == 1);

				text = (Text)email.child_nodes.nth_data (0);
				assert (text.node_name == "#text");
				assert (text.node_value == "gweasley@hogwarts.co.uk");

				// TODO: need to test that preorder traversal order is correct
			});
		Test.add_func ("/gxml/element/normalize", () => {
				Element elem = get_elem_new_doc ("tagname");
				elem.normalize ();

				// STUB
			});
	}
}