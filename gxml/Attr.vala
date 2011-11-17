/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* NOTE: attributes may contain trees as references, for entity references */
/* TODO: figure out whether, if in Element we use set_attribute and
 * change one, whether an Attr node should have its value replaced */
/* allowed values defined in a separate DTD; we won't be parsing those :D */

/* NOTE: default values: complex, might want a hash table storing them for each attribute name */
/* NOTE: children might contain Text or Entity references */
/* NOTE: might want to base this on Xml.Attribute instead (can we?) */
/* NOTE: specified is false if it wasn't set, but was created because it still supplied a default value, I think */
/* NOTE: figure out how entity references work with Attrs */
/* NOTE: value as children nodes: can contain Text and EntityReferences */

namespace GXmlDom {
	/**
	 * Represents an XML Attr node. These represent name=value
	 * attributes associated with XML Elements. Values are often
	 * represented as strings but can also be subtrees for some
	 * Nodes.  For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-637646024]]
	 */
	public class Attr : XNode {
		/**
		 * {@inheritDoc}
		 */
		public override string? namespace_uri {
			get {
				// TODO: there can be multiple NSes on a node, using ->next, right now we just return the first.  What should we do?!?!
				if (this.node->ns == null) {
					return null;
				} else {
					return this.node->ns->href;
				}
				// TODO: handle null ns_def
				// TODO: figure out when node->ns is used, as opposed to ns_def
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? prefix {
			get {
				if (this.node->ns == null) {
					return null;
				} else {
					return this.node->ns->prefix;
				}
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? local_name {
			get {
				return this.node_name;
			}
			internal set {
			}
		}

		/** Private properties */
		private Xml.Attr *node;

		/** Constructors */
		internal Attr (Xml.Attr *node, Document doc) {
			// TODO: wish valac would warn against using this. before calling base()
			base (NodeType.ATTRIBUTE, doc);
			this.node = node;
			this.specified = true;
		}

		/* Public properties (Node general) */

		/**
		 * The node_name of an attribute is the attribute's name.
		 */
		public override string node_name {
			get {
				return this.node->name;
			}
			internal set {
			}
		}

		/* "raises [DomError] on setting/retrieval"?  */
		private string _node_value;
		/**
		 * The node_value for an attribute is a string
		 * representing the contents of the Attr's tree of
		 * children.
		 */
		public override string? node_value {
			/* If Attrs were always attached to elements, then it would have been
			   nice to use elem.node->get/set_prop (name[,value])  :S */
			get {
				this._node_value = "";
				foreach (XNode child in this.child_nodes) {
					this._node_value += child.node_value;
					// TODO: verify that Attr node's child types'
					// node_values are sufficient for building the Attr's value.
				}
				return this._node_value;
			}
			internal set {
				try {
					// TODO: consider adding an empty () method to NodeList
					foreach (XNode child in this.child_nodes) {
						// TODO: this doesn't clear the actual underlying attributes' values, is this what we want to do?  It works if we eventually sync up values
						this.remove_child (child);
					}
					this.append_child (this.owner_document.create_text_node (value));
					// TODO: may want to normalise
				} catch (DomError e) {
					// TODO: handle
				}
				// TODO: need to expand entity references too?
			}
		}

		/**
		 * {@inheritDoc}
		 */
		/* already doc'd in XNode */
		public override NodeList? child_nodes {
			owned get {
				// TODO: always create a new one?
				//       no, this is broken, if we keep creating new ones
				//       then changes are lost each time we call one
				//       unless AttrChildNodeList makes changes to the underlying one
				//       ugh, how are we even passing tests right now?
				return new AttrChildNodeList (this.node, this.owner_document);
			}
			internal set {
			}
		}

		/* Public properties (Attr-specific) */

		/**
		 * The name of the attribute's name=value pair.
		 */
		public string name {
			get {
				// TODO: make sure that this is the right name, and that ownership is correct
				return this.node_name;
			}
			private set {
			}
		}

		/**
		 * Whether an Attr was explicitly set in the
		 * underlying document. If the attribute is changed,
		 * it is set to false.
		 *
		 * #todo: this requires support from the DTD, and
		 * probably libxml2's xmlAttribute
		 */
		public bool specified {
			// STUB
			get;
			private set;
		}

		/**
		 * Value of the Attr. This is the same as node_value.
		 * It is a stringified version of the value, which can
		 * also be accessed as a tree node structure of
		 * child_nodes.
		 */
		public string value {
			get {
				return this.node_value;
			}
			set {
				this.node_value = value;
			}
		}

		/* Public methods (Node-specific) */

		/**
		 * {@inheritDoc}
		 */
		public override XNode? insert_before (XNode new_child, XNode? ref_child) throws DomError {
			return this.child_nodes.insert_before (new_child, ref_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? replace_child (XNode new_child, XNode old_child) throws DomError {
			return this.child_nodes.replace_child (new_child, old_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? remove_child (XNode old_child) throws DomError {
			return this.child_nodes.remove_child (old_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? append_child (XNode new_child) throws DomError {
			return this.child_nodes.append_child (new_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override bool has_child_nodes () {
			return (this.child_nodes.length > 0);
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? clone_nodes (bool deep) {
			return this; // STUB
		}
	}

}
