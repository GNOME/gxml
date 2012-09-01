/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class AttrTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/element/namespace_uri", () => {
				try {
					Document doc = new Document.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
					DomNode root = doc.document_element;
					Element node = (Element)root.child_nodes.item (0);

					Attr core = node.get_attribute_node ("core");
					Attr shell = node.get_attribute_node ("shell");
					Attr price = node.get_attribute_node ("price");

					assert (core.namespace_uri == "http://mom.co.uk/wands");
					assert (shell.namespace_uri == "http://mom.co.uk/wands");
					assert (price.namespace_uri == null);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/element/prefix", () => {
				try {
					Document doc = new Document.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
					DomNode root = doc.document_element;
					Element node = (Element)root.child_nodes.item (0);

					Attr core = node.get_attribute_node ("core");
					Attr shell = node.get_attribute_node ("shell");
					Attr price = node.get_attribute_node ("price");

					assert (core.prefix == "wands");
					assert (shell.prefix == "wands");
					assert (price.prefix == null);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/element/local_name", () => {
				try {
					Document doc = new Document.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
					DomNode root = doc.document_element;
					Element node = (Element)root.child_nodes.item (0);

					Attr core = node.get_attribute_node ("core");
					Attr shell = node.get_attribute_node ("shell");
					Attr price = node.get_attribute_node ("price");

					assert (core.local_name == "core");
					assert (shell.local_name == "shell");
					assert (price.local_name == "price");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});

		Test.add_func ("/gxml/attribute/node_name", () => {
				try {
					Document doc = get_doc ();
					Attr attr = get_attr ("broomSeries", "Nimbus", doc);

					assert (attr.node_name == "broomSeries");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/node_value", () => {
				try {
					Document doc = get_doc ();
					Attr attr = doc.create_attribute ("bank");

					assert (attr.node_value == "");
					attr.node_value = "Gringots";
					assert (attr.node_value == "Gringots");
					attr.node_value = "Wizardlies";
					assert (attr.node_value == "Wizardlies");
					/* make sure changing .value changes .node_value */
					attr.value = "Gringots";
					assert (attr.node_value == "Gringots");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/name", () => {
				try {
					Document doc = get_doc ();
					Attr attr = get_attr ("broomSeries", "Nimbus", doc);

					assert (attr.name == "broomSeries");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/node_value", () => {
				try {
					Document doc = get_doc ();
					Attr attr = doc.create_attribute ("bank");

					assert (attr.value == "");
					attr.value = "Gringots";
					assert (attr.value == "Gringots");
					attr.value = "Wizardlies";
					assert (attr.value == "Wizardlies");
					/* make sure changing .node_value changes .value */
					attr.node_value = "Gringots";
					assert (attr.value == "Gringots");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/specified", () => {
				// TODO: involves supporting DTDs, which come later
			});
		Test.add_func ("/gxml/attribute/parent_node", () => {
				try {
					Document doc = get_doc ();
					Element elem = get_elem ("creature", doc);
					Attr attr = get_attr ("breed", "Dragons", doc);

					assert (attr.parent_node == null);
					elem.set_attribute_node (attr);
					assert (attr.parent_node == null);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/previous_sibling", () => {
				try {
					Document doc = get_doc ();
					Element elem = get_elem ("creature", doc);
					Attr attr1 = get_attr ("breed", "Dragons", doc);
					Attr attr2 = get_attr ("size", "large", doc);

					elem.set_attribute_node (attr1);
					elem.set_attribute_node (attr2);

					assert (attr1.previous_sibling == null);
					assert (attr2.previous_sibling == null);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/next_sibling", () => {
				try {
					Document doc = get_doc ();
					Element elem = get_elem ("creature", doc);
					Attr attr1 = get_attr ("breed", "Dragons", doc);
					Attr attr2 = get_attr ("size", "large", doc);

					elem.set_attribute_node (attr1);
					elem.set_attribute_node (attr2);

					assert (attr1.next_sibling == null);
					assert (attr2.next_sibling == null);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/insert_before", () => {
				try {
					Document doc = get_doc ();
					Attr attr = get_attr ("pie", "Dumbleberry", doc);
					Text txt = doc.create_text_node ("Whipped ");

					assert (attr.value == "Dumbleberry");
					attr.insert_before (txt, attr.child_nodes.first ());
					assert (attr.value == "Whipped Dumbleberry");
					// the Text nodes should be merged
					assert (attr.child_nodes.length == 1);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/replace_child", () => {
				try {
					Document doc = get_doc ();
					Attr attr = get_attr ("WinningHouse", "Slytherin", doc);
					Text txt = doc.create_text_node ("Gryffindor");

					assert (attr.value == "Slytherin");
					attr.replace_child (txt, attr.child_nodes.item (0));
					assert (attr.value == "Gryffindor");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/attribute/remove_child", () => {
				try {
					Document doc = get_doc ();
					Attr attr = get_attr ("parchment", "MauraudersMap", doc);

					assert (attr.value == "MauraudersMap");
					// mischief managed
					attr.remove_child (attr.child_nodes.last ());
					assert (attr.value == "");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
	}
}
