/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Node.vala
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
 */

using GXml;

namespace GXml {
	public interface NamedNodeMap<T> : GLib.Object {
		// TODO: consider adding lookup, remove, etc from GLib.HashTable as convenience API
		// TODO: figure out how to let people do attributes["pie"] for attributes.get_named_item ("pie"); GLib HashTables can do it

		public abstract T get_named_item (string name);
		public abstract T set_named_item (T item);
		public abstract T remove_named_item (string name);
		public abstract T item (ulong index);
		public abstract ulong length {
			get;
			private set;
		}
	}

	public class NamedAttrMap : GLib.Object, NamedNodeMap<Attr?> {
		private Element elem; 

		internal NamedAttrMap (Element e) {
			this.elem = e;
		}

		public Attr? get_named_item (string name) {
			Xml.Attr *prop = this.elem.node->has_prop (name);
			return this.elem.owner_document.lookup_attr (prop);
		}

		public Attr? set_named_item (Attr? item) {
			Xml.Attr *prop;
			Attr old;

			/* TODO: INUSE_ATTRIBUTE_ERR if new_attr already belongs to
			   another element */
			this.elem.check_read_only ();
			this.elem.check_wrong_document (item);

			/* we take a clone, because libxml2 recycles xmlAttrs apparently(?),
			   and we'd just return the old xmlAttr but with the new values */
			old = this.get_named_item (item.node_name);
			if (old != null) {
				old = (GXml.Attr)old.clone_node (true);
			}

			/* TODO: instead of using item.node_value, which uses child_nodes
			         and iterates over them, use xmlNodeListGetString () */
			this.elem.node->set_prop (item.node_name, item.node_value);

			return old;
		}

		public Attr? remove_named_item (string name) {
			Attr clone;
			Attr old;

			old = this.get_named_item (name);
			if (old == null) {
				GXml.warning (DomException.NOT_FOUND,
					      "No child with name '%s' exists in node '%s'".printf (name, this.elem.node_name));
				return null;
			} else {
				/* Get a clone, because libxml2's xmlRemoveProp frees an
				 * Attrs memory, and we still want to return a copy */
				clone = (Attr)old.clone_node (true);
				/* TODO: implement cloning for Attrs; may need to clone a
				 *       new xmlAttr, all so Attrs can exist outside
				 *       of an Element (will we need an out of tree
				 *       placeholder Element?) THANKS DOM :( */
				this.elem.node->has_prop (name)->remove ();
				/* TODO: embed Xml.Attr into GXml.Attr; but then when we
				 *       remove xmlAttrs, because they'll be freed from
				 *       memory, we need to invalidate any GXml.Attrs that
				 *       hold them (which we can find using doc.lookup_attr()
				 */
				return clone;
			}
		}

		public Attr? item (ulong index) {
			Xml.Attr *attr;

			attr = this.elem.node->properties;
			for (int i = 0; i < index && attr != null; i++) {
				attr = attr->next;
			}

			if (attr == null) {
				return null;
			} else {			
				return this.elem.owner_document.lookup_attr (attr);
			}
		}

		public ulong length {
		 	get {
				int len = 0;
				for (Xml.Attr *attr = this.elem.node->properties; attr != null; attr = attr->next) {
					len++;
				}
				return len;
			}
		  	private set {
			}
		}
	}
}
