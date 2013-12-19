/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

// namespace GXml {
// 	public class TestElement : Element {
// 		public TestElement (Xml.Node *node, Document doc) {
// 			/* /home2/richard/gxml/test/ElementTest.vala:7.4-7.19: error: chain up
// 			   to `GXml.Element' not supported */
// 			base (node, doc);
// 		}
// 	}
// }

class ElementTest : GXmlTest  {
	public static void add_tests () {
		Test.add_func ("/gxml/element/namespace_support_manual", () => {
				// TODO: wanted to use TestElement but CAN'T because Vala won't let me access the internal constructor of Element?
				Xml.Doc *xmldoc;
				Xml.Node *xmlroot;
				Xml.Node *xmlnode;
				Xml.Ns *ns_magic;
				Xml.Ns *ns_course;
				xmldoc = new Xml.Doc ();

				xmlroot = xmldoc->new_node (null, "Potions");
				ns_course = xmlroot->new_ns ("http://hogwarts.co.uk/courses", "course");
				xmldoc->set_root_element (xmlroot);

				xmlnode = xmldoc->new_node (null, "Potion");
				ns_magic = xmlnode->new_ns ("http://hogwarts.co.uk/magic", "magic");
				xmlnode->new_ns_prop (ns_course, "commonName", "Florax");
				xmlroot->add_child (xmlnode);

				Document doc = new Document.from_libxml2 (xmldoc);
				GXml.Node root = doc.document_element;
				GXml.Node node = root.child_nodes.item (0);

				assert (node.namespace_uri == null);
				assert (node.prefix == null);
				xmlnode->set_ns (ns_magic);
				assert (node.namespace_uri == "http://hogwarts.co.uk/magic");
				assert (node.prefix == "magic");
				assert (node.local_name == "Potion");
				assert (node.node_name == "Potion");
			});
		Test.add_func ("/gxml/element/namespace_uri", () => {
				// TODO: wanted to use TestElement but CAN'T because Vala won't let me access the internal constructor of Element?
				Document doc = new Document.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.Node root = doc.document_element;
				GXml.Node node = root.child_nodes.item (0);

				assert (node.namespace_uri == "http://hogwarts.co.uk/magic");
			});
		Test.add_func ("/gxml/element/testing", () => {
				// TODO: wanted to use TestElement but CAN'T because Vala won't let me access the internal constructor of Element?
				Document doc = new Document.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"><products:Ingredient /></magic:Potion></Potions>");
				GXml.Node root = doc.document_element;
				GXml.Node node = root.child_nodes.item (0);

				// root.dbg_inspect ();
				// node.dbg_inspect ();
				// node.child_nodes.item (0).dbg_inspect ();

				assert (node.namespace_uri == "http://hogwarts.co.uk/magic");

				// TODO: remove below
				// message ("going to show attributes on node %s", node.node_name);
				// foreach (Attr attr in node.attributes.get_values ()) {
				// 	message ("attrkey: %s, value: %s", attr.node_name, attr.node_value);
				// }
			});
		Test.add_func ("/gxml/element/prefix", () => {
				Document doc = new Document.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.Node root = doc.document_element;
				GXml.Node node = root.child_nodes.item (0);

				assert (node.prefix == "magic");
			});
		Test.add_func ("/gxml/element/local_name", () => {
				Document doc = new Document.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.Node root = doc.document_element;
				GXml.Node node = root.child_nodes.item (0);

				assert (node.local_name == "Potion");
			});
		Test.add_func ("/gxml/element/namespace_definitions", () => {
				Document doc = new Document.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.Node root = doc.document_element;
				GXml.Node node = root.child_nodes.item (0);

				NodeList namespaces = node.namespace_definitions;

				assert (namespaces.length == 2);

				assert (namespaces.item (0).prefix == "xmlns");
				assert (namespaces.item (0).node_name == "magic");
				assert (namespaces.item (0).node_value == "http://hogwarts.co.uk/magic");
				assert (namespaces.item (1).prefix == "xmlns");
				assert (namespaces.item (1).node_name == "products");
				assert (namespaces.item (1).node_value == "http://diagonalley.co.uk/products");
				assert (node.local_name == "Potion");
			});
		Test.add_func ("/gxml/element/attributes", () => {
				NamedAttrMap attributes;

				Document doc;
				Element elem;

				doc = get_doc ();

				elem = doc.create_element ("alphanumeric");

				attributes = elem.attributes;
				assert (attributes != null);
				assert (attributes.length == 0);

				elem.set_attribute ("alley", "Diagon");
				elem.set_attribute ("train", "Hogwarts Express");

				assert (attributes == elem.attributes);
				assert (attributes.length == 2);
				assert (attributes.get_named_item ("alley").value == "Diagon");
				assert (attributes.get_named_item ("train").value == "Hogwarts Express");

				Attr attr;
				attr = doc.create_attribute ("owl");
				attr.value = "Hedwig";

				attributes.set_named_item (attr);

				assert (attributes.length == 3);
				assert (elem.get_attribute ("owl") == "Hedwig");

				attributes.remove_named_item ("alley");
				assert (elem.get_attribute ("alley") == "");
			});
		/* by accessing .attributes, the element is marked as
		 * dirty, because it can't be sure whether we're
		 * changing attributes independently in the obtained
		 * HashTable, and the document will have to re-sync
		 * before stringifying (or saving)*/
		Test.add_func ("/gxml/element/syncing_of_dirty_elements", () => {
				NamedAttrMap attrs;
				string str;

				Document doc = new Document.from_string ("<?xml version='1.0' encoding='UTF-8'?><entry><link rel='http://schemas.google.com/contacts/2008/rel#photo'/></entry>");
				GXml.Node root = doc.document_element;
				foreach (GXml.Node child in root.child_nodes) {
					attrs = child.attributes;
				}

				str = doc.to_string ();
			});
		Test.add_func ("/gxml/element/get_set_attribute", () => {
				Document doc;
				Element elem = get_elem_new_doc ("student", out doc);

				assert ("" == elem.get_attribute ("name"));

				elem.set_attribute ("name", "Malfoy");
				assert ("Malfoy" == elem.get_attribute ("name"));
				elem.set_attribute ("name", "Lovegood");
				assert ("Lovegood" == elem.get_attribute ("name"));
			});
		Test.add_func ("/gxml/element/remove_attribute", () => {
				Document doc;
				Element elem = get_elem_new_doc ("tagname", out doc);

				elem.set_attribute ("name", "Malfoy");
				assert ("Malfoy" == elem.get_attribute ("name"));
				assert ("Malfoy" == elem.get_attribute_node ("name").value);
				elem.remove_attribute ("name");
				assert ("" == elem.get_attribute ("name"));
				assert (null == elem.get_attribute_node ("name"));

				// Consider testing default attributes (see Attr and specified)
			});
		Test.add_func ("/gxml/element/get_attribute_node", () => {
				Document doc;
				Element elem = get_elem_new_doc ("tagname", out doc);

				assert (elem.get_attribute_node ("name") == null);
				elem.set_attribute ("name", "Severus");
				assert (elem.get_attribute_node ("name").value == "Severus");
			});
		Test.add_func ("/gxml/element/set_attribute_node", () => {
				Document doc;
				Element elem = get_elem_new_doc ("tagname", out doc);
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
			});


