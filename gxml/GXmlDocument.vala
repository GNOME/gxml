/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GDocument.vala
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
using Xml;

/**
 * DOM4 class implemeting {@link GXml.Document} and {GXml.DomDocument} interface,
 * powered by libxml-2.0 library.
 *
 * This class use {@link Xml.TextWriter} to write down XML documents using
 * its contained {@link GXml.Node} children or other XML structures.
 */
public class GXml.GDocument : GXml.GNode,
                              GXml.Document,
                              GXml.DomParentNode,
                              GXml.DomNonElementParentNode,
                              GXml.DomDocument,
                              GXml.DomXMLDocument,
                              GXml.XPathContext
{
  protected Xml.Doc* doc;
  protected Xml.Buffer _buffer;

  public GDocument () {
    doc = new Xml.Doc ();
  }
  public GDocument.from_path (string path, int options = 0) throws GLib.Error {
    this.from_file (File.new_for_path (path), options);
  }

  public GDocument.from_uri (string uri, int options = 0) throws GLib.Error {
    this.from_file (File.new_for_uri (uri), options);
  }

  public GDocument.from_file (GLib.File file, int options = 0, Cancellable? cancel = null) throws GLib.Error {
    if (!file.query_exists ())
      throw new DocumentError.INVALID_DOCUMENT_ERROR (_("File doesn't exist"));
    var b = new MemoryOutputStream.resizable ();
    b.splice (file.read (), 0);
    this.from_string ((string) b.data, options);
  }

  public GDocument.from_string (string str, int options = 0) throws GLib.Error {
    Xml.reset_last_error ();
    doc = Xml.Parser.parse_memory (str, (int) str.length);
    var e = Xml.get_last_error ();
    if (e != null) {
      var errmsg = "Parser Error for string";
      string s = libxml2_error_to_string (e);
      if (s != null)
        errmsg = ".  ";
      throw new GXml.Error.PARSER (errmsg);
    }
    if (doc == null)
      doc = new Xml.Doc ();
  }
  public GDocument.from_stream (GLib.InputStream istream) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    if (b.data == null)
      throw new DocumentError.INVALID_DOCUMENT_ERROR (_("stream doesn't provide data"));
    this.from_string ((string) b.data);
  }
  public GDocument.from_doc (Xml.Doc doc) { this.doc = doc; }
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
  // GXml.Node
  public override Gee.Map<string,GXml.Node> attrs { owned get { return new GHashMapAttr (this, (Xml.Node*) doc) as Gee.Map<string,GXml.Node>; } }
  public override Gee.BidirList<GXml.Node> children_nodes { owned get { return new GListChildren (this, (Xml.Node*) doc) as Gee.BidirList<GXml.Node>; } }
  public override Gee.List<GXml.Namespace> namespaces { owned get { return new GListNamespaces (this, (Xml.Node*) doc) as Gee.List<GXml.Namespace>; } }
  public override GXml.Document document { get { return this; } }
  // GXml.Document
  public bool indent { get; set; default = false; }
  public bool ns_top { get; set; default = false; }
  public bool prefix_default_ns { get; set; default = false; }
  public bool backup { get; set; default = true; }
  public GLib.File file { get; set; }
  public GXml.Node root {
    owned get {
      var r = doc->get_root_element ();
      if (r == null) {
        int found = 0;
        for (int i = 0; i < children_nodes.size; i++) {
          GXml.Node n = children_nodes.get (i);
          if (n is GXml.Element) {
            found++;
            if (found == 1)
              return n;
          }
        }
        if (found > 1) {
          GLib.warning ("Document have more than one root GXmlElement. Using first found");
        }
      } 
      return new GElement (this, r);
    }
  }
  public GXml.Node GXml.Document.create_comment (string text)
  {
    var c = doc->new_comment (text);
    return new GComment (this, c);
  }
  public GXml.Node create_pi (string target, string data)
  {
    var pi = doc->new_pi (target, data);
    return new GProcessingInstruction (this, pi);
  }
  public GXml.Node GXml.Document.create_element (string name) throws GLib.Error
  {
    Xml.reset_last_error ();
    var el = doc->new_raw_node (null, name, null);
    var e = Xml.get_last_error ();
    if (e != null) {
      var errmsg = "Parser Error for string";
      string s = libxml2_error_to_string (e);
      if (s != null)
        errmsg = ".  ";
      throw new GXml.Error.PARSER (errmsg);
    }
    return new GElement (this, el);
  }
  public GXml.Node create_text (string text)
  {
    var t = doc->new_text (text);
    return new GText (this, t);
  }
  public GXml.Node create_cdata (string text)
  {
    var cd = doc->new_cdata_block (text, text.length);
    return new GCDATA (this, cd);
  }
  public override string to_string ()
  {
#if DEBUG
    GLib.message ("TDocument: to_string ()");
#endif
    Xml.Doc doc = null;
    Xml.TextWriter tw = new Xml.TextWriter.doc (out doc);
    try { TDocument.write_document (this, tw); } catch { return "<?xml version=\"0\"?>"; }
    string str;
    int size;
    doc.dump_memory (out str, out size);
    return str;
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
    return TDocument.tw_save_as (this, f, cancellable);
  }
  // DomDocument implementation
  protected GImplementation _implementation = new GImplementation ();
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
      return (DomElement) (this as Document).create_element (local_name);
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
      var e = (this as GXml.Document).create_element (qname);
      e.set_namespace (ns, prefix);
      return e as DomElement;
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
    return new GDocumentFragment (this);
  }
  public DomText create_text_node (string data) throws GLib.Error {
      return (DomText) create_text (data);
  }
  public DomComment GXml.DomDocument.create_comment (string data) throws GLib.Error {
      return (DomComment) create_comment (data);
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
        dst = (this as DomDocument).create_element (node.node_name);
        GXml.Node.copy (this, (GXml.Node) dst, (GXml.Node) node, deep);
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
      GXml.Node.copy (this, dst, (GXml.Node) node, true);
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
      var l = new DomElementList ();
      foreach (GXml.DomNode n in child_nodes) {
        if (n is DomElement) l.add ((DomElement) n);
      }
      return l;
    }
  }
  public DomElement? first_element_child {
    owned get { return (DomElement) (this as Document).children_nodes.first (); }
  }
  public DomElement? last_element_child {
    owned get { return (DomElement) (this as Document).children_nodes.last (); }
  }
  public int child_element_count { get { return children_nodes.size; } }

  public DomNodeList query_selector_all (string selectors) throws GLib.Error  {
    var cs = new CssSelectorParser ();
    cs.parse (selectors);
    var l = new GomNodeList ();
    foreach (GXml.Node e in children_nodes) {
      if (!(e is DomElement)) continue;
      if (cs.match (e as DomElement))
        l.add (e as DomNode);
      l.add_all ((e as DomElement).query_selector_all (selectors));
    }
    return l as DomNodeList;
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
                                    Gee.List<GXml.Namespace>? resolver = null)
                                    throws GXml.XPathError
  {
    XPathObject nullobj = null;
    if (document_element == null)
      return nullobj;
    return (document_element as XPathContext).evaluate (expression, resolver);
  }
}


