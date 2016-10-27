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
 * A GXml Object Model (GOM) implementation of {@link GomElement}.It can be used
 * transparently as {@link DomElement} in a XML tree.
 */
public class GXml.GomElement : GomNode,
                                  DomChildNode,
                                  DomNonDocumentTypeChildNode,
                                  DomParentNode,
                                  DomElement,
                                  GomObject {
  /**
   * Holds namespaces in current node, using URI as key and prefix as value
   */
  protected Gee.HashMap<string?,string> _namespaces = new Gee.HashMap<string?,string> ();


  // DomNode overrides
  public string? lookup_prefix (string? nspace) {
    if (nspace == null) return null;
    var nsp = _namespaces.get (nspace);
    if (nsp == "") return null;
    return nsp;
  }
  public string? lookup_namespace_uri (string? prefix) {
    string s = "";
    if (prefix != null) s = prefix;
    foreach (string k in _namespaces.keys) {
      if (_namespaces.get (k) == prefix) return k;
    }
    return null;
  }

  // DomChildNode
  public void remove () {
    if (parent_node != null) {
      var i = parent_node.child_nodes.index_of (this);
      parent_node.child_nodes.remove_at (i);
    }
  }
  // DomNonDocumentTypeChildNode
  public DomElement? previous_element_sibling {
    get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == 0) return null;
        var n = parent_node.child_nodes.item (i - 1);
        if (n is DomElement) return (DomElement) n;
        return null;
      }
      return null;
    }
  }
  public DomElement? next_element_sibling {
    get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == parent_node.child_nodes.length - 1) return null;
        var n = parent_node.child_nodes.item (i + 1);
        if (n is DomElement) return (DomElement) n;
        return null;
      }
      return null;
    }
  }

  // DomParentNode
  public new DomHTMLCollection children {
    owned get {
      var l = new DomElementList ();
      foreach (GXml.DomNode n in child_nodes) {
        if (n is DomElement) l.add ((DomElement) n);
      }
      return l;
    }
  }
  public DomElement? first_element_child { owned get { return (DomElement) children.first (); } }
  public DomElement? last_element_child { owned get { return (DomElement) children.last (); } }
  public ulong child_element_count { get { return (ulong) children.size; } }

  public DomElement? query_selector (string selectors) throws GLib.Error {
  // FIXME:
    throw new DomError.SYNTAX_ERROR (_("DomElement query_selector is not implemented"));
  }
  public DomNodeList query_selector_all (string selectors) throws GLib.Error {
  // FIXME:
    throw new DomError.SYNTAX_ERROR (_("DomElement query_selector_all is not implemented"));
  }
  // GXml.DomElement
  protected string _namespace_uri = null;
  public string? namespace_uri { owned get { return _namespace_uri.dup (); } }
  protected string _prefix = null;
  public string? prefix { owned get { return _prefix; } }
  /**
   * Derived classes should define this value at construction time.
   */
  protected string _local_name = "";
  public string local_name {
    owned get {
      return _local_name;
    }
  }

  public string tag_name { owned get { return _local_name; } }

  public string? id {
    owned get { return (this as GomElement).get_attribute ("id"); }
    set { (this as GomObject).set_attribute ("id", value); }
  }
  public string? class_name {
    owned get { return (this as GomElement).get_attribute ("class"); }
    set { (this as GomObject).set_attribute ("class", value); }
  }
  public DomTokenList class_list {
    owned get {
      return new GDomTokenList (this, "class");
    }
  }


  construct {
    _node_type = DomNode.NodeType.ELEMENT_NODE;
  }

  public GomElement (DomDocument doc, string local_name) {
    _document = doc;
    _local_name = local_name;
  }
  public GomElement.namespace (DomDocument doc, string namespace, string prefix, string local_name) {
    _document = doc;
    _local_name = local_name;
    _namespace_uri = namespace;
    string nsp = prefix;
    if (nsp == null) nsp = "";
    _prefix = nsp;
    if (!_namespaces.has_key (namespace))
      _namespaces.set (namespace, nsp);
  }
  /**
   * Holds attributes in current node, using attribute's name as key
   * and it's value as value. Appends namespace prefix to attribute's name as
   * key if a namespaced attribute.
   */
  protected class Attributes : HashMap<string,string>, DomNamedNodeMap  {
    public ulong length { get { return (ulong) size; } }
    public DomNode? item (ulong index) { return null; }
    public DomNode? get_named_item (string name) {
      if (":" in name) return null;
      var v = get (name);
      if (v == null) return null;
      var n = new GomAttr (this, name, v);
      return n;
    }
    public DomNode? set_named_item (DomNode node) throws GLib.Error {
      if (":" in node.node_name) return null;
      set (node.node_name, node.node_value);
      var n = new GomAttr (this, node.node_name, node.node_value);
    }
    public DomNode? remove_named_item (string name) throws GLib.Error {
      if (":" in name) return null;
      var v = get (name);
      if (v == null) return null;
      var n = new GomAttr (this, name, v);
      set (name, null);
      return n;
    }
    // Introduced in DOM Level 2:
    public DomNode? remove_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
      if (":" in local_name) return null;
      var nsp = _name_spaces.get (namespace_uri);
      if (nsp == null) return null;
      var v = get (nsp+":"+local_name);
      if (v == null) return null;
      var n = new GomAttr (this, namespace_uri, nsp, local_name, v);
      set (name, null);
      return n;
    }
    // Introduced in DOM Level 2:
    public DomNode? get_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
      if (":" in local_name) return null;
      var nsp = _name_spaces.get (namespace_uri);
      if (nsp == null) return null;
      var v = get (nsp+":"+local_name);
      if (v == null) return null;
      var n = new GomNode ();
      n._node_value = v;
      n._local_name = local_name;
      return n;
    }
    // Introduced in DOM Level 2:
    public DomNode? set_named_item_ns (DomNode node) throws GLib.Error {
      /* TODO:Ç
      WRONG_DOCUMENT_ERR: Raised if arg was created from a different document than the one that created this map.

NO_MODIFICATION_ALLOWED_ERR: Raised if this map is readonly.

INUSE_ATTRIBUTE_ERR: Raised if arg is an Attr that is already an attribute of another Element object. The DOM user must explicitly clone Attr nodes to re-use them in other elements.

HIERARCHY_REQUEST_ERR: Raised if an attempt is made to add a node doesn't belong in this NamedNodeMap. Examples would include trying to insert something other than an Attr node into an Element's map of attributes, or a non-Entity node into the DocumentType's map of Entities.

NOT_SUPPORTED_ERR: May be raised if the implementation does not support the feature "XML" and the language exposed through the Document does not support XML Namespaces (such as [HTML 4.01]).
      */
      string ns, ln, nsp;
      if (node is DomElement) {
        ns = (node as DomElement).namespace_uri;
        ln = (node as DomElement).local_name;
        nsp = (node as DomElement).prefix;
      } else
        return null;
      if (":" in ln)
        throw new DomError.NOT_SUPPORTED_ERROR (_("Invalid local name"));
      var nsp = _name_spaces.get (ns);
      if (nsp == null && _namespaces.size == 0) {
        _namespaces.set (ns, "");
      }
      if (nsp == null) nsp = "";
      set (nsp+":"+local_name, node.node_value);
      var n = new GomNode ();
      n.node_value = v;
      n._local_name = name;
      return n;
    }
  }
  protected Attributes _attributes = new Attributes ();
  public DomNamedNodeMap attributes { owned get { return (DomNamedNodeMap) _attributes; } }
  public string? get_attribute (string name) { return (this as GomObject).get_attribute (name); }
  public string? get_attribute_ns (string? namespace, string local_name) {
    DomNode p = null;
    try { p = _attributes.get_named_item_ns (namespace, local_name); }
    catch (GLib.Error e) {
      string s = _("Error:");
      GLib.warning (s+e.message);
      return null;
    }
    if (p == null) return null;
    return p.node_value;
  }
  public void set_attribute (string name, string? value) { (this as GomObject).set_attribute (name, value); }
  public void set_attribute_ns (string? namespace, string name, string? value) {
    string p = "";
    string n = name;
    if (":" in name) {
      var s = name.split (":");
      if (s.length != 2) return;
      p = s[0];
      n = s[1];
    } else
      n = name;
      //TODO: Throw errors on xmlns and no MXLNS https://www.w3.org/TR/dom/#dom-element-setattributens
    var nsp = _namespaces.get (namespace);
    if (nsp != p) {
      _namespaces.set (namespace, p); // Set Default
    }
    _attributes.set (p+":"+n, value);
  }
  public void remove_attribute (string name) {
    (this as GomElement).remove_attribute (name);
  }
  public void remove_attribute_ns (string? namespace, string local_name) {
    if (":" in local_name) return;
    var nsp = _namespaces.get (namespace);
    if (nsp == null) return;
    var a = _attributes.get (nsp+local_name);
    if (a == null) return;
    _namespaces.set (nsp+local_name, null);
  }
  public bool has_attribute (string name) {
    return _attributes.has_key (name);
  }
  public bool has_attribute_ns (string? namespace, string local_name) {
    var nsp = _namespaces.get (namespace);
    if (nsp == null) return false;
    var a = _namespaces.get (nsp+local_name);
    if (a != null) return true;
  }


  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
    var l = new GDomHTMLCollection ();
    //FIXME: quircks mode not considered
    foreach (GXml.DomNode n in child_nodes) {
      if (!(n is DomElement)) continue;
      if (n.node_name == local_name)
        l.add (n as DomElement);
      l.add_all ((n as DomElement).get_elements_by_tag_name (local_name));
    }
    return l;
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name) {
    var l = new GDomHTMLCollection ();
    //FIXME: quircks mode not considered
    foreach (GXml.DomNode n in child_nodes) {
      if (!(n is DomElement)) continue;
      if (n.node_name == local_name
          && (n as DomElement).namespace_uri == namespace)
        l.add (n as DomElement);
      l.add_all ((n as DomElement).get_elements_by_tag_name_ns (namespace, local_name));
    }
    return l;
  }
  public DomHTMLCollection get_elements_by_class_name (string class_names) {
    var l = new GDomHTMLCollection ();
    if (class_names == "") return l;
    string[] cs = {};
    if (" " in class_names) {
      cs = class_names.split (" ");
    } else
      cs += class_names;
    foreach (GXml.DomNode n in child_nodes) {
      if (!(n is DomElement)) continue;
      string cls = (n as DomElement).get_attribute ("class");
      if (cls != null) {
        string[] ncls = {};
        if (" " in cls)
          ncls = cls.split (" ");
        else
          ncls += cls;
        int found = 0;
        foreach (string cl in cs) {
          foreach (string ncl in ncls) {
            if (cl == ncl) {
              found++;
            }
          }
        }
        if (found == cs.length) {
          if (l.size == 0)
            l.add (n as DomElement);
          else
            l.insert (0, n as DomElement);
        }
      }
      l.add_all ((n as DomElement).get_elements_by_class_name (class_names));
    }
    return l;
  }
}


