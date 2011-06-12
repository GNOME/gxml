/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	// TODO: figure out how to create this; Xml.Doc doesn't have new_element()

	public class Element : BackedNode {
		/** Public properties */
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


		/** Constructors */
		internal Element (Xml.Node *node, Document doc) {
			base (node, doc);
			// TODO: consider string ownership, libxml2 memory
			// TODO: do memory testing
		}

		/** Public Methods */
		// TODO: for base.attribute-using methods, how do I re-sync base.attributes with Xml.Node* attributes?
		public string get_attribute (string name) {
			// should I used .attributes.lookup (name)?
			Attr attr = this.attributes.lookup (name);

			if (attr != null)
				return attr.value;
			else
				return ""; // IDL says empty string, TODO: consider null instead
		}
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
		public void remove_attribute (string name) throws DomError {
			this.attributes.remove (name);
		}
		public Attr get_attribute_node (string name) {
			// rightfully returns NULL if it does not exist
			return this.attributes.lookup (name);
		}
		public Attr set_attribute_node (Attr new_attr) throws DomError {
			// TODO: need to actually associate this with the libxml2 structure!
			Attr old = this.attributes.lookup (new_attr.name);
			this.attributes.replace (new_attr.name, new_attr);
			return old;
		}
		public Attr remove_attribute_node (Attr old_attr) throws DomError {
			// TODO: need to check for nulls

			this.attributes.remove (old_attr.name);
			return old_attr; // TODO: is this what we want to return?
		}

		// TODO: somewhere want to make clear that node_value does not contain the contents of a node, but that its text children do :)

		/*
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
		public List<DomNode> get_elements_by_tag_name (string name) {
			List<DomNode> tagged = new List<DomNode> ();
			Queue<Xml.Node*> tocheck = new Queue<Xml.Node*> ();

			/* TODO: find out whether we are supposed to include this element,
			         or just its descendants */
			tocheck.push_head (base.node);

			while (tocheck.is_empty () == false) {
				Xml.Node *cur = tocheck.pop_head ();

				if (cur->name == name) {
					tagged.append (this.owner_document.lookup_node (cur));
				}

				for (Xml.Node *child = cur->last; child != null; child = child->prev) {
					tocheck.push_head (child);
				}
			}

			return tagged;
		}

		/* This merges all Text nodes that are adjacent to one
		 * another for the descendents of this Element */
		public void normalize () {
			// STUB

			foreach (DomNode child in this.child_nodes) {
				switch (child.node_type) {
				case NodeType.ELEMENT:
					((Element)child).normalize ();
					break;
				case NodeType.TEXT:
					// TODO: check siblings: what happens in vala when you modify a list you're iterating?
					// STUB
					break;
				}

			}
		}
	}
}
