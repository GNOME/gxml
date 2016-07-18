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

/* TODO: add tests for g_warnings being set; apparently you can trap g_criticals and test error messages with gtester */
class GAttributeTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/gattribute/value", () => {
			try {
				GDocument doc = new GDocument.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
				GAttribute attr = (GAttribute) doc.root.children_nodes[0].attrs.get ("price");
				assert (attr != null);
				assert (attr.name == "price");
				assert (attr.value == "43.56");
				attr.value = "56.1";
				assert (doc.root.children_nodes[0].to_string () == "<Wand price=\"56.1\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/>");
				// shell property is Namespaced, but no other property exists with same name then this should work
				GAttribute shell = (GAttribute) doc.root.children_nodes[0].attrs.get ("shell");
				assert (shell != null);
				assert (shell.name == "shell");
				assert (shell.value == "oak");
				shell.value = "Bad!?";
				Test.message (doc.root.children_nodes[0].to_string ());
				assert (doc.root.children_nodes[0].to_string () == "<Wand price=\"56.1\" wands:core=\"dragon heart cord\" wands:shell=\"Bad!?\"/>");
			} catch (GLib.Error e) {
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gattribute/namespace", () => {
			try {
				GDocument doc = new GDocument.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
				assert (doc.root != null);
				GXml.GNode root = (GXml.GNode) doc.root;
				GElement node = (GElement)root.children_nodes[0];

				GAttribute core = (GAttribute) node.attrs.get ("core");
				assert (core != null);
				assert (core.name == "core");
				assert (core.namespace.prefix == "wands");
				assert (core.namespace.uri == "http://mom.co.uk/wands");
				assert (core.namespaces != null);
				assert (core.namespaces.size == 1);
				assert (core.namespaces[0].uri == "http://mom.co.uk/wands");
				assert (core.prefix == "wands");
				GAttribute shell = (GAttribute) node.attrs.get ("shell");
				assert (shell != null);
				assert (shell.name == "shell");
				assert (shell.namespaces != null);
				assert (shell.namespaces.size == 1);
				assert (shell.namespaces[0].uri == "http://mom.co.uk/wands");
				assert (shell.prefix == "wands");
				GAttribute price = (GAttribute) node.attrs.get ("price");
				assert (price != null);
				assert (price.name == "price");
				assert (price.namespaces != null);
				assert (price.namespaces.size == 0);
			} catch (GLib.Error e) {
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gattribute/namespace_value", () => {
			try {
				GDocument doc = new GDocument.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\" shell=\"NoNs\"/></Wands>");
				// User namespace prefix to find namespaced attribute
				var nspshell = ((GElement) doc.root.children_nodes[0]).get_attr ("wands:shell") as GAttribute;
				assert (nspshell != null);
				assert (nspshell.name == "shell");
				assert (nspshell.namespace != null);
				assert (nspshell.namespace.prefix == "wands");
				assert (nspshell.namespace.uri == "http://mom.co.uk/wands");
				assert (nspshell.value == "oak");
				// User namespace prefix to find namespaced attribute from Node.attrs
				var nspshell2 = doc.root.children_nodes[0].attrs.get ("wands:shell") as GAttribute;
				assert (nspshell2 != null);
				assert (nspshell2.name == "shell");
				assert (nspshell2.namespace != null);
				assert (nspshell2.namespace.prefix == "wands");
				assert (nspshell2.namespace.uri == "http://mom.co.uk/wands");
				assert (nspshell2.value == "oak");
				// User no namespaced attribute
				var shell = ((GElement) doc.root.children_nodes[0]).get_attr ("shell") as GAttribute;
				assert (shell != null);
				assert (shell.name == "shell");
				assert (shell.namespace == null);
				assert (shell.value == "NoNs");
				// User no namespaced from Node.attrs
				var shell2 = doc.root.children_nodes[0].attrs.get ("shell") as GAttribute;
				assert (shell2 != null);
				assert (shell2.name == "shell");
				assert (shell2.namespace == null);
				assert (shell2.value == "NoNs");
			} catch (GLib.Error e) {
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/tw-attribute/parent", () => {
			var doc = new GDocument ();
			var e = doc.create_element ("root");
			doc.children_nodes.add (e);
			var c = doc.create_element ("child");
			e.children_nodes.add (c);
			(e as GXml.Element).set_attr ("attr", "val");
			assert (doc.root != null);
			assert (doc.root.attrs["attr"] != null);
			assert (doc.root.attrs["attr"].parent != null);
			assert (doc.root.attrs["attr"].parent.name == "root");
		});
	}
}
