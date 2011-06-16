/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

using Gee;

namespace GXml.Dom {
	public interface NodeList : Gee.Iterable<DomNode> {
		public abstract ulong length {
			get; private set;
		}
		// internal NodeList (Xml.Node* head, Document owner);
		public abstract DomNode item (ulong idx);

		/** GNOME List conventions
		 ** Probably don't want to keep all of them since they're not all relevant.
		 **/
		public abstract void foreach (Func<DomNode> func);
		public abstract DomNode first ();
		public abstract DomNode last ();
		public abstract DomNode? nth (ulong n);
		public abstract DomNode? nth_data (ulong n);
		public abstract DomNode? nth_prev (DomNode pivot, ulong n);
		public abstract int find (DomNode target);
		public abstract int find_custom (DomNode target, CompareFunc<DomNode> cmp);
		public abstract int position (DomNode target);
		public abstract int index (DomNode target);

		internal abstract DomNode? insert_before (DomNode new_child, DomNode ref_child) /*throws DomError*/;
		internal abstract DomNode? replace_child (DomNode new_child, DomNode old_child) /*throws DomError*/;
		internal abstract DomNode? remove_child (DomNode old_child) /*throws DomError*/;
		internal abstract DomNode? append_child (DomNode new_child) /*throws DomError*/;

		public abstract string to_string ();
	}

	// TODO: this will somehow need to watch the document and find out as new elements are added, and get reconstructed each time, or get reconstructed-on-the-go?
	// public class NameTagNodeList : NodeList {

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

		internal NodeChildNodeList (Xml.Node* parent, Document owner) {
			this.parent = parent;
			this.owner = owner;
		}

