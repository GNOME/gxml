/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

// namespace GXml.Dom {
// 	public class TestElement : Element {
// 		public TestElement (Xml.Node *node, Document doc) {
// 			/* /home2/richard/gxml/test/ElementTest.vala:7.4-7.19: error: chain up
// 			   to `GXml.Dom.Element' not supported */
// 			base (node, doc);
// 		}
// 	}
// }

class ElementTest : GXmlTest  {
	public static void add_tests () {
		Test.add_func ("/gxml/element/namespace_support_manual", () => {
				try {
					// TODO: wanted to use TestElement but CAN'T because Vala won't let me access the internal constructor of Element? 
					Xml.Doc *xmldoc;
					Xml.Node *xmlroot;
					Xml.Node *xmlnode;
					xmldoc = new Xml.Doc ();

					xmlroot = xmldoc->new_node (null, "Potions");
					Xml.Ns *ns = xmlroot->new_ns ("http://hogwarts.co.uk/courses", "course");
					xmldoc->set_root_element (xmlroot);

					xmlnode = xmldoc->new_node (null, "Potion");
					xmlnode->new_ns ("http://hogwarts.co.uk/magic", "magic");
					xmlnode->new_ns_prop (ns, "commonName", "Florax");
					xmlroot->add_child (xmlnode);

					Document doc = new Document.for_libxml2 (xmldoc);
					XNode root = doc.document_element;
					XNode node = root.child_nodes.item (0);

					message ("%s", doc.to_string ());
					assert (node.namespace_uri == "http://hogwarts.co.uk/magic");
					assert (node.prefix == "magic");
					assert (node.local_name == "Potion");
					assert (node.node_name == "Potion");
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}				
			});
		Test.add_func ("/gxml/element/namespace_uri", () => {
				try {
					// TODO: wanted to use TestElement but CAN'T because Vala won't let me access the internal constructor of Element? 
					Document doc = new Document.from_string ("<Potions><Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
					XNode root = doc.document_element;
					XNode node = root.child_nodes.item (0);

					assert (node.namespace_uri == "http://hogwarts.co.uk/magic");
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}				
			});
		Test.add_func ("/gxml/element/prefix", () => {
				try {
					Document doc = new Document.from_string ("<Potions><Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
					XNode root = doc.document_element;
					XNode node = root.child_nodes.item (0);

					assert (node.prefix == "magic");
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}				
			});
		Test.add_func ("/gxml/element/local_name", () => {
				try {
					Document doc = new Document.from_string ("<Potions><Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
					XNode root = doc.document_element;
					XNode node = root.child_nodes.item (0);

					assert (node.local_name == "Potion");
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}				
			});
		Test.add_func ("/gxml/element/attributes", () => {
				try {
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

				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/element/get_set_attribute", () => {
				try {
					Element elem = get_elem_new_doc ("student");

					assert ("" == elem.get_attribute ("name"));

					elem.set_attribute ("name", "Malfoy");
					assert ("Malfoy" == elem.get_attribute ("name"));
					elem.set_attribute ("name", "Lovegood");
					assert ("Lovegood" == elem.get_attribute ("name"));
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/element/remove_attribute", () => {
				try {
					Element elem = get_elem_new_doc ("tagname");

					elem.set_attribute ("name", "Malfoy");
					assert ("Malfoy" == elem.get_attribute ("name"));
					assert ("Malfoy" == elem.get_attribute_node ("name").value);
					elem.remove_attribute ("name");
					assert ("" == elem.get_attribute ("name"));
					assert (null == elem.get_attribute_node ("name"));

					// Consider testing default attributes (see Attr and specified)
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/element/get_attribute_node", () => {
				try {
					Element elem = get_elem_new_doc ("tagname");

					assert (elem.get_attribute_node ("name") == null);
					elem.set_attribute ("name", "Severus");
					assert (elem.get_attribute_node ("name").value == "Severus");
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/element/set_attribute_node", () => {
				try {
					Element elem = get_elem_new_doc ("tagname");
					Attr attr1 = elem.owner_document.create_attribute ("name");
					Attr attr2 = elem.owner_document.create_attribute ("name");

					attr1.value = "Snape";
					attr2.value = "Moody";

					/* We test to make sure that the current value in the node after being set is correct,
					   and that the old node gets correctly returned when replaced. */
					assert (elem.get_attribute_node ("name") == null);
					assert (elem.set_attribute_node (attr1) == null);
					assert (elem.get_attribute_node ("name").value == "Snape");
					assert (elem.set_attribute_node (attr2).value == "Snape");
					assert (elem.get_attribute_node ("name").value == "Moody");
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});


		Test.add_func ("/gxml/element/remove_attribute_node", () => {
				try {
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
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});


		Test.add_func ("/gxml/element/get_elements_by_tag_name", () => {
				try {
					Document doc;
					XNode root;
					Element elem;
					NodeList emails;
					Element email;
					Text text;

					doc = get_doc ();

					root = doc.document_element; // child_nodes.nth_data (0);
					assert (root.node_name == "Sentences");

					elem = (Element)root;
					emails = elem.get_elements_by_tag_name ("Email");
					assert (emails.length == 2);

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
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/element/get_elements_by_tag_name.live", () => {
				/* Need to test the following cases:

				   you have an element, it has 3 title descendants.
				   get the node list, has 3 nodes
				   add a title to the element, node list has 4 nodes
				   add a title to a grand child, node list has 5 nodes
				   add another element tree with 2 titles at various depths, list has 7
				   add a document fragment with 2 titles at various depths, list has 9

				   remove a single child element, list has 8
				   remove a deeper descendent, list has 7
				   remove a tree with 2, list has 5
				   readd the tree, list has 7
				*/
				try {
					Document doc;
					string xml;

					xml =
"<A>
  <t />
  <Bs>
    <t />
    <B>
      <t />
      <D><t /></D>
      <D><t /></D>
    </B>
    <B><t /></B>
    <B></B>
  </Bs>
  <Cs><C><t /></C></Cs>
</A>";
					doc = new Document.from_string (xml);

					XNode a = doc.document_element;
					XNode bs = a.child_nodes.item (3);
					XNode b3 = bs.child_nodes.item (7);
					XNode t1, t2;

					NodeList ts = ((Element)bs).get_elements_by_tag_name ("t");
					assert (ts.length == 5);

					// Test adding direct child
					bs.append_child (t1 = doc.create_element ("t"));
					assert (ts.length == 6);

					// Test adding descendant
					b3.append_child (doc.create_element ("t"));
					assert (ts.length == 7);

					// Test situation where we add a node tree
					XNode b4;
					XNode d, d2;

					b4 = doc.create_element ("B");
					b4.append_child (doc.create_element ("t"));
					d = doc.create_element ("D");
					d.append_child (t2 = doc.create_element ("t"));
					b4.append_child (d);

					bs.append_child (b4);

					assert (ts.length == 9);

					// Test situation where we use insert_before
					d2 = doc.create_element ("D");
					d2.append_child (doc.create_element ("t"));
					b4.insert_before (d2, d);

					assert (ts.length == 10);

					// Test situation where we add a document fragment
					DocumentFragment frag;

					frag = doc.create_document_fragment ();
					frag.append_child (doc.create_element ("t"));
					d = doc.create_element ("D");
					d.append_child (doc.create_element ("t"));
					frag.append_child (d);
					d2 = doc.create_element ("D");
					d2.append_child (doc.create_element ("t"));
					frag.insert_before (d2, d);

					b4.append_child (frag);
					assert (ts.length == 13);

					// Test removing single child
					t1.parent_node.remove_child (t1);
					assert (ts.length == 12);

					// Test removing deeper descendant
					t2.parent_node.remove_child (t2);
					assert (ts.length == 11);

					// Test removing subtree
					b4 = b4.parent_node.remove_child (b4);

					assert (ts.length == 6);

					// Test restoring subtree
					bs.append_child (b4);
					assert (ts.length == 11);
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/element/normalize", () => {
				try {
					Element elem = get_elem_new_doc ("tagname");
					elem.normalize ();

					// STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/element/to_string", () => {
				try {
					Element elem = get_elem_new_doc ("country");
					elem.append_child (elem.owner_document.create_text_node ("New Zealand"));
					assert (elem.to_string () == "<country>New Zealand</country>");
					// TODO: want to test with format on and off
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
	}
}