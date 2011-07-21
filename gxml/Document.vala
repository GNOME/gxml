/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/*
 * GXml
 * Copyright (C) Richard Schwarting 2011 <aquarichy@gmail.com>
 *
 * GXml is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * GXml is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General
 * Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with GXml. If not, see <http://www.gnu.org/licenses/>.
 */

/* TODO:
 * * later on, go over libxml2 docs for Tree and Node and Document, etc., and see if we're missing anything significant
 * * compare performance between libxml2 and GXml (should be a little different, but not too much)
 */

/**
 * The XML Document Object Model.
 */
namespace GXml.Dom {
	internal struct InputStreamBox {
		public InputStream str;
		public Cancellable can;
	}

	internal struct OutputStreamBox {
		public OutputStream str;
		public Cancellable can;
	}

	/**
	 * Represents an XML Document as a tree of nodes. The Document has a document element, which is the root of the tree. A Document can have its type defined by a DocumentType.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#i-Document]]
	 */
	public class Document : XNode {
		/** Private properties */
		internal HashTable<Xml.Node*, XNode> node_dict = new HashTable<Xml.Node*, XNode> (GLib.direct_hash, GLib.direct_equal);
		// We don't want want to use XNode's Xml.Node or its dict
		// internal HashTable<Xml.Attr*, Attr> attr_dict = new HashTable<Xml.Attr*, Attr> (null, null);

		private Xml.Doc *xmldoc;

		/** Private methods */
		// internal unowned Attr? lookup_attr (Xml.Attr *xmlattr) {
		// 	unowned Attr attrnode;

		// 	if (xmlattr == null) {
		// 		return null; // TODO: consider throwing an error instead
		// 	}

		// 	attrnode = this.attr_dict.lookup (xmlattr);
		// 	if (attrnode == null) {
		// 		// TODO: threadsafety
		// 		this.attr_dict.insert (xmlattr, new Attr (xmlattr, this));
		// 		attrnode = this.attr_dict.lookup (xmlattr);
		// 	}

		// 	return attrnode;
		// }

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

		/* Public properties */

		/**
		 * Provides the name for this node. For documents, it is always "#document".
		 */
		public override string node_name {
			get {
				return "#document"; // TODO: wish I could return "#" + base.node_name
			}
			private set {
			}
		}

		// TODO: DTD
		/**
		 * The Document Type Definition (DTD) defining this document. This may be null.
		 */
		public DocumentType? doctype {
			// either null, or a DocumentType object
			// STUB
			get;
			private set;
		}
		/**
		 * Describes the features of the DOM implementation behind this document.
		 */
		public Implementation implementation {
			// set in constructor
			get;
			private set;
		}
		/**
		 * The root node of the document's node tree.
		 */
		public Element document_element {
			// TODO: should children work at all on Document, or just this, to get root?
			get {
				return (Element)this.lookup_node (this.xmldoc->get_root_element ());
			}
			private set {
			}
		}

		/** Constructor */

		/* All other constructors should call this one,
		   passing it a Xml.Doc* object */
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
			if (doc->int_subset == null && doc->ext_subset == null) {
				this.doctype = null;
			} else {
				// TODO: make sure libxml2 binding patch for this makes it through
				this.doctype = new DocumentType (doc->int_subset, doc->ext_subset, this);
			}
			this.implementation = new Implementation ();
		}
		/**
		 * Creates a Document from the file at file_path.
		 *
		 * @throws DomError When a Document cannot be constructed for the specified file.
		 */
		public Document.for_path (string file_path) throws DomError {
			Xml.Doc *doc = Xml.Parser.parse_file (file_path); // consider using read_file
			// TODO: might want to check that the file_path exists
			this (doc);
		}

