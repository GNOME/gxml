/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class Entity : VirtualNode {
		public string public_id {
			get;
			private set;
		}
		public string system_id {
			get;
			private set;
		}
		public string notation_name {
			get;
			private set;
		}

		internal Entity (Document doc) {
			base (NodeType.ENTITY, doc);
		}
	}
}
