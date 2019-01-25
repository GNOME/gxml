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

/**
 * A DOM4 implementation of {@link DomDocument}, for one step parsing.
 *
 * This object avoids pre and post XML parsing, by using a one step parsing
 * to translate text XML tree to an GObject based tree.
 */
public class GXml.GomDocument : GomNode,
                              DomParentNode,
                              DomNonElementParentNode,
                              DomDocument,
                              DomXMLDocument
{
  // DomDocument implementation
  protected DomImplementation _implementation = new GomImplementation ();
  protected string _url;
  protected string _origin;
  protected string _compat_mode;
  protected string _character_set;
  protected string _content_type;
  protected GXml.DomEvent _constructor;
  public DomImplementation implementation { get { return _implementation; } }
  public string url { get { return _url; } }
  public string document_uri { get { return _url; } }
  public string origin { get { return _origin; } }
  public string compat_mode { get { return _compat_mode; } }
  public string character_set { get { return _character_set; } }
  public string content_type { get { return _content_type; } }

  public DomDocumentType? doctype {
    owned get {
      foreach (DomNode n in child_nodes) {
        if (n is DomDocumentType) return (DomDocumentType) n;
      }
      return null;
    }
  }
  public DomElement? document_element {
    owned get {
      if (child_nodes.size == 0) return null;
      return child_nodes[0] as DomElement;
    }
  }

  construct {
    _local_name = "#document";
    _node_type = DomNode.NodeType.DOCUMENT_NODE;
    _url = "about:blank";
    _origin = "";
    _compat_mode = "";
    _character_set = "utf-8";
    _content_type = "application/xml";
  }
  public GomDocument () {}
  public GomDocument.from_path (string path) throws GLib.Error {
    var file = GLib.File.new_for_path (path);
    this.from_file (file);
  }

  /**
   * Creates a document parsing a URI file.
   */
  public GomDocument.from_uri (string uri) throws GLib.Error {
    this.from_file (File.new_for_uri (uri));
  }

  /**
   * Creates a document parsing a file.
   */
  public GomDocument.from_file (GLib.File file) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_file (file, null);
  }

  /**
   * Creates a document parsing a stream.
   */
  public GomDocument.from_stream (GLib.InputStream stream) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_stream (stream, null);
  }

  /**
   * Creates a document parsing a string.
   */
  public GomDocument.from_string (string str) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_string (str, null);
  }

  /**
   * Writes a dump XML representation of document to a file.
   */
  public void write_file (GLib.File file) throws GLib.Error {
    var parser = new XParser (this);
    parser.write_file (file, null);
  }
  /**
   * Writes asynchronically a dump XML representation of document to a file.
   */
  public async void write_file_async (GLib.File file) throws GLib.Error {
    var parser = new XParser (this);
    yield parser.write_file_async (file, null);
  }
  /**
   * Writes a dump XML representation of document to a stream.
   */
  public void write_stream (GLib.OutputStream stream) throws GLib.Error {
    var parser = new XParser (this);
    parser.write_stream (stream, null);
  }
  /**
   * Writes a dump XML representation of document to a stream.
   */
  public async void write_stream_async (GLib.OutputStream stream) throws GLib.Error {
    var parser = new XParser (this);
    parser.write_stream (stream, null);
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GomDocument}
   */
  public InputStream create_stream () throws GLib.Error {
    var parser = new XParser (this);
    return parser.create_stream (null);
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GomDocument}
   */
  public async InputStream create_stream_async () throws GLib.Error {
    var parser = new XParser (this);
    return yield parser.create_stream_async (null);
  }
  /**
   * Serialize {@link GomDocument} to a string.
   */
  public string write_string () throws GLib.Error {
    var parser = new XParser (this);
    return parser.write_string ();
  }
  /**
   * Serialize {@link GomDocument} to a string.
   */
  public async string write_string_async () throws GLib.Error {
    var parser = new XParser (this);
    return yield parser.write_string_async ();
  }
  /**
   * Reads a file contents and parse it to document.
   */
  public void read_from_file (GLib.File file) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_file (file, null);
  }
  /**
   * Reads a file contents and parse it to document.
   */
  public async void read_from_file_async (GLib.File file) throws GLib.Error {
    var parser = new XParser (this);
    yield parser.read_file_async (file, null);
  }
  /**
   * Reads a string and parse it to document.
   */
  public void read_from_string (string str) throws GLib.Error {
    var parser = new XParser (this);
    parser.read_string (str, null);
  }
  /**
   * Reads a string and parse it to document.
   */
  public async void read_from_string_async (string str) throws GLib.Error {
    var parser = new XParser (this);
    yield parser.read_string_async (str, null);
  }

  public DomElement create_element (string local_name) throws GLib.Error {
    var e = new GomElement ();
    e.initialize_document (this, local_name);
    return e;
  }
  public DomElement create_element_ns (string? namespace_uri, string qualified_name) throws GLib.Error
  {
    string n = "";
    string nsp = null;
    if (":" in qualified_name) {
      var s = qualified_name.split (":");
      if (s.length != 2)
        throw new DomError.NAMESPACE_ERROR
          (_("Creating a namespaced element with invalid node name"));
      nsp = s[0];
      n = s[1];
    } else
      n = qualified_name;
    if (nsp == "" && namespace_uri == null)
      throw new DomError.NAMESPACE_ERROR
        (_("Creating a namespaced element with invalid namespace"));
    if ((n == "xmlns" || nsp == "xmlns")
        && namespace_uri != "http://www.w3.org/2000/xmlns/")
      throw new DomError.NAMESPACE_ERROR
        (_("Invalid namespace URI for xmlns prefix. Use http://www.w3.org/2000/xmlns/"));
    if ((n != "xmlns" || nsp != "xmlns")
        && namespace_uri == "http://www.w3.org/2000/xmlns/")
      throw new DomError.NAMESPACE_ERROR
        (_("Only xmlns prefixs can be used with http://www.w3.org/2000/xmlns/"));
    var e = new GomElement ();
    e.initialize_document_with_namespace (this, namespace_uri, nsp, n);
    return e;
  }

  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
      var l = new GDomHTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_tag_name (local_name));
      return l;
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? ns, string local_name) {
      var l = new GDomHTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_tag_name_ns (ns, local_name));
      return l;
  }
  public DomHTMLCollection get_elements_by_class_name(string class_names) {
      var l = new GDomHTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_class_name (class_names));
      return l;
  }

  public DomDocumentFragment create_document_fragment() {
    return new GomDocumentFragment (this);
  }
  public DomText create_text_node (string data) throws GLib.Error {
    return new GomText (this, data);
  }
  public DomComment GXml.DomDocument.create_comment (string data) throws GLib.Error {
    return new GomComment (this, data);
  }
  public DomProcessingInstruction create_processing_instruction (string target, string data) throws GLib.Error {
    return new GomProcessingInstruction (this, target, data);
  }

  public DomNode import_node (DomNode node, bool deep = false) throws GLib.Error {
      if (node is DomDocument)
        throw new GXml.DomError.NOT_SUPPORTED_ERROR (_("Can't import a Document"));
      if (!(node is DomElement) && this.document_element == null)
        throw new GXml.DomError.HIERARCHY_REQUEST_ERROR (_("Can't import a non Element type node to a Document"));
      GXml.DomNode dst = null;
      if (node is DomElement) {
        dst = (this as DomDocument).create_element (node.node_name);
        GXml.DomNode.copy (this, dst, node, deep);
        if (document_element == null) {
          this.append_child (dst);
          return dst;
        }
      }
      if (node is DomText)
        dst = this.create_text_node ((node as DomText).data);
      if (node is DomComment)
        dst = (this as DomDocument).create_comment ((node as DomComment).data);
      if (node is DomProcessingInstruction)
        dst = this.create_processing_instruction ((node as DomProcessingInstruction).target, (node as DomProcessingInstruction).data);
      if (dst != null) {
        document_element.append_child (dst as DomNode);
        return dst;
      }
      return node;
  }
  public DomNode adopt_node (DomNode node) throws GLib.Error {
      if (node is DomDocument)
        throw new GXml.DomError.NOT_SUPPORTED_ERROR (_("Can't adopt a Document"));
      if (this == node.owner_document) return node;
      var dst = this.create_element (node.node_name);
      GXml.DomNode.copy (this, dst, node, true);
      if (node.parent_node != null)
        node.parent_node.child_nodes.remove_at (node.parent_node.child_nodes.index_of (node));
      if (this.document_element == null)
        this.append_child (dst as DomNode);
      else
        document_element.append_child (dst as DomNode);
      return (DomNode) dst;
  }

  public DomEvent create_event (string iface) {
      var s = iface.down ();
      if (s == "customevent") _constructor = new GXml.GDomCustomEvent ();
      if (s == "event") _constructor = new GXml.GDomCustomEvent ();
      if (s == "events") _constructor = new GXml.GDomCustomEvent ();
      if (s == "htmlevents") _constructor = new GXml.GDomCustomEvent ();
      if (s == "keyboardevent") _constructor = null;
      if (s == "keyevents") _constructor = null;
      if (s == "messageevent") _constructor = null;
      if (s == "mouseevent") _constructor = null;
      if (s == "mouseevents") _constructor = null;
      if (s == "touchevent") _constructor = null;
      if (s == "uievent") _constructor = null;
      if (s == "uievents") _constructor = null;
      return _constructor;
  }

  public DomRange create_range() {
      return new GDomRange (this);
  }

  // NodeFilter.SHOW_ALL = 0xFFFFFFFF
  public DomNodeIterator create_node_iterator (DomNode root, int what_to_show = (int) 0xFFFFFFFF, DomNodeFilter? filter = null)
  {
    return new GDomNodeIterator (root, what_to_show, filter);
  }
  public DomTreeWalker create_tree_walker (DomNode root, int what_to_show = (int) 0xFFFFFFFF, DomNodeFilter? filter = null) {
      return new GDomTreeWalker (root, what_to_show, filter);
  }
  // DomParentNode
  public DomHTMLCollection children {
    owned get {
      var l = new GDomHTMLCollection ();
      foreach (GXml.DomNode n in child_nodes) {
        if (n is DomElement) l.add ((DomElement) n);
      }
      return l;
    }
  }
  public DomElement? first_element_child {
    owned get { return (DomElement) child_nodes.first (); }
  }
  public DomElement? last_element_child {
    owned get { return (DomElement) child_nodes.last (); }
  }
  public int child_element_count { get { return child_nodes.size; } }

  public DomNodeList query_selector_all (string selectors) throws GLib.Error  {
    var cs = new CssSelectorParser ();
    cs.parse (selectors);
    var l = new GomNodeList();
    foreach (DomElement e in children) {
      if (cs.match (e))
        l.add (e);
      l.add_all (cs.query_selector_all (e));
    }
    return l;
  }
  // DomNonElementParentNode
  public DomElement? get_element_by_id (string element_id) throws GLib.Error {
    var l = get_elements_by_property_value ("id", element_id);
    if (l.size == 0) return null;
    return l.get_element (0) as DomElement;
  }
}

