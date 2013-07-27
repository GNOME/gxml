/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* NodeList.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2013  Daniel Espinosa <esodan@gmail.com>
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
	 * A live list used to store {@link GXml.DomNode}s.
	 *
	 * Usually contains the children of a {@link GXml.DomNode}, or
	 * the results of {@link GXml.Element.get_elements_by_tag_name}.
	 * {@link GXml.NodeList} implements both the DOM Level 1 Core API for
	 * a NodeList, as well as the {@link GLib.List} API, to make
	 * it more accessible and familiar to GLib programmers.
	 * Implementing classes also implement {@link Gee.Iterable}, to make
	 * iteration in supporting languages (like Vala) nice and
	 * easy.
	 *
	 * Version: DOM Level 1 Core
	 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-536297177]]
	 */
	public interface NodeList : Gee.Iterable<DomNode> {
		/* NOTE:
		 * children should define constructors like:
		 *     internal NodeList (Xml.Node* head, Document owner);
		 */

		/**
		 * The number of nodes contained within this list
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-length]]
		 */
		public abstract ulong length {
			get; private set;
		}


		/* ** NodeList methods ** */

		/**
		 * Access the idx'th item in the list.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-item]]
		 */
		public abstract DomNode item (ulong idx);


		/* ** GNOME List conventions **
		 * These methods mimic those available through GList, to make GXmlNodeList more familiar to GLib programmers.
		 * Probably don't want to keep all of them since they're not all relevant.
		 */

		/**
		 * Call the provided func on each item of the list.
		 */
		public abstract void foreach (Func<DomNode> func);
		// TODO: add hints for performance below, perhaps
		/**
		 * Retrieve the first node in the list.
		 */
		public abstract DomNode first ();
		/**
		 * Retrieve the last node in the list.
		 */
		public abstract DomNode last ();
		/**
		 * Obtain the n'th item in the list. Used for compatibility with GLib.List.
		 */
		public abstract DomNode? nth (ulong n);
		/**
		 * Obtain the n'th item in the list. Used for compatibility with GLib.List.
		 */
		public abstract DomNode? nth_data (ulong n);
		/**
		 * Obtain the item n places before pivot in the list.
		 */
		public abstract DomNode? nth_prev (DomNode pivot, ulong n);
		/**
		 * Obtain index for node target in the list.
		 */
		public abstract int find (DomNode target);
		/**
		 * Obtain index for node target in the list, using CompareFunc to compare.
		 */
		public abstract int find_custom (DomNode target, CompareFunc<DomNode> cmp);
		/**
		 * Obtain index for node target in the list.
		 */
		public abstract int position (DomNode target);
		/**
		 * Obtain index for node target in the list.
		 */
		public abstract int index (DomNode target);
		// TODO: wow, lots of those GList compatibility methods are the same in a case like this.


		/* These exist to support management of a node's children */
		internal abstract DomNode? insert_before (DomNode new_child, DomNode? ref_child);
		internal abstract DomNode? replace_child (DomNode new_child, DomNode old_child);
		internal abstract DomNode? remove_child (DomNode old_child);
		internal abstract DomNode? append_child (DomNode new_child);

		/**
		 * Creates an XML string representation of the nodes in the list.
		 *
		 * #todo: write a test
		 *
		 * @param in_line Whether to parse and expand entities or not.
		 *
		 * @return The list as an XML string.
		 *
		 * @todo: write a test
		 */
		public abstract string to_string (bool in_line);
	}

	/**
	 * This provides a NodeList that is backed by a GLib.List of
	 * DomNodes.  A root {@link GXml.DomNode} is specified, which
	 * is usually the owner/parent of the list's contents
	 * (children of the parent).
	 */
	internal class GListNodeList : Gee.Traversable<DomNode>, Gee.Iterable<DomNode>, NodeList, GLib.Object {
		internal DomNode root;
		internal GLib.List<DomNode> nodes;

		internal GListNodeList (DomNode root) {
			this.root = root;
			this.nodes = new GLib.List<DomNode> ();
		}

		/**
		 * {@inheritDoc}
		 */
		public ulong length {
			get {
				return nodes.length ();
			}
			private set {
			}
		}

		/**
		 * {@inheritDoc}
		 */
		public DomNode item (ulong idx) {
			return this.nth_data (idx);
		}
		/**
		 * {@inheritDoc}
		 */
		public bool foreach (ForallFunc<DomNode> func) {
			return iterator ().foreach (func);
		}
		/**
		 * {@inheritDoc}
		 */
		public DomNode first () {
			return this.nodes.first ().data;
		}
		/**
		 * {@inheritDoc}
		 */
		public DomNode last () {
			return this.nodes.last ().data;
		}
		/**
		 * {@inheritDoc}
		 */
		public DomNode? nth (ulong n) {
			return this.nth_data (n);
		}
		/**
		 * {@inheritDoc}
		 */
		public DomNode? nth_data (ulong n) {
			return this.nodes.nth_data ((uint)n);
		}
		/**
		 * {@inheritDoc}
		 */
		public DomNode? nth_prev (DomNode pivot, ulong n) {
			unowned GLib.List<DomNode> list_pivot = this.nodes.find (pivot);
			return list_pivot.nth_prev ((uint)n).data;
		}
		/**
		 * {@inheritDoc}
		 */
		public int find (DomNode target) {
			return this.index (target);
		}
		/**
		 * {@inheritDoc}
		 */
		public int find_custom (DomNode target, CompareFunc<DomNode> cmp) {
			unowned GLib.List<DomNode> list_pt = this.nodes.find_custom (target, cmp);
			return this.index (list_pt.data);
		}
		/**
		 * {@inheritDoc}
		 */
		public int position (DomNode target) {
			return this.index (target);
		}
		/**
		 * {@inheritDoc}
		 */
		public int index (DomNode target) {
			return this.nodes.index (target);
		}

		internal DomNode? insert_before (DomNode new_child, DomNode? ref_child) {
			this.nodes.insert_before (this.nodes.find (ref_child), new_child);
			return new_child;
		}
		internal DomNode? replace_child (DomNode new_child, DomNode old_child) {
			int pos = this.index (old_child);
			this.remove_child (old_child);
			this.nodes.insert (new_child, pos);
			return old_child;
		}
		internal DomNode? remove_child (DomNode old_child) /*throws DomError*/ {
			this.nodes.remove (old_child);
			return old_child;
		}
		internal DomNode? append_child (DomNode new_child) /*throws DomError*/ {
			this.nodes.append (new_child);
			return new_child;
		}

		public string to_string (bool in_line) {
			string str = "";

			foreach (DomNode node in this.nodes) {
				str += node.to_string ();
			}

			return str;
		}

		/* ** Iterable methods ***/
		public GLib.Type element_type {
			get {
				return typeof (DomNode);
			}
		}
		public Gee.Iterator<DomNode> iterator () {
			return new NodeListIterator (this);
		}

		/**
		 * Iterator for NodeLists.  Allows you to iterate a
		 * collection neatly in vala.
		 */
		private class NodeListIterator : GenericNodeListIterator {
			/* When you receive one, initially you cannot get anything.
			 * Use has_next () to determine if there is a next one.
			 *   If the list is not empty, this should always be true.
			 *   (If it wasn't read-only, it could become empty by removing)
			 * Use next () to advance to the first/next one.
			 *   If not empty, always succeed
			 * get () fails before first next and after remove (), always succeeds elsewise.
			 *   Implies we cycle
			 * remove () always fails (does nothing)
			 */

			private unowned GLib.List<DomNode> cur;
			private unowned GLib.List<DomNode> first_node;
			private unowned GLib.List<DomNode> next_node;

			public NodeListIterator (GListNodeList list) {
				this.cur = null;
				this.first_node = list.nodes;
				this.next_node = list.nodes;
			}

			protected override DomNode get_current () {
				return this.cur.data;
			}

			protected override bool is_empty () {
				return (this.next_node == null);
			}

			// TODO: address ambiguity of libgee documentation that led me to believe that a call to get needed to be valid in such a way that I had to cycle here.
			protected override void advance () {
				this.cur = this.next_node;
				this.next_node = this.cur.next;
			}
		}
	}

	/* TODO: this will somehow need to watch the document and find
	 * out as new elements are added, and get reconstructed each
	 * time, or get reconstructed-on-the-go?
	 */
	internal class TagNameNodeList : GListNodeList { internal string tag_name;
		internal TagNameNodeList (string tag_name, DomNode root, Document owner) {
			base (root);
			this.tag_name = tag_name;
		}
	}

	/* TODO: warning: this list should NOT be edited :(
	   we need a new, better live AttrNodeList :| */
	internal class AttrNodeList : GListNodeList {
		internal AttrNodeList (DomNode root, Document owner) {
			base (root);
			base.nodes = root.attributes.get_values ();
		}
	}

	internal class NamespaceAttrNodeList : GListNodeList {
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
	// TODO: remember that the order of interfaces that you're listing as implemented matters
	internal abstract class ChildNodeList : Gee.Traversable<DomNode>, Gee.Iterable<DomNode>, NodeList, GLib.Object {
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
				int len = 0;
				for (Xml.Node *cur = head; cur != null; cur = cur->next) {
					len++;
				}
				return len;
			}
			private set { }
		}

		/**
		 * {@inheritDoc}
		 */
		public DomNode item (ulong idx) {
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


		/** GNOME List conventions
		 ** Probably don't want to keep all of them since they're not all relevant.
		 **/
		public bool foreach (ForallFunc<DomNode> func) {
			return iterator ().foreach (func);
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
		internal new DomNode? insert_before (DomNode new_child, DomNode? ref_child) {
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
			} else {
				if (new_child.node_type == NodeType.DOCUMENT_FRAGMENT) {
					foreach (DomNode new_grand_child in new_child.child_nodes) {
						child->add_prev_sibling (((BackedNode)new_grand_child).node);
					}
				} else {
					child->add_prev_sibling (((BackedNode)new_child).node);
				}
			}
			return new_child;
		}

		internal new DomNode? replace_child (DomNode new_child, DomNode old_child) {
			// TODO: verify that libxml2 already removes
			// new_child first if it is found elsewhere in
			// the tree.

			// TODO: nuts, if Node as an iface can't have properties,
			//       then I have to cast these to DomNodes, ugh.
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
		internal new DomNode? remove_child (DomNode old_child) /* throws DomError */ {
			// TODO: verify that old_child is a valid child here and then unlink

			((BackedNode)old_child).node->unlink (); // TODO: do we need to free libxml2 stuff manually?
			return old_child;
		}

		internal virtual DomNode? append_child (DomNode new_child) /* throws DomError */ {
			// TODO: verify that libxml2 will first remove
			// new_child if it already exists elsewhere in
			// the tree.

			if (new_child.node_type == NodeType.DOCUMENT_FRAGMENT) {
				foreach (DomNode grand_child in new_child.child_nodes) {
					parent_as_xmlnode->add_child (((BackedNode)grand_child).node);
				}
			} else {
				parent_as_xmlnode->add_child (((BackedNode)new_child).node);
			}

			return new_child;
		}

		private string _str;
		public string to_string (bool in_line = true) {
			_str = "";
			foreach (DomNode node in this) {
				_str += node.to_string ();
			}
			return _str;
		}

		/* ** NodeListIterator ***/

		private class NodeListIterator : GenericNodeListIterator {
			private weak Document doc;
			private Xml.Node *cur;
			private Xml.Node *head;
			private Xml.Node *next_node;

			/* TODO: consider rewriting this to work on NodeList instead of the Xml.Node*
			   list, then perhaps we could reuse it for get_elements_by_tag_name () */
			public NodeListIterator (ChildNodeList list) {
				this.head = list.head;
				this.next_node = this.head;
				this.cur = null;
				this.doc = list.owner;
			}

			/* ** model-specific methods ***/

			protected override DomNode get_current () {
				return this.doc.lookup_node (this.cur);
			}

			protected override bool is_empty () {
				return (this.next_node == null);
			}

			protected override void advance () {
				this.cur = this.next_node;
				this.next_node = cur->next;
			}
		}
	}

	private abstract class GenericNodeListIterator : Gee.Traversable<DomNode>, Gee.Iterator<DomNode>, GLib.Object {
		protected abstract DomNode get_current ();
		protected abstract bool is_empty ();
		protected abstract void advance ();

		public bool foreach (ForallFunc<DomNode> f) {
			var r = this.get ();
			bool ret = f(r);
			if (ret && this.next ())
				return true;
			else
				return false;
		}

		/* ** Iterator methods ***/

		/**
		 * Obtain the current DomNode in the iteration.
		 * Returns null if there is none, which occurs
		 * if the list is empty or if iteration has
		 * not started (next () has never been
		 * called).
		 */
		public new DomNode get () {
			if (this.valid) {
				return this.get_current ();
			} else {
				// TODO: file bug, Iterator wants DomNode, not DomNode?, but it wants us to be able to return null.
				return null;
			}
		}

		/**
		 * Advance to the next DomNode in the list
		 */
		public bool next () {
			if (this.is_empty ()) {
				// the list is empty
				return false;
			} else {
				this.advance ();
				return true;
			}
		}

		/**
		 * Checks whether there is a next DomNode in the list.
		 */
		public bool has_next () {
			return (! this.is_empty ());
		}

		/**
		 * Lets the user know that the NodeList is
		 * read_only so the remove () operation will
		 * fail.
		 */
		public bool read_only {
			get {
				return true;
			}
		}

		/**
		 * Indicates whether a call to get () will
		 * succeed. This should only be false at the
		 * start before the first call to next ().
		 */
		public bool valid {
			get {
				return (this.get_current () != null);
			}
		}

		/**
		 * NodeLists are read-only.  remove () will
		 * always fail.  To remove a node from a
		 * document, it must be done from the parent
		 * node using remove_child ().
		 */
		public void remove () {
			// TODO: consider making this totally silent
			GLib.warning ("Remove on NodeList not supported: Nodes must be removed from parent or doc separately.");
		}
	}
}
