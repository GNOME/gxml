/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class AttrNode : GLib.Object, Node { // TODO: if we use interfaces, we have to extend GObject
		/** Private properties */
		private Xml.Attr *node;
		// TODO: make sure none of the other classes have any extra private data

		internal static HashTable<Xml.Attr*, AttrNode> dict = new HashTable<Xml.Attr*, AttrNode> (null, null);

		/** Private methods */
		internal static unowned AttrNode? lookup (Xml.Attr *attr) {
			unowned AttrNode attrnode;

			if (attr == null) {
				return null; // TODO: consider throwing an error instead
			}
			
			attrnode = AttrNode.dict.lookup (attr);
			if (attrnode == null) {
				// TODO: is this necessary?  is it possible for anyone to try
				// to look up a node that hasn't been created yet?
				// Yes, because we don't create new Nodes for all the members
				// of a Doc (there could be millions), just as they are requested
				// TODO: create node
				// TODO: threadsafety
				AttrNode.dict.insert (attr, new AttrNode (attr));
				attrnode = AttrNode.dict.lookup (attr);				
			}

			return attrnode;
		}

		/** Constructors */
		// TODO: want to keep this private to the name space; verify that internal is appropriate for GXml.Dom classes
		internal AttrNode (Xml.Attr *node) { 
			this.node = node;

			// AttrNode.dict.insert (node, this); // TODO: something like this? 
		}
		
		/** Public properties */
		public string node_name {
			get {
				return this.node->name;
			}
			private set {
			}
		}
		public string node_value {
			get {
				return this.node->children->content; // TODO: same as value here?
			}
			private set {
			}
		}/* "raises [DomError] on setting/retrieval"?  */
		public ushort node_type {
			get {
				return (ushort)this.node->type; // TODO: Same type?  Do we want to upgrade ushort to ElementType?
			}
			private set {
			}
		}
		public Node parent_node {
			get {
				// TODO: is parent never null?
				return DomNode.lookup (this.node->parent); // TODO: figure out whether we really want to recreate wrapper objects each time
			}
			private set {
			}
		}

		public List<Node> child_nodes {
			/* TODO: for Attr, what are we supposed to do here? */
			owned get {
				List<Node> children = new List<Node> ();
				for (Xml.Node *child = this.node->children; child != null; child = child->next) {
					children.append (DomNode.lookup (child));
				}
				return children;				
			}
			private set {
			}
		}
		public Node? first_child {
			/* TODO: for Attr, what are we supposed to do here? */
			get {
				if (this.node->children == null) {
					return null; // TODO: what's the appropriate return value?  
				} else {
					return DomNode.lookup (this.node->children);
				}
			}
			private set {
			}
		}
		public Node? last_child {
			/* TODO: for Attr, what are we supposed to do here? */
			// TODO: for Attr, there should just be one child and its content, huh
			// some children would be Nodes of different types; doesn't this lose that information? 
			get {
				Xml.Node *child = this.node->children;
				if (child == null) {
					return null;
				}
				while (child->next != null) {
					child = child->next;
				}
				return DomNode.lookup (child);
			}
			private set {
			}
		}
		public Node previous_sibling {
			get {
				return AttrNode.lookup (this.node->prev);
			}
			private set {
			}
		}
		public Node next_sibling {
			get {
				return AttrNode.lookup (this.node->next);
			}
			private set {
			}
		}
		/* HashTable used for XML NamedNodeMap */
		public HashTable<string,Attr> attributes {
			get {
				return null; 
				// STUB: do we want to create one locally and update it for the object, or just translate node->properties each call?
				// TODO: this is getting dumb, why is Attr a Node again? :S
			}
			private set {
			}
		}
		public Document owner_document {
			get;
			private set;
		}

		Node insert_before (Node new_child, Node ref_child) throws DomError {
			return this; // STUB
		}
		Node replace_child (Node new_child, Node old_child) throws DomError {
			return this; // STUB
		}
		Node remove_child (Node old_child) throws DomError {
			return this; // STUB
		}
		Node append_child (Node new_child) throws DomError {
			return this; // STUB
		}
		bool has_child_nodes () {
			return false; // STUB
		}
		Node clone_nodes (bool deep) {
			return this; // STUB
		}
	}
}
