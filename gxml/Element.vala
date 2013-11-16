/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Element.vala
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
	// TODO: figure out how to create this; Xml.Doc doesn't have new_element()

	/**
	 * Represent an XML Element node, which have attributes and children.
	 *
	 * To create one, use {@link GXml.Document.create_element}.
	 *
	 * These can have child nodes
	 * of various types including other Elements. Elements can
	 * have Attr attributes associated with them. Elements have
	 * tag names. In addition to methods inherited from Node,
	 * Elements have additional methods for manipulating
	 * attributes, as an alternative to manipulating the
	 * attributes HashMap directly.
	 *
	 * Version: DOM Level 1 Core<<BR>>
	 * URL: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-745549614]]
	 */
	public class Element : BackedNode {
		/* Public properties */

		// TODO: find out how to do double-spaces in Valadoc, so we can indent <img...
		/**
		 * The element's tag_name. Multiple elements can have
		 * the same tag name in a document. XML example:
		 * {{{<photos>
		 *   <img src="..." />
		 *   <img src="..." />
		 * </photos>}}}
		 * In this example, photos and img are tag names.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-104682815]]
		 */
		public string tag_name {
			get {
				// This is the same as node_name from Node:
				// http://www.w3.org/TR/DOM-Level-1/level-one-core.html
				// TODO: is this the same as tagname from Document's get_elem_by...?
				return base.node_name;
			}
			private set {
			}
		}

		/**
		 * Elements do not have a node_value. Instead, their
		 * contents are stored in Attr attributes and in
		 * child_nodes.
		 */
		public override string? node_value {
			get {
				return null;
			}
			private set {
			}
		}

		// Note that NamedNodeMap is 'live' so changes to the Node should be seen in an already obtained NamedNodeMap
		private NamedAttrMap _attributes = null;

		/**
		 * Contains a {@link GXml.NamedAttrMap} of
		 * {@link GXml.Attr} attributes associated with this
		 * {@link GXml.Element}.
		 *
		 * Attributes in the NamedNodeMap are updated live, so
		 * changes in the element's attributes through its
		 * other methods are reflected in the attributes
		 *
		 * Do not free this or its contents.  It's memory will
		 * be released when the owning {@link GXml.Document}
		 * is freed.
		 */
		public override NamedAttrMap? attributes {
			get {
				// TODO: investigate memory handling
				if (this._attributes == null) {
					this._attributes = new NamedAttrMap (this);
				}
				return this._attributes;
			}
			internal set {
			}
		}

		/* Constructors */
		internal Element (Xml.Node *node, Document doc) {
			base (node, doc);
			// TODO: consider string ownership, libxml2 memory
		}

		/* Public Methods */

		/**
		 * Retrieve the attribute value, as a string, for an
		 * attribute associated with this element with the
		 * name name.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-666EE0F9]]
		 *
		 * @param name The name of the attribute whose value to retrieve
		 *
		 * @return The value of the named attribute, or "" if
		 * no such attribute is set.
		 */
		public string get_attribute (string name) {
			Attr attr = this.get_attribute_node (name);

			if (attr != null)
				return attr.value;
			else
				return ""; // IDL says empty string
		}

		/**
		 * Set the value of this element's attribute named
		 * name to the string value.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-F68F082]]
		 *
		 * @param name Name of the attribute whose value to set
		 * @param value The value to set
		 */
		public void set_attribute (string name, string value) {
			Attr attr;

			attr = this.owner_document.create_attribute (name);
			attr.value = value;

			this.set_attribute_node (attr);
		}
		/**
		 * Remove the attribute named name from this element.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-6D6AC0F9]]
		 *
		 * @param name The name of the attribute to unset
		 */
		public void remove_attribute (string name) {
			this.check_read_only (); // TODO: check all this.check_*, and see if we should be aborting the current functions on failure or just warn, like here
			this.attributes.remove_named_item (name);
		}
		/**
		 * Get the Attr node representing this element's attribute named name.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-217A91B8]]
		 *
		 * @param name The name of the Attr node to retrieve
		 *
		 * @return The Attr node named by name for this element, or %NULL if none is set
		 */
		public Attr? get_attribute_node (string name) {
			return this.attributes.get_named_item (name);
		}
		/**
		 * Set the attribute in Attr for this element.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-887236154]]
		 *
		 * @param new_attr The attribute to set
		 *
		 * @return If an Attr with the same name exists, it
		 * is replaced and the old Attr is returned.
		 * Elsewise, %NULL is returned.
		 */
		public Attr set_attribute_node (Attr new_attr) {
			// TODO: INUSE_ATTRIBUTE_ERR if new_attr already belongs to another element
			// NO_MODIFICATION_ALLOWED_ERR and WRONG_DOCUMENT_ERR checked within
			return this.attributes.set_named_item (new_attr);
		}

		/**
		 * Remove Attr old_attr from this element, if it was
		 * set.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-D589198]]
		 *
		 * @param old_attr The Attr we are removing
		 *
		 * @return The old_attr we wanted to remove, even if
		 * it wasn't found.
		 */
		public Attr remove_attribute_node (Attr old_attr) {
			this.check_read_only ();
			return this.attributes.remove_named_item (old_attr.name);
		}

		// TODO: consider making the life of TagNameNodeLists optional, and dead by default, at the Document level
		private void check_add_tag_name (Element basenode, Node child) {
			// TODO: make sure there aren't any other NodeTypes that could have elements as children
			if (child.node_type == NodeType.ELEMENT || child.node_type == NodeType.DOCUMENT_FRAGMENT) {
				// the one we're examining is an element, and might need to be added
				if (child.node_type == NodeType.ELEMENT) {
					basenode.on_new_descendant_with_tag_name ((Element)child);
				}

				// if we're adding an element with descendants, or a document fragment, they might contain nodes that should go into a tag name node list for an ancestor node
				foreach (Node grand_child in child.child_nodes) {
					check_add_tag_name (basenode, grand_child);
				}
			}
		}
		/**
		 * Checks whether a descendant of a node is an Element, or whether its descendants
		 * are elements.  If they are, we check the basenode and its ancestors to see
		 * whether they're keeping that node in a TagNameNodeList, so we can remove it.
		 */
		private void check_remove_tag_name (Element basenode, Node child) {
			// TODO: make sure there aren't any other NodeTypes that could have elements as children
			if (child.node_type == NodeType.ELEMENT) {
				// the one we're examining is an element, and might need to be removed from a tag name node list
				basenode.on_remove_descendant_with_tag_name ((Element)child);

				// if we're removing an element with descendants, it might contain nodes that should also be removed from a tag name node list for an ancestor node
				foreach (Node grand_child in child.child_nodes) {
					check_remove_tag_name (basenode, grand_child);
				}
			}
		}

		/* ** Node methods ** */

		/**
		 * {@inheritDoc}
		 */
		public override unowned Node? insert_before (Node new_child, Node? ref_child) {
			unowned Node ret = base.insert_before (new_child, ref_child);
			check_add_tag_name (this, new_child);
			return ret;
		}

		/**
		 * {@inheritDoc}
		 */
		public override unowned Node? replace_child (Node new_child, Node old_child) {
			check_remove_tag_name (this, old_child);
			unowned Node ret = base.replace_child (new_child, old_child);
			check_add_tag_name (this, new_child);
			return ret;
		}

		/**
		 * {@inheritDoc}
		 */
		public override unowned Node? remove_child (Node old_child) {
			check_remove_tag_name (this, old_child);
			unowned Node ret = base.remove_child (old_child);
			return ret;
		}

		/**
		 * {@inheritDoc}
		 */
		public override unowned Node? append_child (Node new_child) {
			unowned Node ret = base.append_child (new_child);
			check_add_tag_name (this, new_child);
			return ret;
		}


		/* Visual explanation of get_elements_by_tag_name tree traversal.
		     a
		   b    c
		  d e  f g

		  we want: a b d e c f g

		  start:
		  add a

		  pop top of stack (a)
		  a: check for match: yes? add to return list
		  a: add children from last to first (c,b) to top of stack (so head=b, then c)

		  a
		  a< [bc]
		  b< [de]c
		  d< ec
		  e< c
		  c< [fg]
		  f< g
		  g<

		  see a, add a, visit a
		*/

		/* This keeps a list of all descendants with a given tag name, so you can do
		   elem.get_elements_by_tag_name ("name") and find them quickly; whenever a
		   node is added to the DOM, all its ancestors have it added to their list */
		private List<TagNameNodeList> tag_name_lists = new List<TagNameNodeList> ();

		/* Adds a new descendant to this elements cached list of child descendants,
		   used to isolate the subtree of nodes when filtering by tag name */
		private void on_new_descendant_with_tag_name (Element elem) {
			// TODO: consider using a HashTable instead
			foreach (TagNameNodeList list in tag_name_lists) {
				// TODO: take into account case sensitivity or insensitivity?
				if (elem.tag_name == list.tag_name) {
					list.append_child (elem);
					break;
				}
			}
			if (this.parent_node != null && this.parent_node.node_type == NodeType.ELEMENT)
				((Element)this.parent_node).on_new_descendant_with_tag_name (elem);
		}
		/**
		 * Checks whether this element has a TagNameNodeList containing this element,
		 * and if so, removes it.  It also asks the parents above if they have such
		 * a list.
		 */
		private void on_remove_descendant_with_tag_name (Element elem) {
			foreach (TagNameNodeList list in tag_name_lists) {
				if (elem.tag_name == list.tag_name) {
					foreach (Node tag_elem in list) {
						if (((Element)tag_elem) == elem) {
							list.remove_child (tag_elem);
							break;
						}
					}
					break;
				}
			}
			if (this.parent_node != null && this.parent_node.node_type == NodeType.ELEMENT)
				((Element)this.parent_node).on_remove_descendant_with_tag_name (elem);
		}

		/**
		 * Obtains a NodeList of Elements with the given
		 * tag_name that are descendants of this Element.
		 * This will include the current element if it
		 * matches. The returned list is updated as necessary
		 * as the tree changes.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1938918D]]
		 *
		 * @param tag_name The tag name to match for
		 *
		 * @return A NodeList containing the matching descendants
		 */
		/*TODO: make sure we want to include the current
		 * element, I think probably not.
		 */
		public NodeList get_elements_by_tag_name (string tag_name) {
			TagNameNodeList tagged = new TagNameNodeList (tag_name, this, this.owner_document);
			//List<Node> tagged = new List<Node> ();
			Queue<Xml.Node*> tocheck = new Queue<Xml.Node*> ();

			/* TODO: find out whether we are supposed to include this element,
			         or just its descendants */
			tocheck.push_head (base.node);

			while (tocheck.is_empty () == false) {
				Xml.Node *cur = tocheck.pop_head ();

				if (cur->name == tag_name) {
					tagged.append_child (this.owner_document.lookup_node (cur));
				}

				for (Xml.Node *child = cur->last; child != null; child = child->prev) {
					tocheck.push_head (child);
				}
			}

			this.tag_name_lists.append (tagged);

			return tagged;
		}

		/**
		 * This merges all adjacent Text nodes that are
		 * descendants of this element. Sibling Text nodes
		 * are not distinguishable in XML when stored outside
		 * of the DOM.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-162CF083]]
		 */
		public void normalize () {
			// TODO: do not normalise CDATASection which
			//       inherits from Text don't think that
			//       will be a problem, given that it will
			//       have a different .node_type

			foreach (Node child in this.child_nodes) {
				switch (child.node_type) {
				case NodeType.ELEMENT:
					((Element)child).normalize ();
					break;
				case NodeType.TEXT:
					// TODO: check siblings: what happens in vala when you modify a list you're iterating?
					// TODO: I think libxml2 automatically normalises adjacent text nodes, which is kind of annoying.
					// STUB
					break;
				}

			}
		}

		/**
		 * This is a convenience property for Elements, useful
		 * when you want to see Text descendents of an
		 * element. With the XML example
		 * {{{<shops>
		 *   <shop id="1">Eeylops Owl Emporium</shop>
		 *   <shop id="2">Obscurus Books</shop>
		 * </shops>}}} taking the
		 * node for the shop element with id 1 and using this
		 * method, you would get back "Eeylops Owl Emporiums".
		 * If you used it on the shops element, you'd get
		 * {{{Eeylops Owl EmporiumObscurus Books}}} with the
		 * XML tags omitted.
		 *
		 * Setting content replaces the Element's children
		 * with a Text node containing `value`.
		 */
		// TODO: add test
		public string content {
			owned get {
				// <> in with stringifying child nodes would get escaped, here the content is preserved
				return base.node->get_content ();
			}
			set {
				// TODO: check impact on existing child nodes; they will be
				//       detached, right?
				// TODO: is XML in value interpreted or escaped?
				base.node->set_content (value);
			}
		}

		/**
		 * {@inheritDoc}
		 */
		public override string to_string (bool format = false, int level = 0) {
			/* TODO: may want to determine a way to only sync when
			   attributes have been modified */

			this.owner_document.dirty_elements.append (this);
			return base.to_string (format, level);
		}
	}
}
