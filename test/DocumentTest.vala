/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;


/* For testing:
   https://live.gnome.org/Vala/TestSample
*/

class DocumentTest : GXmlTest {
	public static void add_tests () {
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

					assert (doc != null);

					// TODO: test contents
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
					// OutputStream outstream = fout.create (FileCreateFlags.REPLACE_DESTINATION, null);
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
					List<XNode> elems = doc.get_elements_by_tag_name ("fish");
					elems = null;
					//STUB
				} catch (GXml.Dom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
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