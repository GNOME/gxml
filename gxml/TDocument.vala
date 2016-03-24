/* TDocument.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
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
public class GXml.TDocument : GXml.TNode, GXml.Document
{
  protected Gee.ArrayList<GXml.Node> _namespaces;
  protected Gee.ArrayList<GXml.Node> _children;
  GXml.Element _root = null;
  construct {
    _name = "#document";
  }
  public TDocument () {}
  public TDocument.from_path (string path) {
    this.file = GLib.File.new_for_path (path);
    if (!file.query_exists ()) return;
    try { read_doc (this, file, null); } catch {}
    
  }

  public TDocument.from_uri (string uri) {
    this.from_file (File.new_for_uri (uri));
  }

  public TDocument.from_file (GLib.File file) {
    if (!file.query_exists ()) return;
    try { read_doc (this, file, null); } catch {}
    this.file = file;
  }

  public TDocument.from_stream (GLib.InputStream stream) {
    try { read_doc_stream (this, stream, null); } catch {}
  }

  public TDocument.from_string (string str) {
    var minput = new GLib.MemoryInputStream ();
    minput.add_data ((uint8[]) str.dup (), null);
    TDocument.from_stream (minput);
  }

  // GXml.Node
  public override Gee.List<GXml.Namespace> namespaces {
    owned get {
      if (_namespaces == null) _namespaces = new Gee.ArrayList<GXml.Node> ();
      return _namespaces.ref () as Gee.List<GXml.Namespace>;
    }
  }
  public override Gee.BidirList<GXml.Node> children {
    owned get {
      if (_children == null) _children  = new Gee.ArrayList<GXml.Node> ();
      return _children.ref () as Gee.BidirList<GXml.Node>;
    }
  }
  /**
   * {@inheritDoc}
   *
   * All namespaces are stored at {@link GXml.Node.namespaces} owned by
   * this {@link GXml.TDocument}.
   *
   * First namespace at list, is considered default one for the document. If
   * you haven't declared a namespace for this document or for its root element,
   * and you define one for a child node, this one is added for the first time
   * to document's namespaces, then this becomes the default namespace. To avoid
   * this, you should set a namespace for documento or its root, then childs.
   *
   * Default {@link GXml.Namespace} for a document is the first
   */
  public override bool set_namespace (string uri, string? prefix)
  {
    if (_namespaces == null) _namespaces = new Gee.ArrayList<GXml.Node> ();
    _namespaces.add (new TNamespace (this, uri, prefix));
    return true;
  }
  public override GXml.Document document { get { return this; } }
  // GXml.Document
  public bool indent { get; set; default = false; }
  public bool ns_top { get; set; default = false; }
  public bool prefix_default_ns { get; set; default = false; }
  public bool backup { get; set; default = true; }
  public GLib.File file { get; set; }
  public GXml.Node root {
    owned get {
      if (_children == null) _children  = new Gee.ArrayList<GXml.Node> ();
      if (_root == null) {
        int found = 0;
        for (int i = 0; i < children.size; i++) {
          GXml.Node n = children.get (i);
          if (n is GXml.Element) {
            found++;
            if (found == 1)
              _root = (GXml.Element) n;
          }
        }
        if (found > 1) {
          GLib.warning (_("Document have more than one root GXmlElement. Using first found"));
        }
      }
      return _root;
    }
  }
  public GXml.Node create_comment (string text)
  {
    var c = new TComment (this, text);
    return c;
  }
  public GXml.Node create_pi (string target, string data)
  {
    var pi = new TProcessingInstruction (this, target, data);
    return pi;
  }
  public GXml.Node create_element (string name) throws GLib.Error
  {
    if (Xmlx.validate_name (name, 1) != 0)
      throw new GXml.Error.PARSER (_("Invalid element name"));
    return new TElement (this, name);
  }
  public GXml.Node create_text (string text)
  {
    var t = new TText (this, text);
    return t;
  }
  public GXml.Node create_cdata (string text)
  {
    var t = new TCDATA (this, text);
    return t;
  }
  public bool save (GLib.Cancellable? cancellable = null)
    throws GLib.Error
    requires (file != null)
  {
    return save_as (file, cancellable);
  }
  [Deprecated (since="0.8.1", replacement="save_as")]
  public bool save_to (GLib.File f, GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    return save_as (f, cancellable);
  }
  public bool save_as (GLib.File f, GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    return tw_save_as (this, f, cancellable);
  }
  public static bool tw_save_as (GXml.Document doc, GLib.File f,
                                GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    var buf = new Xml.Buffer ();
    var tw = Xmlx.new_text_writer_memory (buf, 0);
    write_document (doc, tw);
    var s = new GLib.StringBuilder ();
    s.append (buf.content ());
    var b = new GLib.MemoryInputStream.from_data (s.data, null);
    var ostream = f.replace (null, doc.backup, GLib.FileCreateFlags.NONE, cancellable);
    ostream.splice (b, GLib.OutputStreamSpliceFlags.NONE);
    ostream.close ();
    return true;
  }
  public static void write_document (GXml.Document doc, Xml.TextWriter tw)
    throws GLib.Error
  {
    tw.start_document ();
    tw.set_indent (doc.indent);
    // Root
    if (doc.root == null) {
      tw.end_document ();
    }
    var dns = new ArrayList<string> ();
#if DEBUG
    GLib.message ("Starting writting Document child nodes");
#endif
    start_node (doc, tw, doc, false, ref dns);
#if DEBUG
    GLib.message ("Ending writting Document child nodes");
#endif
    tw.end_element ();
#if DEBUG
    GLib.message ("Ending Document");
#endif
    tw.end_document ();
    tw.flush ();
  }
  public static void start_node (GXml.Document doc, Xml.TextWriter tw,
                                GXml.Node node, bool root,
                                ref Gee.ArrayList<string> declared_ns)
    throws GLib.Error
  {
    int size = 0;
#if DEBUG
    GLib.message (@"Starting Node: start Node: '$(node.name)'");
#endif
    if (node is GXml.Element) {
#if DEBUG
      GLib.message (@"Starting Element... '$(node.name)'");
      GLib.message (@"Element Document is Null... '$((node.document == null).to_string ())'");
      GLib.message (@"Namespaces in Element... '$(node.namespaces.size)'");
#endif
      if (root) {
        if (node.document.namespaces.size > 0) {
          var dns = node.document.namespaces.get (0);
          assert (dns != null);
          if (doc.prefix_default_ns) {
            tw.start_element_ns (dns.prefix, node.name, dns.uri);
            declared_ns.add (dns.uri);
#if DEBUG
              GLib.message (@"Declared NS: '$(dns.uri)' Total declared = $(declared_ns.size.to_string ())");
#endif
          }
          else {
            tw.start_element (node.name);
            if (dns.prefix == null)
              tw.write_attribute ("xmlns",dns.uri);// Write default namespace no prefix
            else
              tw.write_attribute ("xmlns:"+dns.prefix,dns.uri);
            // Add to declared namespaces
            declared_ns.add (dns.uri);
#if DEBUG
              GLib.message (@"Declared NS: $(dns.uri) Total declared = $(declared_ns.size.to_string ())");
#endif
          }
          if (node.document.namespaces.size > 1 && node.document.ns_top) {
            for (int i = 1; i < node.document.namespaces.size; i++) {
              GXml.Namespace ns = node.document.namespaces.get (i);
              if (ns.prefix == null) continue;
              tw.write_attribute ("xmlns:"+ns.prefix, ns.uri);
              declared_ns.add (ns.uri);
#if DEBUG
              GLib.message (@"Declared NS: '$(ns.uri)' Total declared = $(declared_ns.size.to_string ())");
#endif
            }
          }
        }
        else
          tw.start_element (node.name);
      }
    else {
      if (node.namespaces.size > 0) {
#if DEBUG
      GLib.message (@"Starting Element: '$(node.name)' start with NS");
#endif
      if (node.document.ns_uri () == node.ns_uri ()) {
#if DEBUG
      GLib.message (@"Node '$(node.name)' Have Default NS");
#endif
        if (node.document.prefix_default_ns)  // Default NS at root element
          tw.start_element_ns (node.ns_prefix (), node.name, null);
        else // Don't prefix. Using default namespace and prefix_default_ns = false
          tw.start_element (node.name);
      }
      else {
#if DEBUG
      GLib.message (@"No default NS in use for Node '$(node.name)'. Ns = '$(node.ns_uri ())'");
#endif
        if (node.ns_prefix () == null && !declared_ns.contains (node.ns_uri ())) {// Its a default ns for children
          tw.start_element_ns (node.ns_prefix (), node.name, node.ns_uri ());
          declared_ns.add (node.ns_uri ());
#if DEBUG
          GLib.message (@"Declared NS: '$(node.ns_uri ())' Total declared = $(declared_ns.size.to_string ())");
#endif
        }
        else {
          if (node.document.ns_top || declared_ns.contains (node.ns_uri ()))
            tw.start_element_ns (node.ns_prefix (), node.name, null);
          else {
            tw.start_element_ns (node.ns_prefix (), node.name, node.ns_uri ());
            declared_ns.add (node.ns_uri ());
#if DEBUG
            GLib.message (@"Declared NS: $(node.ns_uri ()) Total declared = $(declared_ns.size.to_string ())");
#endif
          }
        }
      }
    } else {
#if DEBUG
      GLib.message (@"Starting Element: '$(node.name)' : start no NS: Check for default prefix_default_ns enabled");
#endif
        if (node.document.prefix_default_ns)
          tw.start_element_ns (node.document.ns_prefix (), node.name, null);
        else
          tw.start_element (node.name);
      }
    }
#if DEBUG
    GLib.message (@"Starting Element '$(node.name)': writting attributes");
#endif
    foreach (Namespace ns in node.namespaces) {
      // Declare all namespaces in node
#if DEBUG
      GLib.message ("Current Ns:"+ns.uri+":: on Node:"+node.name);
#endif
      if (declared_ns.contains (ns.uri)) continue;
      tw.write_attribute ("xmlns:"+ns.prefix, ns.uri);
      declared_ns.add (ns.uri);
    }
    foreach (GXml.Node attr in node.attrs.values) {
      if (attr.namespaces.size > 0) {
#if DEBUG
      GLib.message (@"Starting Element '$(node.name)': write attribute '$(attr.name)' with NS");
#endif
        if (!declared_ns.contains (attr.ns_uri ())) {
          size += tw.write_attribute_ns (attr.ns_prefix (), attr.name, attr.ns_uri (), attr.value);
          declared_ns.add (attr.ns_uri ());
#if DEBUG
          GLib.message (@"Declared NS: $(attr.ns_uri ()) Total declared = $(declared_ns.size.to_string ())");
#endif
        }
        else
          size += tw.write_attribute_ns (attr.ns_prefix (), attr.name, null, attr.value);
      }
      else {
#if DEBUG
        GLib.message (@"Starting Element '$(node.name)': write attribute '$(attr.name)' no NS");
#endif
        size += tw.write_attribute (attr.name, attr.value);
      }
      if (size > 1500)
        tw.flush ();
    }
  }
  // Non Elements
#if DEBUG
    GLib.message (@"Starting Element: writting Node '$(node.name)' childs");
#endif
    foreach (GXml.Node n in node.childs) {
#if DEBUG
      GLib.message (@"Child Node is: $(n.get_type ().name ())");
#endif
      if (n is GXml.Element) {
#if DEBUG
      GLib.message (@"Starting Child Element: writting Node '$(n.name)'");
#endif
        if (node.namespaces.size > 0) {
          if (node.document.namespaces.size > 0)
            if (node.ns_uri () != node.document.ns_uri ())
              if (n.namespaces.size == 0 && node.ns_prefix == null) // Apply parent ns
                n.set_namespace (node.ns_uri (), node.ns_prefix ());
        }
        if (node is GXml.Document) {
#if DEBUG
          GLib.message ("Found Root Node in Document. Starting Root node");
#endif
          start_node (doc, tw, n, true, ref declared_ns);
        }
        else
          start_node (doc, tw, n, false, ref declared_ns);
        size += tw.end_element ();
        if (size > 1500)
          tw.flush ();
      }
      if (n is GXml.Text) {
      //GLib.message ("Writting Element's contents");
      size += tw.write_string (n.value);
      if (size > 1500)
        tw.flush ();
      }
      if (n is GXml.Comment) {
#if DEBUG
      GLib.message (@"Starting Child Element: writting Comment '$(n.value)'");
#endif
        size += tw.write_comment (n.value);
        if (size > 1500)
          tw.flush ();
      }
      if (n is GXml.CDATA) {
#if DEBUG
      GLib.message (@"Starting Child Element: writting CDATA '$(n.value)'");
#endif
        size += Xmlx.text_writer_write_cdata (tw, n.value);
        if (size > 1500)
          tw.flush ();
      }
      if (n is GXml.ProcessingInstruction) {
  #if DEBUG
      GLib.message (@"Starting Child Element: writting ProcessingInstruction '$(n.value)'");
  #endif
        size += Xmlx.text_writer_write_pi (tw, ((ProcessingInstruction) n).target, ((ProcessingInstruction) n).data);
        if (size > 1500)
          tw.flush ();
      }
    }
  }
  public override string to_string ()
  {
#if DEBUG
    GLib.message ("TDocument: to_string ()");
#endif
    Xml.Doc doc = new Xml.Doc ();
    Xml.TextWriter tw = Xmlx.new_text_writer_doc (ref doc);
    write_document (this, tw);
    string str;
    int size;
    doc.dump_memory (out str, out size);
    return str;
  }
  /**
   * Enum for {@link Xml.TextReader} flag on parsing.
   */
  public enum ReadType {
    NEXT,
    CONTINUE,
    STOP
  }
  /**
   * Delegate function to control parsing of XML documents. Return {@link ReadType.NEXT}
   * to skip all children nodes of current {@link GXml.Node}; {@link ReadType.CONTINUE}
   * or {@link ReadType.STOP} to parse next child or node on reading.
   *
   * While you get the current {@link Xml.TextReader} used in parsing, you can control
   * next action to take depending on current node.
   */
  public delegate ReadType ReadTypeFunc (GXml.Node node, TextReader tr);
  /**
   * Read a {@link GXml.Document} from a {@link GLib.File}, parsing is controller
   * using {@link ReadTypeFunc}, if null it parse all nodes.
   */
  public static void read_doc (GXml.Document doc, GLib.File file, ReadTypeFunc? rtfunc = null) throws GLib.Error {
    if (!file.query_exists ())
      throw new GXml.DocumentError.INVALID_FILE (_("File doesn't exists"));
    read_doc_stream (doc, file.read (), rtfunc);
  }
  /**
   * Reads document from {@link GLib.InputStream} objects.
   */
  public static void read_doc_stream (GXml.Document doc, GLib.InputStream istream, ReadTypeFunc? rtfunc = null) {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    var tr = new TextReader.for_memory ((char[]) b.data, (int) b.get_data_size (), "/memory");
    GXml.Node current = null;
    while (read_node (doc, tr, rtfunc) == ReadType.CONTINUE);
  }
  /**
   * Parse current node in {@link Xml.TextReader}.
   *
   * Returns: a {@link GXml.Node} respresenting current parsed one.
   */
  public static ReadType read_node (GXml.Node node,
                                      Xml.TextReader tr,
                                      ReadTypeFunc? rntfunc = null) throws GLib.Error {
    GXml.Node n = null;
    string prefix, nsuri;
    ReadType rt = ReadType.CONTINUE;
    if (rntfunc != null) rt = rntfunc (node, tr);
    if (rt == ReadType.CONTINUE)
      if (tr.read () != 1) return ReadType.STOP;
    if (rt == ReadType.NEXT)
      if (tr.next () != 1) return ReadType.STOP;
    var t = tr.node_type ();
#if DEBUG
    GLib.message ("ReadNode: Current Node:"+node.name);
#endif
    switch (t) {
    case Xml.ReaderType.NONE:
#if DEBUG
      GLib.message ("Type NONE");
#endif
      if (tr.read () != 1) return ReadType.STOP;
      break;
    case Xml.ReaderType.ELEMENT:
      bool isempty = (tr.is_empty_element () == 1);
#if DEBUG
      if (isempty) GLib.message ("Is Empty node:"+node.name);
      GLib.message ("ReadNode: Element: "+tr.const_local_name ());
#endif
      n = node.document.create_element (tr.const_local_name ());
      ReadType nrt = ReadType.CONTINUE;
      if (rntfunc != null) nrt = rntfunc (n, tr);
      if (nrt == ReadType.NEXT)
        tr.next ();
      if (nrt == ReadType.CONTINUE)
        node.children.add (n);
#if DEBUG
      GLib.message ("ReadNode: next node:"+n.to_string ());
      GLib.message ("ReadNode: next node attributes:"+(tr.has_attributes ()).to_string ());
#endif
      prefix = tr.prefix ();
      if (prefix != null) {
        nsuri = tr.lookup_namespace (prefix);
        if (nsuri != null) {
          n.set_namespace (nsuri, prefix);
#if DEBUG
          GLib.message ("Number of NS in node: "+n.namespaces.size.to_string ());
#endif
        }
      }
      var nattr = tr.attribute_count ();
#if DEBUG
      GLib.message ("Number of Attributes:"+nattr.to_string ());
#endif
      for (int i = 0; i < nattr; i++) {
        var c = tr.move_to_attribute_no (i);
#if DEBUG
        GLib.message ("Current Attribute: "+i.to_string ());
        if (c != 1) GLib.message ("Fail to move to attribute number: "+i.to_string ());
#endif
        if (tr.is_namespace_decl () == 1) {
#if DEBUG
          GLib.message ("Is Namespace Declaration...");
#endif
          string nsp = tr.const_local_name ();
          tr.read_attribute_value ();
          if (tr.node_type () == Xml.ReaderType.TEXT) {
            nsuri = tr.read_string ();
            n.set_namespace (nsuri,nsp);
#if DEBUG
            GLib.message ("Number of NS in node: "+n.namespaces.size.to_string ());
#endif
          }
        } else {
          var attrname = tr.const_local_name ();
          prefix = tr.prefix ();
#if DEBUG
          GLib.message ("Attribute: "+tr.const_local_name ());
#endif
          tr.read_attribute_value ();
          if (tr.node_type () == Xml.ReaderType.TEXT) {
            var attrval = tr.read_string ();
#if DEBUG
            GLib.message ("Attribute:"+attrname+" Value: "+attrval);
#endif
            if (prefix != null) {
              nsuri = tr.lookup_namespace (prefix);
              if (nsuri != null) {
#if DEBUG
                GLib.message ("Setting a NS Attribute: "+prefix+":"+attrname);
#endif
                (n as GXml.Element).set_ns_attr (new TNamespace (n.document, nsuri, prefix), attrname, attrval);
              }
            } else
              (n as GXml.Element).set_attr (attrname, attrval);
          }
        }
      }
      if (isempty) return ReadType.CONTINUE;
      while (read_node (n, tr, rntfunc) == ReadType.CONTINUE);
#if DEBUG
      GLib.message ("Current Document: "+node.document.to_string ());
#endif
      break;
    case Xml.ReaderType.ATTRIBUTE:
#if DEBUG
      GLib.message ("Type ATTRIBUTE");
#endif
      break;
    case Xml.ReaderType.TEXT:
      var txtval = tr.read_string ();
#if DEBUG
      GLib.message ("Type TEXT");
      GLib.message ("ReadNode: Text Node : '"+txtval+"'");
#endif
      n = node.document.create_text (txtval);
      node.children.add (n);
      break;
    case Xml.ReaderType.CDATA:
      var cdval = tr.value ();
#if DEBUG
      GLib.message ("Type CDATA");
      GLib.message ("ReadNode: CDATA Node : '"+cdval+"'");
#endif
      n = node.document.create_cdata (cdval);
      node.children.add (n);
      break;
    case Xml.ReaderType.ENTITY_REFERENCE:
#if DEBUG
      GLib.message ("Type ENTITY_REFERENCE");
#endif
      break;
    case Xml.ReaderType.ENTITY:
#if DEBUG
      GLib.message ("Type ENTITY");
#endif
      break;
    case Xml.ReaderType.PROCESSING_INSTRUCTION:
      var pit = tr.const_local_name ();
      var pival = tr.value ();
#if DEBUG
      GLib.message ("Type PROCESSING_INSTRUCTION");
      GLib.message ("ReadNode: PI Node : '"+pit+"' : '"+pival+"'");
#endif
      n = node.document.create_pi (pit,pival);
      node.children.add (n);
      break;
    case Xml.ReaderType.COMMENT:
      var commval = tr.value ();
#if DEBUG
      GLib.message ("Type COMMENT");
      GLib.message ("ReadNode: Comment Node : '"+commval+"'");
#endif
      n = node.document.create_comment (commval);
      node.children.add (n);
      break;
    case Xml.ReaderType.DOCUMENT:
#if DEBUG
      GLib.message ("Type DOCUMENT");
#endif
      break;
    case Xml.ReaderType.DOCUMENT_TYPE:
#if DEBUG
      GLib.message ("Type DOCUMENT_TYPE");
#endif
      break;
    case Xml.ReaderType.DOCUMENT_FRAGMENT:
#if DEBUG
      GLib.message ("Type DOCUMENT_FRAGMENT");
#endif
      break;
    case Xml.ReaderType.NOTATION:
#if DEBUG
      GLib.message ("Type NOTATION");
#endif
      break;
    case Xml.ReaderType.WHITESPACE:
#if DEBUG
      GLib.message ("Type WHITESPACE");
#endif
      break;
    case Xml.ReaderType.SIGNIFICANT_WHITESPACE:
#if DEBUG
      GLib.message ("Type SIGNIFICANT_WHITESPACE");
#endif
      break;
    case Xml.ReaderType.END_ELEMENT:
#if DEBUG
      GLib.message ("Type END_ELEMENT");
#endif
      return ReadType.STOP;
    case Xml.ReaderType.END_ENTITY:
#if DEBUG
      GLib.message ("Type END_ENTITY");
#endif
      return ReadType.STOP;
    case Xml.ReaderType.XML_DECLARATION:
#if DEBUG
      GLib.message ("Type XML_DECLARATION");
#endif
      break;
    }
    return ReadType.CONTINUE;
  }
}
