/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
 *
 * Copyright (C) 2016 Daniel Espinosa <esodan@gmail.com>
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

class GomDocumentTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/gom-document/construct_api", () => {
			try {
				DomDocument d = new GomDocument ();
				DomElement r = d.create_element ("root");
				assert (r is DomElement);
				assert (r.local_name == "root");
				assert (r.tag_name == "root");
				assert (r.node_type == DomNode.NodeType.ELEMENT_NODE);
				assert (r.node_name == "root");
				d.child_nodes.add (r);
				assert (d.document_element != null);
				assert (d.document_element.node_name == "root");
				//Test.message ("r string: "+d.document_element.to_string ());
				//assert (d.document_element.to_string () == "<root/>");
			} catch {assert_not_reached ();}
		});
		Test.add_func ("/gxml/gom-document/construct_from_path_error", () => {
				DomDocument doc;
				try {
				GLib.Test.message ("invalid file...");
					// file does not exist
					doc = new GDocument.from_path ("/tmp/asdfjlkansdlfjl");
					assert_not_reached ();
				} catch {}

				try {
					// file exists, but is not XML (it's a directory!)
					doc = new GDocument.from_path ("/tmp/");
					assert_not_reached ();
				} catch  {}
				try {
					doc = new GDocument.from_path ("test_invalid.xml");
					assert_not_reached ();
				} catch {}
			});
		Test.add_func ("/gxml/gom-document/construct_from_stream", () => {
				var fin = File.new_for_path (GXmlTestConfig.TEST_DIR + "/test.xml");
				assert (fin.query_exists ());
				try {
					var instream = fin.read (null);
					var doc = new GDocument.from_stream (instream);
					assert (doc != null);
					// TODO: CHECKS
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/gom-document/gfile/local", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test-file.xml");
				if (f.query_exists ()) f.delete ();
				var s = new GLib.StringBuilder ();
				s.append ("""<document_element />""");
				var d = new GDocument.from_string (s.str);
				Test.message ("Saving to file: "+f.get_uri ()+d.to_string ());
				d.save_as (f);
				assert (f.query_exists ());
				var d2 = new GDocument.from_file (f);
				assert (d2 != null);
				assert (d2.document_element != null);
				assert (d2.document_element.node_name == "document_element");
				f.delete ();
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
			});
		Test.add_func ("/gxml/gom-document/gfile/remote", () => {
			try {
				var rf = GLib.File.new_for_uri ("https://git.gnome.org/browse/gxml/plain/gxml.doap");
				if (!rf.query_exists ()) {
					GLib.message ("No remote file available. Skiping...");
					return;
				}
				var d = new GDocument.from_file (rf);
				assert (d != null);
				assert (d.document_element != null);
				assert (d.document_element.node_name == "Project");
				bool fname, fshordesc, fdescription, fhomepage;
				fname = fshordesc = fdescription = fhomepage = false;
				foreach (DomNode n in d.document_element.child_nodes) {
					if (n.node_name == "name") fname = true;
					if (n.node_name == "shortdesc") fshordesc = true;
					if (n.node_name == "description") fdescription = true;
					if (n.node_name == "homepage") fhomepage = true;
				}
				assert (fname);
				assert (fshordesc);
				assert (fdescription);
				assert (fhomepage);
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/xml.doap");
				d.save_as (f);
				assert (f.query_exists ());
				f.delete ();
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-document/construct_from_stream_error", () => {
				File fin;
				InputStream instream;
				FileIOStream iostream;
				DomDocument doc;

				try {
					fin = File.new_tmp ("gxml.XXXXXX", out iostream);
					doc = new GDocument.from_stream (iostream.input_stream);
					GLib.message ("Passed parse error stream");
					assert_not_reached ();
				} catch  {}
			});
		Test.add_func ("/gxml/gom-document/construct_from_string", () => {
			try {
				string xml;
				DomDocument doc;
				GXml.DomNode document_element;

				xml = "<Fruits><Apple></Apple><Orange></Orange></Fruits>";
				doc = new GomDocument.from_string (xml);
				assert (doc.document_element != null);
				document_element = doc.document_element;
				assert (document_element.node_name == "Fruits");
				assert (document_element.child_nodes.size == 2);
				var n1 = document_element.child_nodes.get (0);
				assert (n1 != null);
				assert (n1.node_name == "Apple");
			} catch { assert_not_reached (); }
			});
		Test.add_func ("/gxml/gom-document/construct_from_string_no_document_element", () => {
			try {
				string xml;
				DomDocument doc;
				GXml.DomNode document_element;

				xml = """<?xml version="1.0"?>""";
				doc = new GDocument.from_string (xml);
				assert_not_reached ();
			} catch {}
			});
		Test.add_func ("/gxml/gom-document/construct_from_string_invalid", () => {
			try {
				string xml;
				DomDocument doc;
				GXml.DomNode document_element;

				xml = "";
				doc = new GDocument.from_string (xml);
			} catch { assert_not_reached (); }
			});
		Test.add_func ("/gxml/gom-document/save", () => {
				DomDocument doc;
				int exit_status;

				try {
					doc = new GDocument.from_string ("<document_element />");
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/test_out_path.xml");
					(doc as GDocument).save_as (f);
					assert (f.query_exists ());
					f.delete ();
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/gom-document/save_error", () => {
				DomDocument doc;

				try {
					doc = new GDocument.from_string ("<document_element />");
					(doc as GDocument).save_as (GLib.File.new_for_path ("/tmp/a/b/c/d/e/f/g/h/i"));
					assert_not_reached ();
				} catch {}
			});

		Test.add_func ("/gxml/gom-document/create_element", () => {
			try {
				DomDocument doc = new GDocument.from_string ("<document_element />");
				GElement elem = null;

				elem = (GElement) doc.create_element ("Banana");
				assert (elem.tag_name == "Banana");
				assert (elem.tag_name != "banana");

				elem = (GElement) doc.create_element ("ØÏØÏØ¯ÏØÏ  ²øœ³¤ïØ£");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_text_node", () => {
			try {
				DomDocument doc = new GDocument.from_string ("<document_element />");
				DomText text = (DomText) doc.create_text_node ("Star of my dreams");
				assert (text is GomText);
				assert (text is DomText);

				assert (text.node_name == "#text");
				assert (text.node_value == "Star of my dreams");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_comment", () => {
			try {
				DomDocument doc = new GDocument.from_string ("<document_element />");
				DomComment comment = (GXml.DomComment) doc.create_comment ("Ever since the day we promised.");

				assert (comment.node_name == "#comment");
				assert (comment.data == "Ever since the day we promised.");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_processing_instruction", () => {
			try {
				DomDocument doc = new GomDocument.from_string ("<document_element />");
				DomProcessingInstruction instruction = doc.create_processing_instruction ("target", "data");
				assert (instruction is GomProcessingInstruction);
				assert (instruction is DomProcessingInstruction);
				assert (instruction.node_name == "target");
				assert (instruction.node_value == "data");
				GLib.message ("Target:"+instruction.node_name);
				GLib.message ("Dat:"+instruction.node_value);
				assert (instruction.data == "data");
				assert (instruction.target != null);
				assert_not_reached ();
				assert (instruction.target == "target");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_attribute", () => {
			try {
				DomDocument doc = new GDocument.from_string ("<document_element />");
				assert (doc.document_element != null);
				((DomElement) doc.document_element).set_attribute ("attrname", "attrvalue");
				//Test.message ("DOC:"+doc.to_string ());
				var attr = ((DomElement) doc.document_element).get_attribute ("attrname");
				Test.message ("Attr value: "+attr);
				assert (attr != null);
				assert (attr == "attrvalue");
				//
				//Test.message ("DOC libxml2:"+doc.libxml_to_string ());
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/to_string/basic", () => {
			try {
				DomDocument doc = new GDocument.from_string ("<?xml version=\"1.0\"?>
<Sentences><Sentence lang=\"en\">I like the colour blue.</Sentence><Sentence lang=\"de\">Ich liebe die T&#xFC;r.</Sentence><Authors><Author><Name>Fred</Name><Email>fweasley@hogwarts.co.uk</Email></Author><Author><Name>George</Name><Email>gweasley@hogwarts.co.uk</Email></Author></Authors></Sentences>");
				string s1 = "";//doc.to_string ();
				string[] cs1 = s1.split ("\n");
				Test.message (s1);
				assert (cs1[0] == "<?xml version=\"1.0\"?>");
				assert (cs1[1] == "<Sentences><Sentence lang=\"en\">I like the colour blue.</Sentence><Sentence lang=\"de\">Ich liebe die T&#xFC;r.</Sentence><Authors><Author><Name>Fred</Name><Email>fweasley@hogwarts.co.uk</Email></Author><Author><Name>George</Name><Email>gweasley@hogwarts.co.uk</Email></Author></Authors></Sentences>");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/to_string/extended", () => {
			try {
				var d = new GDocument.from_path (GXmlTestConfig.TEST_DIR+"/gom-document-read.xml");
				Test.message (d.to_string ());
				assert (d.document_element != null);
				assert (d.document_element.node_name == "DataTypeTemplates");
				Test.message (d.document_element.child_nodes.size.to_string ());
				assert (d.document_element.child_nodes[0] is GXml.Text);
				assert (d.document_element.child_nodes[1] is GXml.Element);
				assert (d.document_element.child_nodes[2] is GXml.Text);
				assert (d.document_element.child_nodes[2].node_value == "\n");
				assert (d.document_element.child_nodes.size == 3);
				assert (d.document_element.child_nodes[1].node_name == "DAType");
				assert (d.document_element.child_nodes[1].child_nodes.size == 3);
				assert (d.document_element.child_nodes[1].child_nodes[1].node_name == "BDA");
				assert (d.document_element.child_nodes[1].child_nodes[1].child_nodes.size == 3);
				assert (d.document_element.child_nodes[1].child_nodes[1].child_nodes[1].node_name == "Val");
				assert (d.document_element.child_nodes[1].child_nodes[1].child_nodes[1].child_nodes.size == 1);
				assert (d.document_element.child_nodes[1].child_nodes[1].child_nodes[1].child_nodes[0] is GXml.Text);
				assert (d.document_element.child_nodes[1].child_nodes[1].child_nodes[1].child_nodes[0].node_value == "status_only");
			} catch (GLib.Error e) { GLib.message ("ERROR: "+e.message); assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/namespace", () => {
			try {
				DomDocument doc = new GDocument.from_string ("<document_element><child/></document_element>");
				doc.document_element.set_attribute_ns ("http://www.gnome.org/GXml","xmlns:gxml","http://www.gnome.org/GXml");
				assert (doc.document_element != null);
				assert (doc.document_element.namespace_uri != null);
				assert (doc.document_element.namespace_uri == "http://www.gnome.org/GXml");
				assert (doc.document_element.prefix != null);
				assert (doc.document_element.prefix == "gxml");
				assert (doc.document_element.child_nodes != null);
				assert (doc.document_element.child_nodes.size == 1);
				var c = doc.document_element.child_nodes[0] as DomElement;
				assert (c is DomElement);
				c.set_attribute_ns ("http://www.gnome.org/GXml2","gxml2", "http://www.gnome.org/GXml2");
				assert (c.prefix == "gxml2");
				assert (c.namespace_uri == "http://www.gnome.org/GXml2");
				c.set_attribute_ns ("http://www.gnome.org/GXml2","gxml:prop","val");
				var p = (c as DomElement).get_attribute_ns ("http://www.gnome.org/GXml2", "prop");
				assert (p == null);
				assert (p == "val");
			} catch (GLib.Error e) {
				GLib.message ("ERROR: "+ e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-document/parent", () => {
			var doc = new GomDocument ();
			assert (doc.parent_node == null);
		});
	}
}
