/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

// NOTE: be careful about what extra data subclasses keep


namespace GXml.Dom {
	public enum NodeType {
		/* NOTE: bug in vala?  if I don't have == 0, I fail when creating
		   this class because I can't set default values for NodeType properties
		   GLib-GObject-CRITICAL **: g_param_spec_enum: assertion `g_enum_get_value (enum_class, default_value) != NULL' failed */
		X_UNKNOWN = 0,
		ELEMENT = 1,
		ATTRIBUTE,
		TEXT,
		CDATA_SECTION,
		ENTITY_REFERENCE,
		ENTITY,
		PROCESSING_INSTRUCTION,
		COMMENT,
		DOCUMENT,
		DOCUMENT_TYPE,
		DOCUMENT_FRAGMENT,
		NOTATION;
	}

	public class DomNode : GLib.Object {
		/** Private properties */
		private Xml.Node *node;

		/** Constructors */
		internal DomNode.virtual () {
		}
		internal DomNode (Xml.Node *node, Document owner) {
			this.node = node;
			this.node_type = (NodeType)node->type;
			this.owner_document = owner; // Considered using node->doc instead, but some subclasses don't have corresponding Xml.Nodes

			// Save the correspondence between this Xml.Node* and its DomNode
			owner.node_dict.insert (node, this);
			// TODO: Consider checking whether the Xml.Node* is already recorded.  It shouldn't be.
		}


		/** Public properties */
		/* None of the following should store any data locally (except the attribute table), they should get data from Xml.Node* */
		public string node_name {
			get {
				return this.node->name;
			}
			private set {
			}
		}

		public virtual string? node_value {
			get {
				return this.node->content;
			}
			internal set {
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
		}/* "raises [DomError] on setting/retrieval"?  */
		public virtual Dom.NodeType node_type {
			get {
				/* Right now, Dom.NodeType's 12 values map perfectly to libxml2's first 12 types */
				return (NodeType)this.node->type;
			}
			internal set {
			}
			// default = NodeType.ELEMENT;
		}
		public DomNode parent_node {
			get {
				return this.owner_document.lookup_node (this.node->parent);
				// TODO: is parent never null? parent is probably possible to be null, like when you create a new element unattached
				// return new DomNode (this.node->parent);
				// TODO: figure out whether we really want to recreate wrapper objects each time
			}
			private set {
			}
		}
		/* TODO: just used unowned to avoid compilation error for stub; investigate what's right */
		// TODO: need to let the user know that editing this list doesn't add children to the node (but then what should?)
		public List<DomNode> child_nodes {
			owned get {
				List<DomNode> children = new List<DomNode> ();
				for (Xml.Node *child = this.node->children; child != null; child = child->next) {
					children.append (this.owner_document.lookup_node (child));
					// children.append (new DomNode (child));
				}
				return children;
			}
			private set {
			}
		}
		public DomNode? first_child {
			get {
				if (this.node->children == null) {
					return null; // TODO: what's the appropriate return value?
				} else {
					//return new DomNode (this.node->children);
					return this.owner_document.lookup_node (this.node->children);
				}
			}
			private set {
			}
		}
		public DomNode? last_child {
			// some children would be Nodes of different types; doesn't this lose that information?
			get {
				Xml.Node *child = this.node->children;
				if (child == null) {
					return null;
				}
				while (child->next != null) {
					child = child->next;
				}
				//return new DomNode (child);
				return this.owner_document.lookup_node (this.node->children);
			}
			private set {
			}
		}
		public DomNode? previous_sibling {
			get {
				return this.owner_document.lookup_node (this.node->prev);
				//return new DomNode (this.node->prev);
			}
			private set {
			}
		}
		public DomNode? next_sibling {
			get {
				//return new DomNode (this.node->next);
				return this.owner_document.lookup_node (this.node->next);
			}
			private set {
			}
		}
		/* HashTable used for XML NamedNodeMap */
		// TODO: note that NamedNodeMap is 'live' so changes to the Node should be seen in the NamedNodeMap (already retrieved), no duplicating it: http://www.w3.org/TR/DOM-Level-1/level-one-core.html
		private HashTable<string,Attr> _attributes = new HashTable<string,Attr> (GLib.str_hash, GLib.str_equal); // TODO: make sure other HashTables have appropriate hash, equal functions
		public HashTable<string,Attr>? attributes {
			// TODO: make sure we want the user to be able to manipulate attributes using this HashTable. // Yes, we do, it should be a live reflection
			// TODO: remember that this table needs to be synced with libxml2 structures; perhaps use a flag that indicates whether it was even accessed, and only then sync it later on
			get {
				switch (this.node_type) {
				case NodeType.ELEMENT:
					return this._attributes;
					// TODO: what other nodes have attrs?
				default:
					return null;
				}
			}
			private set {
			}
		}
		public Document owner_document {
			get;
			internal set;
		}

		public DomNode insert_before (DomNode new_child, DomNode ref_child) throws DomError {
			Xml.Node *child = this.node->children;

			while (child != ((DomNode)ref_child).node && child != null) {
				child = child->next;
			}
			if (child == null) {
				// TODO: couldn't insert before ref, since ref not found
			} else {
				child->add_prev_sibling (((DomNode)new_child).node);
			}

			return new_child; // TODO: make sure that's what we should be returning
		}
		public DomNode replace_child (DomNode new_child, DomNode old_child) throws DomError {
			// TODO: nuts, if Node as an iface can't have properties,
			//       then I have to cast these to DomNodes, ugh.
			// TODO: need to handle errors?

			// TODO: want to do a 'find_child' function
			Xml.Node *child = this.node->children;

			while (child != null && child != ((DomNode)old_child).node) {
				child = child->next;
			}

			if (child != null) {
				// it is a valid child
				child->replace (((DomNode)new_child).node);
			}
			return this; // TODO: what to return?
		}
		public DomNode remove_child (DomNode old_child) throws DomError {
			((DomNode)old_child).node->unlink (); // TODO: do we need to free libxml2 stuff manually?
			return old_child; // TODO: what do we want to return?
		}
		public DomNode append_child (DomNode new_child) throws DomError {
			this.node->add_child (new_child.node);
			return new_child; // TODO: what to return?
		}
		public bool has_child_nodes () {
			return (this.node->children != null);
		}
		public DomNode clone_nodes (bool deep) {
			return this; // STUB
		}
	}
}
