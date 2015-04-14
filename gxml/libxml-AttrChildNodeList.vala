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

internal class GXml.AttrChildNodeList : ChildNodeList {
	Xml.Attr *parent;

	internal override Xml.Node *head {
		get {
			return parent->children;
		}
		set {
			parent->children = value;
		}
	}

	internal AttrChildNodeList (Xml.Attr* parent, xDocument owner) {
		this.parent = parent;
		this.owner = owner;
	}

	internal override Xml.Node *parent_as_xmlnode {
		get {
			/* This is disgusting, but we do this for the case where
			   xmlAttr*'s immediate children list the xmlAttr as their
			   parent, but claim that xmlAttr is an xmlNode* (since
			   the parent field is of type xmlNode*). We need to get
			   an Xml.Node*ish parent for when we append new children
			   here, whether we're the list of children of an Attr
			   or not. */
			return (Xml.Node*)parent;
		}
	}
}
