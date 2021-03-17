/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* DomXDocumentTest.vala
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

class DomXDocumentTest : GLib.Object {

const string STRDOC = "<?xml version=\"1.0\"?>
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

const string HTMLDOC ="
<html>
<body>
<p class=\"black\">Text content</p>
<p id=\"p01\">p01 p id</p>
<p class=\"black block\">Two classes</p>
<p class=\"   time request hole   \">Three classes</p>
</body>
</html>
";

const string XMLDOC ="<?xml version=\"1.0\"?>
<root>
<project xmlns:gxml=\"http://live.gnome.org/GXml\">
<code class=\"parent\"/>
<code class=\"node parent\"/>
<page class=\"node\"/>
<page class=\"parent node hole\"/>
</project>
<Author name=\"You\" />
</root>
";

	public static int main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/gxml/dom/document/init/empty", () => {
			var doc = new XDocument ();
			assert (doc != null);
		});
		Test.add_func ("/gxml/dom/document/init/from_string", () => {
			try {
				var doc = new XDocument.from_string (STRDOC) as DomDocument;
				assert (doc != null);
		  } catch (GLib.Error e) {
		    GLib.warning ("Error: "+e.message);
		  }
		});
		Test.add_func ("/gxml/dom/document/children", () => {
			try {
#if DEBUG
				GLib.message ("Doc: "+STRDOC);
#endif
				var doc = new XDocument.from_string (STRDOC) as DomDocument;
				DomElement root = doc.document_element;
				assert (root != null);
				assert (root is DomElement);
				assert (root.node_name == "Sentences");
				assert (root.has_child_nodes ());
				assert (root.children.size == 3);
				assert (root.children[0].node_name == "Sentence");
				assert (root.children[0].get_attribute ("lang") == "en");
				assert (root.children[0].node_value == "I like the colour blue.");
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/dom/document/child_nodes", () => {
			try {
#if DEBUG
				GLib.message ("Doc: "+STRDOC);
#endif
				var doc = new XDocument.from_string (STRDOC) as DomDocument;
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
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/dom/document/element_collections", () => {
			try {
#if DEBUG
				GLib.message ("Doc: "+STRDOC);
#endif
				var doc = new XDocument.from_string (HTMLDOC) as DomDocument;
				assert (doc is DomDocument);
				var le = doc.get_elements_by_tag_name ("p");
				assert (le.size == 4);
				assert (le[0].get_attribute ("class") == "black");
				assert (le[1].get_attribute ("id") == "p01");
				var lc = doc.get_elements_by_class_name ("black");
#if DEBUG
				GLib.message ("DOC\n"+(doc as XDocument).to_string ());
#endif
				assert (lc.size == 2);
				assert (lc[0].node_name == "p");
				assert (lc[0].get_attribute ("class") == "black block");
				var nid = doc.get_element_by_id ("p01");
				assert (nid != null);
				assert (nid.node_name == "p");
				assert (nid.get_attribute ("id") == "p01");
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/dom/element/element_collections", () => {
			try {
				GLib.message ("Doc: "+HTMLDOC);
				var doc = new XDocument.from_string (HTMLDOC) as DomDocument;
				assert (doc is DomDocument);
				assert (doc.document_element.children.size == 1);
				var le = doc.document_element.get_elements_by_tag_name ("p");
				assert (le.size == 4);
				assert (le[0].get_attribute ("class") == "black");
				assert (le[1].get_attribute ("id") == "p01");
				var lc = doc.document_element.get_elements_by_class_name ("black");
#if DEBUG
				GLib.message("size"+lc.size.to_string ());
#endif
				assert (lc.size == 2);
				assert (lc[0].node_name == "p");
				assert ("black" in lc[0].get_attribute ("class"));
				var lc2 = doc.document_element.get_elements_by_class_name ("time");
				assert (lc2.size == 1);
				var lc3 = doc.document_element.get_elements_by_class_name ("time request");
				assert (lc3.size == 1);
				var lc4 = doc.document_element.get_elements_by_class_name ("time request hole");
				assert (lc4.size == 1);
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/dom/node", () => {
			try {
			var doc = new XDocument.from_string (HTMLDOC) as DomDocument;
			assert (doc is DomDocument);
			message (doc.write_string ());
			assert (doc.document_element.children.size == 1);
			assert (doc.document_element.children[0] != null);
			assert (doc.document_element.children[0].children[1] != null);
			var e = doc.document_element.children[0].children[1];
			assert (e.node_name == "p");
			assert (e is DomElement);
			assert (((DomElement) e).get_attribute ("id") == "p01");
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
			message ("%s: '%s'", e.parent_node.node_name, e.parent_node.text_content);
			assert (e.parent_node.text_content == "\n\n\n\n\n");
			assert (e.parent_node.has_child_nodes ());
			e.parent_node.normalize ();
			assert (e.parent_node.text_content == null);
			var cn = ((XElement) e).clone_node (false) as DomElement;
			assert (cn.node_name == "p");
			assert (cn.get_attribute ("id") == "p01");
			assert (cn.child_nodes != null);
			assert (cn.child_nodes.size == 0);
			var cn2 = ((XElement) e).clone_node (true) as DomElement;
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
			assert (p.children.length == 8);
			assert (p.children[7] is DomElement);
			assert (p.children[7].node_name == "p");
			assert (p.children[7].get_attribute ("id") == "newp");
			var pn3 = doc.create_element ("p") as DomElement;
			pn3.set_attribute ("id", "newp1");
			pn3.set_attribute ("class", "black");
			p.replace_child (pn3, pn2);
			assert (p.children.length == 8);
			assert (p.children[7] is DomElement);
			assert (p.children[7].node_name == "p");
			assert (p.children[7].get_attribute ("id") == "newp1");
			assert (p.children[7].get_attribute ("class") == "black");
			var pn4 = doc.create_element ("p") as DomElement;
			pn4.set_attribute ("id", "newp2");
			pn4.set_attribute ("class", "black");
			p.replace_child (pn4, p.child_nodes[0]);
			assert (p.children.length == 8);
			assert (p.children[0] is DomElement);
			assert (p.children[0].node_name == "p");
			assert (p.children[0].get_attribute ("id") == "newp2");
			assert (p.children[0].get_attribute ("class") == "black");
			p.remove_child (p.children[0]);
			assert (p.children.length == 7);
			assert (p.children[0] is DomElement);
			assert (p.children[0].node_name == "p");
			assert (!p.has_attribute ("id"));
			assert (p.children[0].get_attribute ("class") == "black");
			assert (ng2 is DomElement);
			assert (ng2.node_name == "OtherNode");
			assert (ng2.lookup_namespace_uri (null) == "http://live.gnome.org/GXml");
			assert (ng2.lookup_prefix ("http://live.gnome.org/GXml") == null);
			assert (ng2.tag_name == "OtherNode");

#if DEBUG
			GLib.message ("BODY:"+(doc.document_element as GXml.Node).to_string ());
#endif
			var l = doc.document_element.get_elements_by_tag_name ("p");
			assert (l != null);
			assert (l is DomHTMLCollection);
			assert (l.length == 5);
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
#if DEBUG
			GLib.message ("Node with default ns: "+lns.length.to_string ());
#endif
			assert (lns.length == 1);
			assert (lns.item (0) is DomElement);
			assert (lns.item (0).node_name == "OtherNode");
			var lcl = doc.document_element.get_elements_by_class_name ("black");
			assert (lcl != null);
			assert (lcl is DomHTMLCollection);
			assert (lcl.length == 3);
			assert (lcl.item (0) is DomElement);
			assert (lcl.item (1) is DomElement);
			assert (lcl.item (0).node_name == "p");
			assert (lcl.item (1).node_name == "p");
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/dom/element/api", () => {
			try {
#if DEBUG
			GLib.message ("Doc: "+HTMLDOC);
#endif
			var doc = new XDocument.from_string (HTMLDOC) as DomDocument;
			assert (doc is DomDocument);
			assert (doc.document_element.children.size == 1);
			var n1 = doc.create_element_ns ("http://live.gnome.org/GXml","gxml:code");
			doc.document_element.append_child (n1);
			var n = doc.document_element.children[1] as DomElement;
			assert (n.node_name == "code");
			n.set_attribute ("id","0y1");
			n.set_attribute ("class","login black");
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
			assert (((DomNode) n).lookup_namespace_uri ("gxml") == "http://live.gnome.org/GXml");
			assert (((DomNode) n).lookup_prefix ("http://live.gnome.org/GXml") == "gxml");
			assert (n.tag_name == "gxml:code");
			n.remove_attribute ("id");
			assert (n.get_attribute ("id") == null);
			assert (!n.has_attribute ("id"));
			var n2 = doc.create_element ("p");
			doc.document_element.append_child (n2);
			assert (doc.document_element.children.length == 3);
#if DEBUG
			GLib.message ("DOC:"+(doc.document_element as GXml.Node).to_string ());
#endif
			assert (n2.attributes.length == 0);
#if DEBUG
			GLib.message ("Setting nice NS");
#endif
			n2.set_attribute_ns ("http://devel.org/","dev:nice","good");
			assert (n2.attributes.length == 1);
			assert (n2.has_attribute_ns ("http://devel.org/","nice"));
			assert (!n2.has_attribute_ns ("http://devel.org/","dev:nice"));
#if DEBUG
			GLib.message ("NODE:"+(n2 as GXml.Node).to_string ());
#endif
			assert (n2.get_attribute_ns ("http://devel.org/","nice") == "good");
			assert (n2.get_attribute_ns ("http://devel.org/","dev:nice") == null);
			} catch (GLib.Error e) {
				GLib.message ("Error: "+ e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/dom/document/api", () => {
			try {
#if DEBUG
				GLib.message ("Doc: "+XMLDOC);
#endif
				var doc = new XDocument.from_string (XMLDOC) as DomDocument;
				assert (doc.url == "about:blank");
				assert (doc.document_uri == "about:blank");
				assert (doc.origin == "");
				assert (doc.compat_mode == "");
				assert (doc.character_set == "utf-8");
				assert (doc.content_type == "application/xml");
				assert (doc.doctype == null);
				assert (doc.document_element != null);
				assert (doc.document_element is DomElement);
				assert (doc.document_element.node_name == "root");
				var le = doc.get_elements_by_tag_name ("code");
				assert (le.length == 2);
				assert (le.item (0) is DomElement);
				assert (le.item (0).node_name == "code");
				var n = doc.create_element_ns ("http://git.gnome.org/browse/gxml","git:MyNode");
				var n2 = doc.document_element.append_child (n) as DomElement;
				n2.set_attribute ("class","node");
				var lens = doc.get_elements_by_tag_name_ns ("http://git.gnome.org/browse/gxml","MyNode");
				assert (lens.length == 1);
				assert (lens.item (0) is DomElement);
				assert (lens.item (0).node_name == "MyNode");
#if DEBUG
				GLib.message ("DOC: "+(doc.document_element as GXml.Node).to_string ());
#endif
				var lec = doc.get_elements_by_class_name ("node");
				assert (lec.length == 4);
				assert (lec.item (0) is DomElement);
				assert (lec.item (0).node_name == "MyNode");
				assert (lec.item (1) is DomElement);
				assert (lec.item (1).node_name == "page");
				n.set_attribute ("class","node parent");
				var lec2 = doc.get_elements_by_class_name ("parent");
				assert (lec2.length == 4);
				assert (lec2.item (0) is DomElement);
				var lec3 = doc.get_elements_by_class_name ("parent code");
				assert (lec3.length == 0);
				var lec4 = doc.get_elements_by_class_name ("code parent");
				assert (lec4.length == 0);
				var lec5 = doc.get_elements_by_class_name ("node parent");
#if DEBUG
				GLib.message ("Doc in use:\n"+(doc as XDocument).libxml_to_string ());
				GLib.message ("Class node found: "+lec5.length.to_string ());
#endif
				assert (lec5.length == 3);
				assert (lec5.item (0) is DomElement);
				assert (lec5.item (0).node_name == "MyNode");
				assert (lec5.item (1) is DomElement);
				assert (lec5.item (1).node_name == "page");
				assert (lec5.item (2) is DomElement);
				assert (lec5.item (2).node_name == "code");
				var t = doc.create_text_node ("TEXT");
				n.append_child (t);
				assert (n.child_nodes[0] is DomText);
				assert (n.child_nodes[0].node_value == "TEXT");
				var comment = doc.create_comment ("COMMENT");
				doc.document_element.append_child (comment);
				assert (doc.document_element.last_child is DomComment);
				assert (doc.document_element.last_child.node_value == "COMMENT");
				var pi = doc.create_processing_instruction ("git","commit");
				doc.document_element.append_child (pi);
#if DEBUG
				GLib.message ("DOC: "+(doc.document_element as GXml.Node).to_string ());
#endif
				assert (doc.document_element.last_child is DomProcessingInstruction);
			} catch (GLib.Error e) {
				GLib.message ("Error: "+ e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/dom/document/import", () => {
			try {
#if DEBUG
				GLib.message ("Doc: "+XMLDOC);
#endif
				var doc = new XDocument.from_string (XMLDOC) as DomDocument;
				var doc2 = new XDocument.from_string (STRDOC) as DomDocument;
				doc.import_node (doc2.document_element, false);
#if DEBUG
				GLib.message ("DOC: "+(doc.document_element as GXml.Node).to_string ());
#endif
				assert (doc.document_element.last_child is DomElement);
				assert (doc.document_element.last_child.node_name == "Sentences");
				assert (doc.document_element.last_child.child_nodes.length == 0);
			} catch (GLib.Error e) {
				GLib.message ("Error: "+ e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/dom/document/adopt", () => {
			try {
#if DEBUG
				GLib.message ("Doc: "+XMLDOC);
#endif
				var doc = new XDocument.from_string (XMLDOC) as DomDocument;
				var doc2 = new XDocument.from_string (STRDOC) as DomDocument;
				doc2.adopt_node (doc.document_element.children.last ());
#if DEBUG
				GLib.message ("DOC: "+(doc.document_element as GXml.Node).to_string ());
				GLib.message ("DOC: "+(doc2.document_element as GXml.Node).to_string ());
#endif
				assert (doc.document_element.children.last ().node_name == "project");
				assert (doc2.document_element.last_child is DomElement);
				assert (doc2.document_element.last_child.node_name == "Author");
			} catch (GLib.Error e) {
				GLib.message ("Error: "+ e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/dom/document/event", () => {
		});
		Test.add_func ("/gxml/dom/document/range", () => {
		});
		Test.add_func ("/gxml/dom/document/iterator", () => {
		});
		Test.add_func ("/gxml/dom/document/walker", () => {
		});
		Test.add_func ("/gxml/dom/character", () => {
			try {
				var d = new XDocument () as DomDocument;
				var t = d.create_text_node ("TEXT") as DomCharacterData;
				assert (t.data == "TEXT");
				assert (t.length == "TEXT".length);
				assert (t.substring_data (0,2) == "TE");
				assert (t.substring_data (0,3) == "TEX");
				assert (t.substring_data (1,3) == "EXT");
				assert (t.substring_data (1,4) == "EXT");
				assert (t.substring_data (1,5) == "EXT");
				assert (t.substring_data (2,0) == "");
				try {
					t.substring_data (5,1);
					assert_not_reached ();
				}
				catch {}
				t.append_data (" HI");
				assert (t.data == "TEXT HI");
				t.replace_data (0, 4, "");
				assert (t.data == " HI");
				t.insert_data (0, "TEXT");
				assert (t.data == "TEXT HI");
				t.delete_data (0, 4);
				assert (t.data == " HI");
				t.insert_data (0, "TEXT");
				assert (t.data == "TEXT HI");
				t.replace_data (0, 4, "text");
				assert (t.data == "text HI");
				var n = d.create_element ("node");
				d.append_child (n);
				n.append_child (t);
				assert (t.parent_node.child_nodes.length == 1);
				assert (t.parent_node.child_nodes.length == 1);
				var ntst = d.create_element ("child");
				n.append_child (ntst);
				var ct1 = d.create_text_node ("TEXT1");
				ntst.append_child (ct1);
				assert (ntst.child_nodes.length == 1);
				var ct2 = d.create_text_node ("TEXT2");
				ntst.append_child (ct2);
				/* assert (ntst.child_nodes.length == 2);
				BUG: libxml2 doesn't support continuos DomText nodes
				when it is added, its data is concatecated in just text
				node*/
#if DEBUG
				GLib.message ("NTST: "+(ntst as GXml.Node).to_string ());
#endif
				assert (ntst.child_nodes.item (0) is DomText);
				assert (((DomText) ntst.child_nodes.item (0)).data == "TEXT1TEXT2");
				/* BUG: DomText.whole_text */
				assert (((DomText) ntst.child_nodes.item(0)).whole_text == "TEXT1TEXT2");
			} catch (GLib.Error e) {
				GLib.message ("Error: "+ e.message);
				assert_not_reached ();
			}
		});

		Test.run ();

		return 0;
	}
}
