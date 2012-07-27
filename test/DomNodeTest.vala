/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

/* For testing, based on:
   https://live.gnome.org/Vala/TestSample

   Using an Element subclass of Node to test Node.
*/

class DomNodeTest : GXmlTest {
	// TODO: test setters?

	public static void add_tests () {
		Test.add_func ("/gxml/domnode/node_name_get", () => {
				try {
					// TODO: should DomNodes never have a null name?
					Document doc = get_doc ();
					DomNode node;

					node = get_elem ("elemname", doc);
					assert (node.node_name == "elemname");

					node = doc.create_attribute ("attrname");
					assert (node.node_name == "attrname");

					node = doc.create_text_node ("some text");
					assert (node.node_name == "#text");

					node = doc.create_cdata_section ("cdata");
					assert (node.node_name == "#cdata-section");

					node = doc.create_entity_reference ("refname");
					assert (node.node_name == "refname");

					// node = doc.create_entity ();
					// assert (node.node_name == ...); // entity name

					node = doc.create_processing_instruction ("target", "data");
					assert (node.node_name == "target");

					node = doc.create_comment ("some comment");
					assert (node.node_name == "#comment");

					assert (doc.node_name == "#document");

					// node = doc.create_document_type ("");
					// assert (node.node_name == ...); // document-type name

					// node = doc.create_document_fragment ("");
					// assert (node.node_name == "#document-fragment");

					// node = doc.create_notation ("some notation");
					// assert (node.node_name == ...); // notation name
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/node_type_get", () => {
				try {
					// TODO: implement commented-out types

					Document doc = get_doc ();
					DomNode node;

					node = get_elem ("a", doc);
					assert (node.node_type == NodeType.ELEMENT);

					node = doc.create_attribute ("name");
					assert (node.node_type == NodeType.ATTRIBUTE);

					node = doc.create_text_node ("some text");
					assert (node.node_type == NodeType.TEXT);

					node = doc.create_cdata_section ("cdata");
					assert (node.node_type == NodeType.CDATA_SECTION);

					node = doc.create_entity_reference ("refname");
					assert (node.node_type == NodeType.ENTITY_REFERENCE);

					// node = doc.create_entity ();
					// assert (node.node_type == NodeType.ENTITY);

					node = doc.create_processing_instruction ("target", "data");
					assert (node.node_type == NodeType.PROCESSING_INSTRUCTION);

					node = doc.create_comment ("some comment");
					assert (node.node_type == NodeType.COMMENT);

					assert (doc.node_type == NodeType.DOCUMENT);

					// node = doc.create_document_type ("");
					// assert (node.node_type == NodeType.DOCUMENT_TYPE);

					// node = doc.create_document_fragment ("");
					// assert (node.node_type == NodeType.DOCUMENT_FRAGMENT);

					// node = doc.create_notation ("some notation");
					// assert (node.node_type == NodeType.NOTATION);

				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/node_value_get", () => {
				try {

					/* See: http://www.w3.org/TR/DOM-Level-1/level-one-core.html */

					Document doc = get_doc ();

					DomNode node;

					node = doc.create_element ("elem");
					assert (node.node_value == null);

					node = doc.create_attribute ("name");
					((Attr)node).value = "Harry Potter";
					assert (node.node_value == "Harry Potter");

					node = doc.create_text_node ("text content");
					assert (node.node_value == "text content");

					node = doc.create_cdata_section ("cdata content");
					assert (node.node_value == "cdata content");

					node = doc.create_entity_reference ("refname");
					assert (node.node_value == null);

					// TODO: entity

					node = doc.create_processing_instruction ("target", "proc inst data");
					assert (node.node_value == "proc inst data");

					node = doc.create_comment ("some comment");
					assert (node.node_value == "some comment");

					assert (doc.node_value == null);

					/* TODO: Document Type, Document Fragment, Notation */
					// assert (attr.node_value == "harry");
					/* TODO: figure out a solution.
					   Attr's node_value doesn't get used when elem is thought of
					   as a DomNode.
					   DomNode wants to get it from DomNode's Xml.Node* node,
					   while Attr wants to get it from Attr's Xml.Attr* node. :( */
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/parent_node", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("James", doc);
					DomNode child = get_elem ("Harry", doc);

					assert (child.parent_node == null);
					parent.append_child (child);
					assert (child.parent_node == parent);

					DomNode attr = doc.create_attribute ("a");
					assert (attr.parent_node == null);
					assert (doc.parent_node == null);
					// assert (document fragment's parent_node == null); // TODO
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/child_nodes", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_1);
					parent.append_child (child_2);
					assert (parent.child_nodes.length == 3);
					assert (parent.child_nodes.nth_data (0) == child_0);
					assert (parent.child_nodes.nth_data (2) == child_2);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/first_child", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_1);
					parent.append_child (child_2);

					assert (parent.first_child == child_0);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/last_child", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_1);
					parent.append_child (child_2);

					assert (parent.last_child == child_2);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/previous_sibling", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_1);
					parent.append_child (child_2);

					assert (child_0.previous_sibling == null);
					assert (child_1.previous_sibling == child_0);
					assert (child_2.previous_sibling == child_1);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/next_sibling", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_1);
					parent.append_child (child_2);

					assert (child_0.next_sibling == child_1);
					assert (child_1.next_sibling == child_2);
					assert (child_2.next_sibling == null);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/attributes", () => {
				try {
					Document doc = get_doc ();
					DomNode elem = get_elem ("Hogwarts", doc);
					DomNode attr = get_attr ("Potter", "Lily", doc);

					assert (elem.attributes != null);
					assert (attr.attributes == null);

					// TODO: test more
					// TODO: test compatibility between live changes and stuff
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/owner_document", () => {
				try {
					Document doc2 = get_doc ();
					Document doc1 = get_doc ();
					DomNode elem = get_elem ("Malfoy", doc1);

					assert (elem.owner_document == doc1);
					assert (elem.owner_document != doc2);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/insert_before", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_2);
					parent.insert_before (child_0, child_2);
					parent.insert_before (child_1, child_2);

					assert (parent.first_child == child_0);
					assert (parent.last_child == child_2);
					assert (parent.child_nodes.length == 3);
					assert (parent.child_nodes.nth_data (0) == child_0);
					assert (parent.child_nodes.nth_data (1) == child_1);
					assert (parent.child_nodes.nth_data (2) == child_2);
					assert (child_0.previous_sibling == null);
					assert (child_1.previous_sibling == child_0);
					assert (child_2.previous_sibling == child_1);
					assert (child_0.next_sibling == child_1);
					assert (child_1.next_sibling == child_2);
					assert (child_2.next_sibling == null);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/replace_child", () => {
				try {
					// TODO: for this one, and others that include a ref_child, we want to test passing an irrelevant ref child and a null ref child

					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_2);

					parent.replace_child (child_1, child_2);

					assert (parent.first_child == child_0);
					assert (parent.last_child == child_1);
					assert (parent.child_nodes.length == 2);
					assert (parent.child_nodes.nth_data (0) == child_0);
					assert (parent.child_nodes.nth_data (1) == child_1);
					assert (child_0.previous_sibling == null);
					assert (child_1.previous_sibling == child_0);
					assert (child_0.next_sibling == child_1);
					assert (child_1.next_sibling == null);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/remove_child", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_2);
					parent.append_child (child_1);

					parent.remove_child (child_2);

					assert (child_2.previous_sibling == null);
					assert (child_2.next_sibling == null);

					assert (parent.first_child == child_0);
					assert (parent.last_child == child_1);
					assert (parent.child_nodes.length == 2);
					assert (parent.child_nodes.nth_data (0) == child_0);
					assert (parent.child_nodes.nth_data (1) == child_1);
					assert (child_0.previous_sibling == null);
					assert (child_1.previous_sibling == child_0);
					assert (child_0.next_sibling == child_1);
					assert (child_1.next_sibling == null);

					parent.remove_child (child_0);

					assert (parent.first_child == child_1);
					assert (parent.last_child == child_1);
					assert (parent.child_nodes.length == 1);
					assert (parent.child_nodes.nth_data (0) == child_1);
					assert (child_1.previous_sibling == null);
					assert (child_1.next_sibling == null);

					parent.remove_child (child_1);

					assert (parent.first_child == null);
					assert (parent.last_child == null);
					assert (parent.child_nodes.length == 0);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/append_child", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);
					DomNode child_1 = get_elem ("Ron", doc);
					DomNode child_2 = get_elem ("Ginnie", doc);

					assert (parent.child_nodes.length == 0);
					parent.append_child (child_0);
					parent.append_child (child_1);
					parent.append_child (child_2);

					assert (parent.first_child == child_0);
					assert (parent.last_child == child_2);
					assert (parent.child_nodes.length == 3);
					assert (parent.child_nodes.nth_data (0) == child_0);
					assert (parent.child_nodes.nth_data (1) == child_1);
					assert (parent.child_nodes.nth_data (2) == child_2);
					assert (child_0.previous_sibling == null);
					assert (child_1.previous_sibling == child_0);
					assert (child_2.previous_sibling == child_1);
					assert (child_0.next_sibling == child_1);
					assert (child_1.next_sibling == child_2);
					assert (child_2.next_sibling == null);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/has_child_nodes", () => {
				try {
					Document doc = get_doc ();
					DomNode parent = get_elem ("Molly", doc);
					DomNode child_0 = get_elem ("Percy", doc);

					assert (parent.has_child_nodes () == false);

					parent.append_child (child_0);

					assert (parent.has_child_nodes () == true);
				} catch (GXml.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/domnode/clone_nodes", () => {
				// STUB
			});

	}
}
