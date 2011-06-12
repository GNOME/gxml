/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class DomNode : GLib.Object {
		internal DomNode (NodeType type, Document owner) {
			this.node_type = type;
			this.owner_document = owner;
		}
		internal DomNode.for_document () {
			this.node_name = "#document";
			this.node_type = NodeType.DOCUMENT;
		}

		public virtual string? node_value {
			get {
				return null;
			}
			internal set {
			}
		}

		public virtual string node_name {
			get; internal set;
		}


		private NodeType _node_type;
		public virtual NodeType node_type {
			get {
				return _node_type;
			}
				// return  (NodeType)this.node->type; // TODO: Same type?  Do we want to upgrade ushort to ElementType?
			//}
			internal set {
				this._node_type = value;
			}
		}

		public Document owner_document {
			get;
			internal set;
		}

		// TODO: declare more of interface here
		public virtual DomNode? parent_node {
			get { return null; }
			internal set {}
		}
		public virtual List<DomNode>? child_nodes {
			// TODO: need to implement NodeList
			owned get { return null; }
			internal set {}
		}
		public virtual DomNode? first_child {
			get { return null; }
			internal set {}
		}
		public virtual DomNode? last_child {
			get { return null; }
			internal set {}
		}
		public virtual DomNode? previous_sibling {
			get { return null; }
			internal set {}
		}
		public virtual DomNode? next_sibling {
			get { return null; }
			internal set {}
		}
		public virtual HashTable<string,Attr>? attributes {
			get { return null; }
			internal set {}
		}

		// These may need to be overridden by subclasses that support them.
		// TODO: figure out what non-BackedNode classes should be doing with these, anyway
		public virtual DomNode? insert_before (DomNode new_child, DomNode ref_child) throws DomError {
			return null;
		}
		public virtual DomNode? replace_child (DomNode new_child, DomNode old_child) throws DomError {
			return null;
		}
		public virtual DomNode? remove_child (DomNode old_child) throws DomError {
			return null;
		}
		public virtual DomNode? append_child (DomNode new_child) throws DomError {
			return null;
		}
		public virtual bool has_child_nodes () {
			return false;
		}
		public virtual DomNode? clone_nodes (bool deep) {
			return null;
			// STUB
		}
	}
}