		// TODO: can we make this private?
		internal static int _iowrite (void *ctx, char[] buf, int len) {
			OutputStreamBox *box = (OutputStreamBox*)ctx;
			OutputStream outstream = box->str;
			int bytes_writ = -1;

			try {
				// TODO: want to propagate error, get cancellable
				// TODO: handle char[] -> uint8[] better?
				bytes_writ = (int)outstream.write ((uint8[])buf, box->can);
			} catch (GLib.IOError e) {
				// TODO: process
				bytes_writ = -1;
			}

			return bytes_writ;
		}
		// TODO: can we make this private?
		internal static int _iooutclose (void *ctx) {
			OutputStreamBox *box = (OutputStreamBox*)ctx;
			OutputStream outstream = box->str;
			int success = -1;

			try {
				// TODO: handle, propagate? error
				// TODO: want ctx to include Cancellable
				if (outstream.close (box->can)) {
					success = 0;
				}
			} catch (GLib.Error e) {
				// TODO: process
				success = -1;
			}

			return success;
		}
		// TODO: can we make this private?
		internal static int _ioread (void *ctx, char[] buf, int len) {
			InputStreamBox *box = (InputStreamBox*)ctx;
			InputStream instream = box->str;
			int bytes_read = -1;

			try {
				// TODO: want to propagate error, get cancellable
				// TODO: handle char[] -> uint8[] better?
				bytes_read = (int)instream.read ((uint8[])buf, box->can);
			} catch (GLib.IOError e) {
				// TODO: process
				bytes_read = -1;
			}

			return bytes_read;
		}
		// TODO: can we make this private?
		internal static int _ioinclose (void *ctx) {
			InputStreamBox *box = (InputStreamBox*)ctx;
			InputStream instream = box->str;
			int success = -1;

			try {
				// TODO: handle, propagate? error
				// TODO: want ctx to include Cancellable
				if (instream.close (box->can)) {
					success = 0;
				}
			} catch (GLib.Error e) {
				// TODO: process
				success = -1;
			}

			return success;
		}
		/**
		 * Creates a Document from the File fin.
		 *
		 * @throws DomError When a Document cannot be constructed for the specified file.
		 */
		public Document.for_file (File fin) throws DomError {
			// TODO: accept cancellable
			InputStream instream;

			try {
				instream = fin.read (null);
			} catch (GLib.Error e) {
				throw new DomError.INVALID_DOC (e.message);
			}
			this.for_stream (instream);
		}
		/**
		 * Creates a Document from data provided through the InputStream instream.
		 *
		 * @throws DomError When a Document cannot be constructed for the specified stream.
		 */
		public Document.for_stream (InputStream instream) throws DomError {
			// TODO: accept Cancellable
			Cancellable can = new Cancellable ();
			InputStreamBox box = { instream, can };

			Xml.TextReader reader = new Xml.TextReader.for_io ((Xml.InputReadCallback)_ioread,
									   (Xml.InputCloseCallback)_ioinclose,
									   &box, "", null, 0);
			reader.read ();
			reader.expand ();
			Xml.Doc *doc = reader.current_doc ();

			this (doc);
		}
		/**
		 * Creates a Document from data found in memory.
		 *
		 * @throws DomError When a Document cannot be constructed for the specified data.
		 */
		public Document.from_string (string memory) throws DomError {
			Xml.Doc *doc = Xml.Parser.parse_memory (memory, (int)memory.length);
			this (doc);
		}
		/**
		 * Saves a Document to the file at path file_path
		 */
		// TODO: is this a simple Unix file path, or does libxml2 do networks, too?
		public void save_to_path (string file_path) {
			this.xmldoc->save_file (file_path);
		}

		// TODO: consider adding a save_to_file, but then we need to figure out which flags to accept
		/**
		 * Saves a Document to the OutputStream outstream.
		 */
		public void save_to_stream (OutputStream outstream) throws DomError {
			Cancellable can = new Cancellable ();
			OutputStreamBox box = { outstream, can };

			// TODO: make sure libxml2's vapi gets patched
			Xml.SaveCtxt *ctxt = new Xml.SaveCtxt.to_io ((Xml.OutputWriteCallback)_iowrite,
								     (Xml.OutputCloseCallback)_iooutclose,
								     &box, null, 0);
			ctxt->save_doc (this.xmldoc);
			ctxt->flush ();
		}

