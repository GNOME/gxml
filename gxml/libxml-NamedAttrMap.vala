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
	 * A class implementing {@link NamedNodeMap} interface for {@link Attr} objects.
	 * 
	 * A collection of {@link NamedNodeMap} of type {@link Attr} objects in a {@link xElement}.
	 */
	public abstract class AbstractNamedAttrMap : Object,
		Traversable<Entry<string,GXml.Attribute>>,
		Iterable<Entry<string,GXml.Attribute>>
	{
		protected xElement elem;

		internal AbstractNamedAttrMap (xElement e) {
			this.elem = e;
		}

		// Gee.Iterable
		public Gee.Iterator<AbstractNamedAttrMap.Entry> iterator () { return new Iterator (this); }
		// Gee.Traversable
		public new bool @foreach (Gee.ForallFunc<AbstractNamedAttrMap.Entry> f) { return new Iterator (this).foreach (f); }
		
		public class Entry : Gee.Map.Entry<string,Attribute> {
			public Entry (string k, Attribute v) {
				_key = k;
				value = v;
			}
			private string _key;
			public override string key { get { return _key; } }
			public override bool read_only { get { return true; } }
			public override Attribute value { get; set; }
		}
		protected class Iterator : Object,
			Gee.Traversable<AbstractNamedAttrMap.Entry>,
			Gee.Iterator<AbstractNamedAttrMap.Entry>
		{
			protected AbstractNamedAttrMap nm;
			protected Xml.Attr* cur = null;
			public Iterator (AbstractNamedAttrMap nm)
			{
				this.nm = nm;
			}
			// Gee.Traversable
			new bool @foreach (Gee.ForallFunc<AbstractNamedAttrMap.Entry> f)
			{
				while (next ()) { if (!f (@get())) return false; }
				return true;
			}
			// Gee.Iterator
			public new Entry @get ()
			{
				string k = "";
				if (cur != null) k = cur->name;
				return new Entry (k, (GXml.Attribute) new Attr (cur, (xDocument) nm.elem.document));
			}
			public bool has_next ()
			{
				if (nm.elem.node == null) return false;
				if (nm.elem.node->properties == null) return false;
				if (cur == null) return false;
				if (cur->next == null) return false;
				return true;
			}
			public bool next ()
			{
				if (cur == null) {
					if (nm.elem.node == null) return false;
					if (nm.elem.node->properties == null) return false;
					cur = nm.elem.node->properties;
					return true;
				}
				if (has_next ()) {
					cur = cur->next;
					return true;
				}
				return false;
			}
			public void remove () {
				if (!valid) return;
				nm.elem.node->unset_prop (cur->name); // TODO: namespace
			}
			public bool read_only { get { return false; } }
			public bool valid {
				get {
					if (nm.elem.node == null) return false;
					if (nm.elem.node->properties == null) return false;
					if (cur == null) return false;
					return true;
				}
			}
		}
	}
		/**
	 * A class implementing {@link NamedNodeMap} interface for {@link Attr} objects.
	 * 
	 * A collection of {@link NamedNodeMap} of type {@link Attr} objects in a {@link xElement}.
	 */
	public class NamedAttrMap : AbstractNamedAttrMap, Map<string,GXml.Attribute>,
		NamedNodeMap<Attr?>
	{
		internal NamedAttrMap (xElement e)
		{
			base (e);
			this.elem = e;
		}
		// Gee.Map
		public void clear ()
		{
			if (elem.node == null) return;
			foreach (string key in keys) {
				elem.node->unset_prop (key);
			}
		}
		public bool contains (string key) { return has_key (key); }
		public bool contains_all (Gee.Map<string,GXml.Attribute> map) { return has_all (map); }
		public new Attribute @get (string key)
		{
			var at = elem.node->has_prop (key);
			return (Attribute) new Attr(at, (xDocument) elem.document);
		}
		public bool has (string key, Attribute value)
		{
			var at = elem.node->has_prop (key);
			if (at == null) return false;
			if (at->name == value.name) return true; // Xml.Attr to Xml.Node? to check its value
			return false;
		}
		public bool has_key (string key)
		{
			var at = elem.node->has_prop (key);
			if (at == null) return false;
			return true;
		}
		public Gee.MapIterator<string,Attribute> map_iterator () { return new Iterator (this); }
		public bool remove (string key, out Attribute val = null) { return unset (key, out val); }
		public bool remove_all (Gee.Map<string,Attribute> map) { return unset_all (map); }
		public new void @set (string key, Attribute val)
		{
			elem.node->set_prop (key, val.value);
		}
		public bool unset (string key, out Attribute value = null)
		{
			var r = elem.node->unset_prop (key);
			if (r != 0) return false;
			return true;
		}
		public Gee.Set<Gee.Map.Entry<string,Attribute>> entries {
			owned get {
				var s = new HashSet<AbstractNamedAttrMap.Entry> ();
				var iter = new Iterator (this);
				while (iter.next ()) {
					var v = iter.get ();
					s.add (v);
				}
				return s;
			}
		}
		public Gee.Set<string> keys {
			owned get {
				var s = new HashSet<string> ();
				var iter = new Iterator (this);
				while (iter.next ()) {
					var v = iter.get ();
					s.add (v.key);
				}
				return s;
			}
		}
		public bool read_only { get { return false; } }
		public Gee.Map<string,GXml.Attribute> read_only_view { 
			owned get {
				return new NamedAttrMap (this.elem); // FIXME: No read only is setup
			}
		}
		public int size {
			get {
				var iter = new Iterator (this);
				int i = 0;
				while (iter.next ()) { i++; }
				return i;
			}
		}
		public Gee.Collection<GXml.Attribute> values
		{
			owned get {
				var s = new HashSet<GXml.Attribute> ();
				var iter = new Iterator (this);
				while (iter.next ()) {
					var v = iter.get ();
					s.add (v.value);
				}
				return s;
			}
		}
		// Map Iterator
		private class Iterator : AbstractNamedAttrMap.Iterator, Gee.MapIterator<string,GXml.Attribute>
		{
			public Iterator (NamedAttrMap m) {
				base (m);
			}
			public string get_key () { return get ().key; }
			public Attribute get_value () { return get ().value; }
			public void set_value (Attribute val)
			{
				unset ();
				@set (val.name, val);
			}
			public void unset () {
				nm.elem.node->unset_prop (get ().key);
			}
			public bool mutable { get { return true; } }
		}
		// NamedNodeMap interface
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
		}

	}
}