		internal override Xml.Node *parent_as_xmlnode {
			get {
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

		internal override Xml.Node *parent_as_xmlnode {
			get {
				/* This is disgusting, but we do this for the case where
				   xmlAttr*'s immediate children list the xmlAttr as their
				   parent, but claim that xmlAttr is an xmlNode* (since
				   the parent field is of type xmlNode*).  We need to get
				   an Xml.Node*ish parent for when we append new children
				   here, whether we're the list of children of an Attr
				   or not. */
				return (Xml.Node*)parent;
			}
		}

		internal AttrChildNodeList (Xml.Attr* parent, Document owner) {
			this.parent = parent;
			this.owner = owner;
		}
	}

	// TODO: Desperately want to extend List or implement relevant interfaces to make iterable
	internal abstract class ChildNodeList : Gee.Iterable<DomNode>, NodeList, GLib.Object {
		/* TODO: must be live
		   if this reflects children of a node, then must always be current
		   same with nodes from GetElementByTagName, made need separate impls for each */
		// TODO: if necessary, create two versions that use parent instead of head

		internal Document owner;
		internal abstract Xml.Node *head { get; set; }

		internal abstract Xml.Node *parent_as_xmlnode { get; }

		// TODO: consider uint
		public ulong length {
			get {
				int len = 0;
				for (Xml.Node *cur = head; cur != null; cur = cur->next) {
					len++;
				}
				return len;
			}
			private set { }
		}

		DomNode item (ulong idx) {
			return this.nth (idx);
		}

		/** Iterable methods **/
		public GLib.Type element_type { // TODO: should we need to use the override keyword when implementing interfaces
			get {
				return typeof(DomNode);
			}
		}
		public Gee.Iterator<DomNode> iterator () {
			return new NodeListIterator (this);
		}
		private class NodeListIterator : Gee.Iterator<DomNode>,  GLib.Object {
			private Xml.Node *head;
			private Xml.Node *cur;
			private Xml.Node *next_node;
			private Document doc;

			// TODO: consider rewriting this to work on NodeList instead of the Xml.Node*
			// list, then perhaps we could reuse it for get_elements_by_tag_name ()
			public NodeListIterator (ChildNodeList list) {
				this.head = list.head;
				this.next_node = this.head;
				this.cur = null;
				this.doc = list.owner;
			}
			public new DomNode get () {
				return doc.lookup_node (this.cur);
			}
			public bool next () {
				if (next_node != null) {
					cur = next_node;
					next_node = cur->next;
					return true;
				} else {
					return false;
				}
			}
			public bool first () {
				cur = null;
				next_node = head;

				return (next_node != null);
			}
			public bool has_next () {
				return (next_node != null);
			}
			public void remove () {
				/* TODO: indicate that this is not supported. */
				GLib.warning ("Remove on NodeList not supported: Nodes must be removed from parent or doc separately.");
			}
		}

		/** GNOME List conventions
		 ** Probably don't want to keep all of them since they're not all relevant.
		 **/
		public void foreach (Func<DomNode> func) {
			DomNode node;

			for (Xml.Node *cur = head; cur != null; cur = cur->next) {
				node = this.owner.lookup_node (cur);
				func (node);
			}
		}
		public DomNode first () {
			return this.owner.lookup_node (head);
		}
		public DomNode last () {
			Xml.Node *cur = head;
			while (cur != null && cur->next != null) {
				cur = cur->next;
			}
			return this.owner.lookup_node (cur); // TODO :check for nulls?
		}
		public DomNode? nth (ulong n) {
			Xml.Node *cur = head;
			for (int i = 0; i < n && cur != null; i++) {
				cur = cur->next;
			}
			return this.owner.lookup_node (cur);
		}
		public DomNode? nth_data (ulong n) {
			return nth (n);
		}
		public DomNode? nth_prev (DomNode pivot, ulong n) {
			Xml.Node *cur;
			for (cur = head; cur != null && this.owner.lookup_node (cur) != pivot; cur = cur->next) {
			}
			if (cur == null) {
				return null;
			}
			for (int i = 0; i < n && cur != null; i++) {
				cur = cur->prev;
			}
			return this.owner.lookup_node (cur);
		}
		public int find (DomNode target) {
			int pos = 0;
			Xml.Node *cur;
			for (cur = head; cur != null && this.owner.lookup_node (cur) != target; cur = cur->next) {
				pos++;
			}
			if (cur == null) {
				return -1;
			} else {
				return pos;
			}
		}
		public int find_custom (DomNode target, CompareFunc<DomNode> cmp) {
			int pos = 0;
			Xml.Node *cur;
			for (cur = head; cur != null && cmp (this.owner.lookup_node (cur), target) != 0; cur = cur->next) {
				pos++;
			}
			if (cur == null) {
				return -1;
			} else {
				return pos;
			}
		}
		public int position (DomNode target) {
			return find (target);
		}
		public int index (DomNode target) {
			return find (target);
		}



		/** Node's child methods, implemented here **/
		internal new DomNode? insert_before (DomNode new_child, DomNode ref_child) /* throws DomError */ {
			Xml.Node *child = head;

			while (child != ((BackedNode)ref_child).node && child != null) {
				child = child->next;
			}
			if (child == null) {
				// TODO: couldn't insert before ref, since ref not found
			} else {
				child->add_prev_sibling (((BackedNode)new_child).node);
			}
			return new_child;
		}
		internal new DomNode? replace_child (DomNode new_child, DomNode old_child) /* throws DomError */ {
			// TODO: nuts, if Node as an iface can't have properties,
			//       then I have to cast these to DomNodes, ugh.
			// TODO: need to handle errors?

			// TODO: want to do a 'find_child' function
			Xml.Node *child = head;

			while (child != null && child != ((BackedNode)old_child).node) {
				child = child->next;
			}

			if (child != null) {
				// it is a valid child
				child->replace (((BackedNode)new_child).node);
			}
			return old_child;
		}
		internal new DomNode? remove_child (DomNode old_child) /* throws DomError */ {
			((BackedNode)old_child).node->unlink (); // TODO: do we need to free libxml2 stuff manually?
			return old_child;
		}

		internal virtual DomNode? append_child (DomNode new_child) /* throws DomError */ {
			Xml.Node *err;

			parent_as_xmlnode->add_child (((BackedNode)new_child).node);

			return new_child;
		}

		private string _str;
		public string to_string () {
			_str = "NodeList[";
			foreach (DomNode node in this) {
				_str += "(" + node.to_string () + ")";
			}
			_str += "]";

			Xml.Node *cur;
			_str += " contents[";
			for (cur = head; cur != null; cur = cur->next) {
				_str += "Xml.Node*(%x,%s,%s)".printf ((uint)cur, cur->name, cur->content);
			}
			_str += "]";

			return _str;
		}
	}
}