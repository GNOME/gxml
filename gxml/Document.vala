/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* TODO:
 * * later on, go over libxml2 docs for Tree and Node and Document, etc., and see if we're missing anything significant
 * * compare performance between libxml2 and GXml (should be a little different, but not too much)
 */

namespace GXml.Dom {
	public class Document : XNode {
		/** Private class properties */
		internal HashTable<Xml.Node*, XNode> node_dict = new HashTable<Xml.Node*, XNode> (GLib.direct_hash, GLib.direct_equal);
		private Xml.Doc *xmldoc;

		/** Private methods */
		internal unowned XNode? lookup_node (Xml.Node *xmlnode) {
			unowned XNode domnode;

			if (xmlnode == null) {
				return null; // TODO: consider throwing an error instead
			}

			domnode = this.node_dict.lookup (xmlnode);
			if (domnode == null) {
				// If we don't have a cached the appropriate XNode for a given Xml.Node* yet, create it (type matters)
				// TODO: see if we can attach logic to the enum {} to handle this
				switch ((NodeType)xmlnode->type) {
				case NodeType.ELEMENT:
					new Element (xmlnode, this);
					break;
				case NodeType.TEXT:
					new Text (xmlnode, this);
					break;
				case NodeType.CDATA_SECTION:
					new CDATASection (xmlnode, this);
					break;
				case NodeType.COMMENT:
					new Comment (xmlnode, this);
					break;
				case NodeType.DOCUMENT_FRAGMENT:
					new DocumentFragment (xmlnode, this);
					break;
				/* TODO: These are not yet implemented */
				case NodeType.ENTITY_REFERENCE:
					// new EntityReference (xmlnode, this);
					break;
				case NodeType.ENTITY:
					// new Entity (xmlnode, this);
					break;
				case NodeType.PROCESSING_INSTRUCTION:
					// new ProcessingInstruction (xmlnode, this);
					break;
				case NodeType.DOCUMENT_TYPE:
					// new DocumentType (xmlnode, this);
					break;
				case NodeType.NOTATION:
					// new Notation (xmlnode, this);
					break;
				case NodeType.ATTRIBUTE:
					// TODO: error
					break;
				case NodeType.DOCUMENT:
					// TODO: error
					break;
				}

				domnode = this.node_dict.lookup (xmlnode);
				// TODO: threadsafety?
			}

			return domnode;
		}

		// We don't want want to use XNode's Xml.Node or its dict
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


		// 		// // If we don't have a cached XNode for a given Xml.Node yet, create one
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
		public override string node_name {
			get {
				return "#document"; // TODO: wish I could return "#" + base.node_name
			}
			private set {
			}
		}

		public DocumentType doctype {
			// STUB
			get;
			private set;
		}
		public Implementation implementation {
			// STUB
			get;
			private set;
		}
		public Element document_element {
			// TODO: should children work at all on Document, or just this, to get root?
			get {
				return (Element)this.lookup_node (this.xmldoc->get_root_element ());
			}
			private set {
			}
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
			base.for_document ();
			this.owner_document = this; // this doesn't exist until after base()
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
			/* TODO: libxml2 doesn't complain about invalid names, but the spec
			   for DOM Level 1 Core wants us to.  Handle ourselves? */
			// TODO: what does libxml2 do with Elements?  should we just use nodes?
			// TODO: right now, we're treating libxml2's 'new_node' Node as our Element
			// TODO: use new_node_eat_name()  instead?
			// TODO: what should we be passing for ns other than old_ns?  Figure it out

			Xml.Node *xmlelem = this.xmldoc->new_node (null, tag_name, null);
			Element new_elem = new Element (xmlelem, this);
			return new_elem;
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
			// TODO: figure out what to do for a ProcessingInstruction
			// TODO: want to see whether we can find a libxml2 structure for this
			ProcessingInstruction pi = new ProcessingInstruction (target, data, this);

			return pi;
		}
		// TODO: Consider creating a convenience method for create_attribute_with_value (name, value)
		public Attr create_attribute (string name) throws DomError {
			return new Attr (this.xmldoc->new_prop (name, ""), this);  // TODO: should we pass something other than "" for the unspecified value?
		}
		public EntityReference create_entity_reference (string name) throws DomError {
			return new EntityReference (name, this);
			// STUB: figure out what they mean by entity reference and what libxml2 means by it (xmlNewReference ()?)
		}

		public List<XNode> get_elements_by_tag_name (string tagname) {
			// TODO: does this ensure that the root element is also included?
			// TODO: DO NOT return a separate list, we need to return the live list
			// http://www.w3.org/TR/DOM-Level-1/level-one-core.html
			return this.document_element.get_elements_by_tag_name (tagname);
		}
	}
}
