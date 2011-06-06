/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we really want a text node, or just use strings? */
	public class Text : DomNode {
		internal Text (Xml.Node *text_node, Document doc) {
			base (text_node, doc);
		}
	}
}
