/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Node.vala
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
	 * {@link GXml.Document}s are {@link GXml.Node}s, and are
	 * composed of a tree of {@link GXml.Node}s.
	 *
	 * Version: DOM Level 1 Core<<BR>>
	 * URL: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1950641247]]
	 */
	public class Node : GLib.Object {
		/* Constructors */
		internal Node (NodeType type, Document owner) {
			this.node_type = type;
			this.owner_document = owner;
		}
		internal Node.for_document () {
			this.node_name = "#document";
			this.node_type = NodeType.DOCUMENT;
		}

		/* Utility methods */

		internal void check_wrong_document (Node node) {
			Document this_doc;

			if (this.node_type == NodeType.DOCUMENT) {
				this_doc = (GXml.Document)this;
			} else {
				this_doc = this.owner_document;
			}

			if (this_doc != node.owner_document) {
				GXml.warning (DomException.WRONG_DOCUMENT, "Node tried to interact with this document '%p' but belonged to document '%p'".printf (this_doc, node.owner_document));
			}
		}


		internal bool check_read_only () {
			// TODO: protected methods appear in the generated gxml.h and in the GtkDoc, do we want that?
			// TODO: introduce a concept of read-only-ness, perhaps
			// if read-only, raise NO_MODIFICATION_ALLOWED_ERR
			return false;
		}


		internal void dbg_inspect () {
			message ("node: %s", this.node_name);
			message ("  ns (prefix: %s, uri: %s)", this.prefix, this.namespace_uri);
			if (this.attributes != null) {
				message ("  attributes:");
				for (int i = 0; i < this.attributes.length; i++) {
					Attr attr = this.attributes.item (i);
					message ("    %s", attr.node_name);
				}
			}
			message ("  children:");
			if (this.child_nodes != null) {
				// TODO: consider having non-null hcild_nodes and attributes,
				//       and instead returning empty collections
				//     No, probably don't want that, as nodes which don't
				//     support them really do just want to return null ala spec
				foreach (Node child in this.child_nodes) {
					message ("    %s", child.node_name);
				}
			}
		}

		/* Properties */

		/**
		 * The list of attributes that store namespace definitions.  This is not part of a DOM spec.
		 *
		 * The caller must free this using {@link GLib.Object.unref}.
		 */
		/* @TODO: determine best API for exposing these, as it's not defined in the IDL */
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
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 2 Core<<BR>>
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
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 2 Core<<BR>>
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
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 2 Core<<BR>>
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
		 * arbitrary data, like for {@link GXml.Attr} where
		 * the node_name is the name of the Attr's name=value
		 * pair.
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-F68D095]]
		 */
		public virtual string node_name {
			get; internal set;
		}

		/**
		 * Stores the value of the Node. The nature of
		 * node_value varies based on the type of node. This
		 * can be %NULL.
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-F68D080]]
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
		 * nodes of different types, like {@link GXml.Document}
		 * as a {@link GXml.NodeType.DOCUMENT}, {@link GXml.Attr}
		 * as a {@link GXml.NodeType.ATTRIBUTE}, Element as a
		 * {@link GXml.NodeType.ELEMENT}, etc.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-111237558]]
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
		 * A link to the parent_node of this node. For example,
		 * with elements, the immediate, outer element is the parent.
		 *
		 * XML example: {{{<parent><child></child></parent>}}}
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1060184317]]
		 */
		public virtual Node? parent_node {
			get { return null; }
			internal set {}
		}

		/**
		 * List of child nodes to this node. These sometimes
		 * represent the value of a node as a tree of
		 * {@link GXml.Node}, whereas node_value represents
		 * it as a string. This can be %NULL for node types
		 * that have no children.
		 *
		 * The {@link GXml.NodeList} is live, in that changes to this
		 * node's children will be reflected in an
		 * already-active {@link GXml.NodeList}.
		 *
		 * The caller must call {@link GLib.Object.unref} on
		 * the list when it is done with it.  The lists are
		 * constructed dynamically.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1451460987]]
		 */
		/*
		 * @todo: identify node types that use children for values, like attribute
		 */
		public virtual NodeList? child_nodes {
			// TODO: need to implement NodeList
			owned get { return null; }
			internal set {}
		}

		/**
		 * Links to the first child. If there are no
		 * children, it returns %NULL.
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-169727388]]
		 */
		public virtual Node? first_child {
			get { return null; }
			internal set {}
		}

		/**
		 * Links to the last child. If there are no
		 * children, it returns %NULL.
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-61AD09FB]]
		 */
		public virtual Node? last_child {
			get { return null; }
			internal set {}
		}

		/**
		 * Links to this node's preceding sibling. If there
		 * are no previous siblings, it returns %NULL. Note
		 * that the children of a node are ordered.
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-640FB3C8]]
		 */
		public virtual Node? previous_sibling {
			get { return null; }
			internal set {}
		}

		/**
		 * Links to this node's next sibling. If there is no
		 * next sibling, it returns %NULL. Note that the
		 * children of a node are ordered.
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-6AC54C2F]]
		 */
		public virtual Node? next_sibling {
			get { return null; }
			internal set {}
		}

		/**
		 * A {@link GXml.NamedNodeMap} containing the {@link GXml.Attr}
		 * attributes for this node. `attributes`
		 * actually only apply to {@link GXml.Element}
		 * nodes. For all other {@link GXml.Node} subclasses,
		 * `attributes` is %NULL.
		 *
		 * Do not free this.  It's memory will be released
		 * when the owning {@link GXml.Document} is freed.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-84CF09]]
		 */
		public virtual NamedAttrMap? attributes {
			// TODO: verify memory handling
			get {
				return null;
			}
			internal set {
			}
		}

		/**
		 * A link to the {@link GXml.Document} to which this node belongs.
		 *
		 * Do not free this unless you intend to free all
		 * memory owned by the {@link GXml.Document}, including this
		 * {@link GXml.Node}.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#node-ownerDoc]]
		 */
		public weak Document owner_document {
			get;
			internal set;
		}

		/* Methods */

		/* These may need to be overridden by subclasses that support them.
		 * @TODO: figure out what non-BackedNode classes should be doing with these, anyway
		 * @TODO: want to throw other relevant errors */

		/**
		 * Insert {@link new_child} as a child to this node,
		 * and place it in the list before {@link ref_child}.
		 * If {@link new_child} comes from another document, a copy
		 * of it belonging to this document is appended and
		 * returned.
		 *
		 * If {@link ref_child} is %NULL, {@link new_child} is appended to the
		 * list of children instead.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-insertBefore]]
		 *
		 * @param new_child A new {@link GXml.Node} that will become a child of the current one
		 * @param ref_child The child that {@link new_child} will be placed ahead of
		 *
		 * @return {@link new_child}, the node that has been
		 * inserted.  Do not free it, its memory will be
		 * released when the owning {@link GXml.Document} is
		 * freed.
		 */
		public virtual unowned Node? insert_before (Node new_child, Node? ref_child) {
			return null;
		}

		/**
		 * Replaces {@link old_child} with {@link new_child}
		 * in this node's list of children.  If {@link new_child}
		 * comes from another document, a copy of it belonging
		 * to this document is appended and returned.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-replaceChild]]
		 *
		 * @param new_child A new {@link GXml.Node} that will become a child of the current one
		 * @param old_child A {@link GXml.Node} that will be removed and replaced by {@link new_child}
		 *
		 * @return The removed node {@link old_child}.  Do not free it, its memory will be
		 * released when the owning {@link GXml.Document} is
		 * freed.
		 */
		public virtual unowned Node? replace_child (Node new_child, Node old_child) {
			return null;
		}

		/**
		 * Removes {@link old_child} from this node's list of children,
		 * {@link GXml.Node.child_nodes}.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-removeChild]]
		 *
		 * @param old_child The {@link GXml.Node} child to remove from the current one
		 *
		 * @return The removed node {@link old_child}.  Do not free it, its memory will be
		 * released when the owning {@link GXml.Document} is
		 * freed
		 */
		public virtual unowned Node? remove_child (Node old_child) {
			return null;
		}

		/**
		 * Appends {@link new_child} to the end of this node's
		 * list of children, {@link GXml.Node.child_nodes}.
		 * If the child comes from another document, a copy of
		 * it belonging to this document is appended and
		 * returned.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 *
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-appendChild]]
		 *
		 * @param new_child A new {@link GXml.Node} that will
		 * become the last child of this current node
		 *
		 * @return The newly added child, {@link new_child}, or a
		 * copy of it if {@link new_child} came from another
		 * document.  Do not free it, its memory will be
		 * released when the owning {@link GXml.Document} is
		 * freed.
		 */
		public virtual unowned Node? append_child (Node new_child) {
			return null;
		}

		/**
		 * Indicates whether this node has children.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 *
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-hasChildNodes]]
		 *
		 * @return %TRUE if this node has children, %FALSE if not
		 */
		public virtual bool has_child_nodes () {
			return false;
		}

		/**
		 * Creates a parentless copy of this node.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 *
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-cloneNode]]
		 *
		 * @param deep If %TRUE, descendants are cloned as well. If %FALSE, they are not
		 *
		 * @return A parentless clone of this node.  Do not
		 * free it, its memory will be released when the owning
		 * {@link GXml.Document} is freed.
		 */
		public virtual unowned Node? clone_node (bool deep) {
			return null;
		}

		/**
		 * Provides a string representation of this node.
		 *
		 * Note that if the DOM tree contains a Text node, a
		 * CDATA section, or an EntityRef, it will not be
		 * formatted, since the current implementation with
		 * libxml2 will not handle that case.  (See libxml2's
		 * xmlNodeDumpOutput internals to understand more.)
		 *
		 * @param format %FALSE: no formatting, %TRUE: formatted, with indentation
		 * @param level Indentation level
		 *
		 * @return XML string for node, which must be free
		 * this.
		 */
		// TODO: ask Colin Walters about storing docs in GIR files (might have not been him)
		public virtual string to_string (bool format = false, int level = 0) {
			return "Node(%d:%s)".printf (this.node_type, this.node_name);
		}

		/*** XPath functions ***/

		/* XPATH:TODO: should Node implement "XPathEvaluator" as an interface? No? */

		/**
		 * Evaluates XPath expression in context of current DOM node (or Document).
		 *
		 * @param expr XPath expression
		 * @param nsr namespace resolver object (prefix -> URI mapping)
		 * @param res_type type to cast resulting value to
		 * @return XPath.Result object containing result type and value
		 * @throws GXml.Error when node type is not supported as context of evaluation
		 * @throws XPath.Error when supplied with invalid XPath expression
		 */
		public XPath.Result evaluate (string expr, XPath.NSResolver? nsr = null,
			XPath.ResultType res_type = XPath.ResultType.ANY)
			throws GXml.Error, XPath.Error
		{
			var expression = new XPath.Expression (expr, nsr);
			return expression.evaluate (this, res_type);
		}
	}
}
