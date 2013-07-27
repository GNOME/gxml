/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Comment.vala
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
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

/* TODO: do we really want a comment node, or just use strings? */

/**
 * An XML comment.
 *
 * To create one, use {@link GXml.Document.create_comment}.
 *
 * An XML example looks like: {{{
 * <someNode>
 *    <!-- this is a comment -->
 *    text in the node
 *  </someNode> }}}
 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1728279322]]
 */
public class GXml.Comment : GXml.CharacterData {
	// TODO: Can I make this only accessible from within the GXml.Dom namespace (e.g. from GXml.Dom.Document?)
	internal Comment (Xml.Node *comment_node, Document doc) {
		base (comment_node, doc);
	}
	public override string node_name {
		get {
			return "#comment";
		}
		private set {
		}
	}

}
