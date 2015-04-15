/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Node.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011,2014-2015  Daniel Espinosa <esodan@gmail.com>
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
using Gee;

namespace GXml {
	/**
	 * A collection of elements with a named objects.
	 */
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

	/**
	 * A class implementing {@link NamedNodeMap} interface for {@link Attr} objects.
	 * 
	 * A collection of {@link NamedNodeMap} of type {@link Attr} objects in a {@link xElement}.
	 */
	public class NamedAttrMap : AbstractMap<string,xNode>, NamedNodeMap<Attr?> {
		private xElement elem;

		internal NamedAttrMap (xElement e) {
			this.elem = e;
		}

		public Attr? get_named_item (string name) {
			Xml.Attr *prop = this.elem.node->has_prop (name);
			return this.elem.owner_document.lookup_attr (prop);
		}

		public Attr? set_named_item (Attr? gxml_attr_new) {
			Xml.Node *xml_elem;
			Xml.Attr *xml_prop_old;
			Xml.Attr *xml_prop_new;
			Attr gxml_attr_old;

			/* TODO: INUSE_ATTRIBUTE_ERR if new_attr already belongs to
			   another element */
			this.elem.check_read_only ();
			this.elem.check_wrong_document (gxml_attr_new);

			/* If you set an attribute/property in libxml2, it reuses any existing
			   Xml.Attr with the same name and just changes the value. With GXml,
			   if you set a new value, we want a new GXml.Attr to represent that,
			   and we want the old GXml.Attr to represent the old one. */
			xml_elem = this.elem.node;
			gxml_attr_old = this.get_named_item (gxml_attr_new.node_name);
			if (gxml_attr_old != null) {
				/* TODO: make sure xmlCopyNode is appropriate for xmlAttrs;
				   xmlCopyProp didn't seem to do what we wanted  */
				xml_prop_old = (Xml.Attr*)((Xml.Node*)gxml_attr_old.node)->copy (1);
				gxml_attr_old.set_xmlnode ((Xml.Node*)xml_prop_old, gxml_attr_old.owner_document);
			}

			/* TODO: instead of using item.node_value, which uses child_nodes
			         and iterates over them, use xmlNodeListGetString () */
			xml_prop_new = xml_elem->set_prop (gxml_attr_new.node_name, gxml_attr_new.node_value);
			gxml_attr_new.set_xmlnode ((Xml.Node*)xml_prop_new, gxml_attr_new.owner_document); // TODO: what of the old xmlNode that gxml_attr_new used to have?

			return gxml_attr_old;
		}

