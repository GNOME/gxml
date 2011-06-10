/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

/* For testing:
   https://live.gnome.org/Vala/TestSample
*/

class DocumentTest {
	private static Document get_doc () {
		Document doc = null;

		try {
			doc = new Document.for_path ("test.xml");
		} catch (DomError e) {
		}

		return doc;
	}
	public static void add_document_tests () throws DomError {
		Test.add_func ("/gdom/document/construct_for_path", () => {
				Document doc = get_doc ();
				doc = null;
				// TODO: assert doc != null
			});
		Test.add_func ("/gdom/document/construct_stream", () => {
				// Document doc = new Document ( in_stream );
			});
		Test.add_func ("/gdom/document/construct_from_string", () => {
				string xml = "<Fruits><Apple></Apple><Orange></Orange></Fruits>";
				Document doc = new Document.from_string (xml);
				doc = null;
				//STUB
			});
		Test.add_func ("/gdom/document/create_element", () => {
				Document doc = get_doc ();
				Element elem;

				try {
					elem = doc.create_element ("Banana");
				} catch (DomError e) {
					assert (false);
				}

				assert (elem.tagName == "Banana");
				assert (elem.tagName != "banana");

				try {
					elem = doc.create_element ("ØÏØÏØ¯ÏØÏ  ²øœ³¤ïØ£");
					// We should not get this far
					assert (false);
				} catch (DomError.INVALID_CHARACTER_ERR e) {
				}
			});
		Test.add_func ("/gdom/document/create_document_fragment", () => {
				Document doc = get_doc ();
				DocumentFragment fragment = doc.create_document_fragment ();
				fragment = null;
				//STUB
			});
		Test.add_func ("/gdom/document/create_text_node", () => {
				Document doc = get_doc ();
				Text text = doc.create_text_node ("Star of my dreams");
				text = null;
				//STUB
			});
		Test.add_func ("/gdom/document/create_comment", () => {
				Document doc = get_doc ();
				Comment comment = doc.create_comment ("Ever since the day we promised.");
				comment = null;
				//STUB
			});
		Test.add_func ("/gdom/document/create_cdata_section", () => {
				Document doc = get_doc ();
				CDATASection cdata = doc.create_cdata_section ("put in real cdata");
				cdata = null;
				//STUB
			});
		Test.add_func ("/gdom/document/create_processing_instruction", () => {
				Document doc = get_doc ();
				ProcessingInstruction instruction = doc.create_processing_instruction ("target", "data");
				instruction = null;
				//STUB
			});
		Test.add_func ("/gdom/document/create_attribute", () => {
				Document doc = get_doc ();
				Attr attr = doc.create_attribute ("name");
				attr = null;
				//STUB
			});
		Test.add_func ("/gdom/document/create_entity_reference", () => {
				Document doc = get_doc ();
				EntityReference entity = doc.create_entity_reference ("entref");
				entity = null;
				//STUB
			});
		Test.add_func ("/gdom/document/get_elements_by_tag_name", () => {
				Document doc = get_doc ();
				unowned List<DomNode> elems = doc.get_elements_by_tag_name ("fish");
				elems = null;
				//STUB
			});
	}

	public static void print_node (DomNode node) {
		List<GXml.Dom.DomNode> children = (List<GXml.Dom.DomNode>)node.child_nodes;

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
		foreach (GXml.Dom.DomNode child in children) {
			// TODO: want a stringification method for Nodes?
			print_node (child);
		}
		if (node.node_type != 3)
			GLib.stdout.printf ("</%s>", node.node_name);
	}
}