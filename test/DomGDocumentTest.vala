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
			GDocument doc = new GDocument.from_string (STRDOC);
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
			GDocument doc = new GDocument.from_string (STRDOC);
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
			GDocument doc = new GDocument.from_string (HTMLDOC);
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
			GDocument doc = new GDocument.from_string (HTMLDOC);
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
	}
}
