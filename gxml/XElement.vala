/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GElement.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
 * Copyright (C) 2016  Yannick Inizan <inizan.yannick@gmail.com>
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
 *      Yannick Inizan <inizan.yannick@gmail.com>
 */

using Gee;

/**
 * DOM4 Class implementing {@link GXml.DomElement} interface,
 * powered by libxml-2.0 library.
 */
public class GXml.XElement : GXml.XNonDocumentChildNode,
                            GXml.DomParentNode,
                            GXml.DomElement,
                            GXml.XPathContext
{
  public XElement (XDocument doc, Xml.Node *node) {
    _node = node;
    _doc = doc;
  }
  // GXml.DomNode
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
  public GXml.DomNode? get_attr (string name)
  {
    if (_node == null) return null;
    string prefix = null;
    string n = name;
    if (":" in name) {
      string[] pp = name.split (":");
      if (pp.length != 2) return null;
      prefix = pp[0];
      n = pp[1];
    }
    if (prefix != null) {
      var ns = _node->doc->search_ns (_node, prefix);
      if (ns == null) return null;
      var nsa = _node->has_ns_prop (n,ns->href);
      if (nsa == null) return null;
      return new XAttribute (_doc, nsa);
    }
    var p = _node->has_prop (n);
    if (p == null) return null;
    return new XAttribute (_doc, p);
  }
  public void set_ns_attr (string ns, string aname, string value) {
    if (_node == null) return;
    string prefix = null;
    string qname = aname;
    if (":" in aname) {
      string[] s = aname.split(":");
      if (s.length != 2) return;
      prefix = s[0];
      qname = s[1];
    }
    var ins = _node->doc->search_ns_by_href (_node, ns);
    if (ins != null) {
      _node->set_ns_prop (ins, qname, value);
      return;
    }
    var nns = _node->new_ns (ns, prefix);
    if (nns != null) {
      _node->set_ns_prop (nns, qname, value);
    }
  }
  public GXml.DomNode? get_ns_attr (string name, string uri) {
    if (_node == null) return null;
    var a = _node->has_ns_prop (name, uri);
    if (a == null) return null;
    return new XAttribute (_doc, a);
  }
  public new void normalize () {}
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
  public string tag_name {
    owned get {
      if (_node == null) return "".dup ();
      var ns = _node->ns_def;
      var dns = ns;
      while (ns != null) {
        if (ns->prefix == null) dns = ns;
        ns = ns->next;
      }
      if (dns != null) {
        if (dns->href == "http://www.w3.org/1999/xhtml")
          return _node->name.up ().dup ();
        if (dns->prefix == null)
          return _node->name;
        string qname = dns->prefix+":"+_node->name;
        return qname.dup ();
      }
      return _node->name.dup ();
    }
  }
  public override string to_string () {
    try {
      return write_string ();
    } catch (GLib.Error e) {
      warning (_("Error while converting Element to string: %s"), e.message);
    }
    return "";
  }
  public string write_string (GLib.Cancellable? cancellable = null) {
    var buf = new Xml.Buffer ();
    buf.node_dump (_node->doc, _node, 1, 0);
    return buf.content ().dup ();
  }
  // GXml.DomElement
  public string? namespace_uri {
    owned get {
      if (_node == null) return null;
      var ns = _node->ns_def;
      var dns = ns;
      while (ns != null) {
        if (ns->prefix == null) dns = ns;
        ns = ns->next;
      }
      if (dns != null)
        return dns->href.dup ();
      return null;
    }
  }
  public string? prefix {
    owned get {
      if (_node == null) return null;
      var ns = _node->ns_def;
      var dns = ns;
      while (ns != null) {
        if (ns->prefix == null) dns = ns;
        ns = ns->next;
      }
      if (dns != null)
        if (dns->prefix != null)
          return dns->prefix.dup ();
      return null;
    }
  }
  public string local_name { owned get { return name; } }

  public string? id {
    owned get {
        var p = attrs.get ("id");
        if (p == null) return null;
        return ((XNode) p).value;
    }
    set {
        var p = attrs.get ("id");
        if (p == null)
            set_attr ("id",value);
        else
            ((XNode) p).value = value;
    }
  }
  public string? class_name {
    owned get {
        var p = attrs.get ("class");
        if (p == null) return null;
        return ((XNode) p).value;
    }
    set {
        var p = attrs.get ("class");
        if (p == null)
            set_attr ("class",value);
        else
            ((XNode) p).value = value;
    }
  }
  public DomTokenList class_list {
    owned get {
      return new GXml.TokenList (this, "class");
    }
  }

  public DomNamedNodeMap attributes { owned get { return (DomNamedNodeMap) attrs; } }
  public string? get_attribute (string name) {
    var p = attrs.get (name);
    if (p == null) return null;
    return ((XNode) p).value;
  }
  public string? get_attribute_ns (string? namespace, string local_name) {
    var p = get_ns_attr (local_name, namespace);
    if (p == null) return null;
    return ((XNode) p).value;
  }
  public void set_attribute (string name, string value) throws GLib.Error { set_attr (name, value); }
  public void set_attribute_ns (string? namespace, string name, string value) throws GLib.Error {
    set_ns_attr (namespace, name, value);
  }
  public void remove_attribute (string name) {
    remove_attr (name);
  }
  public void remove_attribute_ns (string? namespace, string local_name) {
    remove_ns_attr (local_name, namespace);
  }
  public bool has_attribute (string name) { return attrs.has_key (name); }
  public bool has_attribute_ns (string? namespace, string local_name) {
    if (_node == null) return false;
    var attr = _node->has_ns_prop (local_name, namespace);
    if (attr == null) return false;
    return true;
  }


  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
    var l = new HTMLCollection ();
    //FIXME: quirks mode not considered
    foreach (GXml.DomElement n in children) {
      if (n.node_name == local_name)
        l.add (n);
      l.add_all (n.get_elements_by_tag_name (local_name));
    }
    return l;
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name) {
    var l = new HTMLCollection ();
    //FIXME: quirks mode not considered
    foreach (GXml.DomElement n in children) {
      if (n.node_name == local_name
          && n.namespace_uri == namespace)
        l.add (n);
      l.add_all (n.get_elements_by_tag_name_ns (namespace, local_name));
    }
    return l;
  }
  public DomHTMLCollection get_elements_by_class_name (string class_names) {
    var l = new HTMLCollection ();
    if (class_names == "") return l;
    string[] cs = {};
    if (" " in class_names) {
      cs = class_names.split (" ");
    } else
      cs += class_names;
    foreach (GXml.DomElement n in children) {
      string cls = n.get_attribute ("class");
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
            l.add (n);
          else
            l.insert (0, n);
        }
      }
      l.add_all (n.get_elements_by_class_name (class_names));
    }
    return l;
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
  public int child_element_count { get { return children.size; } }

  public DomNodeList query_selector_all (string selectors) throws GLib.Error {
    var cs = new CssSelectorParser ();
    cs.parse (selectors);
    return cs.query_selector_all (this);
  }
  // XPathContext implementation
  /**
   * {@inheritDoc}
   */
  public GXml.XPathObject evaluate (string expression,
                                    Gee.Map<string,string>? resolver = null)
                                    throws GXml.XPathObjectError
  {
    GXml.XPathObject nullobj = null;
    if (!(this is GXml.DomNode))
      return nullobj;
    string data = ((XNode) this).to_string();
    var ndoc = Xml.Parser.read_memory (data, data.length);
    var gdoc = new GXml.XDocument.from_doc (ndoc);
    var context = new Xml.XPath.Context (ndoc);
    if (resolver != null) {
      foreach (string prefix in resolver.keys) {
        var uri = resolver.get (prefix);
        int res = context.register_ns (prefix, uri);
        if (res != 0) {
          throw new XPathObjectError.INVALID_NAMESPACE_ERROR (_("invalid namespace. Code: %s"), res.to_string ());
        }
      }
    }
    return new GXml.LXPathObject (gdoc, context.eval (expression));
  }
}
