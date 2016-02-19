/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011-2015  Daniel Espinosa <esodan@gmail.com>
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
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

using GXml;

/* TODO: add tests for g_warnings being set; apparently you can trap g_criticals and test error messages with gtester */
class AttrTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/xattr/namespace_uri", () => {
				xDocument doc = new xDocument.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
				GXml.xNode root = doc.document_element;
				xElement node = (xElement)root.child_nodes.item (0);

				xAttr core = node.get_attribute_node ("core");
				xAttr shell = node.get_attribute_node ("shell");
				xAttr price = node.get_attribute_node ("price");

				assert (core.namespace_uri == "http://mom.co.uk/wands");
				assert (shell.namespace_uri == "http://mom.co.uk/wands");
				assert (price.namespace_uri == null);
			});
		Test.add_func ("/gxml/xattr/namespace_prefix", () => {
				xDocument doc = new xDocument.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
				GXml.xNode root = doc.document_element;
				xElement node = (xElement)root.child_nodes.item (0);

				xAttr core = node.get_attribute_node ("core");
				xAttr shell = node.get_attribute_node ("shell");
				xAttr price = node.get_attribute_node ("price");

				assert (core.namespace_prefix == "wands");
				assert (shell.namespace_prefix == "wands");
				assert (price.namespace_prefix == null);
			});
		Test.add_func ("/gxml/xattr/local_name", () => {
				xDocument doc = new xDocument.from_string ("<Wands xmlns:wands=\"http://mom.co.uk/wands\"><Wand price=\"43.56\" wands:core=\"dragon heart cord\" wands:shell=\"oak\"/></Wands>");
				GXml.xNode root = doc.document_element;
				xElement node = (xElement)root.child_nodes.item (0);

				xAttr core = node.get_attribute_node ("core");
				xAttr shell = node.get_attribute_node ("shell");
				xAttr price = node.get_attribute_node ("price");

				assert (core.local_name == "core");
				assert (shell.local_name == "shell");
				assert (price.local_name == "price");
			});

		Test.add_func ("/gxml/attribute/node_name", () => {
				xDocument doc = get_doc ();
				xAttr attr = get_attr ("broomSeries", "Nimbus", doc);

				assert (attr.node_name == "broomSeries");
			});
		Test.add_func ("/gxml/attribute/node_value", () => {
				xDocument doc = get_doc ();
				xAttr attr = doc.create_attribute ("bank");

				assert (attr.node_value == "");
				attr.node_value = "Gringots";
				assert (attr.node_value == "Gringots");
				attr.node_value = "Wizardlies";
				assert (attr.node_value == "Wizardlies");
				/* make sure changing .value changes .node_value */
				attr.value = "Gringots";
				assert (attr.node_value == "Gringots");
			});
		Test.add_func ("/gxml/attribute/name", () => {
				xDocument doc = get_doc ();
				xAttr attr = get_attr ("broomSeries", "Nimbus", doc);

				assert (attr.name == "broomSeries");
			});
		Test.add_func ("/gxml/attribute/value", () => {
				xDocument doc = get_doc ();
				xAttr attr = doc.create_attribute ("bank");

				assert (attr.value == "");
				attr.value = "Gringots";
				assert (attr.value == "Gringots");
				attr.value = "Wizardlies";
				assert (attr.value == "Wizardlies");
				/* make sure changing .node_value changes .value */
				attr.node_value = "Gringots";
				assert (attr.value == "Gringots");
			});
		Test.add_func ("/gxml/attribute/specified", () => {
				// TODO: involves supporting DTDs, which come later
			});
		Test.add_func ("/gxml/attribute/parent_node", () => {
				xDocument doc = get_doc ();
				xElement elem = get_elem ("creature", doc);
				xAttr attr = get_attr ("breed", "Dragons", doc);

				assert (attr.parent_node == null);
				elem.set_attribute_node (attr);
				assert (attr.parent_node == null);
			});
		Test.add_func ("/gxml/attribute/previous_sibling", () => {
				xDocument doc = get_doc ();
				xElement elem = get_elem ("creature", doc);
				xAttr attr1 = get_attr ("breed", "Dragons", doc);
				xAttr attr2 = get_attr ("size", "large", doc);

				elem.set_attribute_node (attr1);
				elem.set_attribute_node (attr2);

				assert (attr1.previous_sibling == null);
				assert (attr2.previous_sibling == null);
			});
		Test.add_func ("/gxml/attribute/next_sibling", () => {
				xDocument doc = get_doc ();
				xElement elem = get_elem ("creature", doc);
				xAttr attr1 = get_attr ("breed", "Dragons", doc);
				xAttr attr2 = get_attr ("size", "large", doc);

				elem.set_attribute_node (attr1);
				elem.set_attribute_node (attr2);

				assert (attr1.next_sibling == null);
				assert (attr2.next_sibling == null);
			});
		Test.add_func ("/gxml/attribute/insert_before", () => {
				xDocument doc = get_doc ();
				xAttr attr = get_attr ("pie", "Dumbleberry", doc);
				xText txt = doc.create_text_node ("Whipped ");

				assert (attr.value == "Dumbleberry");
				attr.insert_before (txt, attr.child_nodes.first ());
				assert (attr.value == "Whipped Dumbleberry");
				// the Text nodes should be merged
				assert (attr.child_nodes.length == 1);
			});
		Test.add_func ("/gxml/attribute/replace_child", () => {
				xDocument doc = get_doc ();
				xAttr attr = get_attr ("WinningHouse", "Slytherin", doc);
				xText txt = doc.create_text_node ("Gryffindor");

				assert (attr.value == "Slytherin");
				attr.replace_child (txt, attr.child_nodes.item (0));
				assert (attr.value == "Gryffindor");
			});
		Test.add_func ("/gxml/attribute/remove_child", () => {
				xDocument doc = get_doc ();
				xAttr attr = get_attr ("parchment", "MauraudersMap", doc);

				assert (attr.value == "MauraudersMap");
				// mischief managed
				attr.remove_child (attr.child_nodes.last ());
				assert (attr.value == "");
			});
		Test.add_func ("/gxml/attribute/parent", () => {
			var doc = new xDocument.from_string ("<root attr=\"val\"><child/></root>");
			assert (doc.root != null);
			assert (doc.root.attrs["attr"] != null);
			assert (doc.root.attrs["attr"].parent == null);
		});
	}
}
