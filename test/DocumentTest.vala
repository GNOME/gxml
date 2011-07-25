/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class DocumentTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/document/doctype", () => {
				// STUB
				/*
				Document doc = new Document.for_path ("/tmp/dtdtest2.xml");
				// Document doc = get_doc ();
				DocumentType type = doc.doctype;
				HashTable<string,Entity> entities = type.entities;
				assert (false);
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
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/document_element", () => {
				try {
					Document doc = get_doc ();
					Element root = doc.document_element;
					
					assert (root.node_name == "Sentences");
					assert (root.has_child_nodes ());
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});

		Test.add_func ("/gxml/document/construct_for_path", () => {
				try {
					Document doc = get_doc ();

					assert (doc != null);
					// TODO: test contents
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/construct_for_stream", () => {
				try {
					File fin = File.new_for_path ("test.xml");
					InputStream instream = fin.read (null); // TODO use cancellable

					Document doc = new Document.for_stream (instream);

					assert (doc != null);

					// TODO: test contents
				} catch (GLib.Error e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/construct_from_string", () => {
				try {
					string xml = "<Fruits><Apple></Apple><Orange></Orange></Fruits>";
					Document doc = new Document.from_string (xml);

					XNode root = doc.document_element;
					assert (root.node_name == "Fruits");
					assert (root.has_child_nodes () == true);
					assert (root.first_child.node_name == "Apple");
					assert (root.last_child.node_name == "Orange");
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/save", () => {
				try {
					Document doc = get_doc ();
					doc.save_to_path ("test_out_path.xml");
				} catch (GLib.Error e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/save_to_stream", () => {
				try {
					File fin = File.new_for_path ("test.xml");
					InputStream instream = fin.read (null);

					File fout = File.new_for_path ("test_out_stream.xml");
					// OutputStream outstream = fout.create (FileCreateFlags.REPLACE_DESTINATION, null); // REPLACE_DESTINATION doesn't work like I thought it would?
					OutputStream outstream = fout.replace (null, true, FileCreateFlags.REPLACE_DESTINATION, null);

					Document doc = new Document.for_stream (instream);
					doc.save_to_stream (outstream);

					GLib.message ("stub");
					// TODO: figure out how to diff test.xml and test_out.xml
				} catch (GLib.Error e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_element", () => {
				try {
					Document doc = get_doc ();
					Element elem = null;

					try {
						elem = doc.create_element ("Banana");

						assert (elem.tag_name == "Banana");
						assert (elem.tag_name != "banana");
					} catch (DomError e) {
						assert (false);
					}

					try {
						elem = doc.create_element ("ØÏØÏØ¯ÏØÏ  ²øœ³¤ïØ£");

						/* TODO: want to test this, would need to
						   circumvent libxml2 though, and would we end up wanting
						   to validate all nodes libxml2 would let in when reading
						   but not us? :S

						   // We should not get this far
						   assert (false);
						*/
					} catch (DomError.INVALID_CHARACTER e) {
					}
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_document_fragment", () => {
				try {
					Document doc = get_doc ();
					DocumentFragment fragment = doc.create_document_fragment ();
					fragment = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_text_node", () => {
				try {
					Document doc = get_doc ();
					Text text = doc.create_text_node ("Star of my dreams");
					text = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_comment", () => {
				try {
					Document doc = get_doc ();
					Comment comment = doc.create_comment ("Ever since the day we promised.");
					comment = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_cdata_section", () => {
				try {
					Document doc = get_doc ();
					CDATASection cdata = doc.create_cdata_section ("put in real cdata");
					cdata = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_processing_instruction", () => {
				try {
					Document doc = get_doc ();
					ProcessingInstruction instruction = doc.create_processing_instruction ("target", "data");
					instruction = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_attribute", () => {
				try {
					Document doc = get_doc ();
					Attr attr = doc.create_attribute ("name");
					attr = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/create_entity_reference", () => {
				try {
					Document doc = get_doc ();
					EntityReference entity = doc.create_entity_reference ("entref");
					entity = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
		Test.add_func ("/gxml/document/get_elements_by_tag_name", () => {
				try {
					Document doc = get_doc ();
					NodeList elems = doc.get_elements_by_tag_name ("fish");
					elems = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
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
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}

			});
	}

	private static void check_contents (Document test_doc) {
		Element root = test_doc.document_element;

		assert (root.node_name == "Sentences");
		assert (root.has_child_nodes () == true);

		NodeList authors = test_doc.get_elements_by_tag_name ("Author");
		assert (authors.length == 2);

		GLib.warning (test_doc.to_string ());
	}
	public static void print_node (XNode node) {
		List<GXml.Dom.XNode> children = (List<GXml.Dom.XNode>)node.child_nodes;

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
		foreach (GXml.Dom.XNode child in children) {
			// TODO: want a stringification method for Nodes?
			print_node (child);
		}
		if (node.node_type != 3)
			GLib.stdout.printf ("</%s>", node.node_name);
	}
}