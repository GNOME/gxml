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
	 * Version: DOM Level 1 Core
	 * URL: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-745549614]]
	 */
	public class Element : BackedNode {
		/* Public properties */

		// TODO: find out how to do double-spaces in Valadoc, so we can indent <img...
		/**
		 * The element's tag_name. Multiple elements can have
		 * the same tag name in a document. XML example:
		 * {{{&lt;photos>
		 *   &lt;img src="..." />
		 *   &lt;img src="..." />
		 * &lt;/photos>}}}
		 * In this example, photos and img are tag names.
		 *
		 * Version: DOM Level 1 Core
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

		/* HashTable used for XML NamedNodeMap */
		// TODO: note that NamedNodeMap is 'live' so changes to the Node should be seen in the NamedNodeMap (already retrieved), no duplicating it: http://www.w3.org/TR/DOM-Level-1/level-one-core.html
		private HashTable<string,Attr> _attributes = null;

		/**
		 * Contains a HashTable of Attr attributes associated with this element.
		 *
		 * Attributes in the HashTable are updated live, so
		 * changes in the element's attributes through its
		 * other methods are reflected in the attributes
		 * HashTable.
		 */
		public override HashTable<string,Attr>? attributes {
			/*
			 * #todo: verify that because we're giving them a
			 * reference to our own attributes HashTable for
			 * manipulating, that our methods do keep it live, so
			 * we don't need to implement NamedNodeMap.
			 *
			 * #todo: make sure we fill our _attributes at
			 * construction time with the attributes from the
			 * document.
			 */
			/* TODO: make sure we want the user to be able
			 * to manipulate attributes using this
			 * HashTable. Yes, we do, it should be a live
			 * reflection.  That's OK though, as long as
			 * we save dirty attributes tables also when
			 * we save the the ones in our hashtable back
			 * into the xml.Doc before writing that to
			 * whatever disk.
			 */
			/* TODO: remember that this table needs to be
			 * synced with libxml2 structures; perhaps use
			 * a flag that indicates whether it was even
			 * accessed, and only then sync it later on
			 */
			get {
				Attr attr;

				if (this._attributes == null) {
					this.owner_document.dirty_elements.append (this);
					this._attributes = new HashTable<string,Attr> (GLib.str_hash, GLib.str_equal);
					// TODO: make sure other HashTables have appropriate hash, equal functions

					for (Xml.Attr *prop = base.node->properties; prop != null; prop = prop->next) {
						attr = new Attr (prop, this.owner_document);
						this._attributes.replace (prop->name, attr);
					}
				}

				return this._attributes;
			}
			internal set {
			}
		}

		/**
		 * This should be called before saving a GXml Document
		 * to a libxml2 Xml.Doc*, or else any changes made to
		 * attributes in the Element will only exist within
		 * the hash table proxy and will not be recorded.
		 */
		internal void save_attributes (Xml.Node *tmp_node) {
			Attr attr;
			Xml.Ns *ns;

			/* First, check if anyone has tried to access attributes, which
			   means it could have changed.  Do this by checking whether our
			   underlying local hashtable is still null. */
			/* TODO: make sure that in normal operation
			   where attributes aren't _explicitly_ referenced, that we don't
			   internally induce this._attributes from being created. */
			if (this._attributes != null) {
				// First we have to clear the old properties, so we don't create duplicates
				for (Xml.Attr *xmlattr = this.node->properties; xmlattr != null; xmlattr = xmlattr->next) {
					// TODO: make sure that this actually works, and that I don't lose my attr->next for the next step by unsetting attr
					// TODO: need a good test case that makes sure that the properties do not get duplicated, that removed ones stay removed, and new ones appear when recorded to back to a file
					if (this._attributes.lookup (xmlattr->name) == null) {
						// this element no longer has an attribute with this name, so get rid of the underlying one when syncing
						if (xmlattr->ns == null) {
							// Attr has no namespace
							this.node->unset_prop (xmlattr->name);
						} else {
							// Attr has a namespace
							this.node->unset_ns_prop (xmlattr->ns, xmlattr->name);
						}

					}
				}

				// Go through the GXml table of attributes for this element and add corresponding libxml2 ones
				foreach (string propname in this._attributes.get_keys ()) {
					attr = this._attributes.lookup (propname);
					Xml.Attr* saved_attr;

					if (attr.namespace_uri != null || attr.prefix != null) {
						// I hate namespace handling between libxml2 and DOM Level 2/3 Core!
						ns = tmp_node->new_ns (attr.namespace_uri, attr.prefix);
						saved_attr = this.node->set_ns_prop (ns, propname, attr.node_value);
					} else {
						saved_attr = this.node->set_prop (propname, attr.node_value);
					}

					/* Replace an old out-of-tree attr with the newly
					 * allocated one in the tree, that way xmlFreeDoc can
					 * clean up correctly */
					if (attr.node->parent == null) {
						/* If it was in-tree, xmlSetProp should correctly handle the
						   memory when updating the value within its xmlAttr */
						attr.node->free ();
						attr.node = saved_attr;
					}
				}
			}
		}


		/* Constructors */
		internal Element (Xml.Node *node, Document doc) {
			base (node, doc);
			// TODO: consider string ownership, libxml2 memory
			// TODO: do memory testing

			//this.new_descendant_with_tag_name.connect (on_new_descendant_with_tag_name)
		}

		/* Public Methods */
		// TODO: for base.attribute-using methods, how do I re-sync base.attributes with Xml.Node* attributes?

		/**
		 * Retrieve the attribute value, as a string, for an
		 * attribute associated with this element with the
		 * name name.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-666EE0F9]]
		 *
		 * @param name The name of the attribute whose value to retrieve.
		 *
		 * @return The value of the named attribute, or "" if
		 * no such attribute is set.
		 */
		public string get_attribute (string name) {
			// should I used .attributes.lookup (name)?
			Attr attr = this.attributes.lookup (name);

			if (attr != null)
				return attr.value;
			else
				return ""; // IDL says empty string, TODO: consider null instead
		}
		/**
		 * Set the value of this element's attribute named
		 * name to the string value.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-F68F082]]
		 *
		 * @param name Name of the attribute whose value to set.
		 * @param value The value to set.
		 */
		public void set_attribute (string name, string value) {
			// don't need to use insert
			Attr attr = this.attributes.lookup (name);
			if (attr == null) {
				/* TODO: I ended up testing only the case where I created attributes
				 * like this, and not ones read from the file, so I didn't notice
				 * something so important was broken. Ugh.  Add more suitable tests.
				 */

				attr = this.owner_document.create_attribute (name);
			}
			/* TODO: find out if DOM API wants us to create a new one if it doesn't already exist?  (probably, but we'll need to know the doc for that, for doc.create_attribute :| */

			attr.value = value;

			this.attributes.replace (name, attr);
			// TODO: replace wanted 'owned', look up what to do
		}
		/**
		 * Remove the attribute named name from this element.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-6D6AC0F9]]
		 *
		 * @param name The name of the attribute to unset.
		 */
		public void remove_attribute (string name) {
			this.check_read_only (); // TODO: check all this.check_*, and see if we should be aborting the current functions on failure or just warn, like here


			this.attributes.remove (name);
		}
		/**
		 * Get the Attr node representing this element's attribute named name.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-217A91B8]]
		 *
		 * @param name The name of the Attr node to retrieve.
		 *
		 * @return The Attr node named by name for this element, or null if none is set.
		 */
		public Attr? get_attribute_node (string name) {
			// TODO: verify that attributes returns null with unknown name
			return this.attributes.lookup (name);
		}
		/**
		 * Set the attribute in Attr for this element.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-887236154]]
		 *
		 * @param new_attr The attribute to set.
		 *
		 * @return If an Attr with the same name exists, it
		 * is replaced and the old Attr is returned.
		 * Elsewise, null is returned.
		 */
		public Attr set_attribute_node (Attr new_attr) {
			// TODO: INUSE_ATTRIBUTE_ERR if new_attr already belongs to another element

			this.check_read_only ();

			this.check_wrong_document (new_attr);

			// TODO: need to actually associate this with the libxml2 structure!
			// TODO: need to do that at the time of saving. We don't right now :|
			Attr old = this.attributes.lookup (new_attr.name);
			this.attributes.replace (new_attr.name, new_attr);
			return old;
		}

		/**
		 * Remove Attr old_attr from this element, if it was
		 * set.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-D589198]]
		 *
		 * @param old_attr The Attr we are removing.
		 *
		 * @return The old_attr we wanted to remove, even if
		 * it wasn't found.
		 */
		public Attr remove_attribute_node (Attr old_attr) {
			this.check_read_only ();

			if (this.attributes.remove (old_attr.name) == false) {
				GXml.warning (DomException.NOT_FOUND, "No child with name '%s' exists in node '%s'".printf (old_attr.name, this.node_name));
			}

			return old_attr;
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
		public override unowned Node? insert_before (Node new_child, Node? ref_child) {
			unowned Node ret = base.insert_before (new_child, ref_child);
			check_add_tag_name (this, new_child);
			return ret;
		}
		public override unowned Node? replace_child (Node new_child, Node old_child) {
			check_remove_tag_name (this, old_child);
			unowned Node ret = base.replace_child (new_child, old_child);
			check_add_tag_name (this, new_child);
			return ret;
		}
		public override unowned Node? remove_child (Node old_child) {
			check_remove_tag_name (this, old_child);
			unowned Node ret = base.remove_child (old_child);
			return ret;
		}
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
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1938918D]]
		 *
		 * @param tag_name The tag name to match for.
		 *
		 * @return A NOdeList containing the matching descendants.
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
		 * Version: DOM Level 1 Core
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

		// /**
		//  * This is a convenience method for Elements, mostly
		//  * useful when you know a given element's children are
		//  * only Text. With the example {{{&lt;shops>&lt;shop
		//  * id="1">Eeylops Owl Emporium&lt;/shop>&lt;shop
		//  * id="2">Obscurus Books&lt;/shop>&lt;/shops>}}} taking the
		//  * node for the shop element with id 1 and using this
		//  * method, you would get back "Eeylops Owl Emporiums".
		//  * If you used it on the shops element, you'd get
		//  * {{{&lt;shop id="1">Eeylops Owl Emporium&lt;/shop>&lt;shop
		//  * id="2">Obscurus Books&lt;/shop>}}}
		//  *
		//  * @return XML string of child contents
		//  */
		// public string content_to_string () {
		// 	return this.child_nodes.to_string (true);
		// }

		/**
		 * This is a convenience property for Elements, mostly
		 * useful when you know a given element's children are
		 * only Text. With the example {{{&lt;shops>&lt;shop
		 * id="1">Eeylops Owl Emporium&lt;/shop>&lt;shop
		 * id="2">Obscurus Books&lt;/shop>&lt;/shops>}}} taking the
		 * node for the shop element with id 1 and using this
		 * method, you would get back "Eeylops Owl Emporiums".
		 * If you used it on the shops element, you'd get
		 * {{{&lt;shop id="1">Eeylops Owl Emporium&lt;/shop>&lt;shop
		 * id="2">Obscurus Books&lt;/shop>}}}
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
	}
}
