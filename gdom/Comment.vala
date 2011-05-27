/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we really want a comment node, or just use strings? */
	class Comment : DomNode {
		// TODO: Can I make this only accessible from within the GXml.Dom namespace (e.g. from GXml.Dom.Document?)
		internal Comment (Xml.Node *comment_node) {
			base (comment_node);
		}
	}
}
