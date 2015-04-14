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

using Gee;

namespace GXml {
	/**
	 * A live list used to store {@link GXml.xNode}s.
	 *
	 * Usually contains the children of a {@link GXml.xNode}, or
	 * the results of {@link GXml.Element.get_elements_by_tag_name}.
	 * {@link GXml.NodeList} implements both the DOM Level 1 Core API for
	 * a NodeList, as well as the {@link GLib.List} API, to make
	 * it more accessible and familiar to GLib programmers.
	 * Implementing classes also implement {@link Gee.Iterable}, to make
	 * iteration in supporting languages (like Vala) nice and
	 * easy.
	 *
	 * Version: DOM Level 1 Core<<BR>>
	 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-536297177]]
	 */
	public interface NodeList : GLib.Object, Gee.Iterable<xNode>, Gee.Collection<xNode>
	{
		/* NOTE:
		 * children should define constructors like:
		 *     internal NodeList (Xml.Node* head, Document owner);
		 */

		/**
		 * The number of nodes contained within this list
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-length]]
		 */
		public abstract ulong length {
			get; private set;
		}


		/* ** NodeList methods ** */

		/**
		 * Access the idx'th item in the list.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-item]]
		 */
		public abstract xNode item (ulong idx);

		/* These exist to support management of a node's children */
		public abstract unowned xNode? insert_before (xNode new_child, xNode? ref_child);
		public abstract unowned xNode? replace_child (xNode new_child, xNode old_child);
		public abstract unowned xNode? remove_child (xNode old_child);
		public abstract unowned xNode? append_child (xNode new_child);

		/**
		 * Creates an XML string representation of the nodes in the list.
		 *
		 * #todo: write a test
		 *
		 * @param in_line Whether to parse and expand entities or not
		 *
		 * @return The list as an XML string
		 */
		/*
		 * @todo: write a test
		 */
		public abstract string to_string (bool in_line);

		/**
		 * Retrieve the first node in the list.  Like {@link GLib.List.first}.
		 */
		public abstract xNode first ();

		/**
		 * Retrieve the last node in the list.  Like {@link GLib.List.last}.
		 */
		public abstract xNode last ();
		/**
		 * Obtain the n'th item in the list. Like {@link GLib.List.nth}.
		 *
		 * @param n The index of the item to access
		 */
		public abstract new xNode @get (int n);
	}
}

namespace GXml {
	/* TODO: this will somehow need to watch the document and find
	 * out as new elements are added, and get reconstructed each
	 * time, or get reconstructed-on-the-go?
	 */
	internal class TagNameNodeList : GXml.ArrayList { internal string tag_name;
		internal TagNameNodeList (string tag_name, xNode root, Document owner) {
			base (root);
			this.tag_name = tag_name;
		}
	}

	// /* TODO: warning: this list should NOT be edited :(
	//    we need a new, better live AttrNodeList :| */
	// internal class AttrNodeList : GListNodeList {
	// 	internal AttrNodeList (xNode root, Document owner) {
	// 		base (root);
	// 		base.nodes = root.attributes.get_values ();
	// 	}
	// }

	internal class NamespaceAttrNodeList : GXml.ArrayList {
		internal NamespaceAttrNodeList (BackedNode root, Document owner) {
			base (root);
			for (Xml.Ns *cur = root.node->ns_def; cur != null; cur = cur->next) {
				this.append_child (new NamespaceAttr (cur, owner));
			}
		}
	}

	internal class NodeChildNodeList : ChildNodeList {
		Xml.Node *parent;

		internal override Xml.Node *head {
			get {
				return parent->children;
			}
			set {
				parent->children = value;
			}
		}

		internal NodeChildNodeList (Xml.Node *parent, Document owner) {
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

	internal class AttrChildNodeList : ChildNodeList {
		Xml.Attr *parent;

		internal override Xml.Node *head {
			get {
				return parent->children;
			}
			set {
				parent->children = value;
			}
		}

		internal AttrChildNodeList (Xml.Attr* parent, Document owner) {
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
	internal class EntityChildNodeList : ChildNodeList {
		Xml.Entity *parent;

		internal override Xml.Node *head {
			get {
				return parent->children;
			}
			set {
				parent->children = value;
			}
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

		internal EntityChildNodeList (Xml.Entity* parent, Document owner) {
			this.parent = parent;
			this.owner = owner;
		}
	}

	// TODO: Desperately want to extend List or implement relevant interfaces to make iterable
	// TODO: remember that the order of interfaces that you're listing as implemented matters
	internal abstract class ChildNodeList :  Gee.AbstractCollection<xNode>, NodeList
{
		/* TODO: must be live
		   if this reflects children of a node, then must always be current
		   same with nodes from GetElementByTagName, made need separate impls for each */
		// TODO: if necessary, create two versions that use parent instead of head

		internal weak Document owner;
		internal abstract Xml.Node *head { get; set; }

		internal abstract Xml.Node *parent_as_xmlnode { get; }

		/**
		 * {@inheritDoc}
		 */
		public ulong length {
			get {
				return size;
			}
			private set { }
		}

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
		public override Gee.Iterator<xNode> iterator () {
			return new NodeListIterator (this);
		}
		public override bool @foreach (ForallFunc<xNode> func) {
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
			private weak Document doc;
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
}

internal class GXml.ArrayList : Gee.ArrayList<GXml.xNode>, NodeList
{
  public GXml.xNode root;

  public ulong length {
    get { return size; }
    private set {}
  }

  public ArrayList (GXml.xNode root)
  {
    this.root = root;
  }

        public unowned xNode? insert_before (xNode new_child, xNode? ref_child)
    {
        int i = -1;
        if (contains (ref_child)) {
            i = index_of (ref_child);
            insert (i, new_child);
            return new_child;
        }
        return null;
    }

  public unowned xNode? replace_child (xNode new_child, xNode old_child)
  {
    if (contains (old_child)) {
      int i = index_of (old_child);
      remove_at (i);
      insert (i, new_child);
      return new_child;
    }
    return null;
  }

  public unowned xNode? remove_child (xNode old_child)
  {
    if (contains (old_child)) {
      unowned xNode n = old_child;
      remove_at (index_of (old_child));
      return n;
    }
    return null;
  }

  public unowned xNode? append_child (xNode new_child)
  {
    add (new_child);
    return new_child;
  }

/**
     * Retrieve the first node in the list.  Like {@link GLib.List.first}.
     */
    public xNode first () { return first (); }

    /**
     * Retrieve the last node in the list.  Like {@link GLib.List.last}.
     */
    public xNode last () { return last (); }

    public xNode item (ulong idx)
    {
        return @get((int) idx);
    }

    public string to_string (bool in_line) 
    {
        string str = "";
		foreach (xNode node in this) {
			str += node.to_string ();
		}

		return str;
    }
}
