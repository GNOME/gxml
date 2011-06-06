/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class ProcessingInstruction : DomNode {
		internal ProcessingInstruction (Document doc) {
			base.with_type (NodeType.PROCESSING_INSTRUCTION, doc); // TODO: want to pass a real Xml.Node* ?
		}

		public string target {
			get;
			private set;
		}
		public string data /* throws DomError (not supported yet) */ {
			get;
			set;	//throw new DomError.DOM ("Error");
		}
	}
}
