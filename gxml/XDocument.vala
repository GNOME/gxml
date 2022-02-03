/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* XDocument.vala
 *
 * Copyright (C) 2016-2019  Daniel Espinosa <esodan@gmail.com>
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
using Xml;

/**
 * DOM4 class implementing {@link GXml.DomDocument} and {GXml.DomDocument} interface,
 * powered by libxml-2.0 library.
 *
 * This class use {@link Xml.TextWriter} to write down XML documents using
 * its contained {@link GXml.DomNode} children or other XML structures.
 */
public class GXml.XDocument : GXml.XNode,
                              GXml.DomParentNode,
                              GXml.DomNonElementParentNode,
                              GXml.DomDocument,
                              GXml.DomXMLDocument,
                              GXml.XPathContext
{
  internal Xml.Doc* doc;
  protected Xml.Buffer _buffer;
  protected Parser _parser = null;
  
  construct {
    _node = null;
  }

  ~XDocument () {
      delete doc;
  }

  public XDocument () {
    doc = new Xml.Doc ();
  }
  public XDocument.from_path (string path, int options = 0) throws GLib.Error {
    this.from_file (File.new_for_path (path), options);
  }

  public XDocument.from_uri (string uri, int options = 0) throws GLib.Error {
    this.from_file (File.new_for_uri (uri), options);
  }

  public XDocument.from_file (GLib.File file, int options = 0, Cancellable? cancel = null) throws GLib.Error {
    if (!file.query_exists ())
      throw new DomDocumentError.INVALID_DOCUMENT_ERROR (_("File doesn't exist"));
    var parser = new XdParser (this);
    parser.cancellable = cancel;
    parser.read_stream (file.read ());
  }

  public XDocument.from_string (string str, int options = 0) throws GLib.Error {
    var parser = new XdParser (this);
    parser.read_string (str);
  }
  public XDocument.from_stream (GLib.InputStream istream) throws GLib.Error {
    var parser = new XdParser (this);
    parser.read_stream (istream);
  }
  /**
   * Gigen {@link Xml.Doc} is owned by this
   */
  public XDocument.from_doc (Xml.Doc doc) {
    if (this.doc != null) {
      delete this.doc;
      this.doc = null;
    }

    this.doc = doc;
  }

  public Parser GXml.DomDocument.get_xml_parser () {
    if (_parser != null) {
      return _parser;
    }
    return new XdParser (this);
  }
  public void set_xml_parser (Parser parser) {
    _parser = parser;
  }

  // GXml.Node
  public override bool set_namespace (string uri, string? prefix)
  {
    var root = doc->get_root_element ();
    if (root != null) {
      var ns = root->new_ns (uri, prefix);
      return (ns != null);
    }
    return false;
  }
  // GXml.DomNode
  public override Gee.Map<string,GXml.DomNode> attrs { owned get { return new XHashMapAttr (this, (Xml.Node*) doc) as Gee.Map<string,GXml.DomNode>; } }
  public override Gee.BidirList<GXml.DomNode> children_nodes { owned get { return new XListChildren (this, (Xml.Node*) doc) as Gee.BidirList<GXml.DomNode>; } }
  public override GXml.DomDocument document { get { return this; } }
  // GXml.DomDocument
  public bool indent { get; set; default = false; }
  public bool ns_top { get; set; default = false; }
  public bool prefix_default_ns { get; set; default = false; }
  public bool backup { get; set; default = true; }
  public GLib.File file { get; set; }
  public GXml.DomNode root {
    owned get {
      var r = doc->get_root_element ();
      if (r == null) {
        int found = 0;
        for (int i = 0; i < children_nodes.size; i++) {
          GXml.DomNode n = children_nodes.get (i);
          if (n is GXml.DomElement) {
            found++;
            if (found == 1)
              return n;
          }
        }
        if (found > 1) {
          GLib.warning ("Document have more than one root GXmlElement. Using first found");
        }
      }
      return new XElement (this, r);
    }
  }
  public GXml.DomNode create_pi (string target, string data)
  {
    var pi = doc->new_pi (target, data);
    return new XProcessingInstruction (this, pi);
  }

  public GXml.DomNode create_text (string text)
  {
    var t = doc->new_text (text);
    var n = new XText (this, t);
    n.take_node ();
    return n;
  }
  public override string to_string ()
  {
    try {
      return write_string ();
    } catch (GLib.Error e) {
      warning (_("Error writing document to string: %s"), e.message);
      return "";
    }
  }
  /**
   * Uses libxml2 internal dump to memory function over owned
   */
  public string libxml_to_string () {
    string buffer;
    doc->dump_memory (out buffer);
    return buffer.dup ();
  }
  public virtual bool save (GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    return save_as (file, cancellable);
  }
  public virtual bool save_as (GLib.File f, GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    write_file (f, cancellable);
    return true;
  }
  // DomDocument implementation
  protected DomImplementation _implementation = new XImplementation ();
  protected string _url = "about:blank";
  protected string _origin = "";
  protected string _compat_mode = "";
  protected string _character_set = "utf-8";
  protected string _content_type = "application/xml";
  public DomImplementation implementation { get { return (DomImplementation) _implementation; } }
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
  public DomElement? document_element { owned get { return (DomElement) root; } }

  public DomElement GXml.DomDocument.create_element (string local_name) throws GLib.Error {
    Xml.reset_last_error ();
    var el = doc->new_raw_node (null, local_name, null);
    var e = Xml.get_last_error ();
    if (e != null) {
      var errmsg = "Parser Error for string";
      string s = libxml2_error_to_string (e);
      if (s != null)
        errmsg = ".  ";
      throw new GXml.Error.PARSER (errmsg);
    }
    
    var n = new XElement (this, el);
    n.take_node ();
    return n;
  }
  public DomElement GXml.DomDocument.create_element_ns (string? ns, string qualified_name) throws GLib.Error
  {
      string prefix = null;
      string qname = qualified_name;
      if (":" in qualified_name) {
        string[] s = qualified_name.split (":");
        if (s.length != 2) {
          throw new DomError.INVALID_CHARACTER_ERROR (_("Invalid element qualified name: multiple namespace prefixes"));
        }
        prefix = s[0];
        qname = s[1];
      }
      var e = ((GXml.DomDocument) this).create_element (qname);
      ((XElement) e).set_namespace (ns, prefix);
      ((XElement) e).take_node ();
      return e as DomElement;
  }

  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
      var l = new HTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_tag_name (local_name));
      return l;
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? ns, string local_name) {
      var l = new HTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_tag_name_ns (ns, local_name));
      return l;
  }
  public DomHTMLCollection get_elements_by_class_name(string class_names) {
      var l = new HTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_class_name (class_names));
      return l;
  }

  public DomDocumentFragment create_document_fragment() {
    return new XDocumentFragment (this);
  }
  public DomText create_text_node (string data) throws GLib.Error {
      return (DomText) create_text (data);
  }
  public DomComment GXml.DomDocument.create_comment (string data) throws GLib.Error {
    var c = doc->new_comment (data);
    return new XComment (this, c);
  }
  public DomProcessingInstruction create_processing_instruction (string target, string data) throws GLib.Error {
      return (DomProcessingInstruction) create_pi (target, data);
  }

  public DomNode import_node (DomNode node, bool deep = false) throws GLib.Error {
      if (node is DomDocument)
        throw new GXml.DomError.NOT_SUPPORTED_ERROR (_("Can't import a Document"));
      if (!(node is DomElement) && this.document_element == null)
        throw new GXml.DomError.HIERARCHY_REQUEST_ERROR (_("Can't import a non Element type node to a Document"));
      GXml.DomNode dst = null;
      if (node is DomElement) {
        dst = ((DomDocument) this).create_element (node.node_name);
        GXml.DomNode.copy (this, (GXml.DomNode) dst, (GXml.DomNode) node, deep);
        if (document_element == null) {
          this.append_child (dst);
          return dst;
        }
      }
      if (node is DomText)
        dst = this.create_text_node (((DomText) node).data);
      if (node is DomComment)
        dst = ((DomDocument) this).create_comment (((DomComment) node).data);
      if (node is DomProcessingInstruction)
        dst = this.create_processing_instruction (((DomProcessingInstruction) node).target, ((DomProcessingInstruction) node).data);
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
      GXml.DomNode.copy (this, dst as GXml.DomNode, (GXml.DomNode) node, true);
      if (node.parent_node != null)
        node.parent_node.child_nodes.remove_at (node.parent_node.child_nodes.index_of (node));
      if (this.document_element == null)
        this.append_child (dst as DomNode);
      else
        document_element.append_child (dst as DomNode);
      return (DomNode) dst;
  }

  protected GXml.DomEvent _constructor;
  public DomEvent create_event (string iface) {
      var s = iface.down ();
      if (s == "customevent") _constructor = new GXml.CustomEvent ();
      if (s == "event") _constructor = new GXml.CustomEvent ();
      if (s == "events") _constructor = new GXml.CustomEvent ();
      if (s == "htmlevents") _constructor = new GXml.CustomEvent ();
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
      return new GXml.Range (this);
  }

  // NodeFilter.SHOW_ALL = 0xFFFFFFFF
  public DomNodeIterator create_node_iterator (DomNode root, int what_to_show = (int) 0xFFFFFFFF)
  {
    return new NodeIterator (root, what_to_show);
  }
  public DomTreeWalker create_tree_walker (DomNode root, int what_to_show = (int) 0xFFFFFFFF) {
      return new TreeWalker (root, what_to_show);
  }
  // DomParentNode
  public DomHTMLCollection children {
    owned get {
      var l = new DomElementList ();
      foreach (GXml.DomNode n in child_nodes) {
        if (n is DomElement) l.add ((DomElement) n);
      }
      return l;
    }
  }
  public DomElement? first_element_child {
    owned get { return (DomElement) ((DomDocument) this).child_nodes.first (); }
  }
  public DomElement? last_element_child {
    owned get { return (DomElement) ((DomDocument) this).child_nodes.last (); }
  }
  public int child_element_count { get { return child_nodes.size; } }

  public DomNodeList query_selector_all (string selectors) throws GLib.Error  {
    var cs = new CssSelectorParser ();
    cs.parse (selectors);
    var l = new GXml.NodeList();
    foreach (GXml.DomNode e in children_nodes) {
      if (!(e is DomElement)) continue;
      if (cs.match (e as DomElement))
        l.add (e as DomNode);
      l.add_all (cs.query_selector_all (e as DomElement));
    }
    return l;
  }
  // DomNonElementParentNode
  public DomElement? get_element_by_id (string element_id) throws GLib.Error {
    var l = this.get_elements_by_property_value ("id", element_id);
    if (l.size > 0) return (DomElement) l[0];
    return null;
  }
  /**
   * {@link XPathContext} implementation.
   */
  public GXml.XPathObject evaluate (string expression,
                                    Gee.Map<string,string>? resolver = null)
                                    throws GXml.XPathObjectError
  {
    XPathObject nullobj = null;
    if (document_element == null)
      return nullobj;
    return ((XPathContext) document_element).evaluate (expression, resolver);
  }
}


