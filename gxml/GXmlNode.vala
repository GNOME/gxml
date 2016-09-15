/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;

/**
 * Base interface providing basic functionalities to all GXml interfaces.
 */
public abstract class GXml.GNode : Object,
                      GXml.DomEventTarget,
                      GXml.DomNode,
                      GXml.Node
{
  protected GXml.GDocument _doc;
  protected Xml.Node *_node;

  construct {
    Init.init ();
  }

  // GXml.Node
  public virtual bool set_namespace (string uri, string? prefix)
  {
    if (_node == null) return false;
    return ((_node->new_ns (uri, prefix)) != null);
  }
  public virtual Gee.Map<string,GXml.Node> attrs { owned get { return new GHashMapAttr (_doc, _node); } }
  public virtual Gee.BidirList<GXml.Node> children_nodes { owned get { return new GListChildren (_doc, _node); } }
  public virtual Gee.List<GXml.Namespace> namespaces { owned get { return new GListNamespaces (_doc, _node); } }
  public virtual GXml.Document document { get { return _doc; } }
  public virtual GXml.Node parent {
    owned get {
      if (_node == null) return null;
      return to_gnode (document as GDocument, _node->parent);
    }
  }
  public virtual GXml.NodeType type_node {
    get {
      if (_node == null) return GXml.NodeType.X_UNKNOWN;
      return (GXml.NodeType) _node->type;
    }
  }
  public virtual string name {
    owned get {
      if (_node == null) return "#noname";
      return _node->name.dup ();
    }
  }

  public virtual string @value {
    owned get {
      if (_node == null) return "";
      return _node->get_content ();
    }
    set {
      if (_node == null) return;
      _node->set_content (value);
    }
  }
  public virtual string to_string () { return get_type ().name (); }
  public Xml.Node* get_internal_node () { return _node; }
  // Static
  public static GXml.Node to_gnode (GXml.GDocument doc, Xml.Node *node) {
    var t = (GXml.NodeType) node->type;
    switch (t) {
      case GXml.NodeType.ELEMENT:
        return new GElement (doc, node);
      case GXml.NodeType.ATTRIBUTE:
        return new GAttribute (doc, (Xml.Attr*) node);
      case GXml.NodeType.TEXT:
        return new GText (doc, node);
      case GXml.NodeType.CDATA_SECTION:
        return new GCDATA (doc, node);
      case GXml.NodeType.ENTITY_REFERENCE:
        return null;
      case GXml.NodeType.ENTITY:
        return null;
      case GXml.NodeType.PROCESSING_INSTRUCTION:
        return new GProcessingInstruction (doc, node);
      case GXml.NodeType.COMMENT:
        return new GComment (doc, node);
      case GXml.NodeType.DOCUMENT:
        return new GDocument.from_doc (node->doc);
      case GXml.NodeType.DOCUMENT_TYPE:
        return null;
      case GXml.NodeType.DOCUMENT_FRAGMENT:
        return null;
      case GXml.NodeType.NOTATION:
        return null;
    }
    return null;
  }
  // DomNode Implementation
  public DomNode.NodeType node_type {
    get {
      if (_node == null) return DomNode.NodeType.INVALID;
      switch (_node->type) {
        case Xml.ElementType.ELEMENT_NODE:
          return DomNode.NodeType.ELEMENT_NODE;
        case Xml.ElementType.ATTRIBUTE_NODE:
          return DomNode.NodeType.ATTRIBUTE_NODE; // historica
        case Xml.ElementType.TEXT_NODE:
          return DomNode.NodeType.TEXT_NODE;
        case Xml.ElementType.CDATA_SECTION_NODE:
          return DomNode.NodeType.CDATA_SECTION_NODE; // historical
        case Xml.ElementType.ENTITY_REF_NODE:
          return DomNode.NodeType.ENTITY_REFERENCE_NODE; // historical
        case Xml.ElementType.ENTITY_NODE:
          return DomNode.NodeType.ENTITY_NODE; // historical
        case Xml.ElementType.PI_NODE:
          return DomNode.NodeType.PROCESSING_INSTRUCTION_NODE;
        case Xml.ElementType.COMMENT_NODE:
          return DomNode.NodeType.COMMENT_NODE;
        case Xml.ElementType.DOCUMENT_NODE:
          return DomNode.NodeType.DOCUMENT_NODE;
        case Xml.ElementType.DOCUMENT_TYPE_NODE:
          return DomNode.NodeType.DOCUMENT_TYPE_NODE;
        case Xml.ElementType.DOCUMENT_FRAG_NODE:
          return DomNode.NodeType.DOCUMENT_FRAGMENT_NODE;
        case Xml.ElementType.NOTATION_NODE:
          return DomNode.NodeType.NOTATION_NODE;
      }
      return DomNode.NodeType.INVALID;
    }
  }
  public string node_name { owned get { return name; } }

  protected string _base_uri = null;
  public string? base_uri { get { return _base_uri; } }

  public DomDocument? owner_document { get { return (GXml.DomDocument?) document; } }
  public DomNode? parent_node { owned get { return parent as DomNode?; } }
  public DomElement? parent_element {
    owned get {
      if (parent is DomElement) return parent as DomElement?;
      return null;
    }
  }
  public DomNodeList child_nodes { owned get { return children_nodes as DomNodeList; } }
  public DomNode? first_child { owned get { return children_nodes.first () as DomNode?; } }
  public DomNode? last_child { owned get { return children_nodes.last () as DomNode?; } }
  public DomNode? previous_sibling {
    owned get {
      if (_node == null) return null;
      if (_node->prev == null) return null;
      return GNode.to_gnode (_doc, _node->prev) as DomNode?;
    }
  }
  public DomNode? next_sibling {
    owned get {
      if (_node == null) return null;
      if (_node->next == null) return null;
      return GNode.to_gnode (_doc, _node->next) as DomNode?;
    }
  }

	public string? node_value { owned get { return @value; } set { this.@value = value; } }
	public string? text_content {
	  owned get {
	    string t = null;
	    if (this is GXml.Text) return this.@value;
	    if (this is GXml.ProcessingInstruction) return this.@value;
	    if (this is GXml.Comment) return this.@value;
	    if (this is GXml.Document || this is GXml.Element) {
	      foreach (GXml.Node n in children_nodes) {
          if (n is GXml.Text) {
            if (t == null) t = n.value;
            else t += n.value;
          }
	      }
	    }
	    return t;
	  }
	  set {
      if (this is GXml.Document || this is GXml.Element) {
        var t = this.document.create_text (value);
        this.document.children_nodes.add (t);
      }
      if (!(this is GXml.Text || this is GXml.Comment || this is GXml.ProcessingInstruction)) return;
      this.@value = value;
	  }
	}

  public bool has_child_nodes () { return (children_nodes.size > 0); }
  public void normalize () {
    try {
    for (int i = 0; i < children_nodes.size; i++) {
      var n = children_nodes.get (i);
      if (n is DomText) {
        child_nodes.remove_at (i);
      }
    }
    } catch {}
  }

  public DomNode clone_node (bool deep = false) {
    Xml.Node *n = null;
    if (deep)
      n = _node->copy (1);
    else
      n = _node->copy (2);
    if (n == null) return null;
    return (DomNode) GNode.to_gnode (_doc, n);
  }
  public bool is_equal_node (DomNode? node) {
    if (!(node is GXml.Node)) return false;
    if (node == null) return false;
    if (this.children_nodes.size != (node as Node).children_nodes.size) return false;
    foreach (GXml.Node a in attrs.values) {
      if (!(node as GXml.Node?).attrs.has_key (a.name)) return false;
      if (a.value != (node as GXml.Node).attrs.get (a.name).value) return false;
    }
    for (int i=0; i < children_nodes.size; i++) {
      if (!(children_nodes[i] as GXml.DomNode).is_equal_node ((node as GXml.Node?).children_nodes[i] as GXml.DomNode?)) return false;
    }
    return true;
  }

  public DomNode.DocumentPosition compare_document_position (DomNode other) {
    if ((this as GXml.DomNode) == other) return DomNode.DocumentPosition.NONE;
    if (this.document != (other as GXml.Node).document || other.parent_node == null) {
      var p = DomNode.DocumentPosition.DISCONNECTED & DomNode.DocumentPosition.IMPLEMENTATION_SPECIFIC;
      if ((&this) > (&other))
        p = p & DomNode.DocumentPosition.PRECEDING;
      else
       p = p & DomNode.DocumentPosition.FOLLOWING;
      return p;
    }
    if ((this as DomNode).contains (other))
      return DomNode.DocumentPosition.CONTAINED_BY & DomNode.DocumentPosition.FOLLOWING;
    if (this.parent_node.contains (other)) {
      var par = this.parent_node;
      if (par.child_nodes.index_of (this) > par.child_nodes.index_of (other))
        return DomNode.DocumentPosition.PRECEDING;
      else
        return DomNode.DocumentPosition.FOLLOWING;
    }
    if (other.contains (this))
      return DomNode.DocumentPosition.CONTAINS & DomNode.DocumentPosition.PRECEDING;
    GLib.warning (_("Can't find node position"));
    return DomNode.DocumentPosition.NONE;
  }
  public bool contains (DomNode? other) {
    if (other == null) return false;
    return this.child_nodes.contains (other);
  }

  public string? lookup_prefix (string? nspace) {
    if (_node == null) return null;
    if (parent == null) return null;
    if (this is GXml.DocumentType || this is GXml.DocumentFragment) return null;
    var ns = _node->doc->search_ns_by_href (_node, nspace);
    if (ns == null) return null;
    return ns->prefix;
  }
  public string? lookup_namespace_uri (string? prefix) {
    if (this is GXml.DocumentType || this is GXml.DocumentFragment) return null;
    var ns = _node->doc->search_ns (_node, prefix);
    if (ns == null) return null;
    return ns->href;
  }
  public bool is_default_namespace (string? nspace) {
    if (nspace == null) return false;
    var ns = lookup_namespace_uri (null);
    if (ns == nspace) return true;
    return false;
  }

  public DomNode insert_before (DomNode node, DomNode? child) throws GLib.Error {
    if (!(node is GXml.GNode))
      throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid attempt to add invalid node type"));
    if (child != null && !this.contains (child))
      throw new DomError.NOT_FOUND_ERROR (_("Can't find child to insert node before"));
    if (!(this is DomDocument
          || this is DomElement
          || this is DomDocumentFragment))
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert a node"));
    if (!(node is DomDocumentFragment
          || node is DomDocumentType
          || node is DomElement
          || node is DomText
          || node is DomProcessingInstruction
          || node is DomComment))
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert an invalid node type"));
    if ((node is DomText && this is DomDocument)
          || (node is DomDocumentType && !(this is DomDocument)))
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert a document's type or text node to a invalid parent"));
    //FIXME: We should follow steps for DOM4 observers in https://www.w3.org/TR/dom/#concept-node-pre-insert
    if (child != null) {
      int i = this.children_nodes.index_of (child as GXml.Node);
      children_nodes.insert (i, (node as GXml.Node));
      return node;
    }
    children_nodes.add ((node as GXml.Node));
    return node;
  }
  public DomNode append_child (DomNode node) throws GLib.Error {
    return insert_before (node, null);
  }
  public DomNode replace_child (DomNode node, DomNode child) throws GLib.Error {
    if (!(node is GXml.GNode))
      throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid attempt to add invalid node type"));
    if (child == null || !this.contains (child))
      throw new DomError.NOT_FOUND_ERROR (_("Can't find child node to replace or child have a different parent"));
    if (!(this is DomDocument
          || this is DomElement
          || this is DomDocumentFragment))
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert a node"));
    if (!(node is DomDocumentFragment
          || node is DomDocumentType
          || node is DomElement
          || node is DomText
          || node is DomProcessingInstruction
          || node is DomComment))
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert an invalid node type"));
    if ((node is DomText && this is DomDocument)
          || (node is DomDocumentType && !(this is DomDocument)))
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert a document's type or text node to a invalid parent"));
    //FIXME: Checks for HierarchyRequestError for https://www.w3.org/TR/dom/#concept-node-replace
    int i = children_nodes.index_of ((child as GXml.Node));
    children_nodes.remove_at (i);
    if (i < children_nodes.size)
      children_nodes.insert (i, (node as GXml.Node));
    if (i >= children_nodes.size)
      child_nodes.add (node);
    return child;
  }
  public DomNode remove_child (DomNode child) throws GLib.Error {
    if (!this.contains (child))
      throw new DomError.NOT_FOUND_ERROR (_("Can't find child node to remove or child have a different parent"));
    int i = children_nodes.index_of ((child as GXml.Node));
    return (DomNode) children_nodes.remove_at (i);
  }
  // DomEventTarget implementation
  public void add_event_listener (string type, DomEventListener? callback, bool capture = false)
  { return; } // FIXME:
  public void remove_event_listener (string type, DomEventListener? callback, bool capture = false)
  { return; } // FIXME:
  public bool dispatch_event (DomEvent event)
  { return false; } // FIXME:
}

