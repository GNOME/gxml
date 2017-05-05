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
	public class ParsedDelayed : GomElement {
		construct {
			try { initialize ("root"); }
			catch (GLib.Error e) { warning ("Error: "+e.message); }
			parse_children = false;
		}
	}
	public static void add_tests () {
	Test.add_func ("/gxml/gom-element/read/namespace_uri", () => {
			DomDocument doc = null;
			try {
				doc = new GomDocument.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
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
				(node as DomElement).set_attribute_ns ("http://www.w3.org/2000/xmlns", "xmlns:gxmlt","http://org.gnome.org/GXmlTest/");
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
#if DEBUG
				message ("Element: "+(node as GomElement).write_string ());
				message ("Attributes: "+(node as DomElement).attributes.length.to_string ());
				foreach (string k in (node as DomElement).attributes.keys) {
					string v = (node as DomElement).get_attribute (k);
					if (v == null) v = "NULL";
					GLib.message ("Attribute: "+k+"="+v);
				}
#endif
				assert ((node as DomElement).attributes.length == 2);
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
				var parser = new XParser (doc);
				Test.message ("Getting attributes value alley... Node: "+parser.write_string ());
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
				assert (elem.get_attribute ("xola") == null);
				assert (elem.attributes.size == 2);
				try {
#if DEBUG
					message ("Documento:"+parser.write_string ());
#endif
					elem.set_attribute_ns ("http://www.gnome.org/GXml", "gxml2:xola","Mexico");
					assert_not_reached ();
				} catch (GLib.Error e) {
					GLib.message ("Correctly Cough Error:"+e.message);
				}
				assert (elem != null);
				assert (elem.attributes != null);
				assert (elem.attributes.size == 2);
			} catch (GLib.Error e) {
				GLib.message (e.message);
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
				var parser = new XParser (doc);
				string s = parser.write_string ().split ("\n")[1];
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
				var parser = new XParser (doc);
				string s = parser.write_string ().split ("\n")[1];
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/parent", () => {
			try {
				var doc = new GomDocument.from_string ("<root><child/></root>");
				assert (doc.document_element != null);
				assert (doc.document_element.parent_node is GXml.DomNode);
				assert (doc.document_element.parent_node is GXml.DomDocument);
				assert (doc.document_element.child_nodes[0] != null);
				assert (doc.document_element.child_nodes[0].parent_node != null);
				assert (doc.document_element.child_nodes[0].parent_node.node_name == "root");
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/gom-element/parsed-delayed", () => {
			try {
				var n = new ParsedDelayed ();
				n.read_from_string ("<root><child p1=\"Value1\" p2=\"Value2\"><child2/></child></root>");
				assert (n.unparsed != null);
				assert (n.unparsed == "<child p1=\"Value1\" p2=\"Value2\"><child2/></child>");
				assert (!n.has_child_nodes ());
				assert (n.child_nodes.length == 0);
				(n as GomObject).read_unparsed ();
				assert (n.has_child_nodes ());
				assert (n.child_nodes.length == 1);
				assert (n.unparsed == null);
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/gom-element/write/string", () => {
			try {
				var n = new GomElement ();
				n.initialize ("Node");
				n.set_attribute ("name","value");
				var n2 = n.owner_document.create_element ("Node2") as GomElement;
				n.append_child (n2);
				string str = n.write_string ();
				assert ("<Node" in str);
				assert ("<Node name=\"value\"><Node2/></Node>" in str);
				str = n2.write_string ();
				assert ("<Node2/>" in str);
				assert (!("<Node name=\"value\"><Node2/></Node>" in str));
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/gom-element/write/stream", () => {
			try {
				var n = new GomElement ();
				n.initialize ("Node");
				n.set_attribute ("name","value");
				var ostream = new MemoryOutputStream.resizable ();
				n.write_stream (ostream);
				string str = (string) ostream.data;
				assert ("<Node" in str);
				assert ("<Node name=\"value\"/>" in str);
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/gom-element/write/input_stream", () => {
			try {
				var n = new GomElement ();
				n.initialize ("Node");
				n.set_attribute ("name","value");
				var ostream = new MemoryOutputStream.resizable ();
				var istream = n.create_stream ();
				ostream.splice (istream, GLib.OutputStreamSpliceFlags.NONE);
				string str = (string) ostream.data;
				assert ("<Node" in str);
				assert ("<Node name=\"value\"/>" in str);
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
	}
}
