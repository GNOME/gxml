/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Document.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011  Daniel Espinosa <esodan@gmail.com>
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


/*
 * GXml
 * Copyright (C) Richard Schwarting <aquarichy@gmail.com> et al, 2011
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

/* TODO:IMPORTANT: don't use GLib collections, use Libgee! */

/**
 * The XML Document Object Model.
 *
 * GXml provides a DOM Level 1 Core API in a GObject framework.
 */
namespace GXml {
	internal struct InputStreamBox {
		public InputStream str;
		public Cancellable can;
	}

	internal struct OutputStreamBox {
		public OutputStream str;
		public Cancellable can;
	}

	/**
	 * Represents an XML Document as a tree of {@link GXml.DomNode}s.
	 *
	 * The Document has a document element, which is the root of
	 * the tree. A Document can have its type defined by a
	 * {@link GXml.DocumentType}. For more, see:
	 * [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#i-Document]]
	 */
	public class Document : DomNode {
		/* *** Private properties *** */

		/**
		 * This contains a map of Xml.Nodes that have been
		 * accessed and the GXml DomNode we created to represent
		 * them on-demand.  That way, we don't create an DomNode
		 * for EVERY node, even if the user never actually
		 * accesses it.
		 */
		internal HashTable<Xml.Node*, DomNode> node_dict = new HashTable<Xml.Node*, DomNode> (GLib.direct_hash, GLib.direct_equal);
		// We don't want want to use DomNode's Xml.Node or its dict
		// internal HashTable<Xml.Attr*, Attr> attr_dict = new HashTable<Xml.Attr*, Attr> (null, null);

		/**
		 * This contains a list of elements whose attributes
		 * may have been modified within GXml, and whose modified
		 * attributes need to be saved back to the underlying
		 * libxml2 structure when we save.  (Necessary because
		 * the user can obtain a HashTable and modify that in a
		 * way that we can't follow unless we check ourselves.)
		 * Perhaps I really should implement a NamedNodeMap :|
		 * TODO: do that
		 */
		internal List<Element> dirty_elements = new List<Element> ();

		/* TODO: for future reference, find out if internals
		   are only accessible by children when they're
		   compiled together.  I have a test that had a
		   separately compiled TestDocument : Document class,
		   and it couldn't access the internal xmldoc. */
		internal Xml.Doc *xmldoc;

