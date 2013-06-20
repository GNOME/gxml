/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* DocumentFragment.vala
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

namespace GXml {
	/* Lightweight Document object for fragments

	   has a root for the fragment, the fragment of the document is a child to this root
	   if you insert the fragment into a node, the fragment's root is lost and replaced by the receiving node

	   TODO: look into inserting DocumentFragments into nodes
	   * do not insert this node itself, but instead insert its children!
	   * libxml2 might handle this for us already
	   * need to test it
	   TODO: lookup libxml2's support for DocumentFragments

	   [0,inf) children

	 */
	/**
	 * An partial portion of a {@link GXml.Document}, not necessarily valid XML.
	 *
	 * To create one, use {@link GXml.Document.create_document_fragment}.
	 *
	 * This does not need to have a root document element,
	 * or being completely valid. It can have multiple children,
	 * which, if the DocumentFragment is inserted as a child to
	 * another node, become that nodes' children, without the
	 * DocumentFragment itself existing as a child.  For more,
	 * see:
	 * [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-B63ED1A3]]
	 */
	public class DocumentFragment : BackedNode {
		internal DocumentFragment (Xml.Node *fragment_node, Document doc) {
			base (fragment_node, doc);
		}
	}
}
