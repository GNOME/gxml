/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */
// FIXME: Port this class as an implementation of Gee interfaces
internal class GXml.NamespaceAttrNodeList : GXml.LinkedList {
	internal NamespaceAttrNodeList (BackedNode root, xDocument owner) {
		base (root);
    if (root.node->ns_def == null) return;
		Xml.Ns *cur = root.node->ns_def;
		while (cur != null) {
			this.append_child (new NamespaceAttr (cur, owner));
			if (cur->next == null) break;
			cur = cur->next;
		}
	}
}
