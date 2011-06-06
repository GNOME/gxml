/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* TODO:
 * * later on, go over libxml2 docs for Tree and Node and Document, etc., and see if we're missing anything significant
 * * compare performance between libxml2 and GXml (should be a little different, but not too much)
 */

namespace GXml.Dom {
	public class Document : DomNode {
		/** Private class properties */
		internal HashTable<Xml.Node*, DomNode> node_dict = new HashTable<Xml.Node*, DomNode> (GLib.direct_hash, GLib.direct_equal);
		private Xml.Doc *xmldoc;

		/** Private methods */
		internal unowned DomNode? lookup_node (Xml.Node *xmlnode) {
			unowned DomNode domnode;

			if (xmlnode == null) {
				return null; // TODO: consider throwing an error instead
			}

			domnode = this.node_dict.lookup (xmlnode);
			if (domnode == null) {
				// If we don't have a cached DomNode for a given Xml.Node yet, create one
				// TODO: threadsafety?
				new DomNode (xmlnode, this); // inserted within constructor
				domnode = this.node_dict.lookup (xmlnode);
			}

			return domnode;
		}

		// We don't want want to use DomNode's Xml.Node or its dict
		internal HashTable<Xml.Attr*, Attr> attr_dict = new HashTable<Xml.Attr*, Attr> (null, null);

		/** Private methods */
		internal unowned Attr? lookup_attr (Xml.Attr *xmlattr) {
			unowned Attr attrnode;

			if (xmlattr == null) {
				return null; // TODO: consider throwing an error instead
			}

			attrnode = this.attr_dict.lookup (xmlattr);
			if (attrnode == null) {
				// TODO: threadsafety
				this.attr_dict.insert (xmlattr, new Attr (xmlattr, this));
				attrnode = this.attr_dict.lookup (xmlattr);
			}

			return attrnode;
		}



		// /** Private class properties */
		// internal static HashTable<Xml.Doc*, Document> dict = new HashTable<Xml.Doc*, Document> (null, null);

		// /** Private methods */
		// internal static unowned Document? lookup (Xml.Doc *xmldoc) {
		// 	unowned Document domdoc;

		// 	if (xmldoc == null) {
		// 		return null; // TODO: consider throwing an error instead
		// 	}

		// 	domdoc = Document.dict.lookup (xmldoc);

		// 	if (domdoc == null) {
		// 		// TODO: throw an error, these should already be inserted by the Document constructors


		// 		// // If we don't have a cached DomNode for a given Xml.Node yet, create one
		// 		// Document.dict.insert (xmldoc, new Document (xmldoc));
		// 		// domdoc = Document.dict.lookup (xmldoc);
		// 		// // TODO: threadsafety?
		// 	}

		// 	return domdoc;
		// }

		/** Private properties */
		// private Xml.Doc *doc;
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
		private Document (Xml.Doc *doc) throws DomError {
			Xml.Node *root;

			root = doc->get_root_element ();
			if (doc == null)
				throw new DomError.INVALID_DOC ("Failed to parse document.");
			if (root == null)
				throw new DomError.INVALID_ROOT ("Could not obtain root for document.");

			// TODO: consider passing root as a base node?
			base.with_type_no_owner (NodeType.DOCUMENT);
			this.owner_document = this;
			this.xmldoc = doc;
		}
		public Document.for_path (string file_path) throws DomError {
			Xml.Doc *doc = Xml.Parser.parse_file (file_path); // consider using read_file
			// TODO: might want to check that the file_path exists
			this (doc);
		}
		public Document.for_stream (InputStream instream) throws DomError {
			this (null);
			// TODO: figure out what all input streams could be/represent
		}
		public Document.from_string (string memory) throws DomError {
			Xml.Doc *doc = Xml.Parser.parse_memory (memory, (int)memory.length);
			this (doc);
		}

		// TODO: proper name for init function?
		// private void init (Xml.Doc *doc, Xml.Node *root) throws DomError {
		// }

		/** Public Methods */
		public Element create_element (string tag_name) throws DomError {
			// TODO: what does libxml2 do with Elements?  should we just use nodes?
			// TODO: right now, we're treating libxml2's 'new_node' Node as our Element
			// TODO: what should we be passing for ns other than old_ns?  Figure it out
			Element new_elem = new Element (this.xmldoc->new_node (null, tag_name, null), this);

			/* We keep a table of lists indexed by tag name */
			unowned List<DomNode> same_tag = tag_element_idx.lookup (tag_name);
			if (same_tag == null) {
				// TODO: dislike creating it to be owned like this and then looking up separately
				tag_element_idx.insert (tag_name, new List<DomNode> ());
				same_tag = tag_element_idx.lookup (tag_name);
			}
			same_tag.append (new_elem);

			return new_elem; // TODO: use new_node_eat_name()  instead?
		}
		public DocumentFragment create_document_fragment () {
			return new DocumentFragment (this.xmldoc->new_fragment (), this);
		}
		public Text create_text_node (string data) {
			return new Text (this.xmldoc->new_text (data), this);
		}
		public Comment create_comment (string data) {
			return new Comment (this.xmldoc->new_comment (data), this); // TODO: should we be passing around Xml.Node* like this?
		}
		public CDATASection create_cdata_section (string data) throws DomError {
			return new CDATASection (this.xmldoc->new_cdata_block (data, (int)data.length), this);
		}
		public ProcessingInstruction create_processing_instruction (string target, string data) throws DomError {
			// STUB: TODO: figure out what to do for a ProcessingInstruction
			return new ProcessingInstruction (this);
		}
		public Attr create_attribute (string name) throws DomError {
			return new Attr (this.xmldoc->new_prop (name, ""), this);  // TODO: should we pass something other than "" for the unspecified value?
		}
		public EntityReference create_entity_reference (string name) throws DomError {
			return new EntityReference (this);
			// STUB: figure out what they mean by entity reference and what libxml2 means by it (xmlNewReference ()?)
		}

		private HashTable<string,List<DomNode>> tag_element_idx = new HashTable<string,List<DomNode>> (null, null); // TODO: probably want to change key cmp, and val cmp

		public unowned List<DomNode> get_elements_by_tag_name (string tagname) {
			// TODO: does this refer to elements created under this document?  (If so, then we can save them in a structure from above)
			// TODO: or does it just include elements that are children of the root?
			// TODO: a concern I have is that I will be creating new DomNodes for each of these, while I already created them below
			//       so should I maintain a tree structure of GXml.Dom.Node parallel to the libxml2 structure?
			//       if not, I need to not allow GXml.Dom structures to really store data, it should all be accessed from the libxml2 nodes
			// List<DomNode> elems = new List<DomNode> (); // STUB

			return tag_element_idx.lookup (tagname);
			// TODO: want to do any tagname normalisation?
			// TODO: DO NOT return a separate list, we need to return the live list
			// http://www.w3.org/TR/DOM-Level-1/level-one-core.html


			// return elems;
		}
	}
}
