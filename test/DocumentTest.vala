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
				try {
					Document doc = get_doc ();

					Implementation impl = doc.implementation;

					assert (impl.has_feature ("xml") == true);
					assert (impl.has_feature ("xml", "1.0") == true);
					assert (impl.has_feature ("xml", "2.0") == false);
					assert (impl.has_feature ("html") == false);
					assert (impl.has_feature ("nonsense") == false);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/document_element", () => {
				try {
					Document doc = get_doc ();
					Element root = doc.document_element;

					assert (root.node_name == "Sentences");
					assert (root.has_child_nodes ());
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});

		Test.add_func ("/gxml/document/construct_from_path", () => {
				try {
					Document doc = get_doc ();

					check_contents (doc);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/construct_from_stream", () => {
				try {
					File fin = File.new_for_path (GXmlTest.get_test_dir () + "/test.xml");
					InputStream instream = fin.read (null);
					// TODO use cancellable

					Document doc = new Document.from_stream (instream);

					check_contents (doc);
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/construct_from_string", () => {
				try {
					string xml = "<Fruits><Apple></Apple><Orange></Orange></Fruits>";
					Document doc = new Document.from_string (xml);

					DomNode root = doc.document_element;
					assert (root.node_name == "Fruits");
					assert (root.has_child_nodes () == true);
					assert (root.first_child.node_name == "Apple");
					assert (root.last_child.node_name == "Orange");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/save", () => {
				try {
					Document doc = get_doc ();
					int exit_status;
					doc.save_to_path (GLib.Environment.get_tmp_dir () + "/test_out_path.xml"); // TODO: /tmp because of 'make distcheck' being readonly, want to use GXmlTest.get_test_dir () if readable, though

					Process.spawn_sync (null,  { "/usr/bin/diff", GLib.Environment.get_tmp_dir () + "/test_out_path.xml", GXmlTest.get_test_dir () + "/test_out_path_expected.xml" }, null, 0, null, null /* stdout */, null /* stderr */, out exit_status);
					assert (exit_status == 0);
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/save_to_stream", () => {
				try {
					File fin = File.new_for_path (GXmlTest.get_test_dir () + "/test.xml");
					InputStream instream = fin.read (null);

					File fout = File.new_for_path (GLib.Environment.get_tmp_dir () + "/test_out_stream.xml");
					// OutputStream outstream = fout.create (FileCreateFlags.REPLACE_DESTINATION, null); // REPLACE_DESTINATION doesn't work like I thought it would?
					OutputStream outstream = fout.replace (null, true, FileCreateFlags.REPLACE_DESTINATION, null);

					Document doc = new Document.from_stream (instream);
					int exit_status;

					doc.save_to_stream (outstream);

					Process.spawn_sync (null,  { "/usr/bin/diff", GLib.Environment.get_tmp_dir () + "/test_out_stream.xml", GXmlTest.get_test_dir () + "/test_out_stream_expected.xml" }, null, 0, null, null /* stdout */, null /* stderr */, out exit_status);
					assert (exit_status == 0);
				} catch (GLib.Error e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
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
				try {
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
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/create_text_node", () => {
				try {
					Document doc = get_doc ();
					Text text = doc.create_text_node ("Star of my dreams");

					assert (text.node_name == "#text");
					assert (text.node_value == "Star of my dreams");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/create_comment", () => {
				try {
					Document doc = get_doc ();
					Comment comment = doc.create_comment ("Ever since the day we promised.");

					assert (comment.node_name == "#comment");
					assert (comment.node_value == "Ever since the day we promised.");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/create_cdata_section", () => {
				try {
					Document doc = get_doc ();
					CDATASection cdata = doc.create_cdata_section ("put in real cdata");

					assert (cdata.node_name == "#cdata-section");
					assert (cdata.node_value == "put in real cdata");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/create_processing_instruction", () => {
				try {
					Document doc = get_doc ();
					ProcessingInstruction instruction = doc.create_processing_instruction ("target", "data");

					assert (instruction.node_name == "target");
					assert (instruction.target == "target");
					assert (instruction.data == "data");
					assert (instruction.node_value == "data");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/create_attribute", () => {
				try {
					Document doc = get_doc ();
					Attr attr = doc.create_attribute ("attrname");

					assert (attr.name == "attrname");
					assert (attr.node_name == "attrname");
					assert (attr.node_value == "");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/create_entity_reference", () => {
				try {
					Document doc = get_doc ();
					EntityReference entity = doc.create_entity_reference ("entref");

					assert (entity.node_name == "entref");
					// TODO: think of at least one other smoke test
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/get_elements_by_tag_name", () => {
				try {
					Document doc = get_doc ();
					NodeList elems = doc.get_elements_by_tag_name ("Email");

					assert (elems.length == 2);
					assert (((Element)elems.item (0)).content == "fweasley@hogwarts.co.uk");
					/* more thorough test exists in Element, since right now
					   Document uses that one */
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/document/to_string", () => {
				try {
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
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}

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

	public static void print_node (DomNode node) {
		List<GXml.DomNode> children = (List<GXml.DomNode>)node.child_nodes;

		if (node.node_type != 3)
			GLib.stdout.printf ("<%s", node.node_name);
		HashTable<string, Attr> attrs = node.attributes;
		foreach (string key in attrs.get_keys ()) {
			Attr attr = attrs.lookup (key);
			GLib.stdout.printf (" %s=\"%s\"", attr.name, attr.value);
		}

		GLib.stdout.printf (">");
		if (node.node_value != null)
			GLib.stdout.printf ("%s", node.node_value);
		foreach (GXml.DomNode child in children) {
			// TODO: want a stringification method for Nodes?
			print_node (child);
		}
		if (node.node_type != 3)
			GLib.stdout.printf ("</%s>", node.node_name);
	}
}