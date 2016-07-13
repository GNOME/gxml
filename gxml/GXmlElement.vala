/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GElement.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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
 * Class implemeting {@link GXml.Element} interface, not tied to libxml-2.0 library.
 */
public class GXml.GElement : GXml.GNode, GXml.Element, GXml.DomElement
{
  public GElement (GDocument doc, Xml.Node *node) {
    _node = node;
    _doc = doc;
  }
  // GXml.Node
  public override string value
  {
    owned get {
      return content;
    }
    set { content = value; }
  }
  // GXml.Element
  public void set_attr (string aname, string avalue)
  {
    if (_node == null) return;
    if (":" in aname) return;
    _node->set_prop (aname, avalue);
  }
  public GXml.Node get_attr (string name)
  {
    if (_node == null) return null;
    string prefix = "";
    string n = name;
    if (":" in name) {
      string[] pp = name.split (":");
      if (pp.length != 2) return null;
      prefix = pp[0];
      n = pp[1];
    }
    var ps = _node->properties;
    while (ps != null) {
      if (ps->name == n) {
        if (ps->ns == null && prefix == "") return new GAttribute (_doc, ps);
        if (ps->ns == null) continue;
        if (ps->ns->prefix == prefix)
          return new GAttribute (_doc, ps);
      }
      ps = ps->next;
    }
    return null;
  }
  public void set_ns_attr (Namespace ns, string name, string value) {
    if (_node == null) return;
    var ins = _node->doc->search_ns (_node, ns.prefix);
    if (ins != null) {
      _node->set_ns_prop (ins, name, value);
      return;
    }
  }
  public GXml.Node get_ns_attr (string name, string uri) {
    if (_node == null) return null;
    var a = _node->has_ns_prop (name, uri);
    if (a == null) return null;
    return new GAttribute (_doc, a);
  }
  public void normalize () {}
  public string content {
    owned get {
      return _node->get_content ().dup ();
    }
    set {
      _node->set_content (value);
    }
  }
  public void remove_attr (string name) {
    if (_node == null) return;
    var a = _node->has_prop (name);
    if (a == null) return;
    a->remove ();
  }
  public void remove_ns_attr (string name, string uri) {
    if (_node == null) return;
    var a = _node->has_ns_prop (name, uri);
    if (a == null) return;
    a->remove ();
  }
  public string GXml.Element.tag_name { owned get { return _node->name.dup (); } } // FIXME: Tag = prefix:local_name
  public override string to_string () {
    var buf = new Xml.Buffer ();
    buf.node_dump (_node->doc, _node, 1, 0);
    return buf.content ().dup ();
  }
  // GXml.DomElement
  public string? namespace_uri {
    get {
      if (namespace != null)
        return namespace.uri;
      return null;
    }
  }
  public string? prefix {
    get {
      if (namespace != null)
        return namespace.prefix;
      return null;
    }
  }
  public string local_name { get { return name; } }
  public string GXml.DomElement.tag_name {
    get {
      if (namespace != null)
        return namespace.prefix+":"+name;
      return name;
    }
  }

  public abstract string id {
    get {
        var p = attrs.get ("id");
        if (p == null) return null;
        return p.value;
    }
    set {
        var p = attrs.get ("id");
        if (p == null)
            set_attr ("id",value);
        else
            p.value = value;
    }
  }
  public abstract string class_name {
    get {
        var p = attrs.get ("class");
        if (p == null) return null;
        return p.value;
    }
    set {
        var p = attrs.get ("class");
        if (p == null)
            set_attr ("class",value);
        else
            p.value = value;
    }
  }
  public DomTokenList class_list {
    owned get {
      return new GDomTokenList (this, "class");
    }
  }

  public DomNamedNodeMap attributes { get { return new GDomNamedNodeMap (this,(Map<string,DomNode>) attrs); } }
  public string? get_attribute (string name) { return attrs.get (name); }
  public string? get_attribute_ns (string? namespace, string local_name) {
    return get_ns_attr (local_name, namespace);
  }
  public void set_attribute (string name, string value) { set_attr (name, value); }
  public void set_attribute_ns (string? namespace, string name, string value) {
    GNamespace ns = null;
    if (namespace != null)
      ns = new GNamespace ();
    string prefix = null;
    string local_name = null;
    if (":" in name) {
      string[] s = namespace.split (":");
      prefix = s[0];
      local_name = s[1];
    } else {
      local_name = name;
    }
    if (ns != null) {
      ns.prefix = prefix;
      ns.uri = namespace;
    }
    // FIXME: Validate name as in Name and QName https://www.w3.org/TR/domcore/#dom-element-setattributens
    set_ns_attr (ns, local_name, value);
  }
  public void remove_attribute (string name) {
    remove_attr (name);
  }
  public void remove_attribute_ns (string? namespace, string local_name) {
    remove_ns_attr (local_name, namespace);
  }
  public bool has_attribute (string name) { return attrs.has (name); }
  public bool has_attribute_ns (string? namespace, string local_name) {
    var attr = _node->has_ns_prop (name, namespace);
    if (attr == null) return false;
    return true;
  }


  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
    var l = new GDomHTMLCollection ();
    foreach (GXml.Node n in children) {
      if (!(n is GXml.DomElement)) continue;
      if ((n as GXml.DomElement).node_name == local_name)
        l.add (n);
    }
    return l;
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name) {
    var l = new GDomHTMLCollection ();
    foreach (GXml.Node n in children) {
      if (!(n is GXml.DomElement)) continue;
      if ((n as GXml.DomElement).node_name == local_name
          && (n as GXml.DomNode).lookup_namespace_uri == namespace)
        l.add (n);
    }
    return l;
  }
  public DomHTMLCollection get_elements_by_class_name (string class_names) {
    var l = new GDomHTMLCollection ();
    foreach (GXml.Node n in children) {
      if (!(n is GXml.DomElement)) continue;
      if (!n.attrs.has ("class")) continue;
      if (" " in class_names) {
        string[] cs = class_names.split (" ");
        bool cl = true;
        foreach (string s in cs) {
          if (!(s in n.attrs.get ("class").value)) cl = false;
        }
        if (cl)
          l.add (n);
      } else
        if (n.attrs.get ("class") == class_names)
          l.add (n);
    }
    return l;
  }
}
