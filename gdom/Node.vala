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

	interface Node : GLib.Object {
		// TODO: hmm, too bad we can't require properties in an interface, both AttrNode and DomNode should have these available to be DOM Level 1 Core Nodes.

		// /** Public properties */
		// public string node_name;
		// public string node_value;
		// public ushort node_type;
		// public Node parent_node;
		// /* TODO: just used unowned to avoid compilation error for stub; investigate what's right */
		// public unowned List<Node> child_nodes;
		// public Node first_child;
		// public Node last_child;
		// public Node previous_sibling;
		// public Node next_sibling;
		// /* HashTable used for XML NamedNodeMap */
		// public HashTable<string,Attr> attributes;
		// public Document owner_document;

		public abstract Node insert_before (Node new_child, Node ref_child) throws DomError;
		public abstract Node replace_child (Node new_child, Node old_child) throws DomError;
		public abstract Node remove_child (Node old_child) throws DomError;
		public abstract Node append_child (Node new_child) throws DomError;
		public abstract bool has_child_nodes ();
		public abstract Node clone_nodes (bool deep);
	}
}
