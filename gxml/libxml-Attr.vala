/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Attr.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011,2015-2016  Daniel Espinosa <esodan@gmail.com>
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


namespace GXml {
	/**
	 * An XML Attr node, which represents a name="value" pair.
	 *
	 * These represent name="value" attributes associated with XML Elements
	 * (see {@link GXml.Element}). Values are often represented as strings but can
	 * also be more complex subtrees for some nodes.
	 *
	 * To create one, use {@link GXml.xDocument.create_attribute}.
	 *
	 * XML Example: Here, we have an Attr with the name 'flavour'
	 * and the value 'pumpkin'. {{{<pie flavour="pumpkin" />}}}
	 *
	 * Version: DOM Level 1 Core<<BR>>
	 *
	 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-637646024]]
	 *
	 * @see GXml.Node
	 */
	[Version (deprecated=true, deprecated_since="0.12", replacement="GAttribute")]
	public class xAttr : BackedNode, GXml.Attribute {
		/** Private properties */
		/* this displaces BackedNode's xmlNode node */
		internal new Xml.Attr *node;
		internal AttrChildNodeList _attr_list;

		/** Constructors */
		internal xAttr (Xml.Attr *node, xDocument doc) {
			// TODO: wish valac would warn against using this. before calling base()
			//base (NodeType.ATTRIBUTE, doc);
			base ((Xml.Node*)node, doc);
			this.node = node;
			this.specified = true;
			_attr_list = new AttrChildNodeList (this.node, this.owner_document);
		}

		/* Public properties (Node general) */

		private string _node_value;
		/* TODO: find out how to get these to appear in GtkDocs, since they're
		   overriding a base class.  Figure out how to get that multiple lines to
		   appear in the generated valadoc */
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
				foreach (xNode child in this.child_nodes) {
					this._node_value += child.node_value;
					// TODO: verify that Attr node's child types'
					// node_values are sufficient for building the Attr's value.
				}
				return this._node_value;
			}
			internal set {
				// TODO: consider adding an empty () method to NodeList
				foreach (xNode child in this.child_nodes) {
					this.remove_child (child);
				}
				this.append_child (this.owner_document.create_text_node (value));
				// TODO: may want to normalise
				// TODO: need to expand entity references too?
			}
		}

		/**
		 * {@inheritDoc}
		 *
		 * Note: In libxml2, xmlAttrs have parent nodes, which are the Elements that
		 * contain them.  In the W3C DOM, they specifically don't.
		 *
		 * URL: [[http://www.w3.org/2003/01/dom2-javadoc/org/w3c/dom/Attr.html]]
		 */
		/* TODO: figure out whether the W3C DOM thinks that the same Attr could
		 * belong to multiple Elements.  As we have it implemented, each Attr
		 * can belong to 0 or 1 Elements only.
		 */
		public override xNode? parent_node {
			get {
				return null;
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 *
		 * Note: In libxml2, xmlAttrs have siblings, which are other Attrs contained
		 * by the same Element.  In the W3C DOM, they specifically don't.
		 *
		 * URL: [[http://www.w3.org/2003/01/dom2-javadoc/org/w3c/dom/Attr.html]]
		 */
		public override xNode? previous_sibling {
			get {
				return null;
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 *
		 * Note: In libxml2, xmlAttrs have siblings, which are other Attrs contained
		 * by the same Element.  In the W3C DOM, they specifically don't.
		 *
		 * URL: [[http://www.w3.org/2003/01/dom2-javadoc/org/w3c/dom/Attr.html]]
		 */
		public override xNode? next_sibling {
			get {
				return null;
			}
			internal set {
			}
		}


		/**
		 * {@inheritDoc}
		 */
		public override xNodeList? child_nodes {
			get {
				/* TODO: always create a new one?
				       no, this is broken, if we keep creating new ones
				       then changes are lost each time we call one
				       unless AttrChildNodeList makes changes to the underlying
				       one ugh, how are we even passing tests right now? */
				return _attr_list;
			}
			internal set {
			}
		}

		/* Public properties (Attr-specific) */

		/**
		 * The name of the attribute's name=value pair.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1112119403]]
		 */
		public override string name {
			owned get {
				// TODO: make sure that this is the right name, and that ownership is correct
				return this.node_name.dup ();
			}
		}

		/**
		 * Whether an Attr was explicitly set in the
		 * underlying document. If the attribute is changed,
		 * it is set to false.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-862529273]]
		 */
		/* @todo: this requires support from the DTD, and
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
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-221662474]]
		 */
		public override string value {
			owned get {
				return this.node_value.dup ();
			}
			set {
				this.node_value = value;
			}
		}

		/* TODO: make sure that xmlCopyNode (used in BackedNode)
		   is correct for xmlAttr, or we'll have to manually
		   use xmlCopyProp */
		// public override unowned Node? clone_node (bool deep) {
		// 	GLib.warning ("Cloning of Attrs not yet supported");
		// 	return this; // STUB
		// }

		/**
		 * {@inheritDoc}
		 */
		public override string stringify (bool format = false, int level = 0) {
			return "Attr(%s=\"%s\")".printf (this.name, this.value);
		}
		// GXml.Attribute
		public string? prefix {
			owned get {
				if (node == null) return "";
				if (node->ns == null) return "";
				return node->ns->prefix.dup ();
			}
		}
		public Namespace? @namespace {
			owned get {
				if (node == null) return null;
				if (node->ns == null) return null;
				return new NamespaceAttr (node->ns, this.owner_document);
			}
			set {
				if (node == null) return;
				if (node->doc == null) return;
				if (node->parent == null) return;
				var ns = node->parent->new_ns (value.uri, value.prefix);
				node->ns = ns;
			}
		}
	}

}
