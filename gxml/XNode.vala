/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class XNode : GLib.Object {
		internal XNode (NodeType type, Document owner) {
			this.node_type = type;
			this.owner_document = owner;
		}
		internal XNode.for_document () {
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
		public virtual XNode? parent_node {
			get { return null; }
			internal set {}
		}
		public virtual NodeList? child_nodes {
			// TODO: need to implement NodeList
			owned get { return null; }
			internal set {}
		}
		public virtual XNode? first_child {
			get { return null; }
			internal set {}
		}
		public virtual XNode? last_child {
			get { return null; }
			internal set {}
		}
		public virtual XNode? previous_sibling {
			get { return null; }
			internal set {}
		}
		public virtual XNode? next_sibling {
			get { return null; }
			internal set {}
		}
		public virtual HashTable<string,Attr>? attributes {
			get { return null; }
			internal set {}
		}

		// These may need to be overridden by subclasses that support them.
		// TODO: figure out what non-BackedNode classes should be doing with these, anyway
		public virtual XNode? insert_before (XNode new_child, XNode ref_child) throws DomError {
			return null;
		}
		public virtual XNode? replace_child (XNode new_child, XNode old_child) throws DomError {
			return null;
		}
		public virtual XNode? remove_child (XNode old_child) throws DomError {
			return null;
		}
		public virtual XNode? append_child (XNode new_child) throws DomError {
			return null;
		}
		public virtual bool has_child_nodes () {
			return false;
		}
		public virtual XNode? clone_nodes (bool deep) {
			return null;
			// STUB
		}

		private string _str;
		public string to_string () {
			_str = "XNode(%s)".printf (this.node_name);
			return _str;
		}
	}
}

