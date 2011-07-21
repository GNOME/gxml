/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	// TODO: figure out how to create this; Xml.Doc doesn't have new_element()

	/**
	 * Represent an XML Element node. These can have child nodes
	 * of various types including other Elements. Elements can
	 * have Attr attributes associated with them. Elements have
	 * tag names. In addition to methods inherited from XNode,
	 * Elements have additional methods for manipulating
	 * attributes, as an alternative to manipulating the
	 * attributes HashMap directly. For more, see:
	 * [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-745549614]]
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
		private HashTable<string,Attr> _attributes = new HashTable<string,Attr> (GLib.str_hash, GLib.str_equal); // TODO: make sure other HashTables have appropriate hash, equal functions

		/**
		 * Contains a HashTable of Attr attributes associated with this element.
		 *
		 * Attributes in the HashTable are updated live, so
		 * changes in the element's attributes through its
		 * other methods are reflected in the attributes
		 * HashTable.
		 */
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
		public override HashTable<string,Attr>? attributes {
			// TODO: make sure we want the user to be able to manipulate attributes using this HashTable. // Yes, we do, it should be a live reflection
			// TODO: remember that this table needs to be synced with libxml2 structures; perhaps use a flag that indicates whether it was even accessed, and only then sync it later on
			get {
				return this._attributes;
				// switch (this.node_type) {
				// case NodeType.ELEMENT:
				// 	// TODO: what other nodes have attrs?
				// default:
				// 	return null;
				// }
			}
			internal set {
			}
		}


		/* Constructors */
		internal Element (Xml.Node *node, Document doc) {
			base (node, doc);
			// TODO: consider string ownership, libxml2 memory
			// TODO: do memory testing
		}

		/* Public Methods */
		// TODO: for base.attribute-using methods, how do I re-sync base.attributes with Xml.Node* attributes?

		/**
		 * Retrieve the attribute value, as a string, for an
		 * attribute associated with this element with the
		 * name name.
		 *
		 * @param The name of the attribute whose value to retrieve.
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
		 * @param name Name of the attribute whose value to set.
		 * @param value The value to set.
		 */
		public void set_attribute (string name, string value) throws DomError {
			// don't need to use insert
			Attr attr = this.attributes.lookup (name);
			if (attr == null) {
				attr = this.owner_document.create_attribute (name);
			}
				// TODO: find out if DOM API wants us to create a new one if it doesn't already exist?  (probably, but we'll need to know the doc for that, for doc.create_attribute :|

			attr.value = value;

			this.attributes.replace (name, attr);
			// TODO: replace wanted 'owned', look up what to do

		}
		/**
		 * Remove the attribute named name from this element.
		 *
		 * @param name The name of the attribute to unset.
		 */
		public void remove_attribute (string name) throws DomError {
			this.attributes.remove (name);
		}
		/**
		 * Get the Attr node representing this element's attribute named name.
		 *
		 * @param name The name of the Attr node to retrieve.
		 *
		 * @return The Attr node named by name for this element.
		 */
		public Attr? get_attribute_node (string name) {

			// TODO: verify that attributes returns null with unknown name
			return this.attributes.lookup (name);
		}
		/**
		 * Set the attribute in Attr for this element.
		 *
		 * @param Attr The attribute to set.
		 *
		 * @return If an Attr with the same name exists, it
		 * is replaced and the old Attr is returned.
		 * Elsewise, null is returned.
		 */
		public Attr set_attribute_node (Attr new_attr) throws DomError {
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
		 * @param old_attr The Attr we are removing.
		 *
		 * @return The old_attr we wanted to remove, even if
		 * it wasn't found.
		 */
		public Attr remove_attribute_node (Attr old_attr) throws DomError {
			// TODO: need to check for nulls. < Nope, ? controls that.
			this.attributes.remove (old_attr.name);
			return old_attr;
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

		/**
		 * Obtains a NodeList of Elements with the given
		 * tag_name that are descendants of this Element.
		 * This will include the current element if it
		 * matches. The returned list is updated as necessary
		 * as the tree changes.
		 *
		 * @param tag_name The tag name to match for.
		 *
		 * @return A NOdeList containing the matching descendants.
		 */
		/*TODO: make sure we want to include the current
		 * element, I think probably not.
		 */
		public List<XNode> get_elements_by_tag_name (string tag_name) {
			List<XNode> tagged = new List<XNode> ();
			Queue<Xml.Node*> tocheck = new Queue<Xml.Node*> ();

			/* TODO: find out whether we are supposed to include this element,
			         or just its descendants */
			tocheck.push_head (base.node);

			while (tocheck.is_empty () == false) {
				Xml.Node *cur = tocheck.pop_head ();

				if (cur->name == tag_name) {
					tagged.append (this.owner_document.lookup_node (cur));
				}

				for (Xml.Node *child = cur->last; child != null; child = child->prev) {
					tocheck.push_head (child);
				}
			}

			return tagged;
		}

		/**
		 * This merges all adjacent Text nodes that are
		 * descendants of this element. Sibling Text nodes
		 * are not distinguishable in XML when stored outside
		 * of the DOM.
		 */
		public void normalize () {
			// TODO: do not normalise CDATASection which
			//       inherits from Text don't think that
			//       will be a problem, given that it will
			//       have a different .node_type

			// STUB

			foreach (XNode child in this.child_nodes) {
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
	}
}
