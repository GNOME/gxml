/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

// NOTE: be careful about what extra data subclasses keep


namespace GXml.Dom {
	/**
	 * An internal class for nodes whose content is stored in a
	 * corresponding Xml.Node. This would normally be hidden, but
	 * Vala wants base classes to be at least as public as
	 * subclasses.
	 */
	public class BackedNode : XNode {
		/** Private properties */
		internal Xml.Node *node;

		/** Constructors */
		internal BackedNode (Xml.Node *node, Document owner) {
			base ((NodeType)node->type, owner);
			// Considered using node->doc instead, but some subclasses don't have corresponding Xml.Nodes
			this.node = node;

			// Save the correspondence between this Xml.Node* and its XNode
			owner.node_dict.insert (node, this);
			// TODO: Consider checking whether the Xml.Node* is already recorded.  It shouldn't be.
		}


		/* Public properties */

		/**
		 * {@inheritDoc}
		 */
		public override string? namespace_uri {
			get {
				// TODO: there can be multiple NSes on a node, using ->next, right now we just return the first.  What should we do?!?!
				return this.node->ns_def->href;
				// TODO: handle null ns_def
				// TODO: figure out when node->ns is used, as opposed to ns_def
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? prefix {
			get {
				return this.node->ns_def->prefix;
				// TODO: handle null ns
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? local_name {
			get {
				return this.node_name;
			}
			internal set {
			}
		}

		/* None of the following should store any data locally (except the attribute table), they should get data from Xml.Node* */

		// TODO: make sure that subclasses obey the table in Node for node_name, node_value, and attributes; probably figure it out as I create tests for them.
		/**
		 * {@inheritDoc}
		 */
		public override string node_name {
			get {
				return this.node->name;
			}
			internal set {
			}
		}

		/**
		 * {@inheritDoc}
		 */
		public override string? node_value {
			get {
				return this.node->content;
			}
			internal set {
				/* NOTE: this is mainly for Text and CharacterData, many other
				         Nodes really want to edit children, but hopefully they
				         override node_value anyway. */
				this.node->content = value;
			}
		}
		//  {
			// get {
			// 	// TODO: where is this typically stored?
			// 	// TODO: if it's an Element, it should return null, as all its 'value' is in its children
			// 	return this.node->content; // TODO: same as value here?
			// }
			// internal set {
			// 	this.node->children->content = value;
			// }
		//}/* "raises [DomError] on setting/retrieval"?  */
		/**
		 * {@inheritDoc}
		 */
		public override Dom.NodeType node_type {
			get {
				/* Right now, Dom.NodeType's 12 values map perfectly to libxml2's first 12 types */
				return (NodeType)this.node->type;
			}
			internal set {
			}
			// default = NodeType.ELEMENT;
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? parent_node {
			get {
				return this.owner_document.lookup_node (this.node->parent);
				// TODO: is parent never null? parent is probably possible to be null, like when you create a new element unattached
				// return new XNode (this.node->parent);
				// TODO: figure out whether we really want to recreate wrapper objects each time
			}
			internal set {
			}
		}
		/* TODO: just used unowned to avoid compilation error for stub; investigate what's right */
		// TODO: need to let the user know that editing this list doesn't add children to the node (but then what should?)
		/* NOTE: try to avoid using this too often internally, would be much quicker to
		   just traverse Xml.Node*'s children */
		/**
		 * {@inheritDoc}
		 */
		public override NodeList? child_nodes {
			owned get {
				// TODO: always create a new one?
				return new NodeChildNodeList (this.node, this.owner_document);
			}
			internal set {
			}
		}

		private XNode? _first_child;
		/**
		 * {@inheritDoc}
		 */
		public override XNode? first_child {
			get {
				_first_child = this.child_nodes.first ();
				return _first_child;
				// return this.child_nodes.first ();
			}
			internal set {
			}
		}

		private XNode? _last_child;
		/**
		 * {@inheritDoc}
		 */
		public override XNode? last_child {
			get {
				_last_child = this.child_nodes.last ();
				return _last_child;
				//return this.child_nodes.last (); //TODO: just want to relay
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? previous_sibling {
			get {
				return this.owner_document.lookup_node (this.node->prev);
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? next_sibling {
			get {
				return this.owner_document.lookup_node (this.node->next);
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override HashTable<string,Attr>? attributes {
			get {
				return null;
			}
			internal set {
			}
		}

		// TODO: investigate which classes can have children;
		//       e.g. Text shouldn't, and these should error if we try;
		//       how does libxml2 handle it?  test that

		/**
		 * {@inheritDoc}
		 */
		public override XNode? insert_before (XNode new_child, XNode? ref_child) throws DomError {
			return this.child_nodes.insert_before (new_child, ref_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? replace_child (XNode new_child, XNode old_child) throws DomError {
			return this.child_nodes.replace_child (new_child, old_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? remove_child (XNode old_child) /*throws DomError*/ {
			return this.child_nodes.remove_child (old_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override XNode? append_child (XNode new_child) /*throws DomError*/ {
			return this.child_nodes.append_child (new_child);
		}
		/**
		 * {@inheritDoc}
		 */
		public override bool has_child_nodes () {
			return (this.child_nodes.length > 0);
		}

		/**
		 * {@inheritDoc}
		 */
		public override XNode? clone_nodes (bool deep) {
			return this; // STUB
		}

		public override string to_string (bool format = false, int level = 0) {
			Xml.Buffer *buffer;
			string str;

			buffer = new Xml.Buffer ();
			buffer->node_dump (this.owner_document.xmldoc, this.node, level, format ? 1 : 0);
			str = buffer->content ();

			return str;
		}
	}
}