public class GXml.GomImplementation : GLib.Object, GXml.DomImplementation {
  public DomDocumentType
    create_document_type (string qualified_name, string public_id, string system_id)
        throws GLib.Error
  {

    return new GomDocumentType.with_ids (new GomDocument (), qualified_name, public_id, system_id); // FIXME
  }
  public DomXMLDocument create_document (string? namespace,
                                         string? qualified_name,
                                         DomDocumentType? doctype = null)
                                         throws GLib.Error
  {
    var d = new GomDocument ();
    if (doctype != null)
      d.append_child (new GomDocumentType.with_ids (d,
                                                    doctype.name,
                                                    doctype.public_id,
                                                    doctype.system_id));
    d.append_child (d.create_element_ns (namespace, qualified_name));
    return d as DomXMLDocument;
  } // FIXME
  public Document create_html_document (string title) {
    return new GHtmlDocument (); // FIXME:
  }
}


public class GXml.GomDocumentType : GXml.GomNode,
                                  GXml.DomChildNode,
                                  GXml.DomDocumentType
{
  protected string _name = "";
  protected string _public_id = "";
  protected string _system_id = "";

  public string name { get { return _name; } }
  public string public_id { get { return _public_id; } }
  public string system_id { get { return _system_id; } }

  construct {
    _node_type = DomNode.NodeType.DOCUMENT_TYPE_NODE;
    _local_name = "!DOCTYPE";
  }
  public GomDocumentType (DomDocument doc, string name, string? public_id, string? system_id) {
    _document = doc;
     _name = name;
    _public_id = public_id;
    _system_id = system_id;
  }
  public GomDocumentType.with_name (DomDocument doc, string name) {
    _document = doc;
    _name = name;
    _public_id = "";
    _system_id = "";
  }
  public GomDocumentType.with_ids (DomDocument doc, string name, string public_id, string system_id) {
    _document = doc;
    _name = name;
    _public_id = public_id;
    _system_id = system_id;
  }
  // DomChildNode implementation
  public void remove () {
    if (parent_node == null) return;
    if (parent_node.child_nodes == null) return;
    var i = parent_node.child_nodes.index_of (this);
    parent_node.child_nodes.remove_at (i);
  }
}


