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

class XElementTest : GLib.Object  {
	public static int main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/gxml/gelement/to_string", () =>{
			try {
				DomDocument doc = new XDocument.from_string ("<root />");
				var elem = doc.create_element ("country");
				var t = doc.create_text_node ("New Zealand");
				assert (t != null);
				elem.append_child (t);
				message ("Elem1:"+elem.write_string ());
				assert (elem.write_string () == "<country>New Zealand</country>");
				var elem2 = doc.create_element ("messy");
				var t2 = doc.create_text_node ("&lt;<>&gt;");
				elem2.append_child (t2);
				message ("Elem2:"+elem2.write_string ());
				assert (elem2.write_string () == "<messy>&amp;lt;&lt;&gt;&amp;gt;</messy>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gelement/previous_element_sibling", () => {
			try {
				var doc = new XDocument.from_string ("<root> <child/> <child/></root>");
				assert (doc.document_element != null);
				assert (doc.document_element.parent_node is GXml.DomNode);
				assert (doc.document_element.parent_node is GXml.DomDocument);
				var n0 = doc.document_element.child_nodes[0];
				assert (n0 != null);
				assert (n0.parent_node != null);
				string n = n0.parent_node.node_name;
				assert (n != null);
				assert (n == "root");
				assert (n0 is DomText);
				var n1 = doc.document_element.child_nodes[1];
				assert (n1 != null);
				assert (n1 is DomElement);
				assert (n1.node_name == "child");
				assert (((DomElement) n1).next_element_sibling != null);
				assert (((DomElement) n1).next_element_sibling is DomElement);
				assert (((DomElement) n1).next_element_sibling.node_name == "child");
				var n2 = doc.document_element.child_nodes[2];
				assert (n2 != null);
				assert (n2.parent_node != null);
				assert (n2.parent_node.node_name == "root");
				assert (n2 is DomText);
				var n3 = doc.document_element.child_nodes[3];
				assert (n3 != null);
				assert (n3 is DomElement);
				assert (n3.node_name == "child");
				assert (((DomElement) n3).previous_element_sibling != null);
				assert (((DomElement) n3).previous_element_sibling is DomElement);
				assert (((DomElement) n3).previous_element_sibling.node_name == "child");
				} catch (GLib.Error e) {
					Test.message (e.message);
					assert_not_reached ();
				}
		});
		Test.add_func ("/gxml/gelement/css-selector", () => {
			try {
				var d = new XDocument () as DomDocument;
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
    Test.add_func ("/gxml/g-document/dom-write-read", () => {
      try {
        DomDocument d = new XDocument ();
        File dir = File.new_for_path (GXmlTestConfig.TEST_DIR);
        assert (dir.query_exists ());
        File f = File.new_for_uri (dir.get_uri ()+"/test-large.xml");
        assert (f.query_exists ());
        d.read_from_file (f);
      } catch (GLib.Error e) {
        warning ("Error: %s", e.message);
        assert_not_reached ();
      }
    });

		Test.run ();

		return 0;
	}
}
