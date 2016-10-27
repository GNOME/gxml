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
				var d = new GomDocument ();
				var root = d.create_element ("root");
				d.children_nodes.add (root);
				assert (d.root != null);
				Test.message ("Root name: "+d.root.name);
				assert (d.root.name == "root");
				Test.message ("Root string: "+d.root.to_string ());
				assert (d.root.to_string () == "<root/>");
			} catch {assert_not_reached ();}
		});
		Test.add_func ("/gxml/gom-document/construct_from_path_error", () => {
				GomDocument doc;
				try {
				GLib.Test.message ("invalid file...");
					// file does not exist
					doc = new GomDocument.from_path ("/tmp/asdfjlkansdlfjl");
					assert_not_reached ();
				} catch {}

				try {
					// file exists, but is not XML (it's a directory!)
					doc = new GomDocument.from_path ("/tmp/");
					assert_not_reached ();
				} catch  {}
				try {
					doc = new GomDocument.from_path ("test_invalid.xml");
					assert_not_reached ();
				} catch {}
			});
		Test.add_func ("/gxml/gom-document/construct_from_stream", () => {
				var fin = File.new_for_path (GXmlTestConfig.TEST_DIR + "/test.xml");
				assert (fin.query_exists ());
				try {
					var instream = fin.read (null);
					var doc = new GomDocument.from_stream (instream);
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
				s.append ("""<root />""");
				var d = new GomDocument.from_string (s.str);
				Test.message ("Saving to file: "+f.get_uri ()+d.to_string ());
				d.save_as (f);
				assert (f.query_exists ());
				var d2 = new GomDocument.from_file (f);
				assert (d2 != null);
				assert (d2.root != null);
				assert (d2.root.name == "root");
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
				var d = new GomDocument.from_file (rf);
				assert (d != null);
				assert (d.root != null);
				assert (d.root.name == "Project");
				bool fname, fshordesc, fdescription, fhomepage;
				fname = fshordesc = fdescription = fhomepage = false;
				foreach (GXml.Node n in d.root.children_nodes) {
					if (n.name == "name") fname = true;
					if (n.name == "shortdesc") fshordesc = true;
					if (n.name == "description") fdescription = true;
					if (n.name == "homepage") fhomepage = true;
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
				GomDocument doc;

				try {
					fin = File.new_tmp ("gxml.XXXXXX", out iostream);
					doc = new GomDocument.from_stream (iostream.input_stream);
					GLib.message ("Passed parse error stream");
					assert_not_reached ();
				} catch  {}
			});
		Test.add_func ("/gxml/gom-document/construct_from_string", () => {
			try {
				string xml;
				GomDocument doc;
				GXml.Node root;

				xml = "<Fruits><Apple></Apple><Orange></Orange></Fruits>";
				doc = new GomDocument.from_string (xml);
				assert (doc.root != null);
				root = doc.root;
				assert (root.name == "Fruits");
				assert (root.children_nodes.size == 2);
				var n1 = root.children_nodes.get (0);
				assert (n1 != null);
				assert (n1.name == "Apple");
			} catch { assert_not_reached (); }
			});
		Test.add_func ("/gxml/gom-document/construct_from_string_no_root", () => {
			try {
				string xml;
				GomDocument doc;
				GXml.Node root;

				xml = """<?xml version="1.0"?>""";
				doc = new GomDocument.from_string (xml);
				assert_not_reached ();
			} catch {}
			});
		Test.add_func ("/gxml/gom-document/construct_from_string_invalid", () => {
			try {
				string xml;
				GomDocument doc;
				GXml.Node root;

				xml = "";
				doc = new GomDocument.from_string (xml);
			} catch { assert_not_reached (); }
			});
		Test.add_func ("/gxml/gom-document/save", () => {
				GomDocument doc;
				int exit_status;

				try {
					doc = new GomDocument.from_string ("<root />");
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/test_out_path.xml");
					doc.save_as (f);
					assert (f.query_exists ());
					f.delete ();
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/gom-document/save_error", () => {
				GomDocument doc;

				try {
					doc = new GomDocument.from_string ("<root />");
					doc.save_as (GLib.File.new_for_path ("/tmp/a/b/c/d/e/f/g/h/i"));
					assert_not_reached ();
				} catch {}
			});

		Test.add_func ("/gxml/gom-document/create_element", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				GElement elem = null;

				elem = (GElement) doc.create_element ("Banana");
				assert (elem.tag_name == "Banana");
				assert (elem.tag_name != "banana");

				elem = (GElement) doc.create_element ("ØÏØÏØ¯ÏØÏ  ²øœ³¤ïØ£");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_text_node", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				Text text = (Text) doc.create_text ("Star of my dreams");

				assert (text.name == "#text");
				assert (text.value == "Star of my dreams");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_comment", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				Comment comment = (GXml.Comment) doc.create_comment ("Ever since the day we promised.");

				assert (comment.name == "#comment");
				assert (comment.str == "Ever since the day we promised.");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_cdata_section", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				CDATA cdata = (CDATA) doc.create_cdata ("put in real cdata");

				assert (cdata.name == "#cdata-section");
				assert (cdata.value == "put in real cdata");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_processing_instruction", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				ProcessingInstruction instruction = (ProcessingInstruction) doc.create_pi ("target", "data");

				assert (instruction.name == "target");
				assert (instruction.target == "target");
				assert (instruction.data == "data");
				assert (instruction.value == "data");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/create_attribute", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				assert (doc.root != null);
				((GElement) doc.root).set_attr ("attrname", "attrvalue");
				Test.message ("DOC:"+doc.to_string ());
				var attr = ((GElement) doc.root).get_attr ("attrname");
				Test.message ("Attr name: "+attr.name);
				Test.message ("Attr value: "+attr.value);
				assert (attr != null);
				assert (attr is GAttribute);
				assert (attr.name == "attrname");
				assert (attr.value == "attrvalue");
				//
				//Test.message ("DOC libxml2:"+doc.libxml_to_string ());
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/to_string/basic", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<?xml version=\"1.0\"?>
<Sentences><Sentence lang=\"en\">I like the colour blue.</Sentence><Sentence lang=\"de\">Ich liebe die T&#xFC;r.</Sentence><Authors><Author><Name>Fred</Name><Email>fweasley@hogwarts.co.uk</Email></Author><Author><Name>George</Name><Email>gweasley@hogwarts.co.uk</Email></Author></Authors></Sentences>");
				string s1 = doc.to_string ();
				string[] cs1 = s1.split ("\n");
				Test.message (s1);
				assert (cs1[0] == "<?xml version=\"1.0\"?>");
				assert (cs1[1] == "<Sentences><Sentence lang=\"en\">I like the colour blue.</Sentence><Sentence lang=\"de\">Ich liebe die T&#xFC;r.</Sentence><Authors><Author><Name>Fred</Name><Email>fweasley@hogwarts.co.uk</Email></Author><Author><Name>George</Name><Email>gweasley@hogwarts.co.uk</Email></Author></Authors></Sentences>");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/to_string/extended", () => {
			try {
				var d = new GomDocument.from_path (GXmlTestConfig.TEST_DIR+"/gom-document-read.xml");
				Test.message (d.to_string ());
				assert (d.root != null);
				assert (d.root.name == "DataTypeTemplates");
				Test.message (d.root.children_nodes.size.to_string ());
				assert (d.root.children_nodes[0] is GXml.Text);
				assert (d.root.children_nodes[1] is GXml.Element);
				assert (d.root.children_nodes[2] is GXml.Text);
				assert (d.root.children_nodes[2].value == "\n");
				assert (d.root.children_nodes.size == 3);
				assert (d.root.children_nodes[1].name == "DAType");
				assert (d.root.children_nodes[1].children_nodes.size == 3);
				assert (d.root.children_nodes[1].children_nodes[1].name == "BDA");
				assert (d.root.children_nodes[1].children_nodes[1].children_nodes.size == 3);
				assert (d.root.children_nodes[1].children_nodes[1].children_nodes[1].name == "Val");
				assert (d.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes.size == 1);
				assert (d.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes[0] is GXml.Text);
				assert (d.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes[0].value == "status_only");
			} catch (GLib.Error e) { GLib.message ("ERROR: "+e.message); assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/libxml_to_string", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<?xml version=\"1.0\"?>
<Sentences><Sentence lang=\"en\">I like the colour blue.</Sentence><Sentence lang=\"de\">Ich liebe die T&#xFC;r.</Sentence><Authors><Author><Name>Fred</Name><Email>fweasley@hogwarts.co.uk</Email></Author><Author><Name>George</Name><Email>gweasley@hogwarts.co.uk</Email></Author></Authors></Sentences>");
				string s1 = doc.libxml_to_string ();
				string[] cs1 = s1.split ("\n");
				Test.message (s1);
				assert (cs1[0] == "<?xml version=\"1.0\"?>");
				assert (cs1[1] == "<Sentences><Sentence lang=\"en\">I like the colour blue.</Sentence><Sentence lang=\"de\">Ich liebe die T&#xFC;r.</Sentence><Authors><Author><Name>Fred</Name><Email>fweasley@hogwarts.co.uk</Email></Author><Author><Name>George</Name><Email>gweasley@hogwarts.co.uk</Email></Author></Authors></Sentences>");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/gom-document/namespace", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root><child/></root>");
				doc.set_namespace ("http://www.gnome.org/GXml","gxml");
				assert (doc.root != null);
				assert (doc.root.namespaces != null);
				assert (doc.root.namespaces.size == 1);
				assert (doc.root.namespaces[0].prefix == "gxml");
				assert (doc.root.namespaces[0].uri == "http://www.gnome.org/GXml");
				assert (doc.root.children_nodes != null);
				assert (doc.root.children_nodes.size == 1);
				var c = doc.root.children_nodes[0];
				c.set_namespace ("http://www.gnome.org/GXml2","gxml2");
				assert (c.namespaces != null);
				assert (c.namespaces.size == 1);
				assert (c.namespaces[0].prefix == "gxml2");
				assert (c.namespaces[0].uri == "http://www.gnome.org/GXml2");
				(c as Element).set_attr ("gxml:prop","val");
				var p = (c as Element).get_attr ("gxml:prop");
				assert (p == null);
				Test.message ("ROOT: "+doc.root.to_string ());
				assert (doc.root.to_string () == "<root xmlns:gxml=\"http://www.gnome.org/GXml\"><child xmlns:gxml2=\"http://www.gnome.org/GXml2\"/></root>");
				(c as Element).set_ns_attr (doc.root.namespaces[0].uri, "prop", "Ten");
				Test.message ("ROOT: "+doc.root.to_string ());
				assert (c.attrs.size == 1);
				var pt = c.attrs.get ("prop");
				assert (pt != null);
				var pt2 = (c as Element).get_ns_attr ("prop", doc.root.namespaces[0].uri);
				GLib.message ("ROOT: "+doc.root.to_string ());
				assert (doc.root.to_string () == "<root xmlns:gxml=\"http://www.gnome.org/GXml\"><child xmlns:gxml2=\"http://www.gnome.org/GXml2\" gxml:prop=\"Ten\"/></root>");
			} catch (GLib.Error e) {
				GLib.message ("ERROR: "+ e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-document/parent", () => {
			var doc = new GomDocument ();
			assert (doc.parent == null);
		});
	}
}
