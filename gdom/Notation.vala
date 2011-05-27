/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class Notation : DomNode {
		public string public_id {
			get;
			private set;
		}
		public string system_id {
			get;
			private set;
		}

		internal Notation () {
			base (null); // STUB
		}
	}

}