		/* Public Methods */
		/**
		 * Creates an empty Element node with the tag name
		 * tag_name. XML example: {{{<Person></Person>}}}
		 */
		public Element create_element (string tag_name) throws DomError {
			/* TODO: libxml2 doesn't complain about invalid names, but the spec
			   for DOM Level 1 Core wants us to. Handle ourselves? */
			// TODO: what does libxml2 do with Elements?  should we just use nodes? probably
			// TODO: what should we be passing for ns other than old_ns?  Figure it out
			Xml.Node *xmlelem = this.xmldoc->new_node (null, tag_name, null);
			Element new_elem = new Element (xmlelem, this);
			return new_elem;
		}
		/**
		 * Creates a DocumentFragment.
		 */
		public DocumentFragment create_document_fragment () {
			return new DocumentFragment (this.xmldoc->new_fragment (), this);
		}
		/**
		 * Creates a text node containing the text in data.
		 * XML example:
		 * {{{<someElement>Text is contained here.</someElement>}}}
		 */
		public Text create_text_node (string data) {
			return new Text (this.xmldoc->new_text (data), this);
		}
		/**
		 * Creates an XML comment with data. XML example: {{{<!-- data -->}}}
		 */
		public Comment create_comment (string data) {
			return new Comment (this.xmldoc->new_comment (data), this);
			// TODO: should we be passing around Xml.Node* like this?
		}
		/**
		 * Creates a CDATA section containing data. XML
		 * example:
		 * {{{ <![CDATA[Here contains non-XML data, like
		 * code, or something that requires a lot of special
		 * XML entities.]]>. }}}
		 */
		// TODO: figure out how we can represent ]] in a Valadoc
		public CDATASection create_cdata_section (string data) throws DomError {
			check_html ("CDATA section"); // TODO: i18n

			return new CDATASection (this.xmldoc->new_cdata_block (data, (int)data.length), this);
		}
		/**
		 * Creates a Processing Instructions. XML example:
		 * {{{<?pi_target processing instruction data?>
		 * <?xml-stylesheet href="style.xsl" type="text/xml"?>}}}
		 */
		public ProcessingInstruction create_processing_instruction (string target, string data) throws DomError {
			check_html ("processing instructions"); // TODO: i18n
			check_character_validity (target);
			check_character_validity (data); // TODO: do these use different rules?

			// TODO: want to see whether we can find a libxml2 structure for this
			ProcessingInstruction pi = new ProcessingInstruction (target, data, this);

			return pi;
		}
		// TODO: Consider creating a convenience method for create_attribute_with_value (name, value)
		/**
		 * Creates an Attr attribute with name, usually to be associated with an Element.
		 */
		public Attr create_attribute (string name) throws DomError {
			check_character_validity (name);

			return new Attr (this.xmldoc->new_prop (name, ""), this);
			// TODO: should we pass something other than "" for the unspecified value?  probably not, "" is working fine so far
		}
		/**
		 * Creates an entity reference. XML example:
		 * {{{&name;
		 * &apos;}}}
		 */
		public EntityReference create_entity_reference (string name) throws DomError {
			check_html ("entity reference"); // TODO: i18n
			check_character_validity (name);

			return new EntityReference (name, this);
			// STUB: figure out what they mean by entity reference and what libxml2 means by it (xmlNewReference ()?)
		}

		/**
		 * Obtains a list of ELements with the given tag name
		 * tag_name contained within this document.
		 *
		 * This list is updated as new elements are added to
		 * the document.
		 */
		// TODO: make that last statement true.
		public List<XNode> get_elements_by_tag_name (string tag_name) {
			// TODO: return a NodeList
			// TODO: does this ensure that the root element is also included?
			// TODO: DO NOT return a separate list, we need to return the live list
			// http://www.w3.org/TR/DOM-Level-1/level-one-core.html
			return this.document_element.get_elements_by_tag_name (tag_name);
		}

		private void check_html (string feature) throws DomError {
			if (this.doctype != null && this.doctype.name == "html") {
				// TODO: ^ check name == html by icase
				throw new DomError.NOT_SUPPORTED ("HTML documents do not support '%s'".printf (feature)); // i18n
			}
		}
		private void check_character_validity (string str) throws DomError {
			if (false == false) { // TODO: define validity
				throw new DomError.INVALID_CHARACTER ("'%s' contains invalid characters.".printf (str));
			}
		}
	}
}
