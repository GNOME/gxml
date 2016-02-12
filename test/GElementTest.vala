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
				GXml.GNode node = (GXml.GNode) root.children[0];
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
				doc.root.children.add (elem);
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
				elem.children.add (t);
				Test.message ("Elem1:"+elem.to_string ());
				assert (elem.to_string () == "<country>New Zealand</country>");
				var elem2 = doc.create_element ("messy");
				var t2 = doc.create_text ("&lt;<>&gt;");
				elem2.children.add (t2);
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
				doc.children.add ((GNode) root);
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
				doc.children.add (root);
				var n = (GElement) doc.create_element ("child");
				root.children.add (n);
				var t = doc.create_text ("TEXT1");
				root.children.add (t);
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
				doc.children.add (root);
				var n = (GElement) doc.create_element ("child");
				root.children.add (n);
				var t = (Text) doc.create_text ("TEXT1");
				root.children.add (t);
				string s = doc.to_string ().split ("\n")[1];
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
	}
}
