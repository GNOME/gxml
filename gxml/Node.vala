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

/**
 * A DOM4 implementation of {@link DomNode}, for one step parsing.
 *
 * This object avoids pre and post XML parsing, by using a one step parsing
 * to translate text XML tree to an GObject based tree.
 */
public class GXml.Node : GLib.Object,
                            DomEventTarget,
                            DomNode {
// DomNode
  /**
   * Use this field to set node's local name. Can be set at construction time.
   */
  protected string _local_name;
  /**
   * Use this field to set node's prefix. Can be set at construction time.
   */
  protected string _prefix;
  /**
   * Use this field to set node's base URI. Can be set at construction time.
   *
   * See [[https://www.w3.org/TR/dom/#concept-node-base-url]]
   */
  protected string _base_uri;
  /**
   * Use this field to hold node's value. Can be set at construction time.
   */
  protected string _node_value;
  /**
   * Use this field to holding node's parent node. Derived classes should avoid to modify it.
   */
  protected GXml.DomNode _parent;
  /**
   * Use this field to set node's Type. Derived classes should avoid to modify it.
   */
  protected DomNode.NodeType _node_type;
  /**
   * Use this field to set node's child nodes. Derived classes should avoid to modify it.
   */
  protected GXml.NodeList _child_nodes;
  public DomNode.NodeType node_type { get { return _node_type; } }
  public string node_name {
    owned get {
      if (_local_name == null) return "NO NAME";
      if (_prefix == null || _prefix == "") return _local_name;
      return _prefix+":"+_local_name;
    }
  }

  public string? base_uri { get { return _base_uri; } }

  protected GXml.DomDocument _document;
  public DomDocument? owner_document {
    get {
      if (this is DomDocument) return (DomDocument) this;
      if (_document == null) {
        _document = new GXml.Document ();
        if (this is DomElement) {
          try { _document.append_child (this); }
          catch (GLib.Error e) { warning (e.message); }
        }
      }
      return _document;
    }
    construct set { _document = value; }
  }

  public DomNode? parent_node { owned get { return _parent as DomNode?; } }
  public DomElement? parent_element {
    owned get {
      if (_parent is DomElement) return _parent as DomElement?;
      return null;
    }
  }
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
      var pos = ((Gee.ArrayList<DomNode>) _parent.child_nodes).index_of (this);
      if (pos == 0) return null;
      if ((pos - 1) > 0 && (pos - 1) < _parent.child_nodes.size)
        return _parent.child_nodes[pos - 1];
      return null;
    }
  }
  public DomNode? next_sibling {
    owned get {
      if (_parent == null) return null;
      if (_parent.child_nodes == null) return null;
      if (_parent.child_nodes.length == 0) return null;
      var pos = ((Gee.ArrayList<DomNode>) _parent.child_nodes).index_of (this);
      if (pos == 0) return null;
      if ((pos + 1) > 0 && (pos + 1) < _parent.child_nodes.size)
        return _parent.child_nodes[pos + 1];
      return null;
    }
  }

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
      try {
        var t = _document.create_text_node (value);
        child_nodes.add (t);
      } catch (GLib.Error e) {
        GLib.warning (_("Text content in element can't be created"));
      }
    }
  }

  construct {
    _local_name = "";
    _prefix = null;
    _node_type = DomNode.NodeType.INVALID;
    _base_uri = null;
    _node_value = null;
    _child_nodes = new GXml.NodeList ();
    _parent = null;
  }

  public bool has_child_nodes () { return (_child_nodes.size > 0); }
  public void normalize () {
    for (int i = 0; i < child_nodes.size; i++) {
      var n = child_nodes.get (i);
      if (n is DomText) {
        child_nodes.remove_at (i);
      }
    }
  }

  public bool is_equal_node (DomNode? node) { // FIXME: This is not going to work
    if (node == null) return false;
    if (this is DomCharacterData)
      return ((DomComment) this).data == ((DomComment) node).data;
    return false;
  }

  public DomNode.DocumentPosition compare_document_position (DomNode other) {
    if ((this as GXml.DomNode) == other) return DomNode.DocumentPosition.NONE;
    if (this.owner_document != other.owner_document || other.parent_node == null) {
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
    if (this is GXml.DomDocumentType ||
        this is GXml.DomDocumentFragment) return null;
    if (this is DomElement) {
      return ((GXml.Element) this).lookup_prefix (nspace);
    }
    if (this is GXml.Attr) {
      if (this.parent_node == null) return  null;
      return parent_node.lookup_prefix (nspace);
    }
    return null;
  }
  public string? lookup_namespace_uri (string? prefix) {
    if (this is GXml.DomDocumentType ||
        this is GXml.DomDocumentFragment) return null;
    if (this is DomElement) {
        return ((GXml.Element) this).lookup_namespace_uri (prefix);
    }
    if (this is GXml.Attr) {
      if (this.parent_node == null) return  null;
      return this.parent_node.lookup_namespace_uri (prefix);
    }
    return null;
  }
  public bool is_default_namespace (string? nspace) {
    var ns = lookup_namespace_uri (null);
    if (ns == nspace) return true;
    return false;
  }
  /**
   * Sets node's parent and checks for namespace conflics.
   */
  internal void set_parent (DomNode node) throws GLib.Error {
    _document = node.owner_document;
    _parent = node;
  }

  public DomNode insert_before (DomNode node, DomNode? child) throws GLib.Error {
    if (!(node is GXml.Node))
      throw new DomError.INVALID_NODE_TYPE_ERROR
                  (_("Invalid attempt to add invalid node type"));
    if (child != null && !this.contains (child))
      throw new DomError.NOT_FOUND_ERROR
                  (_("Can't find child to insert node before"));
    if (!(this is DomDocument
          || this is DomElement
          || this is DomDocumentFragment))
      throw new DomError.HIERARCHY_REQUEST_ERROR
                  (_("Invalid attempt to insert a node"));
    if (!(node is DomDocumentFragment
          || node is DomDocumentType
          || node is DomElement
          || node is DomText
          || node is DomProcessingInstruction
          || node is DomComment))
      throw new DomError.HIERARCHY_REQUEST_ERROR
                  (_("Invalid attempt to insert an invalid node type"));
    // comments and Text can be added as children of DomDocument
    //  if ((node is DomText && this is DomDocument)
    //       || (node is DomDocumentType && !(this is DomDocument)))
    //   throw new DomError.HIERARCHY_REQUEST_ERROR
    //               (_("Invalid attempt to insert a document or text type to an invalid parent node"));
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
    if (!(node is GXml.Node))
      throw new DomError.HIERARCHY_REQUEST_ERROR
              (_("Node type is invalid. Can't append as child"));
    if (owner_document != node.owner_document)
      throw new DomError.HIERARCHY_REQUEST_ERROR
              (_("Invalid attempt to append a child with different parent document"));
    ((GXml.Node) node).set_parent (this);
    return insert_before (node, null);
  }
  public DomNode replace_child (DomNode node, DomNode child) throws GLib.Error {
    if (!(node is GXml.Node))
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
      throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid attempt to insert a document's type or text node to an invalid parent"));
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

/**
 * List of {@link DomNode} implementing {@link DomNodeList}
 */
public class GXml.NodeList : Gee.ArrayList<DomNode>, DomNodeList {
  public DomNode? item (int index) { return base.get (index); }
  public int length { get { return size; } }
}
