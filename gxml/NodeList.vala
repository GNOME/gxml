/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

using Gee;

namespace GXml.Dom {
	/**
	 * The NodeList is a live list used to store nodes, often the
	 * children of a node, or a list of nodes matching a tag name.
	 */
	public interface NodeList : Gee.Iterable<XNode> {
		public abstract ulong length {
			get; private set;
		}
		/* NOTE:
		 * children should define constructors like:
		 *     internal NodeList (Xml.Node* head, Document owner);
		 */

		/** NodeList methods */

		/**
		 * Access the idx'th item in the list.
		 */
		// TODO: this should throw invalid index or something
		public abstract XNode item (ulong idx);
		/* NOTE: children should implement
		 *     public ulong length;
		 * TODO: figure out how to require this as a property; maybe have to make it into a method
		 */

		/*** GNOME List conventions ***
		 * Probably don't want to keep all of them since they're not all relevant.
		 */
		/**
		 * Call the provided func on each item of the list.
		 */
		public abstract void foreach (Func<XNode> func);
		// TODO: add hints for performance below, perhaps
		/**
		 * Retrieve the first node in the list.
		 */
		public abstract XNode first ();
		/**
		 * Retrieve the last node in the list.
		 */
		public abstract XNode last ();
		/**
		 * Obtain the n'th item in the list. Used for compatibility with GLib.List.
		 */
		public abstract XNode? nth (ulong n);
		/**
		 * Obtain the n'th item in the list. Used for compatibility with GLib.List.
		 */
		public abstract XNode? nth_data (ulong n);
		/**
		 * Obtain the item n places before pivot in the list.
		 */
		public abstract XNode? nth_prev (XNode pivot, ulong n);
		/**
		 * Obtain index for node target in the list.
		 */
		public abstract int find (XNode target);
		/**
		 * Obtain index for node target in the list, using CompareFunc to compare.
		 */
		public abstract int find_custom (XNode target, CompareFunc<XNode> cmp);
		/**
		 * Obtain index for node target in the list.
		 */
		public abstract int position (XNode target);
		/**
		 * Obtain index for node target in the list.
		 */
		public abstract int index (XNode target);
		// TODO: wow, lots of those GList compatibility methods are the same in a case like this.

		/* These exist to support management of a node's children */
		internal abstract XNode? insert_before (XNode new_child, XNode? ref_child) throws DomError;
		internal abstract XNode? replace_child (XNode new_child, XNode old_child) throws DomError;
		internal abstract XNode? remove_child (XNode old_child) /*throws DomError*/;
		internal abstract XNode? append_child (XNode new_child) /*throws DomError*/;

		/**
		 * Provide a string representation of the list.
		 */
		// TODO: convert it to valid XML
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

		internal AttrChildNodeList (Xml.Attr* parent, Document owner) {
			this.parent = parent;
			this.owner = owner;
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
	internal abstract class ChildNodeList : Gee.Iterable<XNode>, NodeList, GLib.Object {
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

		XNode item (ulong idx) {
			return this.nth (idx);
		}

		/** Iterable methods **/
		public GLib.Type element_type { // TODO: should we need to use the override keyword when implementing interfaces
			get {
				return typeof(XNode);
			}
		}
		public Gee.Iterator<XNode> iterator () {
			return new NodeListIterator (this);
		}
		private class NodeListIterator : Gee.Iterator<XNode>,  GLib.Object {
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
			public new XNode get () {
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
		public void foreach (Func<XNode> func) {
			XNode node;

			for (Xml.Node *cur = head; cur != null; cur = cur->next) {
				node = this.owner.lookup_node (cur);
				func (node);
			}
		}
		public XNode first () {
			return this.owner.lookup_node (head);
		}
		public XNode last () {
			Xml.Node *cur = head;
			while (cur != null && cur->next != null) {
				cur = cur->next;
			}
			return this.owner.lookup_node (cur); // TODO :check for nulls?
		}
		public XNode? nth (ulong n) {
			Xml.Node *cur = head;
			for (int i = 0; i < n && cur != null; i++) {
				cur = cur->next;
			}
			return this.owner.lookup_node (cur);
		}
		public XNode? nth_data (ulong n) {
			return nth (n);
		}
		public XNode? nth_prev (XNode pivot, ulong n) {
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
		public int find (XNode target) {
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
		public int find_custom (XNode target, CompareFunc<XNode> cmp) {
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
		public int position (XNode target) {
			return find (target);
		}
		public int index (XNode target) {
			return find (target);
		}



		/** Node's child methods, implemented here **/
		internal new XNode? insert_before (XNode new_child, XNode? ref_child) throws DomError {
			Xml.Node *child = head;

			if (ref_child == null) {
				this.append_child (ref_child);
			}


			while (child != ((BackedNode)ref_child).node && child != null) {
				child = child->next;
			}
			if (child == null) {
				throw new DomError.NOT_FOUND ("ref_child not found.");
				// TODO: provide a more useful description of ref_child, but there are so many different types
			} else {
				child->add_prev_sibling (((BackedNode)new_child).node);
			}
			return new_child;
		}
		internal new XNode? replace_child (XNode new_child, XNode old_child) throws DomError {
			// TODO: verify that libxml2 already removes
			// new_child first if it is found elsewhere in
			// the tree.

			// TODO: nuts, if Node as an iface can't have properties,
			//       then I have to cast these to XNodes, ugh.
			// TODO: need to handle errors?

			// TODO: want to do a 'find_child' function
			Xml.Node *child = head;

			while (child != null && child != ((BackedNode)old_child).node) {
				child = child->next;
			}

			if (child != null) {
				// it is a valid child
				child->replace (((BackedNode)new_child).node);
			} else {
				throw new DomError.NOT_FOUND ("old_child not found");
				// TODO: provide more useful descr. of old_child
			}
			return old_child;
		}
		internal new XNode? remove_child (XNode old_child) /* throws DomError */ {
			// TODO: verify that old_child is a valid child here and then unlink

			((BackedNode)old_child).node->unlink (); // TODO: do we need to free libxml2 stuff manually?
			return old_child;
		}

		internal virtual XNode? append_child (XNode new_child) /* throws DomError */ {
			// TODO: verify that libxml2 will first remove
			// new_child if it already exists elsewhere in
			// the tree.

			parent_as_xmlnode->add_child (((BackedNode)new_child).node);

			return new_child;
		}

		private string _str;
		public string to_string () {
			_str = "NodeList[";
			foreach (XNode node in this) {
				_str += "(" + node.to_string () + ")";
			}
			_str += "]";

			Xml.Node *cur;
			_str += " contents[";
			for (cur = head; cur != null; cur = cur->next) {
				_str += "Xml.Node*(%s,%s)".printf (cur->name, cur->content);
			}
			_str += "]";

			return _str;
		}
	}
}