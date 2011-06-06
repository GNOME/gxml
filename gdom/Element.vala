/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	// TODO: figure out how to create this; Xml.Doc doesn't have new_element()

	public class Element : DomNode {
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
			Attr attr = base.attributes.lookup (name);

			if (attr != null)
				return attr.value;
			else
				return ""; // IDL says empty string, TODO: consider null instead
		}
		public void set_attribute (string name, string value) throws DomError {
			// don't need to use insert
			Attr attr = base.attributes.lookup (name);
			if (attr == null) {
				attr = this.owner_document.create_attribute (name);
			}
				// TODO: find out if DOM API wants us to create a new one if it doesn't already exist?  (probably, but we'll need to know the doc for that, for doc.create_attribute :|

			attr.value = value;

			base.attributes.replace (name, attr);
			// TODO: replace wanted 'owned', look up what to do

		}
		public void remove_attribute (string name) throws DomError {
			base.attributes.remove (name);
		}
		public Attr get_attribute_node (string name) {
			return base.attributes.lookup (name);
		}
		public Attr set_attribute_node (Attr new_attr) throws DomError {
			// don't need to use insert
			base.attributes.replace (new_attr.name, new_attr);
			// TODO: should I check whether I need to insert first?
			return new_attr; // TODO: return this?
		}
		public Attr remove_attribute_node (Attr old_attr) throws DomError {
			// TODO: need to check for nulls

			base.attributes.remove (old_attr.name);
			return old_attr; // TODO: is this what we want to return?
		}

		public List<DomNode> get_elements_by_tag_name (string name) {
			// TODO: consider switching these to List<Element>
			// STUB
			return null; // new List<Node> ();
		}
		public void normalize () {
			// STUB
		}
	}
}
