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

class GomElementTest : GXmlTest  {
	public static void add_tests () {
	Test.add_func ("/gxml/gom-element/read/namespace_uri", () => {
			DomDocument doc = null;
			try {
				doc = new GomDocument.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
			try {
				GXml.GomNode root = (GXml.GomNode) doc.document_element;
				assert (root != null);
				assert (root.node_name == "Potions");
				GXml.GomNode node = (GXml.GomNode) root.child_nodes[0];
				assert (node != null);
				assert (node is DomElement);
				assert ((node as DomElement).local_name == "Potion");
				assert (node.node_name == "magic:Potion");
				assert ((node as DomElement).namespace_uri == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).prefix == "magic");
				assert ((node as DomElement).attributes.size == 2);
				GLib.message ("Attributes: "+(node as DomElement).attributes.size.to_string ());
				/*foreach (string k in (node as DomElement).attributes.keys) {
					string v = (node as DomElement).get_attribute (k);
					if (v == null) v = "NULL";
					GLib.message ("Attribute: "+k+"="+v);
				}*/
				assert ((node as DomElement).get_attribute ("xmlns:magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute ("xmlns:products") == "http://diagonalley.co.uk/products");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/","products") == "http://diagonalley.co.uk/products");
				assert (node.lookup_prefix ("http://diagonalley.co.uk/products") == "products");
				assert (node.lookup_namespace_uri ("products") == "http://diagonalley.co.uk/products");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/namespace_uri", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.GomNode root = (GXml.GomNode) doc.document_element;
				assert (root != null);
				assert (root.node_name == "Potions");
				GXml.GomNode node = (GXml.GomNode) root.child_nodes[0];
				assert (node != null);
				assert (node is DomElement);
				assert ((node as DomElement).local_name == "Potion");
				assert (node.node_name == "magic:Potion");
				assert ((node as DomElement).namespace_uri == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).prefix == "magic");
				assert ((node as DomElement).attributes.size == 2);
				GLib.message ("Attributes: "+(node as DomElement).attributes.size.to_string ());
				/*foreach (string k in (node as DomElement).attributes.keys) {
					string v = (node as DomElement).get_attribute (k);
					if (v == null) v = "NULL";
					GLib.message ("Attribute: "+k+"="+v);
				}*/
				assert ((node as DomElement).get_attribute ("xmlns:magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute ("xmlns:products") == "http://diagonalley.co.uk/products");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/","products") == "http://diagonalley.co.uk/products");
				assert (node.lookup_prefix ("http://diagonalley.co.uk/products") == "products");
				assert (node.lookup_namespace_uri ("products") == "http://diagonalley.co.uk/products");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/attributes", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				assert (doc.document_element != null);
				GomElement elem = (GomElement) doc.create_element ("alphanumeric");
				doc.document_element.child_nodes.add (elem);
				assert (elem.attributes != null);
				assert (elem.attributes.size == 0);
				elem.set_attribute ("alley", "Diagon");
				elem.set_attribute ("train", "Hogwarts Express");
				assert (elem.attributes.size == 2);
				Test.message ("Getting attributes value alley... Node: "+doc.to_string ());
				assert (elem.attributes.get_named_item ("alley").node_value == "Diagon");
				assert (elem.attributes.get_named_item ("train").node_value == "Hogwarts Express");

				elem.set_attribute ("owl", "Hedwig");
				GomAttr attr = elem.attributes.get_named_item ("owl") as GomAttr;
				assert (attr != null);
				assert (attr.node_value == "Hedwig");

				assert (elem.attributes.size == 3);
				assert (elem.get_attribute ("owl") == "Hedwig");

				elem.attributes.remove_named_item ("alley");

				assert (elem.get_attribute ("alley") == null);
				assert (elem.attributes.size == 2);
				elem.remove_attribute ("owl");
				assert (elem.attributes.size == 1);

				elem.set_attribute_ns ("http://www.w3.org/2000/xmlns/", "xmlns:gxml",
															"http://www.gnome.org/GXml");
				assert (elem.attributes.size == 2);
				elem.set_attribute_ns ("http://www.gnome.org/GXml", "gxml:xola","Mexico");
				assert (elem.attributes.size == 3);
				assert (elem.get_attribute_ns ("http://www.gnome.org/GXml", "xola") == "Mexico");
				elem.remove_attribute_ns ("http://www.gnome.org/GXml", "xola");
				assert (elem.get_attribute_ns ("http://www.gnome.org/GXml", "xola") == null);
				assert (elem.attributes.size == 2);
				try {
					elem.set_attribute_ns ("http://www.gnome.org/GXml", "gxml2:xola","Mexico");
					assert_not_reached ();
				} catch {}
				assert (elem.attributes.size == 2);
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/to_string", () =>{
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				var elem = doc.create_element ("country");
				var t = doc.create_text_node ("New Zealand");
				assert (t != null);
				elem.child_nodes.add (t);
				Test.message ("Elem1:"+(elem as GomNode).to_string ());
				assert ((elem as GomElement).to_string () == "<country>New Zealand</country>");
				var elem2 = doc.create_element ("messy");
				var t2 = doc.create_text_node ("&lt;<>&gt;");
				elem2.child_nodes.add (t2);
				Test.message ("Elem2:"+(elem2 as GomNode).to_string ());
				assert ((elem2 as GomNode).to_string () == "<messy>&amp;lt;&lt;&gt;&amp;gt;</messy>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/content/add_aside_child_nodes", () =>{
			try {
				var doc = new GomDocument ();
				var root = (GomElement) doc.create_element ("root");
				doc.child_nodes.add (root);
				var n = (GomElement) doc.create_element ("child");
				root.child_nodes.add (n);
				var t = doc.create_text_node ("TEXT1");
				root.child_nodes.add (t);
				string s = doc.to_string ().split ("\n")[1];
				Test.message ("root="+root.to_string ());
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/content/keep_child_nodes", () =>{
			try {
				var doc = new GomDocument ();
				var root = (GomElement) doc.create_element ("root");
				doc.child_nodes.add (root);
				var n = (GomElement) doc.create_element ("child");
				root.child_nodes.add (n);
				var t = doc.create_text_node ("TEXT1") as DomText;
				root.child_nodes.add (t);
				string s = doc.to_string ().split ("\n")[1];
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/parent", () => {
			var doc = new GomDocument.from_string ("<root><child/></root>");
			assert (doc.document_element != null);
			assert (doc.document_element.parent_node is GXml.DomNode);
			assert (doc.document_element.parent_node is GXml.DomDocument);
			assert (doc.document_element.child_nodes[0] != null);
			assert (doc.document_element.child_nodes[0].parent_node != null);
			assert (doc.document_element.child_nodes[0].parent_node.node_name == "root");
		});
	}
}
