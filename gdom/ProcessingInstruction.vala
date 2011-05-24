/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class ProcessingInstruction : Node {
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
