/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* DomNode.vala
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

namespace GXml {
	/* TODO: consider adding public signals for new/deleted children */

	/**
	 * Represents an XML Node, the base class for most XML structures in
	 * the {@link GXml.Document}'s tree.
	 *
	 * {@link GXml.Document}s are {@link GXml.DomNode}s, and are
	 * composed of a tree of {@link GXml.DomNode}s.
	 *
	 * Version: DOM Level 1 Core
	 * URL: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1950641247]]
	 */
	public class DomNode : GLib.Object {
		/* Constructors */
		internal DomNode (NodeType type, Document owner) {
			this.node_type = type;
			this.owner_document = owner;
		}
		internal DomNode.for_document () {
			this.node_name = "#document";
			this.node_type = NodeType.DOCUMENT;
		}

		/* Utility methods */
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

		/* Properties */

		/**
		 * The list of attributes that store namespace definitions.  This is not part of a DOM spec.
		 * #TODO: determine best API for exposing these, as it's not defined in the IDL
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
		 *
		 * Version: DOM Level 2 Core
		 * URL: [[http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-NodeNSname]]
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
		 *
		 * Version: DOM Level 2 Core
		 * URL: [[http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-NodeNSPrefix]]
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
		 *
		 * Version: DOM Level 2 Core
		 * URL: [[http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-NodeNSLocalN]]
		 */
		public virtual string? local_name {
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
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-nodeName]]
		 */
		public virtual string node_name {
			get; internal set;
		}

		/**
		 * Stores the value of the Node. The nature of
		 * node_value varies based on the type of node. This
		 * can be null.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-nodeValue]]
		 */
		public virtual string? node_value {
			get {
				return null;
			}
			internal set {
				// TODO: NO_MODIFICATION_ALLOWED_ERR if check_read_only ()
			}
		}

		private NodeType _node_type;
		/**
		 * Stores the type of node. Most XML structures are
		 * nodes of different types, like Document, Attr,
		 * Element, etc.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-nodeType]]
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
		 * A link to the parent of this node. For example,
		 * with elements, the immediate, outer element is the parent.
		 *
		 * Example: {{{<parent><child></child></parent>}}}
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-parentNode]]
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
		 * The {@link GXml.NodeList} is live, in that changes to this
		 * node's children will be reflected in an
		 * already-active {@link GXml.NodeList}.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-childNodes]]
		 *
		 * #todo: identify node types that use children for values, like attribute
		 */
		public virtual NodeList? child_nodes {
			// TODO: need to implement NodeList
			owned get { return null; }
			internal set {}
		}

		/**
		 * Links to the first child. If there are no
		 * children, it returns null.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-firstChild]]
		 */
		public virtual DomNode? first_child {
			get { return null; }
			internal set {}
		}

		/**
		 * Links to the last child. If there are no
		 * children, it returns null.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-lastChild]]
		 */
		public virtual DomNode? last_child {
			get { return null; }
			internal set {}
		}

		/**
		 * Links to this node's preceding sibling. If there
		 * are no previous siblings, it returns null. Note
		 * that the children of a node are ordered.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-previousSibling]]
		 */
		public virtual DomNode? previous_sibling {
			get { return null; }
			internal set {}
		}

		/**
		 * Links to this node's next sibling. If there is no
		 * next sibling, it returns null. Note that the
		 * children of a node are ordered.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-nextSibling]]
		 */
		public virtual DomNode? next_sibling {
			get { return null; }
			internal set {}
		}

		/**
		 * A {@link GLib.HashTable} representing the
		 * attributes for this node. `attributes` actually
		 * only apply to {@link GXml.Element} nodes. For all
		 * other {@link GXml.DomNode} subclasses, `attributes`
		 * is null.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-attributes]]
		 */
		public virtual HashTable<string,Attr>? attributes {
			get { return null; }
			internal set {}
		}

		/**
		 * A link to the {@link GXml.Document} to which this node belongs.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-ownerDocument]]
		 */
		public weak Document owner_document {
			get;
			internal set;
		}

		/* Methods */

		/* These may need to be overridden by subclasses that support them.
		 * #TODO: figure out what non-BackedNode classes should be doing with these, anyway
		 * #TODO: want to throw other relevant errors */

		/**
		 * Insert `new_child` as a child to this node, and place
		 * it in the list before `ref_child`.
		 *
		 * If `ref_child` is `null`, `new_child` is appended to the
		 * list of children instead.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-insertBefore]]
		 *
		 * @return `new_child`, the node that has been inserted
		 */
		public virtual DomNode? insert_before (DomNode new_child, DomNode? ref_child) {
			return null;
		}
		/**
		 * Replaces `old_child` with `new_child` in this node's list of children.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-replaceChild]]
		 *
		 * @return The removed node `old_child`.
		 */
		public virtual DomNode? replace_child (DomNode new_child, DomNode old_child) {
			return null;
		}
		/**
		 * Removes `old_child` from this node's list of children.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-removeChild]]
		 *
		 * @return The removed node `old_child`.
		 */
		public virtual DomNode? remove_child (DomNode old_child) {
			return null;
		}
		/**
		 * Appends `new_child` to the end of this node's list of children.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-appendChild]]
		 *
		 * @return The newly added child.
		 */
		public virtual DomNode? append_child (DomNode new_child) {
			return null;
		}
		/**
		 * Indicates whether this node has children.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-hasChildNodes]]
		 *
		 * @return `true` if this node has children, `false` if not
		 */
		public virtual bool has_child_nodes () {
			return false;
		}

		/**
		 * Creates a parentless copy of this node.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-cloneNode]]
		 *
		 * @param deep If `true`, descendants are cloned as well. If `false`, they are not.
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
		 * @return XML string for node
		 */
		// TODO: need to investigate how to activate format
		// TODO: indicate in C that the return value must be freed.
		// TODO: ask Colin Walters about storing docs in GIR files (might have not been him)
		public virtual string to_string (bool format = false, int level = 0) {
			_str = "DomNode(%d:%s)".printf (this.node_type, this.node_name);
			return _str;
		}
	}
}

