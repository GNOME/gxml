/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	enum NodeEnum {
		ELEMENT = 1,
			ATTRIBUTE,
			TEXT,
			CDATA_SECTION,
			ENTITY_REFERENCE,
			ENTITY,
			PROCESSING_INSTRUCTION,
			COMMENT,
			DOCUMENT,
			DOCUMENT_TYPE,
			DOCUMENT_FRAGMENT,
			NOTATION;
	}

	class Node {
		public string node_name {
			get;
			private set;
		}
		public string node_value {
			get;
			private set;
		}/* "raises [DomError] on setting/retrieval"?  */
		public ushort node_type {
			get;
			private set;
		}
		public Node parent_node {
			get;
			private set;
		}
		/* TODO: just used unowned to avoid compilation error for stub; investigate what's right */
		public unowned List<Node> child_nodes {
			get;
			private set;
		}
		public Node first_child {
			get;
			private set;
		}
		public Node last_child {
			get;
			private set;
		}
		public Node previous_sibling {
			get;
			private set;
		}
		public Node next_sibling {
			get;
			private set;
		}
		/* HashTable used for XML NamedNodeMap */
		public HashTable<string,Attr> attributes {
			get;
			private set;
		}
		public Document owner_document {
			get;
			private set;
		}

		Node insert_before (Node new_child, Node ref_child) throws DomError {
			return null; // STUB
		}
		Node replace_child (Node new_child, Node old_child) throws DomError {
			return null; // STUB
		}
		Node remove_child (Node old_child) throws DomError {
			return null; // STUB
		}
		Node append_child (Node new_child) throws DomError {
			return null; // STUB
		}
		bool has_child_nodes () {
			return false; // STUB
		}
		Node clone_nodes (bool deep) {
			return null; // STUB
		}
	}
}
