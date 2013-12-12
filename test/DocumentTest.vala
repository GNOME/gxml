/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class DocumentTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/document/doctype", () => {
				// STUB
				/*
				Document doc = new Document.from_path ("/tmp/dtdtest2.xml");
				// Document doc = get_doc ();
				DocumentType type = doc.doctype;
				HashTable<string,Entity> entities = type.entities;
				assert_not_reached ();
				// TODO: need to find an example file with a DTD that actually sets entities, annotations
				// TODO: fill in
				*/
			});
		Test.add_func ("/gxml/document/implementation", () => {
				Document doc = get_doc ();

				Implementation impl = doc.implementation;

				assert (impl.has_feature ("xml") == true);
				assert (impl.has_feature ("xml", "1.0") == true);
				assert (impl.has_feature ("xml", "2.0") == false);
				assert (impl.has_feature ("html") == false);
				assert (impl.has_feature ("nonsense") == false);
			});
		Test.add_func ("/gxml/document/document_element", () => {
				Document doc = get_doc ();
				Element root = doc.document_element;

				assert (root.node_name == "Sentences");
				assert (root.has_child_nodes ());
			});

		Test.add_func ("/gxml/document/construct_from_path", () => {
				Document doc = get_doc ();

				check_contents (doc);
			});
		Test.add_func ("/gxml/document/construct_from_path_error", () => {
				Document doc;
				try {
					// file does not exist
					doc = new Document.from_path ("/tmp/asdfjlkansdlfjl");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				}
				test_error (DomException.INVALID_DOC);

				try {
					// file exists, but is not XML (it's a directory!)
					doc = new Document.from_path ("/tmp/");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				}
				test_error (DomException.INVALID_DOC);

				try {
					doc = new Document.from_path ("test_invalid.xml");
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				}
				test_error (DomException.INVALID_DOC);
			});
		Test.add_func ("/gxml/document/construct_from_stream", () => {
				File fin;
				InputStream instream;
				Document doc;

				try {
					fin = File.new_for_path (GXmlTest.get_test_dir () + "/test.xml");
					instream = fin.read (null);
					/* TODO: test GCancellable */

					doc = new Document.from_stream (instream);

					check_contents (doc);
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/construct_from_stream_error", () => {
				File fin;
				InputStream instream;
				FileIOStream iostream;
				Document doc;

				try {
					fin = File.new_tmp ("gxml.XXXXXX", out iostream);
					instream = fin.read (null);
					doc = new Document.from_stream (instream);
					assert_not_reached ();
				} catch (GXml.Error e) {
					assert (e is GXml.Error.PARSER);
				} catch (GLib.Error e) {
					stderr.printf ("Test encountered unexpected error '%s'\n", e.message);
					assert_not_reached ();
				}
				test_error (DomException.INVALID_DOC);
			});
		Test.add_func ("/gxml/document/construct_from_string", () => {
				string xml;
				Document doc;
				GXml.Node root;

				xml = "<Fruits><Apple></Apple><Orange></Orange></Fruits>";
				doc = new Document.from_string (xml);

				root = doc.document_element;
				assert (root.node_name == "Fruits");
				assert (root.has_child_nodes () == true);
				assert (root.first_child.node_name == "Apple");
				assert (root.last_child.node_name == "Orange");
			});
		Test.add_func ("/gxml/document/save", () => {
				Document doc;
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
				Document doc;

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
					Document doc;
					int exit_status;

				        fin = File.new_for_path (GXmlTest.get_test_dir () + "/test.xml");
					instream = fin.read (null);

					fout = File.new_for_path (GLib.Environment.get_tmp_dir () + "/test_out_stream.xml");
					// OutputStream outstream = fout.create (FileCreateFlags.REPLACE_DESTINATION, null); // REPLACE_DESTINATION doesn't work like I thought it would?
					outstream = fout.replace (null, true, FileCreateFlags.REPLACE_DESTINATION, null);

					doc = new Document.from_stream (instream);
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
					Document doc;
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
				Document doc = get_doc ();
				Element elem = null;

				elem = doc.create_element ("Banana");
				test_error (DomException.NONE);
				assert (elem.tag_name == "Banana");
				assert (elem.tag_name != "banana");

				elem = doc.create_element ("ØÏØÏØ¯ÏØÏ  ²øœ³¤ïØ£");
				test_error (DomException.INVALID_CHARACTER);
				// assert (elem == null); // TODO: decide what we want returned on DomExceptions
			});
		Test.add_func ("/gxml/document/create_document_fragment", () => {
				Document doc = get_doc ();
				DocumentFragment fragment = doc.create_document_fragment ();

				// TODO: can we set XML in the content, and actually have that translate into real libxml2 underlying nodes?
				Element percy = doc.create_element ("Author");
				Element percy_name = doc.create_element ("Name");
				Element percy_email = doc.create_element ("Email");
				percy_name.content = "Percy";
				percy_email.content = "pweasley@hogwarts.co.uk";
				percy.append_child (percy_name);
				percy.append_child (percy_email);
				fragment.append_child (percy);

				Element ginny = doc.create_element ("Author");
				Element ginny_name = doc.create_element ("Name");
				Element ginny_email = doc.create_element ("Email");
				ginny_name.content = "Ginny";
				ginny_email.content = "weasleyg@hogwarts.co.uk";
				ginny.append_child (ginny_name);
				ginny.append_child (ginny_email);
				fragment.append_child (ginny);

				NodeList authors_list = doc.get_elements_by_tag_name ("Authors");
				assert (authors_list.length == 1);
				Element authors = (Element)authors_list.item (0);
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
				assert (authors.get_elements_by_tag_name ("Author").length == 4);

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
				Document doc = get_doc ();
				Text text = doc.create_text_node ("Star of my dreams");

				assert (text.node_name == "#text");
				assert (text.node_value == "Star of my dreams");
			});
		Test.add_func ("/gxml/document/create_comment", () => {
				Document doc = get_doc ();
				Comment comment = doc.create_comment ("Ever since the day we promised.");

				assert (comment.node_name == "#comment");
				assert (comment.node_value == "Ever since the day we promised.");
			});
		Test.add_func ("/gxml/document/create_cdata_section", () => {
				Document doc = get_doc ();
				CDATASection cdata = doc.create_cdata_section ("put in real cdata");

				assert (cdata.node_name == "#cdata-section");
				assert (cdata.node_value == "put in real cdata");
			});
		Test.add_func ("/gxml/document/create_processing_instruction", () => {
				Document doc = get_doc ();
				ProcessingInstruction instruction = doc.create_processing_instruction ("target", "data");

				assert (instruction.node_name == "target");
				assert (instruction.target == "target");
				assert (instruction.data == "data");
				assert (instruction.node_value == "data");
			});
		Test.add_func ("/gxml/document/create_attribute", () => {
				Document doc = get_doc ();
				Attr attr = doc.create_attribute ("attrname");

				assert (attr.name == "attrname");
				assert (attr.node_name == "attrname");
				assert (attr.node_value == "");
			});
		Test.add_func ("/gxml/document/create_entity_reference", () => {
				Document doc = get_doc ();
				EntityReference entity = doc.create_entity_reference ("entref");

				assert (entity.node_name == "entref");
				// TODO: think of at least one other smoke test
			});
		Test.add_func ("/gxml/document/get_elements_by_tag_name", () => {
				Document doc = get_doc ();
				NodeList elems = doc.get_elements_by_tag_name ("Email");

				assert (elems.length == 2);
				assert (((Element)elems.item (0)).content == "fweasley@hogwarts.co.uk");
				/* more thorough test exists in Element, since right now
				   Document uses that one */
			});
		Test.add_func ("/gxml/document/to_string", () => {
				Document doc = get_doc ();
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

	private static void check_contents (Document test_doc) {
		Element root = test_doc.document_element;

		assert (root.node_name == "Sentences");
		assert (root.has_child_nodes () == true);

		NodeList authors = test_doc.get_elements_by_tag_name ("Author");
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

	public static void print_node (GXml.Node node) {
		List<GXml.Node> children = (List<GXml.Node>)node.child_nodes;

		if (node.node_type != 3)
			GLib.stdout.printf ("<%s", node.node_name);
		NamedAttrMap attrs = node.attributes;
		for (int i = 0; i < attrs.length; i++) {
			Attr attr = attrs.item (i);
			GLib.stdout.printf (" %s=\"%s\"", attr.name, attr.value);
		}

		GLib.stdout.printf (">");
		if (node.node_value != null)
			GLib.stdout.printf ("%s", node.node_value);
		foreach (GXml.Node child in children) {
			// TODO: want a stringification method for Nodes?
			print_node (child);
		}
		if (node.node_type != 3)
			GLib.stdout.printf ("</%s>", node.node_name);
	}
}
