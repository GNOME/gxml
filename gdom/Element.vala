/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class Element : Node {
		public string tag_name {
			get;
			private set;
		}

		string get_attribute (string name) {
			return ""; // STUB
		}
		void set_attribute (string name, string value) throws DomError {
		}
		void remove_attribute (string name) throws DomError {
		}
		Attr get_attribute_node (string name) {
			return null; // STUB
		}
		Attr set_attribute_node (Attr new_attr) throws DomError {
			return null; // STUB
		}
		Attr remove_attribute_node (Attr old_attr) throws DomError {
			return null; // STUB
		}
		List<Node> get_elements_by_tag_name (string name) {
			return new List<Node> ();
		}
		void normalize () {
		}
	}
}
