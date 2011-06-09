/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class VirtualNode : DomNode {
		internal VirtualNode (NodeType type, Document owner) {
			base.virtual ();
			this.node_type = type;
			this.owner_document = owner;
		}
		internal VirtualNode.for_document (NodeType type) {
			base.virtual ();
			this.node_type = type;
		}

		public override string? node_value {
			get {
				return null;
			}
			private set {
			}
		}

		private NodeType _node_type;
		public override NodeType node_type {
			get {
				return _node_type;
			}
				// return  (NodeType)this.node->type; // TODO: Same type?  Do we want to upgrade ushort to ElementType?
			//}
			internal set {
				this._node_type = value;
			}
		}

	}
}