		/* *** Private methods *** */
		internal unowned DomNode? lookup_node (Xml.Node *xmlnode) {
			unowned DomNode domnode;

			if (xmlnode == null) {
				return null; // TODO: consider throwing an error instead
			}

			domnode = this.node_dict.lookup (xmlnode);
			if (domnode == null) {
				// If we don't have a cached the appropriate DomNode for a given Xml.Node* yet, create it (type matters)
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

		List<Xml.Node*> new_nodes = new List<Xml.Node*> ();

		~Document () {
			List<Xml.Node*> to_free = new List<Xml.Node*> ();

			sync_dirty_elements ();

			/* we use two separate loops, because freeing
			   a node frees its descendants, and we might
			   have a branch with children that might be
			   visited after their root ancestor
			*/
			foreach (Xml.Node *new_node in new_nodes) {
				if (new_node->parent == null) {
					to_free.append (new_node);
				}
			}
			foreach (Xml.Node *freeable in to_free) {
				freeable->free ();
			}

			this.xmldoc->free ();
		}

		/** Constructor */
		/**
		 * Creates a Document based on a libxml2 Xml.Doc* object.
		 */
		public Document.from_libxml2 (Xml.Doc *doc, bool require_root = true) throws DomError {
			/* All other constructors should call this one,
			   passing it a Xml.Doc* object */

			Xml.Node *root;

			if (doc == null)
				throw new DomError.INVALID_DOC ("Failed to parse document.");
			if (require_root) {
				root = doc->get_root_element ();
				if (root == null)
					throw new DomError.INVALID_ROOT ("Could not obtain root for document.");
			}

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
		public Document.from_path (string file_path) throws DomError {
			Xml.Doc *doc = Xml.Parser.parse_file (file_path); // consider using read_file
			// TODO: might want to check that the file_path exists
			this.from_libxml2 (doc);
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
		public Document.from_gfile (File fin, Cancellable? can = null) throws DomError {
			// TODO: accept cancellable
			InputStream instream;

			try {
				instream = fin.read (null);
				this.from_stream (instream, can);
				instream.close ();
			} catch (GLib.Error e) {
				throw new DomError.INVALID_DOC (e.message);
			}
		}
		/**
		 * Creates a Document from data provided through the InputStream instream.
		 *
		 * @throws DomError When a Document cannot be constructed for the specified stream.
		 */
		public Document.from_stream (InputStream instream, Cancellable? can = null) throws DomError {
			// TODO: accept Cancellable
			// Cancellable can = new Cancellable ();
			InputStreamBox box = { instream, can };
			Xml.Doc *doc;
			Xml.TextReader reader = new Xml.TextReader.for_io ((Xml.InputReadCallback)_ioread,
									   (Xml.InputCloseCallback)_ioinclose,
									   &box, "", null, 0);
			reader.read ();
			reader.expand ();
			doc = reader.current_doc ();
			reader.close ();

			this.from_libxml2 (doc);
		}
		/**
		 * Creates a Document from data found in memory.
		 *
		 * @throws DomError When a Document cannot be constructed for the specified data.
		 */
		public Document.from_string (string memory) throws DomError {
			/* TODO: consider breaking API to support
			 * xmlParserOptions, encoding, and base URL
			 * from xmlReadMemory */
			Xml.Doc *doc = Xml.Parser.parse_memory (memory, (int)memory.length);
			this.from_libxml2 (doc);
		}
		/**
		 * Creates an empty document.
		 */
		public Document () throws DomError {
			Xml.Doc *doc = new Xml.Doc ();
			this.from_libxml2 (doc, false);
		}

		/**
		 * This should be called by any function that wants to
		 * look at libxml2 data structures, particularly the
		 * attributes of elements.  Such as: saving an Xml.Doc
		 * to disk, or stringifying an Xml.Node.  GXml
		 * developer, if you grep for ".node" and ".xmldoc",
		 * you can help identify potential points where you
		 * should sync.
		 */
		internal void sync_dirty_elements () {
			Xml.Node * tmp_node;

			// TODO: test that adding attributes works with stringification and saving
			if (this.dirty_elements.length () > 0) {
				// tmp_node for generating Xml.Ns* objects when saving attributes
				tmp_node = new Xml.Node (null, "tmp");
				foreach (Element elem in this.dirty_elements) {
					elem.save_attributes (tmp_node);
				}
				this.dirty_elements = new List<Element> (); // clear the old list

				tmp_node->free ();
			}
		}


		/**
		 * Saves a Document to the file at path file_path
		 */
		// TODO: is this a simple Unix file path, or does libxml2 do networks, too?
		public void save_to_path (string file_path) {
			sync_dirty_elements ();

			// TODO: change this to a GIO file so we can save to in a cool way
			this.xmldoc->save_file (file_path);
		}

		/* TODO: consider adding a save_to_file, but then we
		 * need to figure out which flags to accept.  For now
		 * they can just figure it out themselves.
		 */

		/**
		 * Saves a Document to the OutputStream outstream.
		 */
		public void save_to_stream (OutputStream outstream, Cancellable? can = null) throws DomError {
			OutputStreamBox box = { outstream, can };

			sync_dirty_elements ();

			// TODO: make sure libxml2's vapi gets patched
			Xml.SaveCtxt *ctxt = new Xml.SaveCtxt.to_io ((Xml.OutputWriteCallback)_iowrite,
								     (Xml.OutputCloseCallback)_iooutclose,
								     &box, null, 0);
			ctxt->save_doc (this.xmldoc);
			ctxt->flush ();
			ctxt->close ();
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
			Xml.Node *xmlelem;
			Element new_elem;

			xmlelem = this.xmldoc->new_node (null, tag_name, null);
			this.new_nodes.append (xmlelem);
			new_elem = new Element (xmlelem, this);
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
		public NodeList get_elements_by_tag_name (string tag_name) {
			// TODO: does this ensure that the root element is also included?
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
			if (true == false) { // TODO: define validity
				throw new DomError.INVALID_CHARACTER ("'%s' contains invalid characters.".printf (str));
			}
		}
		public override string to_string (bool format = false, int level = 0) {
			string str;
			int len;

			sync_dirty_elements ();
			this.xmldoc->dump_memory_format (out str, out len, format);

			return str;
		}

		/*** DomNode methods ***/

		/**
		 * Appends new_child to this document. A document can
		 * only have one Element child, the root element, and
		 * one DocumentType.
		 *
		 * @return The newly added child.
		 */
		public override DomNode? append_child (DomNode new_child) throws DomError {
			if (new_child.node_type == NodeType.ELEMENT) {
				if (xmldoc->get_root_element () == null) {
					xmldoc->set_root_element (((Element)new_child).node);
				} else {
					throw new DomError.HIERARCHY_REQUEST ("Document already has a root element.  Could not add child element with name '%s'".printf (new_child.node_name));
				}
			} else if (new_child.node_type == NodeType.DOCUMENT_TYPE) {
				GLib.warning ("Appending document_types not yet supported");
			} else {
				GLib.warning ("Appending '%s' not yet supported", new_child.node_type.to_string ());
			}
			return null;
		}

		internal Node copy_node (Node foreign_node, bool deep = true) {
			foreign_node.owner_document.sync_dirty_elements ();
			Xml.Node *our_copy_xml = ((BackedNode)foreign_node).node->doc_copy (this.xmldoc, deep ? 1 : 0);
			// TODO: do we need to append this to this.new_nodes?  Do we need to append the result to this.nodes_to_free?  Test memory implications
			return this.lookup_node (our_copy_xml); // inducing a GXmlNode
		}
	}
}