public class GXml.GomDocumentFragment : GXml.GomNode,
                                        GXml.DomParentNode,
                                        GXml.DomNonElementParentNode,
                                        GXml.DomDocumentFragment
{
  public GomDocumentFragment (DomDocument doc) {
    _document = doc;
    _node_type = DomNode.NodeType.DOCUMENT_FRAGMENT_NODE;
    _local_name = "#document-fragment";
  }
  // DomParentNode
  public new DomHTMLCollection children {
    owned get {
      var l = new GDomHTMLCollection ();
      foreach (GXml.DomNode n in child_nodes) {
        if (n is DomElement) l.add ((DomElement) n);
      }
      return l;
    }
  }
  public DomElement? first_element_child { owned get { return (DomElement) children.first (); } }
  public DomElement? last_element_child { owned get { return (DomElement) children.last (); } }
  public int child_element_count { get { return (int) children.size; } }

  public DomElement? query_selector (string selectors) throws GLib.Error {
  // FIXME:
    throw new DomError.SYNTAX_ERROR (_("DomElement query_selector is not implemented"));
  }
  public DomNodeList query_selector_all (string selectors) throws GLib.Error {
  // FIXME:
    throw new DomError.SYNTAX_ERROR (_("DomElement query_selector_all is not implemented"));
  }

  // DomNonElementParentNode
  public DomElement? get_element_by_id (string element_id) throws GLib.Error {
    var l = get_elements_by_property_value ("id", element_id);
    if (l.size == 0) return null;
    return (DomElement) l.get_element (0) as DomElement;
  }
}

