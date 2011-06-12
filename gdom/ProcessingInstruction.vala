/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class ProcessingInstruction : DomNode {
		internal ProcessingInstruction (string target, string data, Document doc) {
			base (NodeType.PROCESSING_INSTRUCTION, doc); // TODO: want to pass a real Xml.Node* ?
			this.target = target;
			this.data = data;
		}

		public string target {
			get;
			private set;
		}
		public string data /* throws DomError (not supported yet) */ {
			get;
			set;	//throw new DomError.DOM ("Error");
		}
		public override string node_name {
			get {
				return this.target;
			}
			private set {
			}
		}
		public override string? node_value {
			get {
				return this.data;
			}
			private set {
			}
		}

	}
}
