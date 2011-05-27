/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml.Dom {
	class Attr : AttrNode {
		public string name {
			get {
				// TODO: make sure that this is the right name, and that ownership is correct
				return base.node_name;
			}
			private set {
			}
		}
		public bool specified {
			get;
			private set;
		}
		public string value;
		// TODO: if 'specified' is to be set when 'value' is, add setter logic to 'value' property

		internal Attr (Xml.Attr *node) {
			base (node);
			this.specified = false; // TODO: verify that it's false when no value is set
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