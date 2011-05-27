/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* TODO:
 * * later on, go over libxml2 docs for Tree and Node and Document, etc., and see if we're missing anything significant
 * * compare performance between libxml2 and GXml (should be a little different, but not too much)
 */

namespace GXml.Dom {
	class Document : DomNode {
		/** Private properties */
		private Xml.Doc *doc;
		// TODO: since this Document extends from Node, should we be passing something to our base () Node for Node.node?
		//       Perhaps our root element?


		/** Public properties */
		// TODO: set these
		public DocumentType doctype {
			get;
			private set;
		}
		public Implementation implementation {
			get;
			private set;
		}
		public Element document_element {
			get;
			private set;
		}

		/** Constructor */
		public Document.for_path (string file_path) throws DomError {
			Xml.Doc *doc = Xml.Parser.parse_file (file_path); // consider using read_file
			// TODO: exceptions (null doc, null root)
			Xml.Node *root = doc->get_root_element ();

			base (root);
			this.init (doc, root);

			this.doc = doc;

			// TODO: might want to check that the file_path exists
		}
		Document (InputStream instream) {
			// TODO: figure out what all input streams could be/represent
			//this.init ();
			// TODO: exceptions (null doc, null root)

			// Xml.Node *root = doc->get_root_element ();
			base (null);
		}
		public Document.from_string (string memory) throws DomError {
			this.doc = Xml.Parser.parse_memory (memory, (int)memory.length);
			// TODO: exceptions (null doc, null root)
			Xml.Node *root = doc->get_root_element ();
			this.init (doc, root);
			base (root);
		}

		// TODO: proper name for init function?
		private void init (Xml.Doc *doc, Xml.Node *root) throws DomError {
			if (doc == null) {
				throw new DomError.INVALID_DOC ("Failed to parse document.");
			}
			if (root == null) {
				throw new DomError.INVALID_ROOT ("Could not obtain root for document.");
			}
		}

		/** Public Methods */
		Element create_element (string tag_name) throws DomError {
			// TODO: what does libxml2 do with Elements?  should we just use nodes?
			// TODO: right now, we're treating libxml2's 'new_node' Node as our Element
			// TODO: what should we be passing for ns other than old_ns?  Figure it out
			return new Element (doc->new_node (null, tag_name, null)); // TODO: use new_node_eat_name()  instead?
		}
		DocumentFragment create_document_fragment () {
			return new DocumentFragment (doc->new_fragment ());
		}
		Text create_text_node (string data) {
			return new Text (doc->new_text (data));
		}
		Comment create_comment (string data) {
			return new Comment (doc->new_comment (data)); // TODO: should we be passing around Xml.Node* like this?
		}
		CDATASection create_cdata_section (string data) throws DomError {
			return new CDATASection (doc->new_cdata_block (data, (int)data.length));
		}
		ProcessingInstruction create_processing_instruction (string target, string data) throws DomError {
			// STUB: TODO: figure out what to do for a ProcessingInstruction
			return new ProcessingInstruction ();
		}
		Attr create_attribute (string name) throws DomError {
			return new Attr (doc->new_prop (name, ""));  // TODO: should we pass something other than "" for the unspecified value?
		}
		EntityReference create_entity_reference (string name) throws DomError {
			return new EntityReference ();
			// STUB: figure out what they mean by entity reference and what libxml2 means by it (xmlNewReference ()?)
		}
		List<Node> get_elements_by_tag_name (string tagname) {
			// TODO: does this refer to elements created under this document?  (If so, then we can save them in a structure from above)
			// TODO: or does it just include elements that are children of the root?
			// TODO: a concern I have is that I will be creating new DomNodes for each of these, while I already created them below
			//       so should I maintain a tree structure of GXml.Dom.Node parallel to the libxml2 structure?
			//       if not, I need to not allow GXml.Dom structures to really store data, it should all be accessed from the libxml2 nodes
			List<Node> elems = new List<Node> (); // STUB

			return elems;
		}
	}
}
