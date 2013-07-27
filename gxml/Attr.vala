/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Attr.vala
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
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

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

[CCode (gir_namespace = "GXml", gir_version = "0.3")]
namespace GXml {
	/**
	 * Represents an XML Attr node, a name=value pair.
	 *
	 * To create one, use {@link GXml.Document.create_attribute}.
	 *
	 * These represent name=value attributes associated with XML
	 * {@link GXml.Element}s. Values are often represented as strings but can
	 * also be more complex subtrees for some nodes.
	 *
	 * Version: DOM Level 1 Core
	 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-637646024]]
	 */
	public class Attr : DomNode {
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
		internal Xml.Attr *node;

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
				foreach (DomNode child in this.child_nodes) {
					this._node_value += child.node_value;
					// TODO: verify that Attr node's child types'
					// node_values are sufficient for building the Attr's value.
				}
				return this._node_value;
			}
			internal set {
				try {
					// TODO: consider adding an empty () method to NodeList
					foreach (DomNode child in this.child_nodes) {
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
		/* already doc'd in DomNode */
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
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1112119403]]
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
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-862529273]]
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
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-221662474]]
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
		public override DomNode? insert_before (DomNode new_child, DomNode? ref_child) {
			return this.child_nodes.insert_before (new_child, ref_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override DomNode? replace_child (DomNode new_child, DomNode old_child) {
			return this.child_nodes.replace_child (new_child, old_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override DomNode? remove_child (DomNode old_child) {
			return this.child_nodes.remove_child (old_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override DomNode? append_child (DomNode new_child) {
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
		public override DomNode? clone_nodes (bool deep) {
			return this; // STUB
		}
	}

}