		Test.add_func ("/gxml/element/remove_attribute_node", () => {
				Document doc;
				Element elem = get_elem_new_doc ("tagname", out doc);
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
				GXml.Node root;
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

				email = (Element)emails.@get (0);
				assert (email.tag_name == "Email");
				assert (email.child_nodes.length == 1);

				text = (Text)email.child_nodes.@get (0);
				assert (text.node_name == "#text");
				assert (text.node_value == "fweasley@hogwarts.co.uk");

				email = (Element)emails.@get (1);
				assert (email.tag_name == "Email");
				assert (email.child_nodes.length == 1);

				text = (Text)email.child_nodes.@get (0);
				assert (text.node_name == "#text");
				assert (text.node_value == "gweasley@hogwarts.co.uk");

				// TODO: need to test that preorder traversal order is correct
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

				GXml.Node a = doc.document_element;
				GXml.Node bs = a.child_nodes.item (3);
				GXml.Node b3 = bs.child_nodes.item (7);
				GXml.Node t1, t2;

				NodeList ts = ((Element)bs).get_elements_by_tag_name ("t");
				assert (ts.length == 5);

				// Test adding direct child
				bs.append_child (t1 = doc.create_element ("t"));
				assert (ts.length == 6);

				// Test adding descendant
				b3.append_child (doc.create_element ("t"));
				assert (ts.length == 7);

				// Test situation where we add a node tree
				GXml.Node b4;
				GXml.Node d, d2;

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
			});
		Test.add_func ("/gxml/element/normalize", () => {
				Document doc;
				Element elem = get_elem_new_doc ("tagname", out doc);
				elem.normalize ();

				// STUB
			});
		Test.add_func ("/gxml/element/to_string", () => {
				Document doc, doc2;
				Element elem = get_elem_new_doc ("country", out doc);
				elem.append_child (elem.owner_document.create_text_node ("New Zealand"));
				if (elem.to_string () != "<country>New Zealand</country>") {
				  stdout.printf (@"ERROR: Element to_string() fail. Expected <country>New Zealand</country> got: $(elem.to_string ())\n");
				  assert_not_reached ();
				}
				// during stringification, we don't want to confuse XML <> with text <>
				Element elem2 = get_elem_new_doc ("messy", out doc2);
				elem2.append_child (elem.owner_document.create_text_node ("&lt;<>&gt;"));
				string expected = "<messy>&amp;lt;&lt;&gt;&amp;gt;</messy>";
				if (elem2.to_string () != expected) {
					Test.message ("Expected [%s] found [%s]",
						      expected, elem2.to_string ());
					assert_not_reached ();
				}

				// TODO: want to test with format on and off
			});
	}
}
