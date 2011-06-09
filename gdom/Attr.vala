/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml.Dom {
	public class Attr : VirtualNode {

		/** Private properties */
		private Xml.Attr *node;

		/** Constructors */
		internal Attr (Xml.Attr *node, Document doc) {
			// TODO: wish valac would warn against using this. before calling base()
			base (NodeType.ATTRIBUTE, doc);
			this.node = node;
			this.specified = false; // TODO: verify that it's false when no value is set
		}

		/** Public properties (Node general) */
		public override string node_name {
			get {
				return this.node->name;
			}
			internal set {
			}
		}
		public override string? node_value {
			get {
				return this.node->children->content; // TODO: same as value here?
			}
			internal set {
				this.node->children->content = value;
			}
		}/* "raises [DomError] on setting/retrieval"?  */
		public new DomNode parent_node {
			get {
				// TODO: couldn't parent be null? :o
				return this.owner_document.lookup_node (this.node->parent);
			}
			private set {
			}
		}

		/* TODO: figure out how to indicate that this is not supported on Attr */
		// public List<Node> child_nodes {
		// }
		// public Node? first_child {
		// }
		// public Node? last_child {
		// }

		public new Attr previous_sibling {
			get {
				return this.owner_document.lookup_attr (this.node->prev);
			}
			private set {
			}
		}
		public new Attr next_sibling {
			get {
				return this.owner_document.lookup_attr (this.node->next);
			}
			private set {
			}
		}
		/* HashTable used for XML NamedNodeMap */
		// TODO: Attributes don't have attributes, need to find a way to indicate that via Vala

		// private HashTable<string,Attr> _attributes = new HashTable<string,Attr> (null, null);
		// public HashTable<string,Attr> attributes {
		// 	get {
		// 		// TODO: do we really want this for Attr?  Sigh
		// 		return _attributes;
		// 		// STUB: do we want to create one locally and update it for the object, or just translate node->properties each call?
		// 		// TODO: this is getting dumb, why is Attr a Node again? :S
		// 	}
		// 	private set {
		// 	}
		// }

		/** Public properties (Attr-specific) */
		public string name {
			get {
				// TODO: make sure that this is the right name, and that ownership is correct
				return this.node_name;
			}
			private set {
			}
		}
		public bool specified {
			get;
			private set;
		}
		public string value {
			get {

				return this.node_value;
			}
			set {
				// this.parent.node->set_prop (
				this.node_value = value;
			}
		}
		// TODO: if 'specified' is to be set when 'value' is, add setter logic to 'value' property

		/** Public methods (Node-specific) */
		public new DomNode insert_before (DomNode new_child, DomNode ref_child) throws DomError {
			throw new DomError.NOT_SUPPORTED_ERR ("Attributes do not have children.");
		}
		public new DomNode replace_child (DomNode new_child, DomNode old_child) throws DomError {
			throw new DomError.NOT_SUPPORTED_ERR ("Attributes do not have children.");
			// TODO: i18n
		}
		public new DomNode remove_child (DomNode old_child) throws DomError {
			throw new DomError.NOT_SUPPORTED_ERR ("Attributes do not have children.");
		}
		public new DomNode append_child (DomNode new_child) throws DomError {
			throw new DomError.NOT_SUPPORTED_ERR ("Attributes do not have children.");
		}
		public new bool has_child_nodes () {
			return false; // STUB
		}
		public new DomNode clone_nodes (bool deep) {
			return this; // STUB
		}


	}
}

// struct _xmlNode {
// 	void *_private: application data
// 	xmlElementTypetype: type number, must be second !
// 	const xmlChar *name: the name of the node, or the entity
// 	struct _xmlNode *children: parent->childs link
// 	struct _xmlNode *last: last child link
// 	struct _xmlNode *parent: child->parent link
// 	struct _xmlNode *next: next sibling link
// 	struct _xmlNode *prev: previous sibling link
// 	struct _xmlDoc *doc: the containing document End of common part
// 	xmlNs *ns: pointer to the associated namespace
// 	xmlChar *content: the content
// 	struct _xmlAttr *properties: properties list
// 	xmlNs *nsDef: namespace definitions on this node
// 	void *psvi: for type/PSVI informations
// 	unsigned shortline: line number
// 	unsigned shortextra: extra data for XPath/XSLT
// } xmlNode;

// struct _xmlAttribute {
// 	void *_private: application data
// 	xmlElementTypetype: XML_ATTRIBUTE_DECL, must be second !
// 	const xmlChar *name: Attribute name
// 	struct _xmlNode *children: NULL
// 	struct _xmlNode *last: NULL
// 	struct _xmlDtd *parent: -> DTD
// 	struct _xmlNode *next: next sibling link
// 	struct _xmlNode *prev: previous sibling link
// 	struct _xmlDoc *doc: the containing document
// 	struct _xmlAttribute *nexth: next in hash table
// 	xmlAttributeTypeatype: The attribute type
// 	xmlAttributeDefaultdef: the default
// 	const xmlChar *defaultValue: or the default value
// 	xmlEnumerationPtrtree: or the enumeration tree if any
// 	const xmlChar *prefix: the namespace prefix if any
// 	const xmlChar *elem: Element holding the attribute
// } xmlAttribute;