/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using GXml;
using Gee;

public class GXml.GomNode : Object,
                            DomEventTarget,
                            DomNode {
// DomNode
  protected string _local_name = "";
  protected string _prefix = null;
  protected DomNode.NodeType _node_type = DomNode.NodeType.INVALID;
  public DomNode.NodeType node_type { get { return _node_type; } }
  public string node_name {
    owned get {
      if (_prefix == null) return _local_name;
      return _prefix+":"+_local_name;
    }
  }

  protected string _base_uri = null;
  public string? base_uri { get { return _base_uri; } }

  protected GXml.DomDocument _document;
  public DomDocument? owner_document { get { return (GXml.DomDocument?) _document; } }

  protected GXml.DomNode _parent;
  public DomNode? parent_node { owned get { return _parent as DomNode?; } }
  public DomElement? parent_element {
    owned get {
      if (_parent is DomElement) return _parent as DomElement?;
      return null;
    }
  }

  protected class NodeList : Gee.ArrayList<DomNode>, DomNodeList {
    public DomNode? item (ulong index) { return base.get ((int) index); }
    public ulong length { get { return (ulong) base.size; } }
  }
  protected NodeList _child_nodes = new NodeList ();
  public DomNodeList child_nodes { owned get { return _child_nodes as DomNodeList; } }
  public DomNode? first_child {
    owned get {
    if (child_nodes.size == 0) return null;
    return child_nodes[0];
    }
  }
  public DomNode? last_child {
    owned get {
      if (child_nodes.size == 0) return null;
      return child_nodes[child_nodes.size - 1];
    }
  }
  public DomNode? previous_sibling {
    owned get {
     if (_parent == null) return null;
     if (_parent.child_nodes == null) return null;
     if (_parent.child_nodes.length == 0) return null;
     var pos = (_parent.child_nodes as ArrayList<DomNode>).index_of (this);
     if (pos == 0) return null;
     if ((pos - 1) > 0 && (pos - 1) < _parent.child_nodes.size)
      return _parent.child_nodes[pos - 1];
    }
  }
  public DomNode? next_sibling {
    owned get {
     if (_parent == null) return null;
     if (_parent.child_nodes == null) return null;
     if (_parent.child_nodes.length == 0) return null;
     var pos = (_parent.child_nodes as ArrayList<DomNode>).index_of (this);
     if (pos == 0) return null;
     if ((pos + 1) > 0 && (pos + 1) < _parent.child_nodes.size)
      return _parent.child_nodes[pos + 1];
    }
  }

  protected string _node_value = null;
	public string? node_value { owned get { return _node_value; } set { _node_value = value; } }
	public string? text_content {
	  owned get {
	    string t = null;
      foreach (GXml.DomNode n in child_nodes) {
        if (n is GXml.DomText) {
          if (t == null) t = n.node_value;
          else t += n.node_value;
        }
      }
      return t;
    }
    set {
      var t = owner_document.create_text_node (text_content);
      child_nodes.add (t);
    }
  }

  public bool has_child_nodes () { return (_child_nodes.size > 0); }
  public void normalize () {
    try {
    for (int i = 0; i < child_nodes.size; i++) {
      var n = child_nodes.get (i);
      if (n is DomText) {
        child_nodes.remove_at (i);
      }
    }
    } catch {}
  }

  public bool is_equal_node (DomNode? node) { // FIXME:
    if (node == null) return false;
    if (this is DomCharacterData)
      return (this as DomComment).data == (node as DomComment).data;
    if ((this is DomElement) && (node is DomElement)) {
      if ((this as DomElement).child_nodes.size != (node as DomElement).child_nodes.size) return false;
      foreach (GXml.DomNode a in attributes.values) {
        if (!(node as GXml.Node?).attributes.has_key (a.name)) return false;
        if (a.value != (node as GXml.Node).attributes.get (a.name).value) return false;
      }
      for (int i=0; i < child_nodes.size; i++) {
        if (!((this as DomElement).child_nodes[i] as GXml.DomNode).is_equal_node ((node as GXml.Node?).child_nodes[i] as GXml.DomNode?)) return false;
      }
      return true;
    }
    return false;
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
    if (this is GXml.DomDocumentType ||
        this is GXml.DomDocumentFragment) return null;
    if (this is DomElement) {
      return (this as DomElement).lookup_prefix (nspace);
    }
    if (this is DomAttr) {
      if (this.parent_node == null) return  null;
      return this.parent_node.lookup_prefix (nspace);
    }
    return null;
  }
  public string? lookup_namespace_uri (string? prefix) {
    if (this is GXml.DomDocumentType ||
        this is GXml.DomDocumentFragment) return null;
    if (this is DomElement) {
        return (this as DomElement).lookup_namespace_uri (prefix);
    }
    return null;
  }
  public bool is_default_namespace (string? nspace) {
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
      int i = this.child_nodes.index_of (child as GXml.DomNode);
      child_nodes.insert (i, (node as GXml.DomNode));
      return node;
    }
    child_nodes.add ((node as GXml.DomNode));
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
    int i = child_nodes.index_of ((child as GXml.DomNode));
    child_nodes.remove_at (i);
    if (i < child_nodes.size)
      child_nodes.insert (i, (node as GXml.DomNode));
    if (i >= child_nodes.size)
      child_nodes.add (node);
    return child;
  }
  public DomNode remove_child (DomNode child) throws GLib.Error {
    if (!this.contains (child))
      throw new DomError.NOT_FOUND_ERROR (_("Can't find child node to remove or child have a different parent"));
    int i = child_nodes.index_of ((child as GXml.DomNode));
    return (DomNode) child_nodes.remove_at (i);
  }
  // DomEventTarget implementation
  public void add_event_listener (string type, DomEventListener? callback, bool capture = false)
  { return; } // FIXME:
  public void remove_event_listener (string type, DomEventListener? callback, bool capture = false)
  { return; } // FIXME:
  public bool dispatch_event (DomEvent event)
  { return false; } // FIXME:
}

public class GXml.GomAttr : GXml.GomNode {
  protected string _namespace_uri;
  protected string _prefix;
  public string local_name { owned get { return _local_name; } }
  public string name {
    owned get {
      string s = "";
      if (_prefix != null) s = _prefix+":";
      return s+_local_name;
    }
  }
  public string? namespace_uri { owned get { return _namespace_uri; } }
  public string? prefix {
    owned get {
      if (_prefix == "") return null;
      return _prefix;
    }
  }
  public string value { owned get { return _node_value; } set { _node_value = value; } }

  public GomAttr (DomElement element, string name, string value) {
    _document = element.owner_document;
    _parent = element;
    _local_name = name;
    _node_value = value;
  }
  public GomAttr.namespace (DomElement element, string namespace, string? prefix, string name, string value) {
    _document = element.owner_document;
    _parent = element;
    _local_name = name;
    _node_value = value;
    if (element.lookup_prefix (namespace) == prefix
        || (prefix == null && element.lookup_prefix (namespace) == "")) {
      _namespace_uri = namespace;
      _prefix = prefix;
    }
  }
}
