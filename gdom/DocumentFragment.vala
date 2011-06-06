/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class DocumentFragment : DomNode {
		internal DocumentFragment (Xml.Node *fragment_node, Document doc) {
			base (fragment_node, doc);
		}
	}
}
