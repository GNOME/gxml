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
 * A GXml Object Model (GOM) implementation of {@link GXml.Element}. It can be
 * used transparently as {@link DomElement} in a XML tree.
 *
 * It also allows delayed parsing, so you can read large documents by parsing
 * just a XML element node and its attributes but not its children; save its
 * children as a text, for a post-on-step-parsing.
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
   * Parses asynchronically an XML file, deserializing it over {@link GXml.Element}.
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
   * Serialize asynchronically {@link GXml.Element} to a string.
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
    ((GXml.Document) this.owner_document).write_file (f);
  }
  /**
   * Uses element's {@link GXml.Document} to write asynchronically an XML to a file, serializing it.
   */
  public async void write_file_async (GLib.File f, Cancellable? cancellable = null) throws GLib.Error {
    yield ((GXml.Document) this.owner_document).write_file_async (f);
  }
  /**
   * Uses element's {@link GXml.Document} to write an XML to a stream, serializing it.
   */
  public void write_stream (GLib.OutputStream stream) throws GLib.Error {
    ((GXml.Document) this.owner_document).write_stream (stream);
  }
  /**
   * Uses element's {@link GXml.Document} to write an XML to a stream, serializing it.
   */
  public async void write_stream_async (GLib.OutputStream stream, Cancellable? cancellable = null) throws GLib.Error {
    yield ((GXml.Document) this.owner_document).write_stream_async (stream);
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GXml.Element} using node's {@link GXml.Document}
   */
  public InputStream create_stream () throws GLib.Error {
    return ((GXml.Document) this.owner_document).create_stream ();
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GXml.Element} using node's {@link GXml.Document}
   */
  public async InputStream create_stream_async (Cancellable? cancellable = null) throws GLib.Error {
    return yield ((GXml.Document) this.owner_document).create_stream_async ();
  }
  // DomNode overrides
  public new string? lookup_prefix (string? nspace) {
    if (_namespace_uri == nspace)
      return _prefix;
    switch (nspace) {
      case "http://www.w3.org/2000/xmlns/":
      case "http://www.w3.org/2000/xmlns":
        return "xmlns";
      case "http://www.w3.org/XML/1998/namespace":
      case "http://www.w3.org/XML/1998/namespace/":
        return "xml";
      case "http://www.w3.org/1999/xhtml":
      case "http://www.w3.org/1999/xhtml/":
        return "html";
      case "http://www.w3.org/2001/XMLSchema-instance":
      case "http://www.w3.org/2001/XMLSchema-instance/":
        return "xsi";
      case "http://www.w3.org/2000/svg":
      case "http://www.w3.org/2000/svg/":
        return "svg";
      case "http://www.w3.org/1998/Math/MathML":
      case "http://www.w3.org/1998/Math/MathML/":
        return "mathml";
      case "http://www.w3.org/1999/xlink":
      case "http://www.w3.org/1999/xlink/":
        return "xlink";
      default:
        break;
    }
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
    switch (prefix) {
      case "xmlns":
        return "http://www.w3.org/2000/xmlns";
      case "xml":
        return "http://www.w3.org/XML/1998/namespace";
      case "html":
        return "http://www.w3.org/1999/xhtml";
      case "xsi":
        return "http://www.w3.org/2001/XMLSchema-instance";
      case "svg":
        return "http://www.w3.org/2000/svg";
      case "xlink":
        return "http://www.w3.org/1999/xlink";
      case "mathml":
      case "MathML":
        return "http://www.w3.org/1998/Math/MathML";
      default:
        break;
    }
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
    owned get { return ((GXml.Element) this).get_attribute ("class"); }
    set { ((GXml.Object) this).set_attribute ("class", value); }
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
   * has been called in any base class, this method just change element node's name
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
     * Holds {@link GXml.Element} reference to attributes' parent element.
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
      var ov = ((GXml.Object) _element).get_attribute (name);
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
      if ((":" in ((GXml.Attr) node).local_name)
          || ((GXml.Attr) node).local_name == "")
        throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid attribute name: %s"), ((GXml.Attr) node).local_name);
      if (!(node is GXml.Attr))
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid node type. GXml.Attr was expected"));
      GXml.Attr attr = null;
      var pprop = ((GXml.Object) _element).find_property_name (((GXml.Attr) node).local_name);
      if (pprop != null) {
        ((GXml.Object) _element).set_attribute (((GXml.Attr) node).local_name, node.node_value);
        attr = new GXml.Attr.reference (_element, ((GXml.Attr) node).local_name);
      } else {
        attr = new GXml.Attr (_element, ((GXml.Attr) node).local_name, node.node_value);
      }
      set (attr.local_name.down (), attr);
      order.set (size - 1, ((GXml.Attr) node).local_name.down ());
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
      if (":" in local_name) {
        throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid attribute's local name '%s': invalid use of ':' character"), local_name);
      }
      var nsp = _element.lookup_prefix (namespace_uri);
      if (nsp == null) {
        throw new DomError.NAMESPACE_ERROR (_("Namespace URI was not found: %s"), namespace_uri);
      }
      string k = (nsp+":"+local_name).down ();
      var v = get (k);
      return v;
    }
    // Introduced in DOM Level 2:
    public DomNode? set_named_item_ns (DomNode node) throws GLib.Error {
      if (((GXml.Attr) node).local_name == "" || ":" in ((GXml.Attr) node).local_name)
        throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid attribute name: %s"),((GXml.Attr) node).local_name);
      if (!( node is GXml.Attr))
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Invalid node type. GXml.Attr was expected"));

      if (((GXml.Attr) node).prefix == "xmlns"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2000/xmlns/"
              && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2000/xmlns")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with 'xmlns' should use a namespace uri http://www.w3.org/2000/xmlns"));
      if (((GXml.Attr) node).prefix == "xml"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/XML/1998/namespace/"
              && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/XML/1998/namespace")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with 'xml' should use a namespace uri http://www.w3.org/XML/1998/namespace"));
      if (((GXml.Attr) node).prefix == "xsi"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2001/XMLSchema-instance/"
              && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2001/XMLSchema-instance")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with 'xsi' should use a namespace uri http://www.w3.org/2001/XMLSchema-instance"));
      if (((GXml.Attr) node).prefix == "html"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/1999/xhtml/"
              && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/1999/xhtml")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with 'html' should use a namespace uri http://www.w3.org/1999/xhtml"));
      if (((GXml.Attr) node).prefix != null && ((GXml.Attr) node).prefix.down () == "mathml"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/1998/Math/MathML/"
              && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/1998/Math/MathML")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with 'MathML' should use a namespace uri http://www.w3.org/1998/Math/MathML"));
      if (((GXml.Attr) node).prefix == "xlink"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/1999/xlink/"
              && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/1999/xlink")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with 'xlink' should use a namespace uri http://www.w3.org/1999/xlink"));
      if (((GXml.Attr) node).prefix == "svg"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2000/svg"
              && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2000/svg")
        throw new DomError.NAMESPACE_ERROR (_("Namespace attributes prefixed with 'svg' should use a namespace uri http://www.w3.org/2000/svg"));
      if (((GXml.Attr) node).prefix == ""
          || ((GXml.Attr) node).prefix == null
          && ((GXml.Attr) node).local_name != "xmlns") {
        string s = ((GXml.Attr) node).local_name;
        if (((GXml.Attr) node).namespace_uri != null)
          s += "=<"+((GXml.Attr) node).namespace_uri+">";
        throw new DomError.NAMESPACE_ERROR (_("Namespaced attributes should provide a non-null, non-empty prefix: %s"),s);
      }
      if (((GXml.Attr) node).prefix == "xmlns"
          && ((GXml.Attr) node).local_name == "xmlns")
        throw new DomError.NAMESPACE_ERROR (_("Invalid namespace attribute's name."));
      if (((GXml.Attr) node).prefix == "xmlns"
          || ((GXml.Attr) node).local_name == "xmlns"
          || ((GXml.Attr) node).prefix == "xsi") {
        string asp = _element.get_attribute_ns (node.node_value,
                                          ((GXml.Attr) node).local_name);
        if (asp != null) return node;
      }
      if (((GXml.Attr) node).namespace_uri != "http://www.w3.org/2000/xmlns/"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2000/xmlns"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2001/XMLSchema-instance/"
          && ((GXml.Attr) node).namespace_uri != "http://www.w3.org/2001/XMLSchema-instance") {
        string nsn = _element.lookup_namespace_uri (((GXml.Attr) node).prefix);
        string nspn = _element.lookup_prefix (nsn);
        if (nspn != ((GXml.Attr) node).prefix
            && nsn != ((GXml.Attr) node).namespace_uri) {
          throw new DomError.NAMESPACE_ERROR
                  (_("Trying to add an attribute with an undefined namespace's prefix: %s").printf (((GXml.Attr) node).prefix));
        }
        nspn = _element.lookup_prefix (((GXml.Attr) node).namespace_uri);
        nsn = _element.lookup_namespace_uri (nspn);
        if (nspn != ((GXml.Attr) node).prefix
            && nsn != ((GXml.Attr) node).namespace_uri)
          throw new DomError.NAMESPACE_ERROR
                  (_("Trying to add an attribute with an undefined namespace's URI"));
      }

      string p = "";
      if (((GXml.Attr) node).prefix != null
          && ((GXml.Attr) node).prefix != "") {
        p = ((GXml.Attr) node).prefix + ":";
      }
      string k = (p+((GXml.Attr) node).local_name).down ();
      GXml.Attr attr = null;
      var pprop = ((GXml.Object) _element).find_property_name (k);
      if (pprop != null) {
        ((GXml.Object) _element).set_attribute (k, node.node_value);
        attr = new GXml.Attr.reference (_element, k);
      } else {
        attr = new GXml.Attr.namespace (_element, ((GXml.Attr) node).namespace_uri, ((GXml.Attr) node).prefix, ((GXml.Attr) node).local_name, node.node_value);
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
    try {
      var a = _attributes.get_named_item_ns (namespace_uri, local_name) as GXml.Attr;
      if (a != null) {
        return a.value;
      }
      return null;
    } catch (GLib.Error e) {
      debug (_("Error getting attribute with namespace: %s"), e.message);
    }
    return null;
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
      if (s.length != 2) {
        throw new DomError.NAMESPACE_ERROR (_("Invalid attribute name. Just one prefix is allowed"));
      }
      p = s[0];
      n = s[1];
      if (":" in n) {
        throw new DomError.NAMESPACE_ERROR (_("Invalid attribute name. Invalid use of colon: %s"), n);
      }
    }
    if (namespace_uri == null && p == "") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If prefix is null, namespace URI should not be null"));
    }

    if (p == "" && n != "xmlns") {
      throw new DomError.NAMESPACE_ERROR (_("Invalid namespace definition. No prefixed attributes should use 'xmlns' as name"));
    }

    if (p == "xmlns" && n == "xml") {
      throw new DomError.NAMESPACE_ERROR (_("'xml' namespace should not be defined"));
    }

    if (p == "xmlns" && n == "xmlns") {
      throw new DomError.NAMESPACE_ERROR (_("'xmlns' namespace should not be defined"));
    }

    if (p.down () == "xml" && namespace_uri == null) {
        namespace_uri = "http://www.w3.org/XML/1998/namespace/";
    }
    if (p == "xml" && namespace_uri != "http://www.w3.org/XML/1998/namespace/"
        && namespace_uri != "http://www.w3.org/XML/1998/namespace") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If prefix is 'xml', namespace URI should be http://www.w3.org/XML/1998/namespace"));
    }
    if (p.down () == "xmlns" && namespace_uri == null) {
        namespace_uri = "http://www.w3.org/2000/xmlns/";
    }
    if (n == "xmlns" && namespace_uri != "http://www.w3.org/2000/xmlns/"
            && namespace_uri != "http://www.w3.org/2000/xmlns") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace definition. If attribute's prefix is 'xmlns', namespace URI should be http://www.w3.org/2000/xmlns"));
    }
    if (p.down () == "html" && namespace_uri == null) {
        namespace_uri = "http://www.w3.org/1999/xhtml/";
    }
    if (p == "html" && namespace_uri != "http://www.w3.org/1999/xhtml/"
            && namespace_uri != "http://www.w3.org/1999/xhtml") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If attribute's prefix is 'html', namespace URI should be http://www.w3.org/1999/xhtml"));
    }
    if (p.down () == "xsi" && namespace_uri == null) {
        namespace_uri = "http://www.w3.org/2001/XMLSchema-instance/";
    }
    if (p == "xsi" && namespace_uri != "http://www.w3.org/2001/XMLSchema-instance/"
            && namespace_uri != "http://www.w3.org/2001/XMLSchema-instance") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If attribute's prefix is 'xsi', namespace URI should be http://www.w3.org/2001/XMLSchema-instance"));
    }
    if (p.down () == "mathml" && namespace_uri == null) {
        namespace_uri = "http://www.w3.org/1998/Math/MathML/";
    }
    if (p.down () == "mathml" && namespace_uri != "http://www.w3.org/1998/Math/MathML/"
            && namespace_uri != "http://www.w3.org/1998/Math/MathML") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If attribute's prefix is 'MathML', namespace URI should be http://www.w3.org/1998/Math/MathML"));
    }
    if (p.down () == "svg" && namespace_uri == null) {
        namespace_uri = "http://www.w3.org/2000/svg/";
    }
    if (p.down () == "svg" && namespace_uri != "http://www.w3.org/2000/svg/"
            && namespace_uri != "http://www.w3.org/2000/svg") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If attribute's prefix is 'svg', namespace URI should be http://www.w3.org/2000/svg"));
    }
    if (p.down () == "xlink" && namespace_uri == null) {
        namespace_uri = "http://www.w3.org/1999/xlink/";
    }
    if (p.down () == "xlink" && namespace_uri != "http://www.w3.org/1999/xlink/"
            && namespace_uri != "http://www.w3.org/1999/xlink") {
       throw new DomError.NAMESPACE_ERROR (_("Invalid namespace. If attribute's prefix is 'xlink', namespace URI should be http://www.w3.org/1999/xlink"));
    }
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
    //FIXME: quirks mode not considered
    foreach (GXml.DomNode n in child_nodes) {
      if (!(n is DomElement)) continue;
      if (n.node_name == local_name)
        l.add ((DomElement) n);
      l.add_all (((DomElement) n).get_elements_by_tag_name (local_name));
    }
    return l;
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name) {
    var l = new HTMLCollection ();
    //FIXME: quirks mode not considered
    foreach (GXml.DomNode n in child_nodes) {
      if (!(n is DomElement)) continue;
      if (n.node_name == local_name
          && ((DomElement) n).namespace_uri == namespace)
        l.add ((DomElement) n);
      l.add_all (((DomElement) n).get_elements_by_tag_name_ns (namespace, local_name));
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
      string cls = ((DomElement) n).get_attribute ("class");
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
            l.add ((DomElement) n);
          else
            l.insert (0, (DomElement) n);
        }
      }
      l.add_all (((DomElement) n).get_elements_by_class_name (class_names));
    }
    return l;
  }
  /**
   * If true all children are parsed. If false, all its children are stored
   * as plain string in {@link unparsed}. In order to generate an XML tree
   * use {@link read_unparsed}.
   */
  public bool parse_children { get; set; default = true; }

  private string _unparsed = null;
  /**
   * Temporally stores, all unparsed children as plain string. See {@link parse_children}.
   *
   * If it is null, means all children have been already parsed.
   */
  public string unparsed {
    get {
      if (read_buffer != null) {
        return (string) read_buffer.data;
      }
      return _unparsed;
    }
    set {
      _unparsed = value;
    }
  }
  /**
   * Parse all children, adding them to current node, stored in {@link unparsed}.
   * Once it finish, sets {@link unparsed} to null.
   */
  public void read_unparsed () throws GLib.Error {
    if (unparsed != null) {
      var parser = new XParser (this);
      parser.read_child_nodes_string (unparsed);
      unparsed = null;
    }
  }
  /**
   * On memory {@link GLib.MemoryOutputStream} with the unparsed
   * string of the element
   */
  public MemoryOutputStream read_buffer { get; set; }

  /**
   * Synchronically parse {@link read_buffer}
   */
  public void parse_buffer () throws GLib.Error {
    foreach (DomNode n in child_nodes) {
      if (n is GXml.Element) {
        ((GXml.Element) n).parse_buffer ();
      }
    }

    if (read_buffer != null) {
      read_from_string ((string) read_buffer.data);
      read_buffer = null;
    }
  }

  ThreadPool<Element> pool = null;

  /**
   * Monitor multi-threading parsing
   */
  public uint parse_pending () {
    if (pool == null) {
      return 0;
    }
    return pool.unprocessed ();
  }

  /**
   * Asynchronically parse {@link read_buffer}
   */
  public async void parse_buffer_async () throws GLib.Error {
    if (read_buffer == null) {
      return;
    }
    uint nth = GLib.get_num_processors ();
    if (nth > 1) {
      nth = (uint) (nth - 1);
    }
    pool = new ThreadPool<Element>.with_owned_data ((e)=>{
      try {
        if (e.read_buffer != null) {
          e.read_from_string ((string) e.read_buffer.data);
          e.read_buffer = null;
        }
      } catch (GLib.Error err) {
        warning (_("Error parsing child's buffer: %s"), err.message);
      }
    }, (int) nth, false);
    foreach (DomNode n in child_nodes) {
      if (n is GXml.Element) {
        pool.add ((GXml.Element) n);
      }
    }
    //while (lpool.unprocessed () != 0);
    read_from_string ((string) read_buffer.data);
    read_buffer = null;
  }
}


