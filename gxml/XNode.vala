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
 * Auxiliary error codes for parsing/writing libxml2 powered classes
 */
public errordomain GXml.Error {
		NOT_SUPPORTED, /* TODO: GET RID OF THIS */
		PARSER, WRITER;
	}

/**
 * DOM4 Base interface providing basic functionalities to all libxml2 DOM4 implementations.
 */
public abstract class GXml.XNode : GLib.Object,
                      GXml.DomEventTarget,
                      GXml.DomNode
{
  protected GXml.XDocument _doc;
  protected Xml.Node *_node;
  protected bool owned_node = false;

  internal static string libxml2_error_to_string (Xml.Error *e) {
    return _("%s:%s:%d: %s:%d: %s").printf (
            e->level.to_string ().replace ("XML_ERR_",""),
            e->domain.to_string ().replace ("XML_FROM_",""),
            e->code, e->file == null ? "<io>" : e->file, e->line, e->message);
  }

  construct {
    Init.init ();
  }

  ~ XNode () {
      if (owned_node && _node != null) {
          delete _node;
          _node = null;
      }
  }

  // GXml.Node
  public virtual bool set_namespace (string uri, string? prefix)
  {
    if (_node == null) return false;
    return ((_node->new_ns (uri, prefix)) != null);
  }
  public virtual Gee.Map<string,GXml.DomNode> attrs { owned get { return new XHashMapAttr (_doc, _node) as Gee.Map<string,GXml.DomNode>; } }
  public virtual Gee.BidirList<GXml.DomNode> children_nodes { owned get { return new XListChildren (_doc, _node) as Gee.BidirList<GXml.DomNode>; } }
  public virtual GXml.DomDocument document { get { return _doc; } }
  public virtual GXml.DomNode parent {
    owned get {
      GXml.DomNode nullnode = null;
      if (_node == null) return nullnode;
      return to_gnode (document as XDocument, _node->parent, false);
    }
  }
  public virtual GXml.NodeType type_node {
    get {
      if (_node == null) return GXml.NodeType.INVALID;
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

  /**
   * Access to {@link Xml.Node} referenced
   */
  public Xml.Node* get_internal_node () { return _node; }

  internal void take_node () {
      owned_node = true;
  }

  internal void release_node () {
      owned_node = false;
  }
  // Static
  public static GXml.DomNode to_gnode (GXml.XDocument doc, Xml.Node *node, bool take_node) {
    GXml.XNode n = null;
    var t = (GXml.NodeType) node->type;
    switch (t) {
      case GXml.NodeType.ELEMENT:
        n = new XElement (doc, node);
        break;
      case GXml.NodeType.ATTRIBUTE:
        n = new XAttribute (doc, (Xml.Attr*) node);
        break;
      case GXml.NodeType.TEXT:
        n = new XText (doc, node);
        break;
      case GXml.NodeType.ENTITY_REFERENCE:
        n = null;
        break;
      case GXml.NodeType.ENTITY:
        n = null;
        break;
      case GXml.NodeType.PROCESSING_INSTRUCTION:
        n = new XProcessingInstruction (doc, node);
        break;
      case GXml.NodeType.COMMENT:
        n = new XComment (doc, node);
        break;
      case GXml.NodeType.DOCUMENT:
        n = doc;
        break;
      case GXml.NodeType.DOCUMENT_TYPE:
        n = null;
        break;
      case GXml.NodeType.DOCUMENT_FRAGMENT:
        n = null;
        break;
      case GXml.NodeType.NOTATION:
        n = null;
        break;
      case GXml.NodeType.CDATA_SECTION:
      case GXml.NodeType.INVALID:
        n = null;
        break;
    }

    if (take_node && n != null) {
        n.take_node ();
    }

    return n;
  }
  // DomNode Implementation
  public DomNode.NodeType node_type {
    get {
      if (_node == null) return DomNode.NodeType.INVALID;
      switch (_node->type) {
        case Xml.ElementType.ELEMENT_NODE:
          return DomNode.NodeType.ELEMENT_NODE;
        case Xml.ElementType.ATTRIBUTE_NODE:
          return DomNode.NodeType.ATTRIBUTE_NODE; // historical
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
        case Xml.ElementType.ATTRIBUTE_DECL:
        case Xml.ElementType.XINCLUDE_START:
        case Xml.ElementType.DTD_NODE:
        case Xml.ElementType.ENTITY_DECL:
        case Xml.ElementType.XINCLUDE_END:
        case Xml.ElementType.ELEMENT_DECL:
        case Xml.ElementType.NAMESPACE_DECL:
        case Xml.ElementType.DOCB_DOCUMENT_NODE:
        case Xml.ElementType.HTML_DOCUMENT_NODE:
          return DomNode.NodeType.INVALID;
      }
      return DomNode.NodeType.INVALID;
    }
  }
  public string node_name { owned get { return name; } }

  protected string _base_uri = null;
  public string? base_uri { get { return _base_uri; } }

  public DomDocument? owner_document {
    get { return _doc; }
    construct set { _doc = value as XDocument; }
  }
  public DomNode? parent_node { owned get { return parent as DomNode?; } }
  public DomElement? parent_element {
    owned get {
      DomElement nullnode = null;
      if (parent is DomElement) return parent as DomElement?;
      return nullnode;
    }
  }
  public DomNodeList child_nodes { owned get { return children_nodes as DomNodeList; } }
  public DomNode? first_child { owned get { return children_nodes.first () as DomNode?; } }
  public DomNode? last_child { owned get { return children_nodes.last () as DomNode?; } }
  public DomNode? previous_sibling {
    owned get {
      if (_node == null) return null;
      if (_node->prev == null) return null;
      return XNode.to_gnode (_doc, _node->prev, false) as DomNode?;
    }
  }
  public DomNode? next_sibling {
    owned get {
      if (_node == null) return null;
      if (_node->next == null) return null;
      return XNode.to_gnode (_doc, _node->next, false) as DomNode?;
    }
  }

	public string? node_value { owned get { return @value; } set { this.@value = value; } }
	public string? text_content {
	  owned get {
	    string t = null;
	    if (this is GXml.DomText) return ((DomText) this).data;
	    if (this is GXml.DomProcessingInstruction) return this.@value;
	    if (this is GXml.DomComment) return this.@value;
	    if (this is GXml.DomDocument || this is GXml.DomElement) {
	      foreach (GXml.DomNode n in children_nodes) {
          if (n is GXml.DomText) {
            if (t == null) t = ((XNode) n).value;
            else t += ((XNode) n).value;
          }
	      }
	    }
	    return t;
	  }
	  set {
      if (this is GXml.DomDocument || this is GXml.DomElement) {
        try {
          var t = this.document.create_text_node (value);
          this.document.child_nodes.add (t);
        } catch (GLib.Error e) {
          warning (_("Error while setting text content to node: %s"), e.message);
        }
      }
      if (!(this is GXml.DomText || this is GXml.DomComment || this is GXml.DomProcessingInstruction)) return;
      this.@value = value;
	  }
	}

  public bool has_child_nodes () { return (children_nodes.size > 0); }
  public void normalize () {
    for (int i = 0; i < children_nodes.size; i++) {
      var n = children_nodes.get (i);
      if (n is DomText) {
        child_nodes.remove_at (i);
      }
    }
  }

  public DomNode clone_node (bool deep = false) {
    DomNode nullnode = null;
    Xml.Node *n = null;
    if (deep)
      n = _node->copy (1);
    else
      n = _node->copy (2);
    if (n == null) return nullnode;
    return (DomNode) XNode.to_gnode (_doc, n, true);
  }
  public bool is_equal_node (DomNode? node) {
    if (!(node is GXml.DomNode)) return false;
    if (node == null) return false;
    if (this.children_nodes.size != node.child_nodes.size) return false;
    foreach (GXml.DomNode a in attrs.values) {
      if (!((GXml.XNode?) node).attrs.has_key (a.node_name)) return false;
      if (((XNode) a).value != ((XNode) ((GXml.XNode) node).attrs.get (a.node_name)).value) return false;
    }
    for (int i=0; i < children_nodes.size; i++) {
      if (!((GXml.DomNode) children_nodes[i]).is_equal_node (((GXml.DomNode?) node).child_nodes[i])) return false;
    }
    return true;
  }

  public DomNode.DocumentPosition compare_document_position (DomNode other) {
    if ((this as GXml.DomNode) == other) return DomNode.DocumentPosition.NONE;
    if (this.document != ((GXml.DomNode) other).owner_document || other.parent_node == null) {
      var p = DomNode.DocumentPosition.DISCONNECTED & DomNode.DocumentPosition.IMPLEMENTATION_SPECIFIC;
      if ((&this) > (&other))
        p = p & DomNode.DocumentPosition.PRECEDING;
      else
       p = p & DomNode.DocumentPosition.FOLLOWING;
      return p;
    }
    if (((DomNode) this).contains (other))
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
    if (this is GXml.DomDocumentType || this is GXml.DomDocumentFragment) return null;
    var ns = _node->doc->search_ns_by_href (_node, nspace);
    if (ns == null) return null;
    return ns->prefix;
  }
  public string? lookup_namespace_uri (string? prefix) {
    if (this is GXml.DomDocumentType || this is GXml.DomDocumentFragment) return null;
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
    if (!(node is GXml.XNode))
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
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert a document's type or text node to an invalid parent"));
    //FIXME: We should follow steps for DOM4 observers in https://www.w3.org/TR/dom/#concept-node-pre-insert
    if (child != null) {
      int i = this.children_nodes.index_of (child as GXml.DomNode);
      children_nodes.insert (i, (node as GXml.DomNode));
      return node;
    }
    children_nodes.add ((node as GXml.DomNode));
    return node;
  }
  public DomNode append_child (DomNode node) throws GLib.Error {
    return insert_before (node, null);
  }
  public DomNode replace_child (DomNode node, DomNode child) throws GLib.Error {
    if (!(node is GXml.XNode)) {
      throw new DomError.INVALID_NODE_TYPE_ERROR (_("Only GXml.XNode nodes are supported. Given a %s type"), node.get_type ().name ());
    }
    
    if (child == null || !this.contains (child)) {
      throw new DomError.NOT_FOUND_ERROR (_("Can't find child node to replace or child have a different parent"));
    }
    
    if (!(this is DomDocument
          || this is DomElement
          || this is DomDocumentFragment))
    {
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to replace a node on unsupported parent"));
    }
    
    if (!(node is DomDocumentFragment
          || node is DomDocumentType
          || node is DomElement
          || node is DomText
          || node is DomProcessingInstruction
          || node is DomComment))
    {
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to replace invalid node type: %s"), node.get_type ().name ());
    }
    
    if ((node is DomText && this is DomDocument)
          || (node is DomDocumentType && !(this is DomDocument)))
    {
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to replace a node on a document or text node"));
    }
    
    //FIXME: Checks for HierarchyRequestError for https://www.w3.org/TR/dom/#concept-node-replace
    int i = children_nodes.index_of ((child as GXml.DomNode));
    var rch = children_nodes.remove_at (i);
    if (i < children_nodes.size) {
      children_nodes.insert (i, (node as GXml.DomNode));
    }
    
    if (i >= children_nodes.size) {
      child_nodes.add (node);
    }
    
    ((XNode) rch).release_node ();
    ((XNode) child).take_node ();
    
    return child;
  }
  public DomNode remove_child (DomNode child) throws GLib.Error {
    if (!this.contains (child)) {
      throw new DomError.NOT_FOUND_ERROR (_("Can't find child node to remove or child have a different parent"));
    }

    int i = children_nodes.index_of ((child as GXml.DomNode));
    XNode n = (XNode) children_nodes.remove_at (i);
    n.release_node ();
    ((XNode) child).take_node ();
    return child;
  }
  // DomEventTarget implementation
  public void add_event_listener (string type, DomEventListener? callback, bool capture = false)
  { return; } // FIXME:
  public void remove_event_listener (string type, DomEventListener? callback, bool capture = false)
  { return; } // FIXME:
  public bool dispatch_event (DomEvent event)
  { return false; } // FIXME:
}

