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
  protected Parser _parser;
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

  public GXml.Parser parser { get { return _parser; } set { _parser = value; } }

  construct {
    _local_name = "#document";
    _node_type = DomNode.NodeType.DOCUMENT_NODE;
    _url = "about:blank";
    _origin = "";
    _compat_mode = "";
    _character_set = "utf-8";
    _content_type = "application/xml";
    _parser = new XParser (this);
  }
  public GomDocument () {}
  public GomDocument.from_path (string path) throws GLib.Error {
    var file = GLib.File.new_for_path (path);
    from_file (file);
  }

  public GomDocument.from_uri (string uri) throws GLib.Error {
    this.from_file (File.new_for_uri (uri));
  }

  public GomDocument.from_file (GLib.File file) throws GLib.Error {
    _parser.read_file (file, null);
  }

  public GomDocument.from_stream (GLib.InputStream stream) throws GLib.Error {
    _parser.read_stream (stream, null);
  }

  public GomDocument.from_string (string str) throws GLib.Error {
    _parser.read_string (str, null);
  }


  public string to_string () {
    return _parser.write_string ();
  }

  public void write_file (GLib.File file) throws GLib.Error {
    _parser.write_file (file, null);
  }

  public void write_stream (GLib.OutputStream stream) throws GLib.Error {
    _parser.write_stream (stream, null);
  }

  public DomElement create_element (string local_name) throws GLib.Error {
    return new GomElement (this, local_name);
  }
  public DomElement create_element_ns (string? ns, string qualified_name) throws GLib.Error
  {
    string n = "";
    string nsp = "";
    if (":" in qualified_name) {
      var s = qualified_name.split (":");
      if (s.length != 2)
        throw new DomError.NAMESPACE_ERROR
          (_("Creating an namespaced element with invalid node name"));
      nsp = s[0];
      n = s[1];
    } else
      n = qualified_name;
    if (nsp == "" && ns == null)
      throw new DomError.NAMESPACE_ERROR
        (_("Creating an namespaced element with invalid namespace"));
      // TODO: check for xmlns https://www.w3.org/TR/dom/#dom-document-createelementns
    return new GomElement.namespace (this, ns, nsp, n);
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
  public DomHTMLCollection children { owned get { return (DomHTMLCollection) child_nodes; } }
  public DomElement? first_element_child {
    owned get { return (DomElement) child_nodes.first (); }
  }
  public DomElement? last_element_child {
    owned get { return (DomElement) child_nodes.last (); }
  }
  public int child_element_count { get { return child_nodes.size; } }

  public DomElement? query_selector (string selectors) throws GLib.Error {
    return null; // FIXME
  }
  public DomNodeList query_selector_all (string selectors) throws GLib.Error  {
    return null; // FIXME
  }
  // DomNonElementParentNode
  public DomElement? get_element_by_id (string element_id) throws GLib.Error {
    var l = this.get_elements_by_property_value ("id", element_id);
    if (l.size > 0) return (DomElement) l[0];
    return null;
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
    return new HtmlDocument (); // FIXME:
  }
}


public class GXml.GomDocumentType : GXml.GomNode,
                                  GXml.DomNode,
                                  GXml.DomChildNode,
                                  GXml.DomDocumentType
{
  protected string _name = "";
  protected string _public_id = "";
  protected string _system_id = "";

  public  new string name { get { return _name; } }
  public string public_id { get { return _public_id; } }
  public string system_id { get { return _system_id; } }

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
      var l = new DomElementList ();
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
    if (l.size > 0) return (DomElement) l[0];
    return null;
  }
}