internal class GXml.XImplementation : GLib.Object, GXml.DomImplementation {
  public DomDocumentType
    create_document_type (string qualified_name, string public_id, string system_id)
        throws GLib.Error
  {
    return new XDocumentType.with_ids (qualified_name, public_id, system_id); // FIXME
  }
  public DomXMLDocument create_document (string? namespace,
                                         string? qualified_name,
                                         DomDocumentType? doctype = null)
                                         throws GLib.Error
  { return new XDocument (); } // FIXME
  public DomDocument create_html_document (string title) {
    return new XHtmlDocument (); // FIXME:
  }
}


internal class GXml.XDocumentType : GXml.XChildNode,
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

  public XDocumentType.with_name (string name) {
    _name = name;
    _public_id = "";
    _system_id = "";
  }
  public XDocumentType.with_ids (string name, string public_id, string system_id) {
    _name = name;
    _public_id = public_id;
    _system_id = system_id;
  }
  // DomChildNode implementation
  public new void remove () {
    get_internal_node ()->unlink ();
  }
}

internal class GXml.XDocumentFragment : GXml.XDocument,
              GXml.DomDocumentFragment
{
  public XDocumentFragment (GXml.XDocument d)  {
      _doc = d._doc; // FIXME: https://www.w3.org/TR/dom/#dom-document-createdocumentfragment
  }
}

