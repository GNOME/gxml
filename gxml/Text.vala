/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we really want a text node, or just use strings? */
	public class Text : CharacterData {
		internal Text (Xml.Node *text_node, Document doc) {
			base (text_node, doc);
		}
		public override string node_name {
			get {
				return "#text"; // TODO: wish I could return "#" + base.node_name
			}
			private set {
			}
		}

		public Text split_text (ulong offset) /* throws DomError */ {
			/* all text up to offset (but excluding?) kept here
			   rest in new node (returned)
			   become siblings under original parent
			   libxml2 handles this? doesn't look like it
			*/

			// STUB
			return this;
		}
	}
}
