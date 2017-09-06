/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
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

class GElementTest : GXmlTest  {
	public static void add_tests () {
		Test.add_func ("/gxml/gelement/namespace_uri", () => {
			try {
				GDocument doc = new GDocument.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.GNode root = (GXml.GNode) doc.root;
				assert (root != null);
				assert (root.name == "Potions");
				GXml.GNode node = (GXml.GNode) root.children_nodes[0];
				assert (node != null);
				assert (node.name == "Potion");
				assert (node.namespaces != null);
				assert (node.namespaces.size == 2);
				assert (node.namespaces[0].uri == "http://hogwarts.co.uk/magic");
				assert (node.namespaces[0].prefix == "magic");
				assert (node.namespaces.get (1).prefix == "products");
				assert (node.namespaces.get (1).uri == "http://diagonalley.co.uk/products");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gelement/attributes", () => {
			try {
				GDocument doc = new GDocument.from_string ("<root />");
				assert (doc.root != null);
				GElement elem = (GElement) doc.create_element ("alphanumeric");
				doc.root.children_nodes.add (elem);
				assert (elem.attrs != null);
				assert (elem.attrs.size == 0);
				elem.set_attr ("alley", "Diagon");
				elem.set_attr ("train", "Hogwarts Express");
				assert (elem.attrs.size == 2);
				Test.message ("Getting attributes value alley... Node: "+doc.to_string ());
				assert (elem.attrs.get ("alley").value == "Diagon");
				assert (elem.attrs.get ("train").value == "Hogwarts Express");

				elem.set_attr ("owl", "");
				GAttribute attr = elem.get_attr ("owl") as GAttribute;
				assert (attr != null);
				attr.value = "Hedwig";

				assert (elem.attrs.size == 3);
				assert (elem.attrs.get ("owl").value == "Hedwig");

				elem.attrs.unset ("alley");
				assert (elem.attrs.get ("alley") == null);
				assert (elem.attrs.size == 2);
				elem.remove_attr ("owl");
				assert (elem.attrs.size == 1);
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gelement/to_string", () =>{
			try {
				GDocument doc = new GDocument.from_string ("<root />");
				var elem = doc.create_element ("country");
				var t = doc.create_text ("New Zealand");
				assert (t != null);
				elem.children_nodes.add (t);
				Test.message ("Elem1:"+elem.to_string ());
				assert (elem.to_string () == "<country>New Zealand</country>");
				var elem2 = doc.create_element ("messy");
				var t2 = doc.create_text ("&lt;<>&gt;");
				elem2.children_nodes.add (t2);
				Test.message ("Elem2:"+elem2.to_string ());
				assert (elem2.to_string () == "<messy>&amp;lt;&lt;&gt;&amp;gt;</messy>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gelement/content/set", () =>{
			try {
				var doc = new GDocument ();
				var root = (GElement) doc.create_element ("root");
				doc.children_nodes.add ((GNode) root);
				root.content = "TEXT1";
				assert (root.to_string () == "<root>TEXT1</root>");
				string s = doc.to_string ().split ("\n")[1];
				assert (s == "<root>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gelement/content/add_aside_child_nodes", () =>{
			try {
				var doc = new GDocument ();
				var root = (GElement) doc.create_element ("root");
				doc.children_nodes.add (root);
				var n = (GElement) doc.create_element ("child");
				root.children_nodes.add (n);
				var t = doc.create_text ("TEXT1");
				root.children_nodes.add (t);
				string s = doc.to_string ().split ("\n")[1];
				Test.message ("root="+root.to_string ());
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gelement/content/keep_child_nodes", () =>{
			try {
				var doc = new GDocument ();
				var root = (GElement) doc.create_element ("root");
				doc.children_nodes.add (root);
				var n = (GElement) doc.create_element ("child");
				root.children_nodes.add (n);
				var t = (Text) doc.create_text ("TEXT1");
				root.children_nodes.add (t);
				string s = doc.to_string ().split ("\n")[1];
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gelement/parent", () => {
			try {
				var doc = new GDocument.from_string ("<root><child/></root>");
				assert (doc.root != null);
				assert (doc.root.parent is GXml.Node);
				assert (doc.root.parent is GXml.Document);
				assert (doc.root.children_nodes[0] != null);
				assert (doc.root.children_nodes[0].parent != null);
				assert (doc.root.children_nodes[0].parent.name == "root");
				} catch (GLib.Error e) {
					Test.message (e.message);
					assert_not_reached ();
				}
		});
		Test.add_func ("/gxml/gelement/previous_element_sibling", () => {
			try {
				var doc = new GDocument.from_string ("<root> <child/> <child/></root>");
				assert (doc.document_element != null);
				assert (doc.document_element.parent_node is GXml.DomNode);
				assert (doc.document_element.parent_node is GXml.DomDocument);
				assert (doc.document_element.child_nodes[0] != null);
				assert (doc.document_element.child_nodes[0].parent_node != null);
				assert (doc.document_element.child_nodes[0].parent_node.node_name == "root");
				assert (doc.document_element.child_nodes[0] is DomText);
				assert (doc.document_element.child_nodes[1] != null);
				assert (doc.document_element.child_nodes[1] is DomElement);
				assert (doc.document_element.child_nodes[1].node_name == "child");
				assert ((doc.document_element.child_nodes[1] as DomElement).next_element_sibling != null);
				assert ((doc.document_element.child_nodes[1] as DomElement).next_element_sibling is DomElement);
				assert ((doc.document_element.child_nodes[1] as DomElement).next_element_sibling.node_name == "child");
				assert (doc.document_element.child_nodes[2] != null);
				assert (doc.document_element.child_nodes[2].parent_node != null);
				assert (doc.document_element.child_nodes[2].parent_node.node_name == "root");
				assert (doc.document_element.child_nodes[2] is DomText);
				assert (doc.document_element.child_nodes[3] != null);
				assert (doc.document_element.child_nodes[3] is DomElement);
				assert (doc.document_element.child_nodes[3].node_name == "child");
				assert ((doc.document_element.child_nodes[3] as DomElement).previous_element_sibling != null);
				assert ((doc.document_element.child_nodes[3] as DomElement).previous_element_sibling is DomElement);
				assert ((doc.document_element.child_nodes[3] as DomElement).previous_element_sibling.node_name == "child");
				} catch (GLib.Error e) {
					Test.message (e.message);
					assert_not_reached ();
				}
		});
		Test.add_func ("/gxml/gelement/css-selector", () => {
			try {
				var d = new GDocument () as DomDocument;
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				c1.set_attribute ("class", "error");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("class", "warning");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("class", "error warning");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("class", "error calc");
				r.append_child (c4);
				var c5 = d.create_element ("child");
				r.append_child (c5);
				var n1 = r.query_selector ("child");
				assert (n1 != null);
				assert (n1.get_attribute ("class") == "error");
				var n2 = r.query_selector ("child.warning");
				assert (n2 != null);
				assert (n2.get_attribute ("class") == "warning");
				var n3 = r.query_selector ("child[class]");
				assert (n3 != null);
				assert (n3.get_attribute ("class") == "error");
				var n4 = r.query_selector ("child[class=\"error calc\"]");
				assert (n4 != null);
				assert (n4.get_attribute ("class") == "error calc");
				var l1 = r.query_selector_all ("child");
				assert (l1 != null);
				assert (l1.length == 5);
				assert (l1.item (4).node_name == "child");
				var l2 = r.query_selector_all ("child[class]");
				assert (l2 != null);
				assert (l2.length == 4);
				assert (l2.item (3).node_name == "child");
				var l3 = r.query_selector_all ("child[class=\"error\"]");
				assert (l3 != null);
				assert (l3.length == 1);
				assert (l3.item (0).node_name == "child");
				var c6 = d.create_element ("child");
				c6.set_attribute ("prop", "val1");
				r.append_child (c6);
				var c7 = d.create_element ("child");
				c7.set_attribute ("prop", "val1");
				r.append_child (c7);
				var l4 = r.query_selector_all ("child[prop=\"val1\"]");
				assert (l4 != null);
				assert (l4.length == 2);
				assert (l4.item (0).node_name == "child");
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
	}
}
