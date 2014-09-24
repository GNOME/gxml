/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
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
	 * Represents an XML Document as a tree of {@link GXml.Node}s.
	 *
	 * The Document has a root document element {@link GXml.Element}.
	 * A Document's schema can be defined through its
	 * {@link GXml.DocumentType}.
	 *
	 * Version: DOM Level 1 Core<<BR>>
	 * URL: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#i-Document]]
	 */
	public class Document : Node {
		/* *** Private properties *** */

		/**
		 * This contains a map of Xml.Nodes that have been
		 * accessed and the GXml Node we created to represent
		 * them on-demand.  That way, we don't create an Node
		 * for EVERY node, even if the user never actually
		 * accesses it.
		 */
		internal HashTable<Xml.Node*, Node> node_dict = new HashTable<Xml.Node*, Node> (GLib.direct_hash, GLib.direct_equal);
		// We don't want want to use Node's Xml.Node or its dict
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
		internal unowned Attr? lookup_attr (Xml.Attr *xmlattr) {
			// Xml.Attr and Xml.Node are intentionally compatible
			return (Attr)this.lookup_node ((Xml.Node*)xmlattr);
		}

		internal unowned Node? lookup_node (Xml.Node *xmlnode) {
			unowned Node domnode;

			if (xmlnode == null) {
				return null; // TODO: consider throwing an error instead
			}

			domnode = this.node_dict.lookup (xmlnode);
			if (domnode == null) {
				// If we don't have a cached the appropriate Node for a given Xml.Node* yet, create it (type matters)
				// TODO: see if we can attach logic to the enum {} to handle this
				NodeType nodetype = (NodeType)xmlnode->type;
				switch (nodetype) {
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
				case NodeType.ATTRIBUTE:
					new Attr ((Xml.Attr*)xmlnode, this);
					break;
					/* TODO: These are not yet implemented (but we won't support Document */
				case NodeType.ENTITY_REFERENCE:
				case NodeType.ENTITY:
				case NodeType.PROCESSING_INSTRUCTION:
				case NodeType.DOCUMENT_TYPE:
				case NodeType.NOTATION:
				case NodeType.DOCUMENT:
					GLib.warning ("Looking up %s from an xmlNode* is not supported", nodetype.to_string ());
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

		// TODO: DTD, sort of works
		/**
		 * The Document Type Definition (DTD) defining this document. This may be %NULL.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-doctype]]
		 */
		public DocumentType? doctype {
			// either null, or a DocumentType object
			get;
			private set;
		}
		/**
		 * Describes the features of the DOM implementation behind this document.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-implementation]]
		 */
		public Implementation implementation {
			// set in constructor
			get;
			private set;
		}
		/**
		 * The root node of the document's node tree.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-documentElement]]
		 */
		public Element document_element {
			// TODO: should children work at all on Document, or just this, to get root?
			get {
				return (Element)this.lookup_node (this.xmldoc->get_root_element ());
			}
			private set {
			}
		}

		/* A list of strong references to all GXml.Nodes that this Document has created  */
		private List<GXml.Node> nodes_to_free = new List<GXml.Node> ();
		/* A list of references to Xml.Nodes that were created, and may require freeing */
		private List<Xml.Node*> new_nodes = new List<Xml.Node*> ();

		~Document () {
			List<Xml.Node*> to_free = new List<Xml.Node*> ();

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

		/** Constructors */

		/**
		 * Creates a Document from a given Implementation, supporting
		 * the {@ GXml.Implementation.create_document} method.
		 *
		 * Version: DOM Level 3 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/DOM-Level-3-Core/core.html#Level-2-Core-DOM-createDocument]]
		 *
		 * @param impl Implementation creating this Document
		 * @param namespace_uri URI for the namespace in which this Document belongs, or %NULL
		 * @param qualified_name A qualified name for the Document, or %NULL
		 * @param doctype The type of the document, or %NULL
		 *
		 * @return The new document; this must be freed with {@link GLib.Object.unref}
		 */
		internal Document.with_implementation (Implementation impl, string? namespace_uri, string? qualified_name, DocumentType? doctype) {
			this ();
			this.implementation = impl;

			Node root;
			root = this.create_element (qualified_name); // TODO: we do not currently support namespaces, but when we do, this new node will want one
			this.append_child (root);

			this.namespace_uri = namespace_uri;
			/* TODO: find out what should be set to qualified_name; perhaps this.node_name, but then that's supposed
			   to be "#document" according to NodeType definitions in http://www.w3.org/TR/DOM-Level-3-Core/core.html */
			this.doctype = doctype;
		}

		/**
		 * Creates a Document based on a libxml2 Xml.Doc* object.
		 *
		 * @param doc A {@link Xml.Doc} from libxml2
		 * @param require_root A flag to indicate whether we should require a root node, which the DOM normally expects
		 *
		 * @return A new {@link GXml.Document} wrapping the provided {@link Xml.Doc}; this must be freed with {@link GLib.Object.unref}
		 */
		public Document.from_libxml2 (Xml.Doc *doc, bool require_root = true) {
			/* All other constructors should call this one,
			   passing it a Xml.Doc* object */

			Xml.Node *root;

			if (doc == null) // should be impossible
				GXml.warning (DomException.INVALID_DOC, "Failed to parse document, xmlDoc* was NULL");

			if (require_root) {
				root = doc->get_root_element ();
				if (root == null) {
					GXml.warning (DomException.INVALID_ROOT, "Could not obtain a valid root for the document; xmlDoc*'s root was NULL");
				}
			}

			// TODO: consider passing root as a base node?
			base.for_document ();

			this.owner_document = this; // must come after base ()
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
		 * @param file_path A path to an XML document
		 *
		 * @return A {@link GXml.Document} for the given `file_path`; this must be freed with {@link GLib.Object.unref}
		 *
		 * @throws GXml.Error A {@link GXml.Error} if an error occurs while loading
		 */
		public Document.from_path (string file_path) throws GXml.Error {
			Xml.ParserCtxt ctxt;
			Xml.Doc *doc;
			Xml.Error *e;

			ctxt = new Xml.ParserCtxt ();
			doc = ctxt.read_file (file_path, null /* encoding */, 0 /* options */);

			if (doc == null) {
				e = ctxt.get_last_error ();
				GXml.warning (DomException.INVALID_DOC, "Could not load document from path: %s".printf (e->message));
				throw new GXml.Error.PARSER (GXml.libxml2_error_to_string (e));
			}

			this.from_libxml2 (doc);
		}

		/* For {@link GXml.Document.save_to_stream}, to write the document in chunks. */
		internal static int _iowrite (void *ctx, char[] buf, int len) {
			// TODO: can we make this private?
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

		/* For {@link GXml.Document.from_stream}, to read the document in chunks. */
		internal static int _iooutclose (void *ctx) {
			// TODO: can we make this private?
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
		 * Creates a Document for the {@link GLib.File} `fin`.
		 *
		 * @param fin The {@link GLib.File} containing the document
		 * @param can A {@link GLib.Cancellable} to let you cancel opening the file, or %NULL
		 *
		 * @return A new {@link GXml.Document} for `fin`; this must be freed with {@link GLib.Object.unref}
		 *
		 * @throws GLib.Error A {@link GLib.Error} if an error cocurs while reading the {@link GLib.File}
		 * @throws GXml.Error A {@link GXml.Error} if an error occurs while reading the file as a stream
		 */
		public Document.from_gfile (File fin, Cancellable? can = null) throws GXml.Error, GLib.Error {
			// TODO: actually handle cancellable
			InputStream instream;

			try {
				instream = fin.read (null);
				this.from_stream (instream, can);
				instream.close ();
			} catch (GLib.Error e) {
				GXml.warning (DomException.INVALID_DOC, "Could not load document from GFile: " + e.message);
				throw e;
			}
		}

		/**
		 * Creates a {@link GXml.Document} from data provided
		 * through a {@link GLib.InputStream}.
		 *
		 * @param instream A {@link GLib.InputStream} providing our document
		 * @param can      A {@link GLib.Cancellable} object allowing the caller
		 *                 to interrupt and cancel this operation, or %NULL
		 *
		 * @return A new {@link GXml.Document} built from the contents of instream;
		 *         this must be freed with {@link GLib.Object.unref}
		 *
		 * @throws GXml.Error A {@link GXml.Error} if an error occurs while reading the stream
		 */
		public Document.from_stream (InputStream instream, Cancellable? can = null) throws GXml.Error {
			InputStreamBox box = { instream, can };
			Xml.Doc *doc;
			/* TODO: provide Cancellable as user data so we can actually
			   cancel these */
			Xml.TextReader reader;
			Xml.Error *e;
			string errmsg = null;

			reader = new Xml.TextReader.for_io ((Xml.InputReadCallback)_ioread,
							    (Xml.InputCloseCallback)_ioinclose,
							    &box, "", null, 0);
			if (-1 == reader.read ()) {
				errmsg = "Error reading from stream";
			} else if (null == reader.expand ()) {
				errmsg = "Error expanding from stream";
			} else {
				// yay
				doc = reader.current_doc ();
				reader.close ();
				this.from_libxml2 (doc);

				return;
			}

			// uh oh
			e = Xml.Error.get_last_error ();
			if (e != null) {
				errmsg += ".  " + libxml2_error_to_string (e);
			}
			GXml.warning (DomException.INVALID_DOC, errmsg);
			throw new GXml.Error.PARSER (errmsg);
		}

		/**
		 * Creates a Document from data found in memory.
		 *
		 * @param xml A string representing an XML document
		 *
		 * @return A new {@link GXml.Document} from `memory`; this must be freed with {@link GLib.Object.unref}
		 */
		public Document.from_string (string xml) {
			Xml.Doc *doc;
			doc = Xml.Parser.parse_memory (xml, (int)xml.length);
			this.from_libxml2 (doc);
		}
		/**
		 * Creates a Document from data found in memory using options.
		 *
		 * @param xml A string representing an XML document
		 * @param url the base URL to use for the document
		 * @param encoding the document encoding
		 * @param options a combination of {@link Xml.ParserOption}
		 *
		 * @return A new {@link GXml.Document} from `memory`; this must be freed with {@link GLib.Object.unref}
		 */
		public Document.from_string_with_options (string xml, string? url = null,
		                                          string? encoding = null,
		                                          int options = 0)
		{
		  Xml.Doc *doc;
		  doc = Xml.Parser.read_memory (xml, (int)xml.length, url, encoding, options);
		  this.from_libxml2 (doc);
		}

		/**
		 * Creates an empty document.
		 *
		 * @return A new, empty {@link GXml.Document}; this must be freed with {@link GLib.Object.unref}
		 */
		public Document () {
			Xml.Doc *doc;

			doc = new Xml.Doc ();
			this.from_libxml2 (doc, false);
		}

		/**
		 * Saves a Document to the file at path file_path
		 *
		 * @param file_path A path on the local system to save the document to
		 *
		 * @throws GXml.Error A {@link GXml.Error} if an error occurs while writing
		 */
		// TODO: is this a simple Unix file path, or does libxml2 do networks, too?
		public void save_to_path (string file_path) throws GXml.Error {
			string errmsg;
			Xml.Error *e;

			// TODO: change this to a GIO file so we can save to in a cool way

			if (-1 == this.xmldoc->save_file (file_path)) {
				errmsg = "Failed to write file to path '%s'".printf (file_path);
			} else {
				// yay!
				return;
			}

			// uh oh
			e = Xml.Error.get_last_error ();
			if (e != null) {
				errmsg += ".  " + libxml2_error_to_string (e);
			}

			// TODO: use xmlGetLastError to get the real error message
			GXml.warning (DomException.X_OTHER, errmsg);
			throw new GXml.Error.WRITER (errmsg);
		}

		/* TODO: consider adding a save_to_file, but then we
		 * need to figure out which flags to accept.  For now
		 * they can just figure it out themselves.
		 */

		/**
		 * Saves a Document to the OutputStream outstream.
		 *
		 * @param outstream A destination {@link GLib.OutputStream} to save the XML file to
		 * @param can A {@link GLib.Cancellable} to cancel saving with, or %NULL
		 *
		 * @throws GXml.Error A {@link GXml.Error} is thrown if saving encounters an error
		 */
		public void save_to_stream (OutputStream outstream, Cancellable? can = null) throws GXml.Error {
			OutputStreamBox box = { outstream, can };
			string errmsg = null;
			Xml.Error *e;

			/* TODO: provide Cancellable as user data and let these check it
			         so we can actually be interruptible */
			Xml.SaveCtxt *ctxt;
			ctxt = new Xml.SaveCtxt.to_io ((Xml.OutputWriteCallback)_iowrite,
						       (Xml.OutputCloseCallback)_iooutclose,
						       &box, null, 0);
			if (ctxt == null) {
				errmsg = "Failed to create serialization context when saving to stream";
			} else if (-1 == ctxt->save_doc (this.xmldoc)) {
				errmsg = "Failed to save document";
			} else if (-1 == ctxt->flush ()) {
				errmsg = "Failed to flush remainder of document while saving to stream";
			} else if (-1 == ctxt->close ()) {
				errmsg = "Failed to close saving context when saving to stream";
			} else {
				/* success! */
				return;
			}

			/* uh oh */
			e = Xml.Error.get_last_error ();
			if (e != null) {
				errmsg += ".  " + libxml2_error_to_string (e);
			}

			GXml.warning (DomException.X_OTHER, errmsg);
			throw new GXml.Error.WRITER (errmsg);
		}

		/* Public Methods */

		/**
		 * Creates an empty {@link GXml.Element} node with the tag name
		 * `tag_name`, which must be a
		 * [[http://www.w3.org/TR/REC-xml/#NT-Name|valid XML name]].
		 * Its memory is freed when its owner document is
		 * freed.
		 *
		 * XML example: {{{<Person></Person>}}}
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createElement]]

		 * @param tag_name The name of the new {@link GXml.Element}
		 *
		 * @return A new {@link GXml.Element}; this should not be freed
		 */
		public unowned Element create_element (string tag_name) {
			// TODO: what should we be passing for ns other than old_ns?  Figure it out; needed for level 2+ support
			Xml.Node *xmlelem;

			check_invalid_characters (tag_name, "element");

			xmlelem = this.xmldoc->new_node (null, tag_name, null);
			this.new_nodes.append (xmlelem);

			Element new_elem = new Element (xmlelem, this);
			this.nodes_to_free.append (new_elem);
			unowned Element ret = new_elem;

			return ret;
		}
		/**
		 * Creates a {@link GXml.DocumentFragment}.
		 *
		 * Document fragments do not can contain a subset of a
		 * document, without being a complete tree.  Its
		 * memory is freed when its owner document is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createDocumentFragment]]
		 *
		 * @return A {@link GXml.DocumentFragment}; this should not be freed
		 */
		public unowned DocumentFragment create_document_fragment () {
			DocumentFragment fragment = new DocumentFragment (this.xmldoc->new_fragment (), this);
			unowned DocumentFragment ret = fragment;
			this.nodes_to_free.append (fragment);
			return ret;
		}

		/**
		 * Creates a {@link GXml.Text} node containing the text in data.
		 * Its memory is freed when its owner document is freed.
		 *
		 * XML example:
		 * {{{<someElement>Text is contained here.</someElement>}}}
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createTextNode]]
		 *
		 * @param text_data The textual data for the {@link GXml.Text} node
		 *
		 * @return A new {@link GXml.Text} node containing
		 * the supplied data; this should not be freed
		 */
		public unowned Text create_text_node (string text_data) {
			Text text = new Text (this.xmldoc->new_text (text_data), this);
			unowned Text ret = text;
			this.nodes_to_free.append (text);
			return ret;
		}

		/**
		 * Creates an XML comment with data.  Its memory is
		 * freed when its owner document is freed.
		 *
		 * XML example: {{{<!-- data -->}}}
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createComment]]
		 *
		 * @param comment_data The content of the comment
		 *
		 * @return A new {@link GXml.Comment} containing the
		 * supplied data; this should not be freed
		 */
		public unowned Comment create_comment (string comment_data) {
			// TODO: should we be passing around Xml.Node* like this?
			Comment comment = new Comment (this.xmldoc->new_comment (comment_data), this);
			unowned Comment ret = comment;
			this.nodes_to_free.append (comment);
			return ret;
		}

		/**
		 * Creates a CDATA section containing data.
		 *
		 * These do not apply to HTML doctype documents.  Its
		 * memory is freed when its owner document is freed.
		 *
		 * XML example:
		 * {{{ <![CDATA[Here contains non-XML data, like code, or something that requires a lot of special XML entities.]]>. }}}
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createCDATASection]]
		 *
		 * @param cdata_data The content for the CDATA section
		 *
		 * @return A new {@link GXml.CDATASection} with the
		 * supplied data; this should not be freed
		 */
		public unowned CDATASection create_cdata_section (string cdata_data) {
			check_not_supported_html ("CDATA section");

			CDATASection cdata = new CDATASection (this.xmldoc->new_cdata_block (cdata_data, (int)cdata_data.length), this);
			unowned CDATASection ret = cdata;
			this.nodes_to_free.append (cdata);
			return ret;
		}

		/**
		 * Creates a new {@link GXml.ProcessingInstruction}.
		 *
		 * Its memory is freed when its owner document is
		 * freed.
		 *
		 * XML example:
		 * {{{ <?pi_target processing instruction data?>
		 * <?xml-stylesheet href="style.xsl" type="text/xml"?>}}}
		 *
		 * In the above example, the Processing Instruction's
		 * target is 'xml-stylesheet' and its content data is
		 * 'href="style.xsl" type="text/xml"'.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createProcessingInstruction]]
		 *
		 * @param target The target of the instruction
		 * @param data The content of the instruction
		 *
		 * @return A new {@link GXml.ProcessingInstruction}
		 * for the given target; this should not be freed
		 */
		public ProcessingInstruction create_processing_instruction (string target, string data) {
			/* TODO: this is not backed by a libxml2 structure,
			   and is not stored in the NodeDict, so we don't know
			   when it will be freed :( Figure it out.

			   It looks like so far this GXmlProcessingInstruction node doesn't
			   get recorded by its owner_document at all, so the reference
			   is probably lost.

			   We want to manage it with the GXmlDocument, though, and not
			   make the developer manage it, because that would be inconsistent
			   with the rest of the tree (even if the user doesn't insert
			   this PI into a Document at all.  */
			check_not_supported_html ("processing instructions");
			check_invalid_characters (target, "processing instruction");

			// TODO: want to see whether we can find a libxml2 structure for this
			ProcessingInstruction pi = new ProcessingInstruction (target, data, this);

			return pi;
		}

		/**
		 * Creates an {@link GXml.Attr} attribute with `name`, usually to be associated with an Element.
		 *
		 * XML example: {{{<element attributename="attributevalue">content</element>}}}
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createAttribute]]
		 *
		 * @param name The `name` of the attribute
		 *
		 * @return A new {@link GXml.Attr} with the given `name`; this should not be freed
		 */
		public Attr create_attribute (string name) {
			/* TODO: figure out memory for this; its a
			 * Node, not a BackedNode and thus not in
			 * nodedict.  It's like Processing Instruction
			 * in that regard.
			 *
			 * That said, we might be able to make it a
			 * BackedNode after all depending on how
			 * comfortable we are treating libxml2
			 * xmlAttrs as xmlNodes. :D
			 */
			check_invalid_characters (name, "attribute");

			return new Attr (this.xmldoc->new_prop (name, ""), this);

			/* TODO: should we pass something other than
			   "" for the unspecified value?  probably
			   not, "" is working fine so far.

			   Actually, this introduces troublesome
			   compatibility issues when porting libxml2
			   code to GXml, because in GXml, an
			   unspecified value is also "" (because of
			   the spec) whereas in libxml2 it is NULL. */

			/* TODO: want to create a convenience method
			   to create a new Attr with name and value
			   spec'd, like create_attribute_with_value
			   (), make sure that's not already spec'd in
			   later DOM levels. */
		}

		/**
		 * Creates an entity reference.
		 *
		 * XML example: {{{&name;}}}, for example an apostrophe has the name 'apos', so in XML it appears as {{{&apos;}}}
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-createEntityReference]]
		 *
		 * @param name The 'name' of the entity reference
		 *
		 * @return An {@link GXml.EntityReference} for `name`; this should not be freed
		 */
		public EntityReference create_entity_reference (string name) {
			check_not_supported_html ("entity reference");
			check_invalid_characters (name, "entity reference");

			return new EntityReference (name, this);
			// TODO: doublecheck that libxml2 doesn't have a welldefined ER
		}

		/**
		 * Obtains a list of {@link GXml.Element}s, each with
		 * the given tag name `tag_name`, contained within
		 * this document.
		 *
		 * Note that the list is live, updated as new elements
		 * are added to the document.
		 *
		 * Unlike a {@link GXml.Node} and its subclasses,
		 * {@link GXml.NodeList} are not part of the document
		 * tree, and thus their memory is not managed for the
		 * user, so the user must explicitly free them.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-getElementsByTagName]]
		 *
		 * @param tag_name The {@link GXml.Element} tag name we matching for
		 *
		 * @return A {@link GXml.NodeList} of
		 * {@link GXml.Element}s; this must be freed with
		 * {@link GLib.Object.unref}.
		 */
		public NodeList get_elements_by_tag_name (string tag_name) {
			// TODO: verify that it is still live :D
			// TODO: does this ensure that the root element is also included?
			// TODO: determine whether the use needs to free these lists
			return this.document_element.get_elements_by_tag_name (tag_name);
		}

		/**
		 * Feature should be something like "processing instructions"
		 */
		private void check_not_supported_html (string feature) {
			if (this.doctype != null && (this.doctype.name.casefold () == "html".casefold ())) {
				GXml.warning (DomException.NOT_SUPPORTED, "HTML documents do not support '%s'".printf (feature)); // TODO: i18n
			}
		}

		/**
		 * Subject should be something like "element" or "processing instruction"
		 */
		internal static bool check_invalid_characters (string name, string subject) {
			/* TODO: use Xml.validate_name instead  */
			if (Xml.validate_name (name, 0) != 0) { // TODO: define validity
				GXml.warning (DomException.INVALID_CHARACTER, "Provided name '%s' for '%s' is not a valid XML name".printf (name, subject));
				return false;
			}

			return true;
		}

		/**
		 * {@inheritDoc}
		 */
		public override string to_string (bool format = true, int level = 0) {
			string str;
			int len;

			this.xmldoc->dump_memory_format (out str, out len, format);

			return str;
		}

		/*** Node methods ***/

		/**
		 * {@inheritDoc}
		 */
		public override NodeList? child_nodes {
			owned get {
				// TODO: always create a new one?
				// TODO: xmlDoc and xmlNode are very similar, but perhaps we shouldn't do this :D
				return new NodeChildNodeList ((Xml.Node*)this.xmldoc, this.owner_document);
			}
			internal set {
			}
		}


		/**
		 * Replaces `old_child` with `new_child` in this node's list of children.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-replaceChild]]
		 *
		 * @param new_child The child we will replace `old_child` with
		 * @param old_child The child being replaced
		 *
		 * @return The removed node `old_child`; this should not be freed
		 */
		public override unowned Node? replace_child (Node new_child, Node old_child) {
			if (new_child.node_type == NodeType.ELEMENT ||
			    new_child.node_type == NodeType.DOCUMENT_TYPE) {
				/* let append_child do it with its error handling, since
				   we don't consider position with libxml2 */
				return this.append_child (new_child);
			} else {
				return this.replace_child (new_child, old_child);
			}
		}

		/**
		 * Removes `old_child` from this document's list of
		 * children.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-removeChild]]
		 *
		 * @param old_child The child we wish to remove
		 *
		 * @return The removed node `old_child`; this should not be freed
		 */
		public override unowned Node? remove_child (Node old_child) {
			return this.child_nodes.remove_child (old_child);
		}

		/**
		 * Inserts `new_child` into this document before
		 * `ref_child`, an existing child of this
		 * {@link GXml.Document}. A document can only have one
		 * {@link GXml.Element} child (the root element) and
		 * one {@link GXml.DocumentType}.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-952280727]]
		 *
		 * @param new_child The new node to insert into the document
		 * @param ref_child The existing child of the document that new_child will precede, or %NULL
		 *
		 * @return The newly inserted child; this should not be freed
		 */
		public override unowned Node? insert_before (Node new_child, Node? ref_child) {
			if (new_child.node_type == NodeType.ELEMENT ||
			    new_child.node_type == NodeType.DOCUMENT_TYPE) {
				/* let append_child do it with its error handling, since
				   we don't consider position with libxml2 */
				return this.append_child (new_child);
			} else {
				return this.child_nodes.insert_before (new_child, ref_child);
			}
		}

		/**
		 * Appends new_child to this document, appearing at
		 * the end of its list of children.  A document can
		 * only have one {@link GXml.Element} child, the root
		 * element, and one {@link GXml.DocumentType}.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-appendChild]]
		 *
		 * @param new_child The child we're appending
		 *
		 * @return The newly added child; this should not be freed
		 */
		public override unowned Node? append_child (Node new_child) {
			this.check_wrong_document (new_child);
			this.check_read_only ();

			if (new_child.node_type == NodeType.ELEMENT) {
				if (xmldoc->get_root_element () == null) {
					xmldoc->set_root_element (((Element)new_child).node);
				} else {
					GXml.warning (DomException.HIERARCHY_REQUEST, "Document already has a root element.  Could not add child element with name '%s'".printf (new_child.node_name));
				}
			} else if (new_child.node_type == NodeType.DOCUMENT_TYPE) {
				if (this.doctype == null) {
					this.doctype = (DocumentType)new_child;
				} else {
					GXml.warning (DomException.HIERARCHY_REQUEST, "Document already has a doctype.  Could not add new doctype with name '%s'.".printf (((DocumentType)new_child).name));
				}
			} else {
				return this.child_nodes.append_child (new_child);
			}

			return null;
		}

		/**
		 * {@inheritDoc}
		 */
		public override bool has_child_nodes () {
			return (xmldoc->children != null);
		}

		public unowned Node copy_node (Node foreign_node, bool deep = true) {
			Xml.Node *our_copy_xml = ((BackedNode)foreign_node).node->doc_copy (this.xmldoc, deep ? 1 : 0);
			// TODO: do we need to append this to this.new_nodes?  Do we need to append the result to this.nodes_to_free?  Test memory implications
			return this.lookup_node (our_copy_xml); // inducing a GXmlNode
		}
	}
}
