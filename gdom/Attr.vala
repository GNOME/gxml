/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml.Dom {
	class Attr : Node {
		public string name {
			get;
			private set;
		}
		public bool specified {
			get;
			private set;
		}
		string value;
	}
}
