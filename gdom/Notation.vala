/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class Notation : DomNode {
		public string public_id {
			get;
			private set;
		}
		public string system_id {
			get;
			private set;
		}

		internal Notation (Document doc) {
			base.with_type (NodeType.NOTATION, doc); // STUB
		}
	}

}
