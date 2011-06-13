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
		public override NodeList? child_nodes {
			owned get {
				// TODO: always create a new one?
				return new NodeChildNodeList (this.node, this.owner_document);
			}
			internal set {
			}
		}

		private DomNode? _first_child;
		public override DomNode? first_child {
			get {
				_first_child = this.child_nodes.first ();
				return _first_child;
				// return this.child_nodes.first ();
			}
			internal set {
			}
		}

		private DomNode? _last_child;
		public override DomNode? last_child {
			get {
				_last_child = this.child_nodes.last ();
				return _last_child;
				//return this.child_nodes.last (); //TODO: just want to relay
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

		public override DomNode? insert_before (DomNode new_child, DomNode ref_child) /*throws DomError*/ {
			return this.child_nodes.insert_before (new_child, ref_child);
		}
		public override DomNode? replace_child (DomNode new_child, DomNode old_child) /*throws DomError*/ {
			return this.child_nodes.replace_child (new_child, old_child);
		}
		public override DomNode? remove_child (DomNode old_child) /*throws DomError*/ {
			return this.child_nodes.remove_child (old_child);
		}
		public override DomNode? append_child (DomNode new_child) /*throws DomError*/ {
			return this.child_nodes.append_child (new_child);
		}
		public override bool has_child_nodes () {
			return (this.child_nodes.length > 0);
		}

		public override DomNode? clone_nodes (bool deep) {
			return this; // STUB
		}
	}
}
