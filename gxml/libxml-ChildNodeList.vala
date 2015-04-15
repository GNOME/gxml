/* .vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
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

using Gee;

internal abstract class GXml.ChildNodeList : Object,
	Traversable<xNode>, Iterable<xNode>, Gee.Collection<GXml.xNode>, NodeList
{
		/* TODO: must be live
		   if this reflects children of a node, then must always be current
		   same with nodes from GetElementByTagName, made need separate impls for each */
		// TODO: if necessary, create two versions that use parent instead of head

		internal weak xDocument owner;
		internal abstract Xml.Node *head { get; set; }

		internal abstract Xml.Node *parent_as_xmlnode { get; }

		/**
		 * {@inheritDoc}
		 */
		public ulong length {
			get {
				return size;
			}
			protected set { }
		}

		
		public Gee.Collection<xNode> read_only_view { owned get { return new ChildNodeListReadOnly (this); } }

		public bool add (xNode item)
		{
			append_child (item);
			return true;
		}
		public void clear () {}
		public bool contains (xNode item) { return false; }
		public bool remove (xNode item)  { return false; }
		public bool read_only { get { return true; } }
		public int size {
	    get {
        if (head != null) {
          //GLib.warning ("At NodeChildNodeList: get_size");
          int len = 1;
          var cur = head;
          while (cur->next != null) {
              cur = cur->next;
              len++;
          }
          return len;
        }
        return 0;
	    }
		}
		public Gee.Iterator<xNode> iterator () {
			return new NodeListIterator (this);
		}
		public bool @foreach (ForallFunc<xNode> func) {
			return iterator ().foreach (func);
		}

		/** GNOME List conventions */
		public xNode first () {
			return this.owner.lookup_node (head);
		}
		public xNode last () {
			Xml.Node *cur = head;
			while (cur != null && cur->next != null) {
				cur = cur->next;
			}
			return this.owner.lookup_node (cur); // TODO :check for nulls?
		}
		public new xNode @get (int n)
            requires (head != null)
        {
            Xml.Node *cur = head;
            int i = 0;
            while (cur->next != null && i != n) {
                cur = cur->next;
                i++;
            }
			return this.owner.lookup_node (cur);
		}
        public xNode item (ulong idx) { return get ((int) idx); }

		/** Node's child methods, implemented here **/
		internal new unowned xNode? insert_before (xNode new_child, xNode? ref_child) {
			Xml.Node *child = head;

			if (ref_child == null) {
				this.append_child (ref_child);
			}

			while (child != ((BackedNode)ref_child).node && child != null) {
				child = child->next;
			}
			if (child == null) {
				GXml.warning (DomException.NOT_FOUND, "ref_child '%s' not found, was supposed to have '%s' inserted before it.".printf (ref_child.node_name, new_child.node_name));
				return null;
				// TODO: provide a more useful description of ref_child, but there are so many different types
			} else {
				if (new_child.node_type == NodeType.DOCUMENT_FRAGMENT) {
					foreach (xNode new_grand_child in new_child.child_nodes) {
						child->add_prev_sibling (((BackedNode)new_grand_child).node);
					}
				} else {
					child->add_prev_sibling (((BackedNode)new_child).node);
				}
			}
			return new_child;
		}

		internal new unowned xNode? replace_child (xNode new_child, xNode old_child) {
			// TODO: verify that libxml2 already removes
			// new_child first if it is found elsewhere in
			// the tree.

			// TODO: nuts, if Node as an iface can't have properties,
			//       then I have to cast these to Nodes, ugh.
			// TODO: need to handle errors?

			// TODO: want to do a 'find_child' function
			if (new_child.node_type == NodeType.DOCUMENT_FRAGMENT) {
				this.insert_before (new_child, old_child);
				this.remove_child (old_child);
			} else {
				Xml.Node *child = head;

				while (child != null && child != ((BackedNode)old_child).node) {
					child = child->next;
				}

				if (child != null) {
					// it is a valid child
					child->replace (((BackedNode)new_child).node);
				} else {
					GXml.warning (DomException.NOT_FOUND, "old_child '%s' not found, tried to replace with '%s'".printf (old_child.node_name, new_child.node_name));
				}
			}

			return old_child;
		}
		internal new unowned xNode? remove_child (xNode old_child) /* throws DomError */ {
			// TODO: verify that old_child is a valid child here and then unlink

			((BackedNode)old_child).node->unlink (); // TODO: do we need to free libxml2 stuff manually?
			return old_child;
		}

		internal virtual unowned xNode? append_child (xNode new_child) /* throws DomError */ {
			// TODO: verify that libxml2 will first remove
			// new_child if it already exists elsewhere in
			// the tree.

			if (new_child.node_type == NodeType.DOCUMENT_FRAGMENT) {
				foreach (xNode grand_child in new_child.child_nodes) {
					parent_as_xmlnode->add_child (((BackedNode)grand_child).node);
				}
			} else {
				if (new_child.node_type == NodeType.ENTITY_REFERENCE) {
					GLib.warning ("Appending EntityReferences to Nodes is not yet supported");
				} else {
					parent_as_xmlnode->add_child (((BackedNode)new_child).node);
				}
			}

			return new_child;
		}

		public string to_string (bool in_line = true) {
			string str = "";
			foreach (xNode node in this) {
				str += node.to_string ();
			}
			return str;
		}

		/* ** NodeListIterator ***/

		private class NodeListIterator : GLib.Object, Gee.Traversable<xNode>, Gee.Iterator<xNode>
		{
			private weak xDocument doc;
			private Xml.Node *cur;
			private Xml.Node *head;

			/* TODO: consider rewriting this to work on NodeList instead of the Xml.Node*
			   list, then perhaps we could reuse it for get_elements_by_tag_name () */
			public NodeListIterator (ChildNodeList list) {
				this.head = list.head;
				this.cur = null;
				this.doc = list.owner;
			}
			/* Gee.Iterator interface */
			public new xNode @get () { return this.doc.lookup_node (this.cur); }
			public bool has_next () { return head == null ? false : true; }
			public bool next () {
				if (has_next ()) {
					cur = head;
					head = head->next;
					return true;
				}
				return false;
			}
			public void remove () {}
			public bool read_only { get { return true; } }
			public bool valid { get { return cur != null ? true : false; } }

			/* Traversable interface */
			public new bool @foreach (Gee.ForallFunc<xNode> f)
			{
				if (next ())
					return f (get ());
				return false;
			}
		}
	}

	internal class GXml.ChildNodeListReadOnly : Object,
		Traversable<xNode>, Iterable<xNode>, Collection<GXml.xNode>
	{
		public GXml.ChildNodeList list;
		public Gee.Collection<xNode> read_only_view { owned get { return new ChildNodeListReadOnly (list); } }
		public ChildNodeListReadOnly (ChildNodeList list)
		{
			this.list = list;
		}
		public bool add (xNode item) { return false; }
		public void clear () {}
		public bool contains (xNode item) { return list.contains (item); }
		public bool remove (xNode item)  { return false; }
		public bool read_only { get { return true; } }
		public int size { get { return list.size; } }
		public Gee.Iterator<xNode> iterator () { return list.iterator (); }
		public bool @foreach (ForallFunc<xNode> func) {
			return iterator ().foreach (func);
		}
	}