public class GXml.GImplementation : GLib.Object, GXml.DomImplementation {
  public DomDocumentType
    create_document_type (string qualified_name, string public_id, string system_id)
        throws GLib.Error
  {
    return new GDocumentType.with_ids (qualified_name, public_id, system_id); // FIXME
  }
  public DomXMLDocument create_document (string? namespace,
                                         string? qualified_name,
                                         DomDocumentType? doctype = null)
                                         throws GLib.Error
  { return new GDocument (); } // FIXME
  public Document create_html_document (string title) {
    return new GHtmlDocument (); // FIXME:
  }
}


public class GXml.GDocumentType : GXml.GChildNode,
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

  public GDocumentType.with_name (string name) {
    _name = name;
    _public_id = "";
    _system_id = "";
  }
  public GDocumentType.with_ids (string name, string public_id, string system_id) {
    _name = name;
    _public_id = public_id;
    _system_id = system_id;
  }
  // DomChildNode implementation
  public new void remove () {
    get_internal_node ()->unlink ();
  }
}

public class GXml.GDocumentFragment : GXml.GDocument,
              GXml.DomDocumentFragment
{
  public GDocumentFragment (GXml.GDocument d)  {
      _doc = d._doc; // FIXME: https://www.w3.org/TR/dom/#dom-document-createdocumentfragment
  }
}


public class GXml.GDomNodeIterator : Object, GXml.DomNodeIterator {
  protected DomNode _root;
  protected DomNode _reference_node;
  protected bool _pointer_before_reference_node;
  protected int _what_to_show;
  protected DomNodeFilter _filter;
  public GDomNodeIterator (DomNode n, int what_to_show, DomNodeFilter filter) {
    _root = n;
    _what_to_show = what_to_show;
    _filter = filter;
  }
  public DomNode root { get { return _root; } }
  public DomNode reference_node { get { return _reference_node; } }
  public bool pointer_before_reference_node { get { return _pointer_before_reference_node; } }
  public int what_to_show { get { return _what_to_show; } }
  public DomNodeFilter? filter { get { return _filter; } }

  public DomNode? next_node() { return null; } // FIXME
  public DomNode? previous_node() { return null; } // FIXME

  public void detach() { return; } // FIXME
}


public class GXml.GDomTreeWalker : Object, GXml.DomTreeWalker {
  protected DomNode _root;
  protected int _what_to_show;
  protected DomNodeFilter? _filter;
  protected  DomNode _current_node;

  public DomNode root { get { return root; } }
  public int what_to_show { get { return _what_to_show; } }
  public DomNodeFilter? filter { get { return _filter; } }
  public DomNode current_node { get { return _current_node; } }

  public GDomTreeWalker (DomNode r, int w, DomNodeFilter f) {
    _root = r;
    _what_to_show = w;
    _filter = f;
  }

  public DomNode? parentNode() { return null; }// FIXME
  public DomNode? firstChild() { return null; } // FIXME
  public DomNode? lastChild() { return null; }// FIXME
  public DomNode? previousSibling() { return null; }// FIXME
  public DomNode? nextSibling() { return null; }// FIXME
  public DomNode? previousNode() { return null; }// FIXME
  public DomNode? nextNode() { return null; }// FIXME
}
