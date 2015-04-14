/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* NodeList.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2013-2015  Daniel Espinosa <esodan@gmail.com>
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

	// /* TODO: warning: this list should NOT be edited :(
	//    we need a new, better live AttrNodeList :| */
	// internal class AttrNodeList : GListNodeList {
	// 	internal AttrNodeList (xNode root, xDocument owner) {
	// 		base (root);
	// 		base.nodes = root.attributes.get_values ();
	// 	}
	// }

internal class GXml.NodeChildNodeList : ChildNodeList
{
	Xml.Node *parent;

	internal override Xml.Node *head {
		get {
			return parent->children;
		}
		set {
			parent->children = value;
		}
	}

	internal NodeChildNodeList (Xml.Node *parent, xDocument owner) {
		this.parent = parent;
		this.owner = owner;
	}

	internal override Xml.Node *parent_as_xmlnode {
		get {
			/* TODO: check whether this is also
			 * disgusting, like with
			 * AttrChildNodeList, or necessary
			 */
			return parent;
		}
	}
}

