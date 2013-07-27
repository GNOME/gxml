/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Text.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

namespace GXml {
	/* TODO: do we really want a text node, or just use strings? */

	/**
	 * Text children of an element, not the tags or attributes.
	 *
	 * To create one, use {@link GXml.Document.create_text_node}.
	 *
	 * Describes the text found as children of elements throughout
	 * an XML document, like "He who must not be named" in the
	 * XML: {{{&lt;name>He who must not be named&lt;/name>}}}
	 * With libxml2 as a backend, it should be noted that two
	 * adjacent text nodes are always merged into one Text node,
	 * so some functionality for Text, like split_text, will not
	 * work completely as expected.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1312295772]]
	 */
	public class Text : CharacterData {
		internal Text (Xml.Node *text_node, Document doc) {
			base (text_node, doc);
		}
		/**
		 * The name of this node type, "#text"
		 */
		public override string node_name {
			get {
				return "#text"; // TODO: wish I could return "#" + base.node_name
			}
			private set {
			}
		}

		/**
		 * Normally, this would split the text into two
		 * adjacent sibling Text nodes. Currently, with
		 * libxml2, adjacent Text nodes are actually
		 * automatically remerged, so for now, we split the
		 * text and return the second part as a node outside
		 * of the document tree.
		 *
		 * @param offset The point at which to split the Text,
		 * in number of characters.
		 *
		 * @return The second half of the split Text node. For
		 * now, it is not attached to the tree as a sibling to
		 * the first part, as the spec wants.
		 */
		public Text split_text (ulong offset) {
			/* libxml2 doesn't handle this directly, in part because it doesn't
			   allow Text siblings.  Boo! */
			if (offset < 0 || this.length < offset) {
				GLib.warning ("INDEX_SIZE_ERR: split_text called with offset '%lu' on string of length '%lu'", offset, this.length); // i18n
				//this.owner_document.last_error = new DomError.INDEX_SIZE ("Offset '%u' is invalid for string of length '%u'", offset, this.length); // i18n
				return null;
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
