/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class Notation : VirtualNode {
		public string public_id {
			get;
			private set;
		}
		public string system_id {
			get;
			private set;
		}

		internal Notation (Document doc) {
			base (NodeType.NOTATION, doc); // STUB
			// notation name?  is that the same as the arg we pass it? 
		}
	}

}