		public Attr? remove_named_item (string name) {
			Attr gxml_attr_old;
			Xml.Attr *xml_prop_old;
			Xml.Node *xml_elem;

			gxml_attr_old = this.get_named_item (name);
			if (gxml_attr_old == null) {
				GXml.warning (DomException.NOT_FOUND,
					      "No child with name '%s' exists in node '%s'".printf (name, this.elem.node_name));
				return null;
			} else {
				/* xmlRemoveProp () frees the underlying Attr memory
				   preventing us from returning the old attribute.
				   We could just clone the GXml.Attr with it, but
				   then the user would get a GXml.Attr for their old
				   different that would be different from previous GXml.Attrs
				   for it pre-removal (since they'd now have a clone).

				   So, instead we're going to clone the underlying xmlNode
				   and we're going to replace the existing GXmlAttr's
				   underlying xmlNode with the clone, so the user sees
				   the same GXmlAttr, and it has memory that wasn't freed.
				 */
				xml_elem = this.elem.node;
				/* TODO: make sure xmlCopyNode is appropriate for xmlAttrs;
				   xmlCopyProp didn't seem to do what we wanted  */
				xml_prop_old = (Xml.Attr*)((Xml.Node*)gxml_attr_old.node)->copy (1);
				gxml_attr_old.set_xmlnode ((Xml.Node*)xml_prop_old, gxml_attr_old.owner_document);

				xml_elem->has_prop (name)->remove ();

				return gxml_attr_old;
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

		public Gee.Collection<Attr> get_values ()
		{
		  var c = new Gee.ArrayList<Attr> ();
		  for (int i =0; i < length; i++) {
		    c.add (item (i));
		  }
		  return c;
		}
		// Gee.AbstractMap
		public override void clear () {
			foreach (string key in keys) {
				remove_named_item (key);
			}
		}
		public override new xNode @get (string key) { return get_named_item (key); }
		public override bool has (string key, xNode value) {
			var e = get_named_item (key);
			if (e == null) return false;
			if (!(value is BackedNode)) return false;
			if (((BackedNode) value).node == ((BackedNode) e).node) return true;
			if (((Attr) value).node == ((Attr) e).node) return true;
			return false;
		}
		public override bool has_key (string key) {
			if (get_named_item (key) == null) return false;
			return true;
		}
		public override Gee.MapIterator<string,xNode> map_iterator () { return new Iterator (this); }
		public override new void @set (string key, xNode value) {
			var n = get_named_item (key);
			if (n == null) return;
			remove_named_item (key);
			set_named_item ((Attr) value);
		}
		public override bool unset (string key, out xNode value = null) {
			var n = get_named_item (key);
			if (n == null) return false;
			remove_named_item (key);
			return true;
		}
		public override Gee.Set<Gee.Map.Entry<string,xNode>> entries {
			owned get {
				var s = new HashSet<Gee.Map.Entry<string,xNode>> ();
				var iter = map_iterator ();
				while (iter.next ()) {
					var v = iter.get_value ();
					var e = new Entry (iter.get_key (), v);
					s.add (e);
				}
				return s;
			}
		}
		public override Gee.Set<string> keys {
			owned get {
				var s = new HashSet<string> ();
				var iter = map_iterator ();
				while (iter.next ()) {
					s.add (iter.get_key ());
				}
				return s;
			}
		}
		public override bool read_only { get { return false; } }
		public override int size {
			get {
				var iter = map_iterator ();
				int i = 0;
				while (iter.next ()) i++;
				return i;
			}
		}
		public override Gee.Collection<xNode> values {
			owned get {
				var s = new ArrayList <xNode> ();
				var iter = map_iterator ();
				while (iter.next ()) {
					s.add (iter.get_value ());
				}
				return s;
			}
		}
		public class Entry : Gee.Map.Entry<string,xNode> {
			public Entry (string k, xNode v) {
				_key = k;
				value = v;
			}
			private string _key;
			public override string key { get { return _key; } }
			public override bool read_only { get { return true; } }
			public override xNode value { get; set; }
		}
		// Map Iterator
		private class Iterator : Object, Gee.MapIterator<string,xNode>
		{
			NamedAttrMap m;
			Xml.Attr *cur= null;
			Xml.Attr *head = null;
			public Iterator (NamedAttrMap m) {
				this.m = m;
				head = m.elem.node->properties;
			}
			public string get_key () { return cur->name; }
			public xNode get_value () { return m.get_named_item (get_key ()); }
			public bool has_next ()
			{
				if (cur == null) {
					if (head == null) return false;
					return true;
				}
				if (cur->next == null) return false;
				return true;
			}
			public bool next () {
				if (cur == null) {
					cur = head;
					return true;
				}
				if (cur->next == null) return false;
				cur = cur->next;
				return true;
			}
			public void set_value (xNode value) {
				if (!(value is Attr)) return;
				var n = m.get_named_item (get_key ());
				if (n == null) return;
				m.remove_named_item (get_key ());
				m.set_named_item ((Attr) value);
			}
			public void unset () {
				m.remove_named_item (get_key ());
			}
			public bool mutable { get { return true; } }
			public bool read_only { get { return false; } }
			public bool valid {
				get {
					if (cur == null) return false;
					return true;
				}
			}
		}
	}
}
