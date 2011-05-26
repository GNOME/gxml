/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class DomNode : GLib.Object, Node {
		/** Private class properties */
		internal static HashTable<Xml.Node*, DomNode> dict = new HashTable<Xml.Node*, DomNode> (null, null);

		/** Private methods */
		internal static unowned DomNode? lookup (Xml.Node *node) {
			unowned DomNode domnode;

			if (node == null) {
				return null; // TODO: consider throwing an error instead
			}

			domnode = DomNode.dict.lookup (node);
			if (domnode == null) {
				// TODO: is this necessary?  is it possible for anyone to try
				// to look up a node that hasn't been created yet?
				// Yes, because we don't create new Nodes for all the members
				// of a Doc (there could be millions), just as they are requested
				// TODO: create node
				// TODO: threadsafety
				DomNode.dict.insert (node, new DomNode (node));
				domnode = DomNode.dict.lookup (node);
			}

			return domnode;
		}


		/** Private properties */
		private Xml.Node *node;
		// TODO: make sure none of the other classes have any extra private data
		// TODO: make sure we don't want this to be private (we had that before, but then
		//       stuff where we play with siblings got blocked 

		/** Constructors */
		// TODO: want to keep this private to the name space; verify that internal is appropriate for GXml.Dom classes
		internal DomNode (Xml.Node *node) { 
			this.node = node; // TODO: should private properties all start with _?
			// STUB: fill out properties below

			// TODO: will we just let lookup handle insertions?
			// if (node != null) {
			// 	DomNode.dict.insert (node, this);
			// } else {
			// 	// TODO: warn or error or something, right now we have null ones though
			// }
			// TODO: we want to error out if it has already been inserted
		}
		// internal Node () {
		// 	this.node = null;
		// 	// TODO: better solution? have no Xml.Node * for e.g. DocumentType (yet)
		// }
		
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
				return this.node->content; // TODO: same as value here?
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
				return DomNode.lookup (this.node->parent);
				// TODO: is parent never null?
				// return new DomNode (this.node->parent);
				// TODO: figure out whether we really want to recreate wrapper objects each time
			}
			private set {
			}
		}
		/* TODO: just used unowned to avoid compilation error for stub; investigate what's right */
		// TODO: need to let the user know that editing this list doesn't add children to the node (but then what should?) 
		public List<Node> child_nodes {
			owned get {
				List<Node> children = new List<Node> ();
				for (Xml.Node *child = this.node->children; child != null; child = child->next) {
					children.append (DomNode.lookup (child));
					// children.append (new DomNode (child));
				}
				return children;				
			}
			private set {
			}
		}
		public Node? first_child {
			get {
				if (this.node->children == null) {
					return null; // TODO: what's the appropriate return value?  
				} else {
					//return new DomNode (this.node->children);
					return DomNode.lookup (this.node->children);
				}
			}
			private set {
			}
		}
		public Node? last_child {
			// some children would be Nodes of different types; doesn't this lose that information? 
			get {
				Xml.Node *child = this.node->children;
				if (child == null) {
					return null;
				}
				while (child->next != null) {
					child = child->next;
				}
				//return new DomNode (child);
				return DomNode.lookup (this.node->children);
			}
			private set {
			}
		}
		public Node? previous_sibling {
			get {
				return DomNode.lookup (this.node->prev);
				//return new DomNode (this.node->prev);
			}
			private set {
			}
		}
		public Node? next_sibling {
			get {
				//return new DomNode (this.node->next);
				return DomNode.lookup (this.node->next);
			}
			private set {
			}
		}
		/* HashTable used for XML NamedNodeMap */
		private HashTable<string,Attr> _attributes = new HashTable<string,Attr> (null, null); // TODO: use string equals for key compare
		public HashTable<string,Attr> attributes {
			// TODO: make sure we want the user to be able to manipulate attributes using this HashTable.
			// TODO: remember that this table needs to be synced with libxml2 structures; perhaps use a flag that indicates whether it was even accessed, and only then sync it later on
			get {
				return _attributes;
				// STUB: do we want to create one locally and update it for the object, or just translate node->properties each call?
			}
			private set {
			}
		}
		public Document owner_document {
			get;
			private set;
		}

		Node insert_before (Node new_child, Node ref_child) throws DomError {
			Xml.Node *child = this.node->children;

			while (child != ((DomNode)ref_child).node && child != null) {
				child = child->next;
			}
			if (child == null) {
				// TODO: couldn't insert before ref, since ref not found
			} else {
				child->add_prev_sibling (((DomNode)new_child).node);
			}

			return new_child; // TODO: make sure that's what we should be returning
		}
		Node replace_child (Node new_child, Node old_child) throws DomError {
			// TODO: nuts, if Node as an iface can't have properties,
			//       then I have to cast these to DomNodes, ugh.
			// TODO: need to handle errors?
			
			// TODO: want to do a 'find_child' function
			Xml.Node *child = this.node->children;

			while (child != null && child != ((DomNode)old_child).node) {
				child = child->next;
			}

			if (child != null) {
				// it is a valid child
				child->replace (((DomNode)new_child).node);
			}
			return this; // TODO: what to return?
		}
		Node remove_child (Node old_child) throws DomError {
			((DomNode)old_child).node->unlink (); // TODO: do we need to free libxml2 stuff manually?
			return old_child; // TODO: what do we want to return? 
		}
		Node append_child (Node new_child) throws DomError {
			this.node->add_child (((DomNode)new_child).node);
			return new_child; // TODO: what to return?
		}
		bool has_child_nodes () {
			return (this.node->children != null);
		}
		Node clone_nodes (bool deep) {
			return this; // STUB 
		}
	}
}
