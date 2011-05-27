/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class DocumentFragment : DomNode {
		internal DocumentFragment (Xml.Node *fragment_node) {
			base (fragment_node);
		}
	}
}
