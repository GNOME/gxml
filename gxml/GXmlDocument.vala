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
 * Class implemeting {@link GXml.Document} interface, not tied to libxml-2.0 library.
 *
 * This class use {@link Xml.TextWriter} to write down XML documents using
 * its contained {@link GXml.Node} childs or other XML structures.
 */
public class GXml.GDocument : GXml.GNode, GXml.Document, GXml.DomDocument
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
    Xmlx.reset_last_error ();
    doc = Xml.Parser.parse_memory (str, (int) str.length);
    var e = Xmlx.get_last_error ();
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
  public override Gee.Map<string,GXml.Node> attrs { owned get { return new GHashMapAttr (this, (Xml.Node*) doc); } }
  public override Gee.BidirList<GXml.Node> children { owned get { return new GListChildren (this, (Xml.Node*) doc); } }
  public override Gee.List<GXml.Namespace> namespaces { owned get { return new GListNamespaces (this, (Xml.Node*) doc); } }
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
        for (int i = 0; i < childs.size; i++) {
          GXml.Node n = childs.get (i);
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
    Xmlx.reset_last_error ();
    var el = doc->new_raw_node (null, name, null);
    var e = Xmlx.get_last_error ();
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
    Xml.Doc doc = new Xml.Doc ();
    Xml.TextWriter tw = Xmlx.new_text_writer_doc (ref doc);
    TDocument.write_document (this, tw);
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
  protected Implementation _implementation = new Implementation ();
  protected string _url = "";
  protected string _document_uri = "";
  protected string _origin = "";
  protected string _compat_mode = "";
  protected string _character_set = "";
  protected string _content_type = "";
  public DomImplementation implementation { get { return _implementation; } }
  public string url { get { return _url; } }
  public string document_uri { get { return _document_uri; } }
  public string origin { get { return _origin; } }
  public string compat_mode { get { return _compat_mode; } }
  public string character_set { get { return _character_set; } }
  public string content_type { get { return _content_type; } }

  protected DomDocumentType _doctype = null;
  public DomDocumentType? doctype { get { return _doctype; } }
  public DomElement? document_element { get { return root; } }

  public DomElement GXml.Document.create_element (string local_name) throws GLib.Error {
      return create_element_node (local_name);
  }
  public DomElement create_element_ns (string? ns, string qualified_name) throws GLib.Error
  {
      var e = create_element (qualified_name);
      e.set_namespace (ns, null);
      return e;
  }

  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
      return get_elements_by_name (local_name);
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? ns, string local_name) {
      return get_elements_by_name_ns (local_name, ns);
  }
  public DomHTMLCollection get_elements_by_class_name(string class_names) {
      return get_elements_by_property_value ("class", class_names);
  }

  public DomDocumentFragment create_document_fragment() {
    return new GDocumentFragment (this);
  }
  public DomText create_text_node (string data) {
      return create_text (data);
  }
  public DomComment GXml.DomDocument.create_comment (string data) {
      return create_comment_node (data);
  }
  public DomProcessingInstruction create_processing_instruction (string target, string data) {
      return create_pi (target, data);
  }

  public DomNode import_node (DomNode node, bool deep = false) throws GLib.Error {
      if (node is DomDocument)
        throw new GXml.DomError (GXml.DomError.NOT_SUPPORTED_ERROR,_("Can't import a Document"));
      var dst = this.create_element_node ();
      GXml.Node.copy (this, dst, node, deep);
      return dst;
  }
  public DomNode adopt_node (DomNode node) throws GLib.Error {
      if (node is DomDocument)
        throw new GXml.DomError (GXml.DomError.NOT_SUPPORTED_ERROR,_("Can't adopt a Document"));
      var dst = this.create_element_node (node.node_name);
      GXml.Node.copy (this, dst, node, deep);
      if (node.parent != null)
        node.parent.children.remove_at (node.parent.children.index_of (node));
      return dst;
  }

  protected GLib.Object _constructor;
  public abstract DomEvent create_event (string iface) {
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
  }

  public DomRange create_range() {
      return new GDomRange ();
  }

  // NodeFilter.SHOW_ALL = 0xFFFFFFFF
  public DomNodeIterator create_node_iterator (DomNode root, ulong what_to_show = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null)
  {
    return new GDomNodeIterator (root, what_to_show, filter);
  }
  public DomTreeWalker create_tree_walker (DomNode root, ulong what_to_show = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null) {
      return new GDomTreeWolker (root, what_to_show, filter);
  }
}


public class GXml.GImplementation : GLib.Object, GXml.DomImplementation {
  public abstract DomDocumentType
    create_document_type (string qualified_name, string public_id, string system_id)
        throws GLib.Error
  {

  }
  public abstract DomXMLDocument create_document (string? namespace, string? qualified_name, DocumentType? doctype = null) throws GLib.Error;
  public abstract Document create_html_document (string title);

  public virtual bool has_feature() { return true; } // useless; always returns true
}


public class GXml.GDocumentType : GXml.GNode, GXml.DomNode, GXml.DomChildNode, GXml.DomDocumentType {
  protected string _name = "";
  protected string _public_id = "";
  protected string _system_id = "";

  public string name { get { return _name; } }
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
  public void remove () {
    get_internal_node ()->unlink ();
  }
}

public class GXml.GDocumentFragment : GXml.GNode, GXml.DomDocumentFragment {
    public GDocumentFragment (GXml.GDocument doc)  {
        document = doc;
    }
}


public class GXml.GDomNodeIterator : Object, GXml.DomNodeIterator {
  protected DomNode _root;
  protected DomNode _reference_node;
  protected DomNode _pointer_before_reference_node;
  protected DomNode _what_to_show;
  protected DomFilter _filter;
  public GDomNodeIterator (DomNode n, what_to_show, filter) {
    _root = n;
    _what_to_show = what_to_show;
    _filter = filter;
  }
  public DomNode root { get { return _root; } }
  public DomNode reference_node { get { return _reference_node; }} }
  public bool pointer_before_reference_node { get { return _pointer_before_reference_node; } };
  public ulong what_to_show { get { return _what_to_show; } }
  public DomNodeFilter? filter { get { return _filter; } }

  public DomNode? next_node() { return null; // FIXME;}
  public DomNode? previous_node() { return null; // FIXME;}

  public void detach() { return null; // FIXME;}
}


public class GXml.GDomTreeWalker : Object, GXml.DomTreeWalker {
  protected DomNode root { get; }
  protected ulong _what_to_show;
  protected DomNodeFilter? _filter;
  protected  DomNode _current_node;

  public DomNode root { get; }
  public ulong what_to_show { get; }
  public DomNodeFilter? filter { get; }
  public DomNode current_node { get; }

  public DomNode? parentNode() { return null; // FIXME: }
  public DomNode? firstChild() { return null; // FIXME: }
  public DomNode? lastChild() { return null; // FIXME: }
  public DomNode? previousSibling() { return null; // FIXME: }
  public DomNode? nextSibling() { return null; // FIXME: }
  public DomNode? previousNode() { return null; // FIXME: }
  public DomNode? nextNode() { return null; // FIXME: }
}
