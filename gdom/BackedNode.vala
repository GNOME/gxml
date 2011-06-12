/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

// NOTE: be careful about what extra data subclasses keep


namespace GXml.Dom {
	public class BackedNode : DomNode {
		/** Private properties */
		internal Xml.Node *node;

		/** Constructors */
		internal BackedNode (Xml.Node *node, Document owner) {
			base ((NodeType)node->type, owner);
			// Considered using node->doc instead, but some subclasses don't have corresponding Xml.Nodes
			this.node = node;

			// Save the correspondence between this Xml.Node* and its DomNode
			owner.node_dict.insert (node, this);
			// TODO: Consider checking whether the Xml.Node* is already recorded.  It shouldn't be.
		}


		/** Public properties */
		/* None of the following should store any data locally (except the attribute table), they should get data from Xml.Node* */
		public override string node_name {
			get {
				return this.node->name;
			}
			internal set {
			}
		}

		public override string? node_value {
			get {
				return this.node->content;
			}
			internal set {
			}
		}
		//  {
			// get {
			// 	// TODO: where is this typically stored?
			// 	// TODO: if it's an Element, it should return null, as all its 'value' is in its children
			// 	return this.node->content; // TODO: same as value here?
			// }
			// internal set {
			// 	this.node->children->content = value;
			// }
		//}/* "raises [DomError] on setting/retrieval"?  */
		public override Dom.NodeType node_type {
			get {
				/* Right now, Dom.NodeType's 12 values map perfectly to libxml2's first 12 types */
				return (NodeType)this.node->type;
			}
			internal set {
			}
			// default = NodeType.ELEMENT;
		}
		public override DomNode? parent_node {
			get {
				return this.owner_document.lookup_node (this.node->parent);
				// TODO: is parent never null? parent is probably possible to be null, like when you create a new element unattached
				// return new DomNode (this.node->parent);
				// TODO: figure out whether we really want to recreate wrapper objects each time
			}
			internal set {
			}
		}
		/* TODO: just used unowned to avoid compilation error for stub; investigate what's right */
		// TODO: need to let the user know that editing this list doesn't add children to the node (but then what should?)
		/* NOTE: try to avoid using this too often internally, would be much quicker to
		   just traverse Xml.Node*'s children */
		public override List<DomNode>? child_nodes {
			owned get {
				List<DomNode> children = new List<DomNode> ();
				for (Xml.Node *child = this.node->children; child != null; child = child->next) {
					children.append (this.owner_document.lookup_node (child));
					// children.append (new DomNode (child));
				}
				return children;
			}
			internal set {
			}
		}
		public override DomNode? first_child {
			get {
				if (this.node->children == null) {
					return null; // TODO: what's the appropriate return value?
				} else {
					return this.owner_document.lookup_node (this.node->children);
				}
			}
			internal set {
			}
		}
		public override DomNode? last_child {
			get {
				if (this.node->last == null) {
					return null; // TODO: what to return?
				} else {
					return this.owner_document.lookup_node (this.node->last);
				}
			}
			internal set {
			}
		}
		public override DomNode? previous_sibling {
			get {
				return this.owner_document.lookup_node (this.node->prev);
			}
			internal set {
			}
		}
		public override DomNode? next_sibling {
			get {
				return this.owner_document.lookup_node (this.node->next);
			}
			internal set {
			}
		}
		public override HashTable<string,Attr>? attributes {
			get {
				return null;
			}
			internal set {
			}
		}

		public override DomNode? insert_before (DomNode new_child, DomNode ref_child) throws DomError {
			Xml.Node *child = this.node->children;

			while (child != ((BackedNode)ref_child).node && child != null) {
				child = child->next;
			}
			if (child == null) {
				// TODO: couldn't insert before ref, since ref not found
			} else {
				child->add_prev_sibling (((BackedNode)new_child).node);
			}

			return new_child; // TODO: make sure that's what we should be returning
		}
		public override DomNode? replace_child (DomNode new_child, DomNode old_child) throws DomError {
			// TODO: nuts, if Node as an iface can't have properties,
			//       then I have to cast these to DomNodes, ugh.
			// TODO: need to handle errors?

			// TODO: want to do a 'find_child' function
			Xml.Node *child = this.node->children;

			while (child != null && child != ((BackedNode)old_child).node) {
				child = child->next;
			}

			if (child != null) {
				// it is a valid child
				child->replace (((BackedNode)new_child).node);
			}
			return this; // TODO: what to return?
		}
		public override DomNode? remove_child (DomNode old_child) throws DomError {
			((BackedNode)old_child).node->unlink (); // TODO: do we need to free libxml2 stuff manually?
			return old_child; // TODO: what do we want to return?
		}
		public override DomNode? append_child (DomNode new_child) throws DomError {
			this.node->add_child (((BackedNode)new_child).node);
			return new_child; // TODO: what to return?
		}
		public override bool has_child_nodes () {
			return (this.node->children != null);
		}
		public override DomNode? clone_nodes (bool deep) {
			return this; // STUB
		}
	}
}
