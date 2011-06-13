/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* NOTE: attributes may contain trees as references, for entity references */
/* TODO: figure out whether, if in Element we use set_attribute and
 * change one, whether an Attr node should have its value replaced */
/* allowed values defined in a separate DTD; we won't be parsing those :D */

/* NOTE: default values: complex, might want a hash table storing them for each attribute name */
/* NOTE: children might contain Text or Entity references */
/* NOTE: might want to base this on Xml.Attribute instead (can we?) */
/* NOTE: specified is false if it wasn't set, but was created because it still supplied a default value, I think */
/* NOTE: figure out how entity references work with Attrs */
/* NOTE: value as children nodes: can contain Text and EntityReferences */

namespace GXml.Dom {
	public class Attr : DomNode {

		/** Private properties */
		private Xml.Attr *node;

		/** Constructors */
		internal Attr (Xml.Attr *node, Document doc) {
			// TODO: wish valac would warn against using this. before calling base()
			base (NodeType.ATTRIBUTE, doc);
			this.node = node;
			this.specified = true;
		}

		/** Public properties (Node general) */
		public override string node_name {
			get {
				return this.node->name;
			}
			internal set {
			}
		}

		/* "raises [DomError] on setting/retrieval"?  */
		private string _node_value;
		public override string? node_value {
			/* If Attrs were always attached to elements, then it would have been
			   nice to use elem.node->get/set_prop (name[,value])  :S */
			get {
				this._node_value = "";
				foreach (DomNode child in this.child_nodes) {
					this._node_value += child.node_value;
				}
				return this._node_value;
			}
			internal set {
				try {
					// TODO: consider adding an empty () method to NodeList
					foreach (DomNode child in this.child_nodes) {
						this.remove_child (child);
					}
					this.append_child (this.owner_document.create_text_node (value));
					// TODO: may want to normalise
				} catch (DomError e) {
					// TODO: handle
				}
				// TODO: need to expand entity references too?
			}
		}


		public override NodeList? child_nodes {
			owned get {
				// TODO: always create a new one?
				return new AttrChildNodeList (this.node, this.owner_document);
			}
			internal set {
			}
		}


		/** Public properties (Attr-specific) */

		public string name {
			get {
				// TODO: make sure that this is the right name, and that ownership is correct
				return this.node_name;
			}
			private set {
			}
		}

		// TODO: if 'specified' is to be set when 'value' is,
		// add setter logic to 'value' property
		public bool specified {
			get;
			private set;
		}
		public string value {
			get {
				return this.node_value;
			}
			set {
				this.node_value = value;
			}
		}

		/** Public methods (Node-specific) */
		public override DomNode? insert_before (DomNode new_child, DomNode ref_child) throws DomError {
			return this.child_nodes.insert_before (new_child, ref_child);
		}
		public override DomNode? replace_child (DomNode new_child, DomNode old_child) throws DomError {
			return this.child_nodes.replace_child (new_child, old_child);
		}
		public override DomNode? remove_child (DomNode old_child) throws DomError {
			return this.child_nodes.remove_child (old_child);
		}
		public override DomNode? append_child (DomNode new_child) throws DomError {
			return this.child_nodes.append_child (new_child);
		}
		public override bool has_child_nodes () {
			return (this.child_nodes.length > 0);
		}
		public override DomNode? clone_nodes (bool deep) {
			return this; // STUB
		}
	}
}
