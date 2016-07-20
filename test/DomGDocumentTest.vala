/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* DomGDocumentTest.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using GXml;

class DomGDocumentTest : GXmlTest {

static const string STRDOC = "<?xml version=\"1.0\"?>
<!-- Comment -->
<Sentences>
  <Sentence lang=\"en\">I like the colour blue.</Sentence>
  <Sentence lang=\"de\">Ich liebe die T&#xFC;r.</Sentence>
  <Authors>
    <Author>
      <Name>Fred</Name>
      <Email>fweasley@hogwarts.co.uk</Email>
    </Author>
    <Author>
      <Name>George</Name>
      <Email>gweasley@hogwarts.co.uk</Email>
    </Author>
  </Authors>
</Sentences>
";

static const string HTMLDOC ="
<html>
<body>
<p class=\"black\">Text content</p>
<p id=\"p01\">p01 p id</p>
<p class=\"black block\">Two classes</p>
</body>
</html>
";

	public static void add_tests () {
		Test.add_func ("/gxml/dom/document/children", () => {
			GLib.message ("Doc: "+STRDOC);
			var doc = new GDocument.from_string (STRDOC) as DomDocument;
			DomElement root = doc.document_element;
			assert (root != null);
			assert (root is DomElement);
			assert (root.node_name == "Sentences");
			assert (root.has_child_nodes ());
			assert (root.children.size == 3);
			assert (root.children[0].node_name == "Sentence");
			assert (root.children[0].get_attribute ("lang") == "en");
			assert (root.children[0].node_value == "I like the colour blue.");
		});
		Test.add_func ("/gxml/dom/document/child_nodes", () => {
			GLib.message ("Doc: "+STRDOC);
			var doc = new GDocument.from_string (STRDOC) as DomDocument;
			assert (doc is DomDocument);
			assert (doc.child_nodes != null);
			assert (doc.child_nodes.size == 2);
			assert (doc.child_nodes[0] is DomComment);
			assert (doc.child_nodes[1] is DomElement);
			assert (doc.child_nodes[1].node_name == "Sentences");
			assert (doc.document_element != null);
			assert (doc.document_element is DomElement);
			var auths = doc.document_element.children[2];
			assert (auths.node_name == "Authors");
			assert (auths.child_nodes.size == 5);
			assert (auths.child_nodes[4] is DomText);
		});
		Test.add_func ("/gxml/dom/document/element_collections", () => {
			GLib.message ("Doc: "+STRDOC);
			var doc = new GDocument.from_string (HTMLDOC) as DomDocument;
			assert (doc is DomDocument);
			var le = doc.get_elements_by_tag_name ("p");
			assert (le.size == 3);
			assert (le[0].get_attribute ("class") == "black");
			assert (le[1].get_attribute ("id") == "p01");
			var lc = doc.get_elements_by_class_name ("black");
			assert (lc.size == 2);
			assert (lc[0].node_name == "p");
			assert (lc[0].get_attribute ("class") == "black");
			assert (lc[1].node_name == "p");
			assert (lc[1].get_attribute ("class") == "black block");
			var nid = doc.get_element_by_id ("p01");
			assert (nid != null);
			assert (nid.node_name == "p");
			assert (nid.get_attribute ("id") == "p01");
		});
		Test.add_func ("/gxml/dom/element/element_collections", () => {
			GLib.message ("Doc: "+HTMLDOC);
			var doc = new GDocument.from_string (HTMLDOC) as DomDocument;
			assert (doc is DomDocument);
			assert (doc.document_element.children.size == 1);
			var le = doc.document_element.get_elements_by_tag_name ("p");
			assert (le.size == 3);
			assert (le[0].get_attribute ("class") == "black");
			assert (le[1].get_attribute ("id") == "p01");
			var lc = doc.document_element.get_elements_by_class_name ("black");
			GLib.message("size"+lc.size.to_string ());
			assert (lc.size == 2);
			assert (lc[0].node_name == "p");
			assert (lc[0].get_attribute ("class") == "black");
			assert (lc[1].node_name == "p");
			assert (lc[1].get_attribute ("class") == "black block");
		});
		Test.add_func ("/gxml/dom/node", () => {
			try {
			Test.message ("Doc: "+HTMLDOC);
			var doc = new GDocument.from_string (HTMLDOC) as DomDocument;
			assert (doc is DomDocument);
			assert (doc.document_element.children.size == 1);
			assert (doc.document_element.children[0] != null);
			assert (doc.document_element.children[0].children[1] != null);
			var e = doc.document_element.children[0].children[1];
			assert (e.owner_document == (DomDocument) doc);
			assert (e.parent_node != null);
			assert (e.parent_node.node_name == "body");
			assert (e.parent_element != null);
			assert (e.parent_element.node_name == "body");
			assert (e.child_nodes != null);
			assert (e.child_nodes.size == 1);
			assert (e.child_nodes.item (0) != null);
			assert (e.child_nodes.item (0) is DomText);
			assert (e.previous_sibling != null);
			assert (e.previous_sibling is DomText);
			assert (e.next_sibling != null);
			assert (e.next_sibling is DomText);
			var t = e.child_nodes.item (0);
			assert (t.previous_sibling == null);
			assert (t.next_sibling == null);
			assert (t.text_content != null);
			assert (t.text_content == "p01 p id");
			assert (e.parent_node.text_content == "\n\n\n\n");
			assert (e.parent_node.has_child_nodes ());
			e.parent_node.normalize ();
			assert (e.parent_node.text_content == null);
			var cn = e.clone_node (false) as DomElement;
			assert (cn.node_name == "p");
			assert (cn.get_attribute ("id") == "p01");
			assert (cn.child_nodes != null);
			assert (cn.child_nodes.size == 0);
			var cn2 = e.clone_node (true) as DomElement;
			assert (cn2.node_name == "p");
			assert (cn2.get_attribute ("id") == "p01");
			assert (cn2.child_nodes != null);
			assert (cn2.child_nodes.size == 1);
			assert (cn2.child_nodes[0] is DomText);
			assert (cn2.text_content == "p01 p id");
			assert (!e.is_equal_node (cn));
			assert (e.is_equal_node (cn2));
			var e0 = doc.document_element.children[0].children[0];
			assert (e0.node_name == "p");
			assert (doc.document_element.children[0].child_nodes.index_of (e0) == 0);
			var e1 = doc.document_element.children[0].children[1];
			assert (e1.node_name == "p");
			assert (doc.document_element.children[0].child_nodes.index_of (e1) == 1);
			var e2 = doc.document_element.children[0].children[2];
			assert (e2.node_name == "p");
			assert (doc.document_element.children[0].child_nodes.index_of (e2) == 2);
			assert (e.parent_node.contains (e0));
			assert (e.parent_node.contains (e1));
			assert (e.parent_node.contains (e2));
			assert (e1.parent_node.contains (e0) && e0.parent_node.contains (e1));
			assert (e1.compare_document_position (e0) == DomNode.DocumentPosition.PRECEDING);
			assert (e1.parent_node.contains (e2) && e2.parent_node.contains (e1));
			assert (e1.compare_document_position (e2) == DomNode.DocumentPosition.FOLLOWING);
			assert (e1.parent_node.contains (e1));
			assert (e1.compare_document_position (e1.parent_node) == (DomNode.DocumentPosition.CONTAINS & DomNode.DocumentPosition.FOLLOWING));
			assert (e1.contains (e1.child_nodes[0]));
			assert (e1.compare_document_position (e1.child_nodes[0]) == (DomNode.DocumentPosition.CONTAINED_BY & DomNode.DocumentPosition.PRECEDING));
			var b = doc.document_element.children[0];
			assert (b.node_name == "body");
			var ng = doc.create_element_ns ("http://git.gnome.org/browse/gxml","gxml:MyNode");
			b.child_nodes.add (ng);
			assert (ng.lookup_prefix ("http://git.gnome.org/browse/gxml") == "gxml");
			assert (ng.lookup_namespace_uri ("gxml") == "http://git.gnome.org/browse/gxml");
			assert (!ng.is_default_namespace ("gxml:http://git.gnome.org/browse/gxml"));
			var ng2 = doc.create_element_ns ("http://live.gnome.org/GXml", "OtherNode");
			b.child_nodes.add (ng2);
			assert (ng2.lookup_prefix ("http://live.gnome.org/GXml") == null);
			assert (ng2.lookup_namespace_uri (null) == "http://live.gnome.org/GXml");
			assert (ng2.is_default_namespace ("http://live.gnome.org/GXml"));
			var pn = doc.create_element ("p") as DomElement;
			pn.set_attribute ("id", "insertedp01");
			var p = doc.document_element.children[0];
			assert (p.node_name == "body");
			var cp0 = p.children[0];
			assert (cp0.node_name == "p");
			assert (cp0.get_attribute ("class") == "black");
			assert (p.contains (cp0));
			assert (cp0.parent_node.contains (cp0));
			p.insert_before (pn, cp0);
			var ppn = p.children[0];
			assert (ppn.node_name == "p");
			assert (ppn.has_attribute ("id"));
			assert (ppn.get_attribute ("id") == "insertedp01");
			var pn2 = doc.create_element ("p") as DomElement;
			pn2.set_attribute ("id", "newp");
			p.append_child (pn2);
			assert (p.children.length == 7);
			assert (p.children[6] is DomElement);
			assert (p.children[6].node_name == "p");
			assert (p.children[6].get_attribute ("id") == "newp");
			var pn3 = doc.create_element ("p") as DomElement;
			pn3.set_attribute ("id", "newp1");
			pn3.set_attribute ("class", "black");
			p.replace_child (pn3, pn2);
			assert (p.children.length == 7);
			assert (p.children[6] is DomElement);
			assert (p.children[6].node_name == "p");
			assert (p.children[6].get_attribute ("id") == "newp1");
			assert (p.children[6].get_attribute ("class") == "black");
			var pn4 = doc.create_element ("p") as DomElement;
			pn4.set_attribute ("id", "newp2");
			pn4.set_attribute ("class", "black");
			p.replace_child (pn4, p.child_nodes[0]);
			assert (p.children.length == 7);
			assert (p.children[0] is DomElement);
			assert (p.children[0].node_name == "p");
			assert (p.children[0].get_attribute ("id") == "newp2");
			assert (p.children[0].get_attribute ("class") == "black");
			p.remove_child (p.children[0]);
			assert (p.children.length == 6);
			assert (p.children[0] is DomElement);
			assert (p.children[0].node_name == "p");
			assert (!p.has_attribute ("id"));
			assert (p.children[0].get_attribute ("class") == "black");
			// Checking for DomElement NS
			assert (ng2 is DomElement);
			assert (ng2.node_name == "OtherNode");
			assert (ng2.lookup_namespace_uri (null) == "http://live.gnome.org/GXml");
			assert (ng2.lookup_prefix ("http://live.gnome.org/GXml") == null);
			assert (ng2.tag_name == "OtherNode");

			GLib.message ("BODY:"+(doc.document_element as GXml.Node).to_string ());
			var l = doc.document_element.get_elements_by_tag_name ("p");
			assert (l != null);
			assert (l is DomHTMLCollection);
			assert (l.length == 4);
			assert (l[0] is DomElement);
			assert (l[1] is DomElement);
			assert (l[1] is DomElement);
			assert (l[0].node_name == "p");
			assert (l[1].node_name == "p");
			assert (l[2].node_name == "p");
			assert (doc.document_element.children.length == 1);
			var lnst = doc.document_element.get_elements_by_tag_name ("OtherNode");
			assert (lnst.length == 1);
			var nnst = lnst.item (0);
			assert (nnst.namespace_uri == "http://live.gnome.org/GXml");
			var lns = doc.document_element.get_elements_by_tag_name_ns ("http://live.gnome.org/GXml", "OtherNode");
			assert (lns != null);
			assert (lns is DomHTMLCollection);
			GLib.message ("Node with default ns: "+lns.length.to_string ());
			assert (lns.length == 1);
			assert (lns.item (0) is DomElement);
			assert (lns.item (0).node_name == "OtherNode");
			var lcl = doc.document_element.get_elements_by_class_name ("black");
			assert (lcl != null);
			assert (lcl is DomHTMLCollection);
			assert (lcl.length == 3);
			assert (lcl.item (0) is DomElement);
			assert (lcl.item (1) is DomElement);
			assert (lcl.item (2) is DomElement);
			assert (lcl.item (0).node_name == "p");
			assert (lcl.item (1).node_name == "p");
			assert (lcl.item (2).node_name == "p");
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/dom/element/api", () => {
			try {
			GLib.message ("Doc: "+HTMLDOC);
			var doc = new GDocument.from_string (HTMLDOC) as DomDocument;
			assert (doc is DomDocument);
			assert (doc.document_element.children.size == 1);
			var n1 = doc.create_element_ns ("http://live.gnome.org/GXml","gxml:code");
			doc.document_element.append_child (n1);
			var n = doc.document_element.children[1] as DomElement;
			assert (n.node_name == "code");
			n.set_attribute ("id","0y1");
			n.set_attribute ("class","login black");
			assert ((n as GXml.Node).namespaces.size == 1);
			assert ((n as GXml.Node).namespaces[0].uri == "http://live.gnome.org/GXml");
			assert ((n as GXml.Node).namespaces[0].prefix == "gxml");
			assert (n.namespace_uri == "http://live.gnome.org/GXml");
			assert (n.prefix == "gxml");
			assert (n.local_name == "code");
			assert (n.node_name == "code");
			assert (n.id == "0y1");
			assert (n.class_list != null);
			assert (n.class_list.length == 2);
			assert (n.class_list.item (0) == "login");
			assert (n.class_list.item (1) == "black");
			assert (n.attributes != null);
			assert (n.attributes.length == 2);
			assert (n.attributes.get_named_item ("id") is DomNode);
			assert (n.attributes.get_named_item ("id").node_name == "id");
			assert (n.attributes.get_named_item ("id").node_value == "0y1");
			assert (n.node_name == "code");
			assert ((n as DomNode).lookup_namespace_uri ("gxml") == "http://live.gnome.org/GXml");
			assert ((n as DomNode).lookup_prefix ("http://live.gnome.org/GXml") == "gxml");
			assert (n.tag_name == "gxml:code");
			n.remove_attribute ("id");
			assert (n.get_attribute ("id") == null);
			assert (!n.has_attribute ("id"));
			var n2 = doc.create_element ("p");
			doc.document_element.append_child (n2);
			assert (doc.document_element.children.length == 3);
			GLib.message ("DOC:"+(doc.document_element as GXml.Node).to_string ());
			assert (n2.attributes.length == 0);
			GLib.message ("Setting nice NS");
			n2.set_attribute_ns ("http://devel.org/","dev:nice","good");
			assert (n2.attributes.length == 1);
			assert (n2.has_attribute_ns ("http://devel.org/","nice"));
			assert (!n2.has_attribute_ns ("http://devel.org/","dev:nice"));
			GLib.message ("NODE:"+(n2 as GXml.Node).to_string ());
			assert (n2.get_attribute_ns ("http://devel.org/","nice") == "good");
			assert (n2.get_attribute_ns ("http://devel.org/","dev:nice") == null);
			} catch (GLib.Error e) {
				GLib.message ("Error: "+ e.message);
				assert_not_reached ();
			}
		});
	}
}
