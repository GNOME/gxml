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

class DocumentTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/document/doctype", () => {
				// STUB
				/*
				xDocument doc = new xDocument.from_path ("/tmp/dtdtest2.xml");
				// xDocument doc = get_doc ();
				DocumentType type = doc.doctype;
				HashTable<string,Entity> entities = type.entities;
				assert_not_reached ();
				// TODO: need to find an example file with a DTD that actually sets entities, annotations
				// TODO: fill in
				*/
			});
		Test.add_func ("/gxml/document/implementation", () => {
				xDocument doc = get_doc ();

				Implementation impl = doc.implementation;

				assert (impl.has_feature ("xml") == true);
				assert (impl.has_feature ("xml", "1.0") == true);
				assert (impl.has_feature ("xml", "2.0") == false);
				assert (impl.has_feature ("html") == false);
				assert (impl.has_feature ("nonsense") == false);
			});
		Test.add_func ("/gxml/document/document_element", () => {
				xDocument doc = get_doc ();
				xElement root = doc.document_element;

				assert (root.node_name == "Sentences");
				assert (root.has_child_nodes ());
			});

		Test.add_func ("/gxml/document/construct_from_path", () => {
				xDocument doc = get_doc ();

				check_contents (doc);
			});
		Test.add_func ("/gxml/document/construct_from_path_error", () => {
				xDocument doc;
				try {
				GLib.Test.message ("invalid file...");
					// file does not exist
					doc = new xDocument.from_path ("/tmp/asdfjlkansdlfjl");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				}
				test_error (DomException.INVALID_DOC);
				GLib.Test.message ("invalid is directory...");

				try {
					// file exists, but is not XML (it's a directory!)
					doc = new xDocument.from_path ("/tmp/");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				}
				test_error (DomException.INVALID_DOC);
				GLib.Test.message ("invalid xml...");
				try {
					doc = new xDocument.from_path ("test_invalid.xml");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				}
				test_error (DomException.INVALID_DOC);
			});
		Test.add_func ("/gxml/document/construct_from_stream", () => {
				var fin = File.new_for_path (GXmlTestConfig.TEST_DIR + "/test.xml");
				assert (fin.query_exists ());
				try {
					var instream = fin.read (null);
					var doc = new xDocument.from_stream (instream);
					assert (doc != null);
					check_contents (doc);
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/gfile/local", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test-file.xml");
				if (f.query_exists ()) f.delete ();
				var s = new GLib.StringBuilder ();
				s.append ("""<root />""");
				var d = new xDocument.from_string (s.str);
				Test.message ("Saving to file: "+f.get_uri ()+d.to_string ());
				d.save_as (f);
				assert (f.query_exists ());
				var d2 = new xDocument.from_gfile (f);
				assert (d2 != null);
				assert (d2.root != null);
				assert (d2.root.name == "root");
				f.delete ();
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
			});
		Test.add_func ("/gxml/document/gfile/remote", () => {
			try {
				var net = GLib.NetworkMonitor.get_default ();
				if (!net.network_available) return;
				var rf = GLib.File.new_for_uri ("https://git.gnome.org/browse/gxml/plain/gxml.doap");
				assert (rf.query_exists ());
				var d = new xDocument.from_gfile (rf);
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
		Test.add_func ("/gxml/document/construct_from_stream_error", () => {
				File fin;
				InputStream instream;
				FileIOStream iostream;
				xDocument doc;

				try {
					fin = File.new_tmp ("gxml.XXXXXX", out iostream);
					doc = new xDocument.from_stream (iostream.input_stream);
					GLib.message ("Passed parse error stream");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				} catch (GLib.Error e) {
					GLib.message ("Test encountered unexpected error '%s'\n", e.message);
					assert_not_reached ();
				}
				test_error (DomException.INVALID_DOC);
			});
		Test.add_func ("/gxml/document/construct_from_string", () => {
				string xml;
				xDocument doc;
				GXml.xNode root;

				xml = "<Fruits><Apple></Apple><Orange></Orange></Fruits>";
				doc = new xDocument.from_string (xml);

				root = doc.document_element;
				assert (root.node_name == "Fruits");
				assert (root.has_child_nodes () == true);
				assert (root.first_child.node_name == "Apple");
				assert (root.last_child.node_name == "Orange");
			});
		Test.add_func ("/gxml/document/construct_from_string_no_root", () => {
			try {
				string xml;
				xDocument doc;
				GXml.xNode root;

				xml = """<?xml version="1.0"?>""";
				doc = new xDocument.from_string (xml);

				assert (doc != null);
				root = doc.document_element;
				assert (root == null);
			} catch (GLib.Error e) {
				GLib.message ("Error: "+ e.message);
				assert_not_reached ();
			}
			});
		Test.add_func ("/gxml/document/construct_from_string_invalid", () => {
				string xml;
				xDocument doc;
				GXml.xNode root;

				xml = "";
				doc = new xDocument.from_string (xml);

				assert (doc != null);
				root = doc.document_element;
				assert (root == null);
			});
		Test.add_func ("/gxml/document/save", () => {
				xDocument doc;
				int exit_status;

				try {
					doc = get_doc ();
					/* TODO: /tmp because of 'make distcheck' being
					   readonly, want to use GXmlTest.get_test_dir () if
					   readable, though */
					doc.save_to_path (GLib.Environment.get_tmp_dir () + "/test_out_path.xml");

					Process.spawn_sync (null,
							    { "/usr/bin/diff",
							      GLib.Environment.get_tmp_dir () + "/test_out_path.xml",
							      GXmlTest.get_test_dir () + "/test_out_path_expected.xml" },
							    null, 0, null, null /* stdout */, null /* stderr */, out exit_status);
					assert (exit_status == 0);
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/save_error", () => {
				xDocument doc;

				try {
					doc = get_doc ();
					doc.save_to_path ("/tmp/a/b/c/d/e/f/g/h/i");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.WRITER);
				}
				test_error (DomException.X_OTHER);
			});

		Test.add_func ("/gxml/document/save_to_stream", () => {
				try {
					File fin;
					File fout;
					InputStream instream;
					OutputStream outstream;
					xDocument doc;
					int exit_status;

				        fin = File.new_for_path (GXmlTest.get_test_dir () + "/test.xml");
					instream = fin.read (null);

					fout = File.new_for_path (GLib.Environment.get_tmp_dir () + "/test_out_stream.xml");
					// OutputStream outstream = fout.create (FileCreateFlags.REPLACE_DESTINATION, null); // REPLACE_DESTINATION doesn't work like I thought it would?
					outstream = fout.replace (null, true, FileCreateFlags.REPLACE_DESTINATION, null);

					doc = new xDocument.from_stream (instream);
					doc.save_to_stream (outstream);

					Process.spawn_sync (null,
			                                    { "/usr/bin/diff",
							      GLib.Environment.get_tmp_dir () + "/test_out_stream.xml",
							      GXmlTest.get_test_dir () + "/test_out_stream_expected.xml" },
							    null, 0, null, null /* stdout */, null /* stderr */, out exit_status);

					assert (exit_status == 0);
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/save_to_stream_error", () => {
				try {
					File fout;
					FileIOStream iostream;
					OutputStream outstream;
					xDocument doc;
					int exit_status;

					doc = GXmlTest.get_doc ();

					fout = File.new_tmp ("gxml.XXXXXX", out iostream);
					outstream = fout.replace (null, true, FileCreateFlags.REPLACE_DESTINATION, null);
					outstream.close ();

					doc.save_to_stream (outstream);
					assert_not_reached ();
				} catch (GLib.Error e) {
					assert (e is GXml.Error.WRITER);
				}
				test_error (DomException.X_OTHER);
			});
		Test.add_func ("/gxml/document/create_element", () => {
				xDocument doc = get_doc ();
				xElement elem = null;

				elem = (xElement) doc.create_element ("Banana");
				test_error (DomException.NONE);
				assert (elem.tag_name == "Banana");
				assert (elem.tag_name != "banana");

				elem = (xElement) doc.create_element ("ØÏØÏØ¯ÏØÏ  ²øœ³¤ïØ£");
				test_error (DomException.INVALID_CHARACTER);
				// assert (elem == null); // TODO: decide what we want returned on DomExceptions
			});
		Test.add_func ("/gxml/document/create_document_fragment", () => {
				xDocument doc = get_doc ();
				DocumentFragment fragment = doc.create_document_fragment ();

				// TODO: can we set XML in the content, and actually have that translate into real libxml2 underlying nodes?
				xElement percy = (xElement) doc.create_element ("Author");
				xElement percy_name = (xElement) doc.create_element ("Name");
				xElement percy_email = (xElement) doc.create_element ("Email");
				percy_name.content = "Percy";
				percy_email.content = "pweasley@hogwarts.co.uk";
				percy.append_child (percy_name);
				percy.append_child (percy_email);
				fragment.append_child (percy);

				xElement ginny = (xElement) doc.create_element ("Author");
				xElement ginny_name = (xElement) doc.create_element ("Name");
				xElement ginny_email = (xElement) doc.create_element ("Email");
				ginny_name.content = "Ginny";
				ginny_email.content = "weasleyg@hogwarts.co.uk";
				ginny.append_child (ginny_name);
				ginny.append_child (ginny_email);
				fragment.append_child (ginny);

				xNodeList authors_list = doc.get_elements_by_tag_name ("Authors");
				assert (authors_list.length == 1);
				xElement authors = (xElement)authors_list.item (0);
				assert (authors.get_elements_by_tag_name ("Author").length == 2);
				assert (fragment.child_nodes.length == 2);

				assert (doc.to_string () == "<?xml version=\"1.0\"?>
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
");

				authors.append_child (fragment);
				if (authors.get_elements_by_tag_name ("Author").length != 4) {
					stdout.printf (@"Authors: length error. Expected 4, got $(authors.get_elements_by_tag_name ("Author").length)\n'");
					assert_not_reached ();
				}

				string expected = "<?xml version=\"1.0\"?>
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
  <Author><Name>Percy</Name><Email>pweasley@hogwarts.co.uk</Email></Author><Author><Name>Ginny</Name><Email>weasleyg@hogwarts.co.uk</Email></Author></Authors>
</Sentences>
";
				// TODO: want to find a way to flattern the string, strip whitespace
				assert (doc.to_string () == expected);
			});
		Test.add_func ("/gxml/document/create_text_node", () => {
				xDocument doc = get_doc ();
				xText text = doc.create_text_node ("Star of my dreams");

				assert (text.node_name == "#text");
				assert (text.node_value == "Star of my dreams");
			});
		Test.add_func ("/gxml/document/create_comment", () => {
				xDocument doc = get_doc ();
				Comment comment = (GXml.Comment) doc.create_comment ("Ever since the day we promised.");

				assert (comment.name == "#comment");
				assert (comment.str == "Ever since the day we promised.");
			});
		Test.add_func ("/gxml/document/create_cdata_section", () => {
				xDocument doc = get_doc ();
				xCDATASection cdata = doc.create_cdata_section ("put in real cdata");

				assert (cdata.node_name == "#cdata-section");
				assert (cdata.node_value == "put in real cdata");
			});
		Test.add_func ("/gxml/document/create_processing_instruction", () => {
				xDocument doc = get_doc ();
				xProcessingInstruction instruction = doc.create_processing_instruction ("target", "data");

				assert (instruction.node_name == "target");
				assert (instruction.target == "target");
				assert (instruction.data == "data");
				assert (instruction.node_value == "data");
			});
		Test.add_func ("/gxml/document/create_attribute", () => {
				xDocument doc = get_doc ();
				xAttr attr = doc.create_attribute ("attrname");

				assert (attr.name == "attrname");
				assert (attr.node_name == "attrname");
				assert (attr.node_value == "");
			});
		Test.add_func ("/gxml/document/create_entity_reference", () => {
				xDocument doc = get_doc ();
				EntityReference entity = doc.create_entity_reference ("entref");

				assert (entity.node_name == "entref");
				// TODO: think of at least one other smoke test
			});
		Test.add_func ("/gxml/document/get_elements_by_tag_name", () => {
				xDocument doc = get_doc ();
				xNodeList elems = doc.get_elements_by_tag_name ("Email");

				assert (elems.length == 2);
				assert (((xElement)elems.item (0)).content == "fweasley@hogwarts.co.uk");
				/* more thorough test exists in xElement, since right now
				   xDocument uses that one */
			});
		Test.add_func ("/gxml/document/parent", () => {
				var doc = new xDocument ();
				assert (doc.parent == null);
			});
		Test.add_func ("/gxml/document/to_string", () => {
				xDocument doc = get_doc ();
				assert (doc.to_string () == "<?xml version=\"1.0\"?>
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
");
				// TODO: want to test with format on and off

			});
	}

	private static void check_contents (xDocument test_doc) {
		xElement root = test_doc.document_element;

		assert (root.node_name == "Sentences");
		assert (root.has_child_nodes () == true);

		xNodeList authors = test_doc.get_elements_by_tag_name ("Author");
		assert (authors.length == 2);

		assert (test_doc.to_string () == "<?xml version=\"1.0\"?>
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
");
	}

	public static void print_node (GXml.xNode node) {

		if (node.node_type != 3)
			GLib.stdout.printf ("<%s", node.node_name);
		NamedAttrMap attrs = node.attributes;
		for (int i = 0; i < attrs.length; i++) {
			xAttr attr = attrs.item (i);
			GLib.stdout.printf (" %s=\"%s\"", attr.name, attr.value);
		}

		GLib.stdout.printf (">");
		if (node.node_value != null)
			GLib.stdout.printf ("%s", node.node_value);
		foreach (GXml.xNode child in node.child_nodes) {
			// TODO: want a stringification method for Nodes?
			print_node (child);
		}
		if (node.node_type != 3)
			GLib.stdout.printf ("</%s>", node.node_name);
	}
}
