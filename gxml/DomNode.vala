/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml {
	/* TODO: consider adding public signals for new/deleted children */

	/**
	 * Represents an XML Node. Documents are nodes, and are
	 * composed of a tree of nodes. See [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1950641247]]
	 */
	public class DomNode : GLib.Object {
		internal DomNode (NodeType type, Document owner) {
			this.node_type = type;
			this.owner_document = owner;
		}
		internal DomNode.for_document () {
			this.node_name = "#document";
			this.node_type = NodeType.DOCUMENT;
		}

		public void dbg_inspect () {
			message ("node: %s", this.node_name);
			message ("  ns (prefix: %s, uri: %s)", this.prefix, this.namespace_uri);
			if (this.attributes != null) {
				message ("  attributes:");
				foreach (DomNode attr in this.attributes.get_values ()) {
					message ("    %s", attr.node_name);
				}
			}
			message ("  children:");
			if (this.child_nodes != null) {
				// TODO: consider having non-null hcild_nodes and attributes,
				//       and instead returning empty collections
				//     No, probably don't want that, as nodes which don't
				//     support them really do just want to return null ala spec
				foreach (DomNode child in this.child_nodes) {
					message ("    %s", child.node_name);
				}
			}
		}

		// TODO: determine best API for exposing these, as it's not defined in the IDL
		/**
		 * The list of attributes that store namespace definitions
		 */
		public virtual NodeList? namespace_definitions {
			get {
				return null;
			}
			internal set {
			}
		}

		/**
		 * Stores the URI describing the node's namespace.
		 * This only applies to Elements and Attrs from DOM
		 * Level 2 Core that were created with namespace
		 * support.
		 */
		public virtual string? namespace_uri {
			get {
				return null;
			}
			internal set {
			}
		}
		/**
		 * Stores the namespace prefix for the node. This
		 * only applies to Elements and Attrs from DOM Level 2
		 * Core that were created with namespace support.
		 */
		public virtual string? prefix {
			get {
				return null;
			}
			internal set {
			}
		}
		/**
		 * Stores the local name within the namespace. This
		 * only applies to Elements and Attrs from DOM Level 2
		 * Core that were created with namespace support.
		 */
		public virtual string? local_name {
			get {
				return null;
			}
			internal set {
			}
		}

		/**
		 * Stores the value of the Node. The nature of
		 * node_value varies based on the type of node. This
		 * can be null.
		 */
		public virtual string? node_value {
			get {
				return null;
			}
			internal set {
			}
		}

		/**
		 * Stores the name of the node. Sometimes this is
		 * similar to the node type, but sometimes, it is
		 * arbitrary.
		 */
		public virtual string node_name {
			get; internal set;
		}


		private NodeType _node_type;
		/**
		 * Stores the type of node. Most XML structures are
		 * nodes of different types, like Document, Attr,
		 * Element, etc.
		 */
		public virtual NodeType node_type {
			get {
				return _node_type;
			}
				// return  (NodeType)this.node->type; // TODO: Same type?  Do we want to upgrade ushort to ElementType?
			//}
			internal set {
				this._node_type = value;
			}
		}

		/**
		 * A link to the Document to which this node belongs.
		 */
		public Document owner_document {
			get;
			internal set;
		}

		// TODO: declare more of interface here
		/**
		 * A link to the parent of this node. For example,
		 * with elements, the immediate, outer element is the parent.
		 * <parent><child></child></parent>
		 */
		public virtual DomNode? parent_node {
			get { return null; }
			internal set {}
		}
		/**
		 * List of child nodes to this node. These sometimes
		 * represent the value of a node as a tree of values,
		 * whereas node_value represents it as a string. This
		 * can be null for node types that have no children.
		 *
		 * The NodeList is live, in that changes to this
		 * node's children will be reflected in an
		 * already-active NodeList.
		 *
		 * #todo: list nodes that use children for values
		 */
		public virtual NodeList? child_nodes {
			// TODO: need to implement NodeList
			owned get { return null; }
			internal set {}
		}
		/**
		 * Links to the first child. If there are no
		 * children, it returns null.
		 */
		public virtual DomNode? first_child {
			get { return null; }
			internal set {}
		}
		/**
		 * Links to the last child. If there are no
		 * children, it returns null.
		 */
		public virtual DomNode? last_child {
			get { return null; }
			internal set {}
		}
		/**
		 * Links to this node's preceding sibling. If there
		 * are no previous siblings, it returns null. Note
		 * that the children of a node are ordered.
		 */
		public virtual DomNode? previous_sibling {
			get { return null; }
			internal set {}
		}
		/**
		 * Links to this node's next sibling. If there is no
		 * next sibling, it returns null. Note that the
		 * children of a node are ordered.
		 */
		public virtual DomNode? next_sibling {
			get { return null; }
			internal set {}
		}
		/**
		 * Returns a HashTable representing the attributes for
		 * this node. Attributes actually only apply to
		 * Element nodes. For all other types, attributes is
		 * null.
		 */
		public virtual HashTable<string,Attr>? attributes {
			get { return null; }
			internal set {}
		}

		// These may need to be overridden by subclasses that support them.
		// TODO: figure out what non-BackedNode classes should be doing with these, anyway
		/**
		 * Insert new_child as a child to this node, and place
		 * it in the list before ref_child. If ref_child is
		 * null, new_child is appended to the list of children
		 * instead.
		 *
		 * @throws DomError.NOT_FOUND if ref_child is not a valid child.
		 */
		// #todo: want to throw other relevant errors
		public virtual DomNode? insert_before (DomNode new_child, DomNode? ref_child) throws DomError {
			return null;
		}
		/**
		 * Replaces old_child with new_child in this node's list of children.
		 *
		 * @return The removed old_child.
		 *
		 * @throws DomError.NOT_FOUND if ref_child is not a valid child.
		 */
		public virtual DomNode? replace_child (DomNode new_child, DomNode old_child) throws DomError {
			return null;
		}
		/**
		 * Removes old_child from this node's list of children.
		 *
		 * @return The removed old_child.
		 *
		 * @throws DomError.NOT_FOUND if old_child is not a valid child.
		 * #todo: make @throws claim true
		 */
		public virtual DomNode? remove_child (DomNode old_child) throws DomError {
			return null;
		}
		/**
		 * Appends new_child to the end of this node's list of children.
		 *
		 * @return The newly added child.
		 */
		public virtual DomNode? append_child (DomNode new_child) throws DomError {
			return null;
		}
		/**
		 * Indicates whether this node has children.
		 */
		public virtual bool has_child_nodes () {
			return false;
		}
		/**
		 * Creates a parentless copy of this node.
		 *
		 * @param deep If true, descendants are cloned as
		 * well. If false, they are not.
		 *
		 * @return A parentless clone of this node.
		 */
		public virtual DomNode? clone_nodes (bool deep) {
			return null;
		}

		private string _str;
		/**
		 * Provides a string representation of this node.
		 *
		 * @param format false: no formatting, true: formatted, with indentation
		 * @param level Indentation level
		 *
		 * @return XML string for node.
		 */
		// TODO: need to investigate how to activate format
		public virtual string to_string (bool format = false, int level = 0) {
			_str = "DomNode(%d:%s)".printf (this.node_type, this.node_name);
			return _str;
		}
	}
}

