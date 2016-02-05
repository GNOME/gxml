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

internal abstract class GXml.ChildNodeList : AbstractBidirList<xNode>, NodeList
{
		/* TODO: must be live
		   if this reflects children of a node, then must always be current
		   same with nodes from GetElementByTagName, made need separate impls for each */
		// TODO: if necessary, create two versions that use parent instead of head

		internal weak xDocument owner;
		internal abstract Xml.Node *head { get; set; }

		internal abstract Xml.Node *parent_as_xmlnode { get; }
		
		construct { Init.init (); }
		/**
		 * {@inheritDoc}
		 */
		public ulong length {
			get {
				return size;
			}
			protected set { }
		}
		// Gee.AbstractCollection
		public override bool add (xNode item)
		{
			append_child (item);
			return true;
		}
		public override void clear () {}
		public override bool contains (xNode item) { return false; }
		public override bool remove (xNode item)  { return false; }
		public override bool read_only { get { return true; } }
		public override int size {
	    get {
        if (head != null) {
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
		public override Gee.Iterator<xNode> iterator () {
			return new Iterator (this);
		}
		public override bool @foreach (ForallFunc<xNode> func) {
			return iterator ().foreach (func);
		}
		// Gee.AbstractList
		
		public override new xNode @get (int n)
            requires (head != null)
        {
          Test.message ("Searching for node at: "+n.to_string ());
            Xml.Node *cur = head;
            int i = 0;
            while (cur != null) {
              if (i == n) return this.owner.lookup_node (cur);
                cur = cur->next;
                i++;
            }
			return null;
		}
		public override int index_of (xNode item)
      requires (item is BackedNode)
    {
			var l = head;
			int i = 0;
			while (l->next != null) {
				if (((BackedNode) item).node == l)
					return i;
				l = l->next;
			}
			return -1;
		}
		public override void insert (int index, xNode item) {
			var n = get (index);
			if (n != null) {
				insert_before (item, n);
			}
		}
		public override Gee.ListIterator<xNode> list_iterator () { return new Iterator (this); }
		public override xNode remove_at (int index) {
			var n = get (index);
			return remove_child (n);
		}
		public override new void @set (int index, xNode item) {
			var n = get (index);
			replace_child (item, n);
		}
		public override Gee.List<xNode>? slice (int start, int stop) { return null; }

    // Gee.AbstractBidirList
		public override Gee.BidirListIterator<xNode> bidir_list_iterator () { return new Iterator (this); }
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
				GXml.warning (DomException.NOT_FOUND, _("ref_child '%s' not found, was supposed to have '%s' inserted before it.").printf (ref_child.node_name, new_child.node_name));
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
				str += node.stringify ();
			}
			return str;
		}
		//

		/* ** NodeListIterator ***/

		private class Iterator : GLib.Object,
      Gee.Traversable<xNode>, Gee.Iterator<xNode>, Gee.ListIterator<xNode>,
      Gee.BidirIterator<xNode>, Gee.BidirListIterator<xNode>
		{
      private ChildNodeList list;
			private weak xDocument doc;
			private Xml.Node *cur;
			private Xml.Node *head;
      private int i = -1;

			/* TODO: consider rewriting this to work on NodeList instead of the Xml.Node*
			   list, then perhaps we could reuse it for get_elements_by_tag_name () */
			public Iterator (ChildNodeList list) {
				this.head = list.head;
				this.cur = null;
				this.doc = list.owner;
        this.list = list;
			}
			/* Gee.Iterator interface */
			public new xNode @get () { return this.doc.lookup_node (this.cur); }
			public bool has_next () {
        if (cur == null) {
          if (head == null) return false;
          return true;
        }
        return cur->next == null ? false : true;
      }
			public bool next () {
        if (cur == null) {
          cur = head;
          i++;
          return true;
        }
				if (cur->next == null) return false;
        i++;
				cur = cur->next;
				return true;
			}
			public void remove () {
        var n = get ();
        list.remove_child (n);
      }
			public bool read_only { get { return false; } }
			public bool valid { get { return cur != null ? true : false; } }

			/* Traversable interface */
			public new bool @foreach (Gee.ForallFunc<xNode> f)
			{
				if (next ())
					return f (get ());
				return false;
			}
      // Gee.ListIterator
      public void add (xNode item) {
        var n = get ();
        list.insert_before (item, n);
      }
		  public int index () { return i; }
		  public new void @set (xNode item) {
        var n = get ();
        list.replace_child (item, n);
		  }
      // Gee.BidirIterator
      public bool first () {
        var n = ((BackedNode) list.first ()).node;
        if (n == null) return false;
        head = n;
        cur = head;
        i = 0;
        return true;
      }
		  public bool has_previous () {
        if (cur->prev != null) return true;
        return false;
		  }
		  public bool last () {
        if (cur == null) return false;
        while (cur->next != null) {
          cur = cur->next;
          i++;
        }
        return true;
		  }
		  public bool previous () {
        if (cur->prev == null) return false;
        cur = cur->prev;
        i--;
        return true;
		  }
      // Gee.BidirListIterator
      public void insert (xNode item) {
        var n = get ();
        list.insert_before (item, n);
      }
		}
	}
