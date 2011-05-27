/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	// TODO: figure out how to create this; Xml.Doc doesn't have new_element()

	class Element : DomNode {
		/** Public properties */
		public string tag_name {
			get {
				// TODO: is this the same as tagname from Document?
				return base.node_name;
			}
			private set {
			}
		}

		/** Constructors */
		internal Element (Xml.Node *node) {
			base (node);
			// TODO: consider string ownership, libxml2 memory
			// TODO: do memory testing
		}

		/** Public Methods */
		// TODO: for base.attribute-using methods, how do I re-sync base.attributes with Xml.Node* attributes?
		string get_attribute (string name) {
			// should I used .attributes.lookup (name)?
			return base.attributes.lookup (name).value;
		}
		void set_attribute (string name, string value) throws DomError {
			// don't need to use insert
			Attr attr = base.attributes.lookup (name);
			if (attr == null) {
				// TODO: create a new one
				// TODO: find out if DOM API wants us to create a new one if it doesn't already exist?  (probably, but we'll need to know the doc for that, for doc.create_attribute :|
			} else {
				attr.value = value;
			}
			base.attributes.replace (name, attr);
			// TODO: replace wanted 'owned', look up what to do

		}
		void remove_attribute (string name) throws DomError {
			base.attributes.remove (name);
		}
		Attr get_attribute_node (string name) {
			return base.attributes.lookup (name);
		}
		Attr set_attribute_node (Attr new_attr) throws DomError {
			// don't need to use insert
			base.attributes.replace (new_attr.name, new_attr);
			// TODO: should I check whether I need to insert first?
			return new_attr; // TODO: return this?
		}
		Attr remove_attribute_node (Attr old_attr) throws DomError {
			base.attributes.remove (old_attr.name);
			return old_attr; // TODO: is this what we want to return?
		}
		List<Node> get_elements_by_tag_name (string name) {
			// STUB
			return new List<Node> ();
		}
		void normalize () {
			// STUB
		}
	}
}
