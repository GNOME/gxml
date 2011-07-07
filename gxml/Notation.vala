/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class Notation : XNode {
		// private Xml.Notation *notation; // TODO: wrap libxml's xmlNotation

		public override string node_name {
			get {
				return ""; // notation->name;
			}
			private set {
			}
		}

		public string public_id {
			get {
				return ""; // notation->public_id;
			}
			private set {
			}
		}
		public string system_id {
			get {
				return ""; // notation->system_id;
			}
			private set {
			}
		}

		internal Notation (/* Xml.Notation *notation, */ Document doc) {
			base (NodeType.NOTATION, doc); // STUB
			//this.notation = notation;
		}
	}

}
