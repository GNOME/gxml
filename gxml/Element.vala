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
 * A DOM4 implementation of {@link DomElement}, for one-step-parsing.
 *
 * This object avoids pre and post XML parsing, by using a one step parsing
 * to translate text XML tree to an GObject based tree.
 *
 * A GXml Object Model (GOM) implementation of {@link GXml.Element}.It can be used
 * transparently as {@link DomElement} in a XML tree.
 *
 * It also allows delayed parsing, so you can read large documents by parsing
 * just a XML element node and its attributes but not its childs; save its childs
 * as a text, for a post-on-step-parsing.
 */
public class GXml.Element : GXml.Node,
                              DomChildNode,
                              DomNonDocumentTypeChildNode,
                              DomParentNode,
                              DomElement,
                              GXml.Object {
  /**
   * Reference to {@link Attributes} for element's attributes.
   * Derived classes should avoid to modify it.
   */
  protected Attributes _attributes;
  // Convenient Serialization methods
  /**
   * Parses an XML file, deserializing it over {@link GXml.Element}.
   */
  public void read_from_file (GLib.File f,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    parser.read_file (f);
  }
  /**
   * Parses asinchronically an XML file, deserializing it over {@link GXml.Element}.
   */
  public async void read_from_file_async (GLib.File f,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    yield parser.read_file_async (f);
  }
  /**
   * Parses an XML over a {@link GLib.InputStream}, deserializing it over {@link GXml.Element}.
   */
  public void read_from_stream (GLib.InputStream istream,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    parser.read_stream (istream);
  }
  /**
   * Parses asynchronically an XML over a {@link GLib.InputStream}, deserializing it over {@link GXml.Element}.
   */
  public async void read_from_stream_async (GLib.InputStream istream,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    yield parser.read_stream_async (istream);
  }
  /**
   * Parses an XML string, deserializing it over {@link GXml.Element}.
   */
  public void read_from_string (string str, Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    parser.read_string (str);
  }
  /**
   * Parses an XML string, deserializing it over {@link GXml.Element}.
   */
  public async void read_from_string_async (string str, Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    yield parser.read_string_async (str);
  }
  /**
   * Serialize {@link GXml.Element} to a string.
   */
  public string write_string (Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    return parser.write_string ();
  }
  /**
   * Serialize asinchronically {@link GXml.Element} to a string.
   */
  public async string write_string_async (Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.cancellable = cancellable;
    return yield parser.write_string_async ();
  }
  /**
   * Uses element's {@link GXml.Document} to write an XML to a file, serializing it.
   */
  public void write_file (GLib.File f, Cancellable? cancellable = null) throws GLib.Error {
    (this.owner_document as GXml.Document).write_file (f);
  }
  /**
   * Uses element's {@link GXml.Document} to write asynchronically an XML to a file, serializing it.
   */
  public async void write_file_async (GLib.File f, Cancellable? cancellable = null) throws GLib.Error {
    yield (this.owner_document as GXml.Document).write_file_async (f);
  }
  /**
   * Uses element's {@link GXml.Document} to write an XML to a stream, serializing it.
   */
  public void write_stream (GLib.OutputStream stream) throws GLib.Error {
    (this.owner_document as GXml.Document).write_stream (stream);
  }
  /**
   * Uses element's {@link GXml.Document} to write an XML to a stream, serializing it.
   */
  public async void write_stream_async (GLib.OutputStream stream, Cancellable? cancellable = null) throws GLib.Error {
    yield (this.owner_document as GXml.Document).write_stream_async (stream);
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GXml.Element} using node's {@link GXml.Document}
   */
  public InputStream create_stream () throws GLib.Error {
    return (this.owner_document as GXml.Document).create_stream ();
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GXml.Element} using node's {@link GXml.Document}
   */
  public async InputStream create_stream_async (Cancellable? cancellable = null) throws GLib.Error {
    return yield (this.owner_document as GXml.Document).create_stream_async ();
  }
  // DomNode overrides
  public new string? lookup_prefix (string? nspace) {
    if (_namespace_uri == nspace)
      return _prefix;
    foreach (string k in _attributes.keys) {
      if (!("xmlns" in k)) continue;
      string ns_uri = null;
      var prop = _attributes.get (k) as GXml.Attr;
      if (prop != null) {
          ns_uri = prop.value;
      }
      if (ns_uri == null) {
        GLib.warning (_("Invalid namespace URI stored in element's attribute"));
        return null;
      }
      if (ns_uri == nspace) {
        if (":" in k) {
          string[] sa = k.split (":");
          if (sa.length > 2) {
            GLib.warning (_("Invalid attribute name in element's attributes list"));
            return null;
          }
          return sa[1];
        }
      }
    }
    if (parent_node == null) return null;
    return parent_node.lookup_prefix (nspace);
  }
  public new string? lookup_namespace_uri (string? prefix) {
    foreach (string k in attributes.keys) {
      if (!("xmlns" in k)) continue;
      var p = _attributes.get (k) as GXml.Attr;
      string nsp = null;
      if (p != null) {
        nsp = p.value;
      }
      if (prefix == null && k == "xmlns") return nsp;
      if (":" in k) {
        string[] sa = k.split (":");
        if (sa.length != 2) {
          GLib.warning (_("Invalid attribute name in element's attributes list"));
          return null;
        }
        if (prefix == sa[1]) return nsp;
      }
    }
    if (parent_node == null) return null;
    return parent_node.lookup_namespace_uri (prefix);
  }

  // DomChildNode
  public void remove () {
    if (parent_node != null) {
      var i = parent_node.child_nodes.index_of (this);
      if (i < 0 || i > parent_node.child_nodes.length)
        warning (_("Can't locate child node to remove"));
      parent_node.child_nodes.remove_at (i);
    }
  }
  // DomNonDocumentTypeChildNode
  public DomElement? previous_element_sibling {
    owned get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == 0)
          return null;
        for (var j = i; j >= 1; j--) {
          var n = parent_node.child_nodes.item (j - 1);
          if (n is DomElement)
			return n as DomElement;
        }
      }
      return null;
    }
  }
  public DomElement? next_element_sibling {
    owned get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == parent_node.child_nodes.length - 1)
          return null;
        for (var j = i; j < parent_node.child_nodes.length - 1; j--) {
          var n = parent_node.child_nodes.item (j + 1);
          if (n is DomElement)
            return (DomElement) n;
        }
      }
      return null;
    }
  }

  // DomParentNode
  public new DomHTMLCollection children {
    owned get {
      var l = new HTMLCollection ();
      foreach (GXml.DomNode n in child_nodes) {
        if (n is DomElement) l.add (n as DomElement);
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
  // GXml.DomElement
  /**
   * Use this field to set node's namespace URI. Can used to set it at construction time.
   */
  protected string _namespace_uri = null;
  public string? namespace_uri { owned get { return _namespace_uri.dup (); } }
  public string? prefix { owned get { return _prefix; } }
  /**
   * Derived classes should define it at construction time, using
   * {@link GXml.Node._local_name} field. This is the node's name.
   */
  public string local_name {
    owned get {
      return _local_name;
    }
  }

  public string tag_name { owned get { return _local_name; } }

  /**
   * An attribute called 'id'.
   */
  [Description (nick="::id")]
  public string? id { owned get; set; }
  /**
   * An attribute called 'class'.
   */
  public string? class_name {
    owned get { return (this as GXml.Element).get_attribute ("class"); }
    set { (this as GXml.Object).set_attribute ("class", value); }
  }
  /**
   * A list of values of all attributes called 'class'.
   */
  public DomTokenList class_list {
    owned get {
      return new GXml.TokenList (this, "class");
    }
  }

  construct {
    _node_type = DomNode.NodeType.ELEMENT_NODE;
    _attributes = new Attributes (this);
    _local_name = "";
    notify.connect ((pspec)=>{
      if ("::" in pspec.get_nick ()) {
        string name = pspec.get_nick ().replace ("::", "");
        var p = _attributes.get (name.down ());
        if (p == null) {
          GXml.Property prop = new StringRef (this, name);
          _attributes.add_reference (name);
        }
      }
    });
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GXml.Element}
   * using given local name. If {@link GXml.Element.initialize_with_namespace}
   * has been called in any base class, this method just change elment node's name
   * and keeps previous namespace and prefix.
   *
   * No {@link DomDocument} is set by default, if this is a top level element in a
   * document, you can call {@link DomNode.owner_document} to set one if not set
   * already.
   *
   * Any instance properties of type {@link GXml.Element} or {@link Collection}
   * should be initialized using {@link GXml.Object.set_instance_property}
   */
  public void initialize (string local_name) {
    _local_name = local_name;
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GXml.Element}
   * using given local name and document.
   */
  public void initialize_document (DomDocument doc, string local_name) {
    _document = doc;
    _local_name = local_name;
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GXml.Element}
   * using given local name and namespace.
   */
  public void initialize_with_namespace (string? namespace_uri,
                              string? prefix, string local_name) {
    _local_name = local_name;
    _namespace_uri = namespace_uri;
    _prefix = prefix;
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GXml.Element}
   * using given local name, document and namespace.
   */
  public void initialize_document_with_namespace (DomDocument doc, string? namespace_uri,
                              string? prefix, string local_name) {
    _document = doc;
    _local_name = local_name;
    _namespace_uri = namespace_uri;
    _prefix = prefix;
  }
  /**
   * Holds attributes in current node, using attribute's name as key
   * and it's value as value. Appends namespace prefix to attribute's name as
   * key if is a namespaced attribute.
   */
  public class Attributes : Gee.HashMap<string,DomNode>, DomNamedNodeMap  {
    private TreeMap<long,string> order = new TreeMap<long,string> ();
    /**
     * Holds {@link GXml.Element} refrence to attributes' parent element.
     * Derived classes should not modify, but set at construction time.
     */
    protected GXml.Element _element;

    // DomNamedNodeMap
    public int length { get { return size; } }
    public DomNode? item (int index) {
      if (index < 0 || index >= size) return null;
      long i = -1;
      foreach (Gee.Map.Entry<long,string> e in order.ascending_entries) {
        i++;
        if (i == index) {
          var ret = get (e.value);
          message ("Found %s at %ld - Val=%s - as node val = %s", e.value, i, (ret as GXml.Attr).value, ret.node_value);
          return ret;
        }
      }
      return null;
    }

    public Attributes (GXml.Element element) {
      _element = element;
    }

    public DomNode? get_named_item (string name) {
      if (name == "") return null;
      var ov = (_element as GXml.Object).get_attribute (name);
      if (ov != null) {
        return new GXml.Attr (_element, name, ov);
      }
      string p = "";
      string ns = null;
      string n = name.down ();
      if (":" in name) {
        string[] s = name.split (":");
        if (s.length > 2) return null;
        p = s[0];
        n = s[1].down ();
        if (p == "xml")
          ns = "http://www.w3.org/2000/xmlns/";
        if (p == "xmlns")
          ns = _element.lookup_namespace_uri (n);
        if (p != "xmlns" && p != "xml")
          ns =  _element.lookup_namespace_uri (p);
      }
      var prop = get (n) as GXml.Attr;
      string val = null;
      if (prop != null) {
          val = prop.value;
      }
      if (val == null) return null;
      DomNode attr = null;
      if (p == null || p == "")
        attr = new GXml.Attr (_element, n, val);
      else
        attr = new GXml.Attr.namespace (_element, ns, p, n, val);

      return attr;
    }
    /**
     * Takes given {@link DomNode} as a {@link GXml.Attr} and use its name and
     * value to set a property in {@link DomElement} ignoring node's prefix and
     * namespace
     */
    public DomNode? set_named_item (DomNode node) throws GLib.Error {
      if ((":" in (node as GXml.Attr).local_name)
          || (node as GXml.Attr).local_name == "")
        throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid attribute name: %s"), (node as GXml.Attr).local_name);
      if (!(node is GXml.Attr))
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid node type. GXml.Attr was expected"));
      GXml.Attr attr = null;
      var pprop = (_element as GXml.Object).find_property_name ((node as GXml.Attr).local_name);
      if (pprop != null) {
        (_element as GXml.Object).set_attribute ((node as GXml.Attr).local_name, node.node_value);
        attr = new GXml.Attr.reference (_element, (node as GXml.Attr).local_name);
      } else {
        attr = new GXml.Attr (_element, (node as GXml.Attr).local_name, node.node_value);
      }
      set (attr.local_name.down (), attr);
      order.set (size - 1, (node as GXml.Attr).local_name.down ());
      return attr;
    }
    public DomNode? remove_named_item (string name) throws GLib.Error {
      if (":" in name) return null;
      string val = null;
      var prop = get (name.down ()) as GXml.Attr;
      if (prop != null) {
        val = prop.value;
        prop.value = null;
        long i = index_of (name);
        unset (name.down ());
        if (i < 0) {
          warning (_("No index found for attribute %s").printf (name));
        } else {
          order.unset (i);
        }
      }
      return prop as DomNode;
    }
    // Introduced in DOM Level 2:
    public DomNode? remove_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
      if (":" in local_name) return null;
      var nsp = _element.lookup_prefix (namespace_uri);
      if (nsp == null || nsp == "") return null;
      var v = get ((nsp+":"+local_name).down ()) as GXml.Attr;
      if (v == null) return null;
      string k = (nsp+":"+local_name).down ();
      v.value = null;
      unset (k);
      long i = index_of (k);
      if (i < 0) {
        warning (_("No index found for attribute %s").printf (k));
      } else {
        order.unset (i);
      }
      return v as DomNode;
    }
    // Introduced in DOM Level 2:
    public DomNode? get_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
      if (":" in local_name) return null;
      var nsp = _element.lookup_prefix (namespace_uri);
      if (nsp == null) return null;
      var v = get ((nsp+":"+local_name).down ());
      return v;
    }
    // Introduced in DOM Level 2:
    public DomNode? set_named_item_ns (DomNode node) throws GLib.Error {
      if ((node as GXml.Attr).local_name == "" || ":" in (node as GXml.Attr).local_name)
        throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid attribute name: %s"),(node as GXml.Attr).local_name);
      if (!(node is GXml.Attr))
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid node type. GXml.Attr was expected"));

      if ((node as GXml.Attr).prefix == "xmlns"
          && (node as GXml.Attr).namespace_uri != "http://www.w3.org/2000/xmlns/"
              && (node as GXml.Attr).namespace_uri != "http://www.w3.org/2000/xmlns")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with xmlns should use a namespace uri http://www.w3.org/2000/xmlns"));
      if ((node as GXml.Attr).prefix == ""
          || (node as GXml.Attr).prefix == null
          && (node as GXml.Attr).local_name != "xmlns") {
        string s = (node as GXml.Attr).local_name;
        if ((node as GXml.Attr).namespace_uri != null)
          s += "=<"+(node as GXml.Attr).namespace_uri+">";
        throw new DomError.NAMESPACE_ERROR (_("Namespaced attributes should provide a non-null, non-empty prefix: %s"),s);
      }
      if ((node as GXml.Attr).prefix == "xmlns"
          && (node as GXml.Attr).local_name == "xmlns")
        throw new DomError.NAMESPACE_ERROR (_("Invalid namespace attribute's name."));
      if ((node as GXml.Attr).prefix == "xmlns"
          || (node as GXml.Attr).local_name == "xmlns") {
        string asp = _element.get_attribute_ns (node.node_value,
                                          (node as GXml.Attr).local_name);
        if (asp != null) return node;
      }
      if ((node as GXml.Attr).namespace_uri == "http://www.w3.org/2000/xmlns/"
          || (node as GXml.Attr).namespace_uri == "http://www.w3.org/2000/xmlns") {
        if ((node as GXml.Attr).local_name == "xmlns") {
          string ns_uri = _element.lookup_namespace_uri (null);
          if (ns_uri != null && ns_uri != node.node_value) {
            message (_("Duplicated default namespace detected with URI: %s").printf (ns_uri));
          }
        }
        if ((node as GXml.Attr).prefix == "xmlns") {
          string nsprefix = _element.lookup_prefix (node.node_value);
          string nsuri = _element.lookup_namespace_uri ((node as GXml.Attr).local_name);
          if ((nsprefix != null || nsuri != null)
              && (nsprefix != (node as GXml.Attr).local_name
                  || nsuri != node.node_value)) {
            message (_("Duplicated namespace detected for: %s:%s").printf ((node as GXml.Attr).local_name, node.node_value));
          }
        }
      }
      if ((node as GXml.Attr).namespace_uri != "http://www.w3.org/2000/xmlns/"
          && (node as GXml.Attr).namespace_uri != "http://www.w3.org/2000/xmlns"){
        string nsn = _element.lookup_namespace_uri ((node as GXml.Attr).prefix);
        string nspn = _element.lookup_prefix (nsn);
        if (nspn != (node as GXml.Attr).prefix
            && nsn != (node as GXml.Attr).namespace_uri)
          throw new DomError.NAMESPACE_ERROR
                  (_("Trying to add an attribute with an undefined namespace prefix: %s").printf ((node as GXml.Attr).prefix));
        nspn = _element.lookup_prefix ((node as GXml.Attr).namespace_uri);
        nsn = _element.lookup_namespace_uri (nspn);
        if (nspn != (node as GXml.Attr).prefix
            && nsn != (node as GXml.Attr).namespace_uri)
          throw new DomError.NAMESPACE_ERROR
                  (_("Trying to add an attribute with a non found namespace URI"));
      }

      string p = "";
      if ((node as GXml.Attr).prefix != null
          && (node as GXml.Attr).prefix != "")
        p = (node as GXml.Attr).prefix + ":";
      string k = (p+(node as GXml.Attr).local_name).down ();
      GXml.Attr attr = null;
      var pprop = (_element as GXml.Object).find_property_name ((node as GXml.Attr).local_name);
      if (pprop != null) {
        (_element as GXml.Object).set_attribute ((node as GXml.Attr).local_name, node.node_value);
        attr = new GXml.Attr.reference (_element, (node as GXml.Attr).local_name);
      } else {
        attr = new GXml.Attr.namespace (_element, (node as GXml.Attr).namespace_uri, (node as GXml.Attr).prefix, (node as GXml.Attr).local_name, node.node_value);
      }
      set (k, attr);
      order.set (size - 1, k);
      return attr;
    }
    private long index_of (string name) {
      long i = -1;
      foreach (Gee.Map.Entry<long,string> e in order.ascending_entries) {
        i++;
        if (e.value == name) return i;
      }
      return -1;
    }
    public void add_reference (string name) {
      var attr = new GXml.Attr.reference (_element, name);
      set (name.down (), attr);
      order.set (size, name);
    }
  }
  public DomNamedNodeMap attributes { owned get { return (DomNamedNodeMap) _attributes; } }
  public string? get_attribute (string name) {
    string str = null;
    var prop = _attributes.get (name.down ()) as GXml.Attr;
    if (prop != null) {
        str = prop.value;
    }
    return str;
  }
  public string? get_attribute_ns (string? namespace_uri, string local_name) {
    string nsp = null;
    if ((namespace_uri == "http://www.w3.org/2000/xmlns/"
          || namespace_uri == "http://www.w3.org/2000/xmlns")
        && local_name != "xmlns")
      nsp = "xmlns";
    else
      nsp = lookup_prefix (namespace_uri);
    string name = local_name;
    if (nsp != null)
      name = nsp + ":" + local_name;
    string val = null;
    var prop = _attributes.get (name) as GXml.Attr;
    if (prop != null) {
        val = prop.value;
    }
    return val;
  }
  public void set_attribute (string name, string value) throws GLib.Error {
    var a = new GXml.Attr (this, name, value);
    attributes.set_named_item (a);
  }
  public void set_attribute_ns (string? namespace_uri,
                                string name, string value) throws GLib.Error
  {
    string p = "";
    string n = name;
    if (":" in name) {
      var s = name.split (":");
      if (s.length != 2)
        throw new DomError.NAMESPACE_ERROR (_("Invalid attribute name. Just one prefix is allowed"));
      p = s[0];
      n = s[1];
      if (":" in n)
        throw new DomError.NAMESPACE_ERROR (_("Invalid attribute name. Invalid use of colon: %s"), n);
    } else {
      n = name;
    }
    if (namespace_uri == null && p == "")
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If prefix is null, namespace URI should not be null"));
    if (p == "xml" && namespace_uri != "http://www.w3.org/2000/xmlns/" && namespace_uri != "http://www.w3.org/2000/xmlns")
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If prefix is xml, namespace URI should be http://www.w3.org/2000/xmlns"));
    if (p == "xmlns" && namespace_uri != "http://www.w3.org/2000/xmlns/"
            && namespace_uri != "http://www.w3.org/2000/xmlns")
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If attribute's prefix is xmlns, namespace URI should be http://www.w3.org/2000/xmlns"));
    if (p == "" && n == "xmlns"
        && (namespace_uri != "http://www.w3.org/2000/xmlns/"
            && namespace_uri != "http://www.w3.org/2000/xmlns"))
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If attribute's name is xmlns, namespace URI should be http://www.w3.org/2000/xmlns"));
    if (p == "" && n != "xmlns" && n != "xml")
      throw new DomError.NAMESPACE_ERROR (_("Invalid attribute name. No prefixed attributes should use xmlns name"));
    var a = new GXml.Attr.namespace (this, namespace_uri, p, n, value);
    try { _attributes.set_named_item_ns (a); }
    catch (GLib.Error e) {
      throw new DomError.NAMESPACE_ERROR (_("Setting namespaced property error: ")+e.message);
    }
  }
  public void remove_attribute (string name) {
    try { attributes.remove_named_item (name); }
    catch (GLib.Error e)
      { warning (_("Removing attribute Error: ")+e.message); }
  }
  public void remove_attribute_ns (string? namespace_uri, string local_name) {
    try { attributes.remove_named_item_ns (namespace_uri, local_name); }
    catch (GLib.Error e)
      { warning (_("Removing namespaced attribute Error: ")+e.message); }
  }
  public bool has_attribute (string name) {
    return _attributes.has_key (name);
  }
  public bool has_attribute_ns (string? namespace_uri, string local_name) {
  string nsp = null;
    if ((namespace_uri == "http://www.w3.org/2000/xmlns/"
          || namespace_uri == "http://www.w3.org/2000/xmlns")
        && local_name != "xmlns")
      nsp = "xmlns";
    else
      nsp = lookup_prefix (namespace_uri);
    string name = local_name;
    if (nsp != null)
      name = nsp + ":" + local_name;
    return attributes.has_key (name);
  }


  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
    var l = new HTMLCollection ();
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
    var l = new HTMLCollection ();
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
    var l = new HTMLCollection ();
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
  /**
   * If true all children are parsed. If false, all its children are stored
   * as plain string in {@link unparsed}. In order to generate an XML tree
   * use {@link read_unparsed}.
   */
  public bool parse_children { get; set; default = true; }
  /**
   * Temporally stores, all unparsed children as plain string. See {@link parse_children}.
   *
   * If it is null, means all children have been already parsed.
   */
  public string unparsed { get; set; }
  /**
   * Parse all children, adding them to current node, stored in {@link unparsed}.
   * Once it finish, sets {@link unparsed} to null.
   */
  public void read_unparsed () throws GLib.Error {
    if (unparsed == null) return;
    var parser = new XParser (this);
    parser.read_child_nodes_string (unparsed);
    unparsed = null;
  }
}


