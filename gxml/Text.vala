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

		public Text split_text (ulong offset) throws DomError {
			/* libxml2 doesn't handle this directly, in part because it doesn't
			   allow Text siblings.  Boo! */
			if (offset < 0 || offset > this.length) {
				throw new DomError.INDEX_SIZE ("Offset '%u' is invalid for string of length '%u'", offset, this.length); // i18n
			}

			Text other = this.owner_document.create_text_node (this.data.substring ((long)offset));
			this.data = this.data.substring (0, (long)offset);

			/* TODO: Ugh, can't actually let them be siblings in the tree, as
			         the spec requests, because libxml2 automatically merges Text
				 sibligns. */
			/* this.node->add_next_sibling (other.node); */

			return other;
		}
	}
}
