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
public abstract class GXml.GNode : Object, GXml.Node, GXml.DomNode
{
  protected GXml.GDocument _doc;
  protected Xml.Node *_node;

  construct { Init.init (); }

  // GXml.Node
  public virtual bool set_namespace (string uri, string? prefix)
  {
    if (_node == null) return false;
    return ((_node->new_ns (uri, prefix)) != null);
  }
  public virtual Gee.Map<string,GXml.Node> attrs { owned get { return new GHashMapAttr (_doc, _node); } }
  public virtual Gee.BidirList<GXml.Node> children { owned get { return new GListChildren (_doc, _node); } }
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
  public DomNodeList child_nodes { owned get { return children as DomNodeList; } }
  public DomNode? first_child { owned get { return children.first () as DomNode?; } }
  public DomNode? last_child { owned get { return children.last () as DomNode?; } }
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
	      foreach (GXml.Node n in children) {
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
        this.document.children.add (t);
      }
      if (!(this is GXml.Text || this is GXml.Comment || this is GXml.ProcessingInstruction)) return;
      this.@value = value;
	  }
	}

  public bool has_child_nodes () { return (children.size > 0); }
  public void normalize () {
    GXml.DomText t = null;
    int[] r = {};
    for (int i = 0; i < children.size; i++) {
      var n = children.get (i);
      if (n is GXml.DomText) {
        if ((t as GXml.DomText).length == 0) {
          r += i;
          continue;
        }
        if (t == null) {
          t = (GXml.DomText) n;
          continue;
        } else {
          t.data += n.value;
        }
      }
    }
    foreach (int j in r) {
      children.remove_at (j);
    }
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
    if (this.children.size != (node as Node).children.size) return false;
    foreach (GXml.Node a in attrs.values) {
      if (!(node as GXml.Node?).attrs.has_key (a.name)) return false;
      if (a.value != (node as GXml.Node).attrs.get (a.name).value) return false;
    }
    for (int i=0; i < children.size; i++) {
      if (!(children[i] as GXml.DomNode).is_equal_node ((node as GXml.Node?).children[i] as GXml.DomNode?)) return false;
    }
    return true;
  }

  public DomNode.DocumentPosition compare_document_position (DomNode other) {
    if ((&this as GXml.DomNode) == &other) return (DomNode.DocumentPosition) 0;
    if (this.document != (other as GXml.Node).document) {
      var p = DomNode.DocumentPosition.DISCONNECTED & DomNode.DocumentPosition.IMPLEMENTATION_SPECIFIC;
      if ((&this) > (&other))
        p = p & DomNode.DocumentPosition.PRECEDING;
      else
       p = p & DomNode.DocumentPosition.FOLLOWING;
      return p;
    }
    if ((&other as GXml.Node).parent == &this)
      return DomNode.DocumentPosition.CONTAINS & DomNode.DocumentPosition.PRECEDING;
    var op = this.parent as DomNode;
    if (&other == &op)
      return DomNode.DocumentPosition.CONTAINED_BY & DomNode.DocumentPosition.FOLLOWING;
    if (&other < &this) return DomNode.DocumentPosition.PRECEDING;
    return DomNode.DocumentPosition.FOLLOWING;
  }
  public bool contains (DomNode? other) {
    if (other == null) return false;
    var o = other as GXml.Node;
    if (&o == &this) return true;
    var op = o.parent;
    if (&this == &op) return true;
    return false;
  }

  public string? lookup_prefix (string? nspace) {
    if (parent == null) return null;
    if (this is GXml.DocumentType || this is GXml.DocumentFragment) return null;
    if (this is GXml.Document)
      if ((this as GXml.Document).root != null)
        return (document.root as DomNode).lookup_prefix (nspace);
      else
        return null;
    if (this is GXml.Element) {
      if (namespaces.size > 0) {
        var ns = namespaces[0];
        if (ns.prefix == nspace) return ns.uri;
        else return null;
      }
    }
    return (this.parent as GXml.DomNode).lookup_prefix (nspace);
  }
  public string? lookup_namespace_uri (string? prefix) {
    if (prefix == null) return null;
    if (this is GXml.DocumentType || this is GXml.DocumentFragment) return null;
    if (this is GXml.Document)
      if ((this as GXml.Document).root != null)
        return (document.root as DomNode).lookup_namespace_uri (prefix);
      else
        return null;
    if (this is GXml.Element) {
      if (namespaces.size > 0) {
        var ns = namespaces[0];
        if (ns.prefix == prefix) return ns.uri;
        else return null;
      }
    }
    return (this.parent as GXml.DomNode).lookup_namespace_uri (prefix);
  }
  public bool is_default_namespace (string? nspace) {
    if (nspace == null) return false;
    var ns = lookup_namespace_uri (null);
    if (ns == nspace) return true;
    return false;
  }

  public DomNode insert_before (DomNode node, DomNode? child) {
    int i = children.index_of (child as GXml.Node);
    children.insert (i, (node as GXml.Node));
    return node;
  }
  public DomNode append_child (DomNode node) {
    children.add ((node as GXml.Node));
    return node;
  }
  public DomNode replace_child (DomNode node, DomNode child) {
    int i = children.index_of ((child as GXml.Node));
    children.remove_at (i);
    children.insert (i, (node as GXml.Node));
    return child;
  }
  public DomNode remove_child (DomNode child) {
    int i = children.index_of ((child as GXml.Node));
    return (DomNode) children.remove_at (i);
  }
}

