/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Comment.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011,2015  Daniel Espinosa <esodan@gmail.com>
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
 * To create one, use {@link GXml.xDocument.create_comment}.
 *
 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1728279322]]
 */
public class GXml.xComment : GXml.xCharacterData, GXml.Comment {
	// TODO: Can I make this only accessible from within the GXml.Dom namespace (e.g. from GXml.Dom.xDocument?)
	internal xComment (Xml.Node *comment_node, xDocument doc) {
		base (comment_node, doc);
	}
	public override string node_name {
		get {
			return "#comment";
		}
		private set {
		}
	}
	// GXml.Comment interface
	public string str { get { return this.data; } }

}
