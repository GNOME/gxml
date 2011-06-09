/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we really want a cdata section node, or just use strings? */
	/* TODO: check about casing in #vala */
	public class CDATASection : DomNode {
		internal CDATASection (Xml.Node *cdata_node, Document doc) {
			base (cdata_node, doc);
		}
		public override string node_name {
			get {
				return "#cdata-section"; 
			}
			private set {
			}
		}
	}
}
