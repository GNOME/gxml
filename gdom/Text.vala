/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we really want a text node, or just use strings? */
	class Text : DomNode {
		internal Text (Xml.Node *text_node) {
			base (text_node);
		}
	}
}
