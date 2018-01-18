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
 * A GXml Object Model (GOM) implementation of {@link GomElement}.It can be used
 * transparently as {@link DomElement} in a XML tree.
 *
 * It also allows delayed parsing, so you can read large documents by parsing
 * just a XML element node and its attributes but not its childs; save its childs
 * as a text, for a post-on-step-parsing.
 */
public class GXml.GomElement : GomNode,
                              DomChildNode,
                              DomNonDocumentTypeChildNode,
                              DomParentNode,
                              DomElement,
                              GomObject {
  /**
   * Reference to {@link Attributes} for element's attributes.
   * Derived classes should avoid to modify it.
   */
  protected Attributes _attributes;
  // Convenient Serialization methods
  /**
   * Parsing a URI file.
   */
  public void read_from_uri (string uri) throws GLib.Error {
    this.read_from_file (File.new_for_uri (uri));
  }
  /**
   * Parsing asinchronically a URI file.
   */
  public async void read_from_uri_async (string uri) throws GLib.Error {
    yield this.read_from_file_async (File.new_for_uri (uri));
  }
  /**
   * Parses an XML file, deserializing it over {@link GomElement}.
   */
  public void read_from_file (GLib.File f,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_file (f, cancellable);
  }
  /**
   * Parses asinchronically an XML file, deserializing it over {@link GomElement}.
   */
  public async void read_from_file_async (GLib.File f,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    yield parser.read_file_async (f, cancellable);
  }
  /**
   * Parses an XML over a {@link GLib.InputStream}, deserializing it over {@link GomElement}.
   */
  public void read_from_stream (GLib.InputStream istream,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_stream (istream, cancellable);
  }
  /**
   * Parses asynchronically an XML over a {@link GLib.InputStream}, deserializing it over {@link GomElement}.
   */
  public async void read_from_stream_async (GLib.InputStream istream,
                      GLib.Cancellable? cancellable = null) throws GLib.Error {
    var parser = new XParser (this);
    yield parser.read_stream_async (istream, cancellable);
  }
  /**
   * Parses an XML string, deserializing it over {@link GomElement}.
   */
  public void read_from_string (string str) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_string (str, null);
  }
  /**
   * Parses an XML string, deserializing it over {@link GomElement}.
   */
  public async void read_from_string_async (string str) throws GLib.Error {
    var parser = new XParser (this);
    yield parser.read_string_async (str, null);
  }
  /**
   * Serialize {@link GomElement} to a string.
   */
  public string write_string () throws GLib.Error {
    var parser = new XParser (this);
    return parser.write_string ();
  }
  /**
   * Serialize asinchronically {@link GomElement} to a string.
   */
  public async string write_string_async () throws GLib.Error {
    var parser = new XParser (this);
    return yield parser.write_string_async ();
  }
  /**
   * Uses element's {@link GomDocument} to write an XML to a file, serializing it.
   */
  public void write_file (GLib.File f) throws GLib.Error {
    (this.owner_document as GomDocument).write_file (f);
  }
  /**
   * Uses element's {@link GomDocument} to write asynchronically an XML to a file, serializing it.
   */
  public async void write_file_async (GLib.File f) throws GLib.Error {
    yield (this.owner_document as GomDocument).write_file_async (f);
  }
  /**
   * Uses element's {@link GomDocument} to write an XML to a stream, serializing it.
   */
  public void write_stream (GLib.OutputStream stream) throws GLib.Error {
    (this.owner_document as GomDocument).write_stream (stream);
  }
  /**
   * Uses element's {@link GomDocument} to write an XML to a stream, serializing it.
   */
  public async void write_stream_async (GLib.OutputStream stream) throws GLib.Error {
    yield (this.owner_document as GomDocument).write_stream_async (stream);
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GomElement} using node's {@link GomDocument}
   */
  public InputStream create_stream () throws GLib.Error {
    return (this.owner_document as GomDocument).create_stream ();
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GomElement} using node's {@link GomDocument}
   */
  public async InputStream create_stream_async () throws GLib.Error {
    return yield (this.owner_document as GomDocument).create_stream_async ();
  }
  // DomNode overrides
  public new string? lookup_prefix (string? nspace) {
    if (_namespace_uri == nspace)
      return _prefix;
    foreach (string k in _attributes.keys) {
      if (!("xmlns" in k)) continue;
      string ns_uri = _attributes.get (k);
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
      string nsp = _attributes.get (k);
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
      var l = new GDomHTMLCollection ();
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
    var l = new GomNodeList ();
    foreach (DomNode e in child_nodes) {
      if (!(e is DomElement)) continue;
      if (cs.match (e as DomElement))
        l.add (e);
      l.add_all ((e as DomElement).query_selector_all (selectors));
    }
    return l;
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
   * {@link GomNode._local_name} field. This is the node's name.
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
    owned get { return (this as GomElement).get_attribute ("class"); }
    set { (this as GomObject).set_attribute ("class", value); }
  }
  /**
   * A list of values of all attributes called 'class'.
   */
  public DomTokenList class_list {
    owned get {
      return new GDomTokenList (this, "class");
    }
  }

  construct {
    _node_type = DomNode.NodeType.ELEMENT_NODE;
    _attributes = new Attributes (this);
    _local_name = "";
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GomElement}
   * using given local name. If {@link GomElement.initialize_with_namespace}
   * has been called in any base class, this method just change elment node's name
   * and keeps previous namespace and prefix.
   *
   * No {@link DomDocument} is set by default, if this is a top level element in a
   * document, you can call {@link DomNode.owner_document} to set one if not set
   * already.
   *
   * Any instance properties of type {@link GomElement} or {@link GomCollection}
   * should be initialized using {@link GomObject.set_instance_property}
   */
  public void initialize (string local_name) {
    _local_name = local_name;
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GomElement}
   * using given local name and document.
   */
  public void initialize_document (DomDocument doc, string local_name) {
    _document = doc;
    _local_name = local_name;
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GomElement}
   * using given local name and namespace.
   */
  public void initialize_with_namespace (string? namespace_uri,
                              string? prefix, string local_name) {
    _local_name = local_name;
    _namespace_uri = namespace_uri;
    _prefix = prefix;
  }
  /**
   * Convenient function to initialize, at construction time, a {@link GomElement}
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
   * key if a namespaced attribute.
   */
  public class Attributes : HashMap<string,string>, DomNamedNodeMap  {
    private TreeMap<long,string> order = new TreeMap<long,string> ();
    /**
     * Holds {@link GomElement} refrence to attributes' parent element.
     * Derived classes should not modify, but set at construction time.
     */
    protected GomElement _element;
    public int length { get { return size; } }
    public DomNode? item (int index) {
      if (index < 0 || index >= size) return null;
      long i = -1;
      foreach (Map.Entry<long,string> e in order.ascending_entries) {
        i++;
        if (i == index) {
          string name = e.value;
          string v = get (name);
          return new GomAttr (_element, name, v);
        }
      }
      return null;
    }

    public Attributes (GomElement element) {
      _element = element;
    }

    public DomNode? get_named_item (string name) {
      if (name == "") return null;
      var ov = (_element as GomObject).get_attribute (name);
      if (ov != null) {
        return new GomAttr (_element, name, ov);
      }
      string p = "";
      string ns = null;
      string n = name;
      if (":" in name) {
        string[] s = name.split (":");
        if (s.length > 2) return null;
        p = s[0];
        n = s[1];
        if (p == "xml")
          ns = "http://www.w3.org/2000/xmlns/";
        if (p == "xmlns")
          ns = _element.lookup_namespace_uri (n);
        if (p != "xmlns" && p != "xml")
          ns =  _element.lookup_namespace_uri (p);
      }
      string val = get (name);
      if (val == null) return null;
      DomNode attr = null;
      if (p == null || p == "")
        attr = new GomAttr (_element, n, val);
      else
        attr = new GomAttr.namespace (_element, ns, p, n, val);

      return attr;
    }
    /**
     * Takes given {@link DomNode} as a {@link DomAttr} and use its name and
     * value to set a property in {@link DomElement} ignoring node's prefix and
     * namespace
     */
    public DomNode? set_named_item (DomNode node) throws GLib.Error {
      if ((":" in (node as DomAttr).local_name)
          || (node as DomAttr).local_name == "")
        throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid attribute name: %s"), (node as DomAttr).local_name);
      if (!(node is DomAttr))
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid node type. DomAttr was expected"));
      set ((node as DomAttr).local_name, node.node_value);
      order.set (size, (node as DomAttr).local_name);
      return new GomAttr (_element, (node as DomAttr).local_name, node.node_value);
    }
    public DomNode? remove_named_item (string name) throws GLib.Error {
      if (":" in name) return null;
      var v = get (name);
      if (v == null) return null;
      var n = new GomAttr (_element, name, v);
      unset (name);
      long i = index_of (name);
      if (i < 0) {
        warning (_("No index found for attribute %s").printf (name));
      } else {
        order.unset (i);
      }
      return n;
    }
    // Introduced in DOM Level 2:
    public DomNode? remove_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
      if (":" in local_name) return null;
      var nsp = _element.lookup_prefix (namespace_uri);
      if (nsp == null || nsp == "") return null;
      var v = get (nsp+":"+local_name);
      if (v == null) return null;
      var n = new GomAttr.namespace (_element, namespace_uri, nsp, local_name, v);
      string k = nsp+":"+local_name;
      unset (k);
      long i = index_of (k);
      if (i < 0) {
        warning (_("No index found for attribute %s").printf (k));
      } else {
        order.unset (i);
      }
      return n;
    }
    // Introduced in DOM Level 2:
    public DomNode? get_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
      if (":" in local_name) return null;
      var nsp = _element.lookup_prefix (namespace_uri);
      if (nsp == null) return null;
      var v = get (nsp+":"+local_name);
      if (v == null) return null;
      var n = new GomAttr.namespace (_element, namespace_uri, nsp, local_name, v);
      return n;
    }
    // Introduced in DOM Level 2:
    public DomNode? set_named_item_ns (DomNode node) throws GLib.Error {
      if ((node as DomAttr).local_name == "" || ":" in (node as DomAttr).local_name)
        throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid attribute name: %s"),(node as DomAttr).local_name);
      if (!(node is DomAttr))
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid node type. DomAttr was expected"));

      if ((node as DomAttr).prefix == "xmlns"
          && (node as DomAttr).namespace_uri != "http://www.w3.org/2000/xmlns/"
              && (node as DomAttr).namespace_uri != "http://www.w3.org/2000/xmlns")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with xmlns should use a namespace uri http://www.w3.org/2000/xmlns"));
      if ((node as DomAttr).prefix == ""
          || (node as DomAttr).prefix == null
          && (node as DomAttr).local_name != "xmlns") {
        string s = (node as DomAttr).local_name;
        if ((node as DomAttr).namespace_uri != null)
          s += "=<"+(node as DomAttr).namespace_uri+">";
        throw new DomError.NAMESPACE_ERROR (_("Namespaced attributes should provide a non-null, non-empty prefix: %s"),s);
      }
      if ((node as DomAttr).prefix == "xmlns"
          && (node as DomAttr).local_name == "xmlns")
        throw new DomError.NAMESPACE_ERROR (_("Invalid namespace attribute's name."));
      if ((node as DomAttr).prefix == "xmlns"
          || (node as DomAttr).local_name == "xmlns") {
        string asp = _element.get_attribute_ns (node.node_value,
                                          (node as DomAttr).local_name);
        if (asp != null) return node;
      }
      if ((node as DomAttr).namespace_uri == "http://www.w3.org/2000/xmlns/"
          || (node as DomAttr).namespace_uri == "http://www.w3.org/2000/xmlns") {
        if ((node as DomAttr).local_name == "xmlns") {
          string ns_uri = _element.lookup_namespace_uri (null);
          if (ns_uri != null && ns_uri != node.node_value) {
            message (_("Duplicated default namespace detected with URI: %s").printf (ns_uri));
          }
        }
        if ((node as DomAttr).prefix == "xmlns") {
          string nsprefix = _element.lookup_prefix (node.node_value);
          string nsuri = _element.lookup_namespace_uri ((node as DomAttr).local_name);
          if ((nsprefix != null || nsuri != null)
              && (nsprefix != (node as DomAttr).local_name
                  || nsuri != node.node_value)) {
            message (_("Duplicated namespace detected for: %s:%s").printf ((node as DomAttr).local_name, node.node_value));
          }
        }
      }
      if ((node as DomAttr).namespace_uri != "http://www.w3.org/2000/xmlns/"
          && (node as DomAttr).namespace_uri != "http://www.w3.org/2000/xmlns"){
        string nsn = _element.lookup_namespace_uri ((node as DomAttr).prefix);
        string nspn = _element.lookup_prefix (nsn);
        if (nspn != (node as DomAttr).prefix
            && nsn != (node as DomAttr).namespace_uri)
          throw new DomError.NAMESPACE_ERROR
                  (_("Trying to add an attribute with an undefined namespace prefix: %s").printf ((node as DomAttr).prefix));
        nspn = _element.lookup_prefix ((node as DomAttr).namespace_uri);
        nsn = _element.lookup_namespace_uri (nspn);
        if (nspn != (node as DomAttr).prefix
            && nsn != (node as DomAttr).namespace_uri)
          throw new DomError.NAMESPACE_ERROR
                  (_("Trying to add an attribute with a non found namespace URI"));
      }

      string p = "";
      if ((node as DomAttr).prefix != null
          && (node as DomAttr).prefix != "")
        p = (node as DomAttr).prefix + ":";
      string k = p+(node as DomAttr).local_name;
      set (k, node.node_value);
      order.set (size, k);

      var attr = new GomAttr.namespace (_element,
                                    (node as DomAttr).namespace_uri,
                                    (node as DomAttr).prefix,
                                    (node as DomAttr).local_name,
                                    node.node_value);
      return attr;
    }
    private long index_of (string name) {
      long i = -1;
      foreach (Map.Entry<long,string> e in order.ascending_entries) {
        i++;
        if (e.value == name) return i;
      }
      return -1;
    }
  }
  public DomNamedNodeMap attributes { owned get { return (DomNamedNodeMap) _attributes; } }
  public string? get_attribute (string name) {
    string s = (this as GomObject).get_attribute (name);
    if (s != null) return s;
    return _attributes.get (name);
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
    return _attributes.get (name);
  }
  public void set_attribute (string name, string value) throws GLib.Error {
    bool res = (this as GomObject).set_attribute (name, value);
    if (res) return;
    var a = new GomAttr (this, name, value);
    attributes.set_named_item (a);
  }
  public void set_attribute_ns (string? namespace_uri,
                                string name, string value) throws GLib.Error {
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
    } else
      n = name;
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
    var a = new GomAttr.namespace (this, namespace_uri, p, n, value);
    try { _attributes.set_named_item_ns (a); }
    catch (GLib.Error e) {
      throw new DomError.NAMESPACE_ERROR (_("Setting namespaced property error: ")+e.message);
    }
  }
  public void remove_attribute (string name) {
    if ((this as GomObject).remove_attribute (name)) return;
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
    var p = lookup_prefix (namespace_uri);
    if (p == null) return false;
    return attributes.has_key (p+":"+local_name);
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
    parser.read_child_nodes_string (unparsed, null);
    unparsed = null;
  }
}


