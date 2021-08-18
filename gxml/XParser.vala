/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* XParser.vala
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
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;
using Xml;

/**
 * {@link Parser} implementation using libxml2 engine
 */
public class GXml.XParser : GLib.Object, GXml.Parser {
  private DomDocument _document;
  private DomNode _node;
  private TextReader tr;
  private Xml.TextWriter tw;
  private DataInputStream tistream;
  private GLib.HashTable<GLib.Type,GLib.HashTable<string,GLib.Type>> _types;

  public bool backup { get; set; }
  public bool indent { get; set; }
  public GLib.HashTable<GLib.Type,GLib.HashTable<string,GLib.Type>> types {
    get { return _types; }
  }

  public DomNode node { get { return _node; } }

  public Cancellable? cancellable { get; set; }


  public XParser (DomNode node) {
    _node = node;
    if (_node is DomDocument)
      _document = _node as DomDocument;
    else
      _document = _node.owner_document;
  }

  construct {
    backup = true;
    indent = false;
    cancellable = null;
    tistream = null;
    _types = new GLib.HashTable<GLib.Type,GLib.HashTable<string,GLib.Type>> (int_hash, int_equal);
  }

  public void write_stream (OutputStream stream) throws GLib.Error {
    var s = dump ();
    var b = new GLib.MemoryInputStream.from_data (s.data);
    stream.splice (b, GLib.OutputStreamSpliceFlags.NONE, cancellable);
    stream.close ();
    tw = null;
  }
  public async void write_stream_async (OutputStream stream) throws GLib.Error {
    var s = yield dump_async ();
    var b = new GLib.MemoryInputStream.from_data (s.data);
    yield stream.splice_async (b, GLib.OutputStreamSpliceFlags.NONE, 0, cancellable);
    tw = null;
  }

  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML
   */
  public InputStream
  create_stream () throws GLib.Error {
    var s = dump ();
    tw = null;
    return new GLib.MemoryInputStream.from_data (s.data);
  }
  /**
   * Creates asynchronically an {@link GLib.InputStream} to write a string representation
   * in XML
   */
  public async InputStream
  create_stream_async () throws GLib.Error {
    var s = yield dump_async ();
    tw = null;
    return new GLib.MemoryInputStream.from_data (s.data);
  }

  public string write_string () throws GLib.Error  {
    return dump ();
  }
  public async string write_string_async () throws GLib.Error  {
    return yield dump_async ();
  }
  public void read_string (string str) throws GLib.Error {
    if (str == "")
      throw new ParserError.INVALID_DATA_ERROR (_("Invalid document string, it is empty or is not allowed"));
    var stream = new GLib.MemoryInputStream.from_data (str.data);
    read_stream (stream);
  }
  public async void read_string_async (string str) throws GLib.Error {
    if (str == "")
      throw new ParserError.INVALID_DATA_ERROR (_("Invalid document string, it is empty or is not allowed"));
    var stream = new GLib.MemoryInputStream.from_data (str.data);
    Idle.add (read_string_async.callback);
    yield;
    yield read_stream_async (stream);
  }

  static int read_callback (void* context, [CCode (array_length=false)] char[] buffer, int len) {
    XParser *parser = (XParser*) context;
    if (parser->tistream == null) {
      warning (_("Invalid input stream to read data from"));
      return -1;
    }
    int dr = 0;
    try {
      int bs = (int) parser->tistream.get_buffer_size ();
      while (dr < len) {
        var r = parser->tistream.fill (bs > (len - dr) ? (len - dr) : bs,
                            parser->cancellable);
        if (r == 0) {
          break;
        }
        int bdr = 0;
        while (bdr < r) {
          buffer[dr+bdr] = (char) parser->tistream.read_byte (parser->cancellable);
          bdr++;
        }
        dr += bdr;
      }
    } catch (GLib.Error e) {
      message (_("Error reading stream: %s"), e.message);
      return -1;
    }
    return dr;
  }
  static int close_callback (void* context) {
    XParser *parser = (XParser*) context;
    if (parser->tistream == null) {
      return 0;
    }
    try {
      parser->tistream.close (parser->cancellable);
    } catch (GLib.Error e) {
      warning (_("Error closing stream: %s"), e.message);
      return -1;
    }
    return 0;
  }

  public void read_stream (GLib.InputStream istream) throws GLib.Error {
    this.cancellable = cancellable;
    tistream = new DataInputStream (istream);
    tr = new TextReader.for_io (read_callback,
                              close_callback,
                              this,
                              "", null,
                             ParserOption.NOERROR);
    _node.freeze_notify ();
    read_node (_node);
    _node.thaw_notify ();
    tr = null;
    tistream = null;
  }
  public async void read_stream_async (GLib.InputStream istream) throws GLib.Error {
    this.cancellable = cancellable;
    tistream = new DataInputStream (istream);
    Idle.add (read_stream_async.callback);
    yield;
    tr = new TextReader.for_io (read_callback,
                              close_callback,
                              this,
                              "", null,
                             ParserOption.NOERROR);
    _node.freeze_notify ();
    read_node (_node);
    _node.thaw_notify ();
    tr = null;
  }

  /**
   * Reads a node using current parser.
   */
  public void read_node (DomNode node) throws GLib.Error {
    if (tr == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    move_next_node ();
    if (node is DomElement) {
      var element_node= (DomElement) node;
      while (true) {
        if (current_is_element ()
            &&
            (current_node_name ().down () == element_node.local_name.down ())) {
          break;
        }
        if (!current_is_document ()) {
          read_child_node (_document);
        }
        if (!move_next_node ()) break;
      }
      read_element (element_node);
    }
    if (current_is_element () && (node is DomDocument))
      read_child_element (node);
    else {
      if (node is GXml.DomDocument) {
        read_child_nodes (node);
      }
      if (node is GXml.Element) {
        if (((GXml.Element) node).parse_children)
          read_child_nodes (node);
        else {
          ((GXml.Element) node).unparsed = read_unparsed ();
          //warning ("Unparsed text: "+((GXml.Object) node).unparsed);
          move_next_node ();
        }
      }
    }
  }
  public void read_child_nodes_string (string str) throws GLib.Error {
    tr = new TextReader.for_memory ((char[]) str.data, (int) str.data.length, "/gxml_memory");
    read_child_nodes (_node);
    tr = null;
  }
  public void read_child_nodes_stream (GLib.InputStream istream) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    tr = new TextReader.for_memory ((char[]) b.data, (int) b.get_data_size (), "/gxml_memory");
    read_child_nodes (_node);
    tr = null;
  }
  public async void read_child_nodes_stream_async (GLib.InputStream istream) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    Idle.add (read_child_nodes_stream_async.callback);
    yield;
    tr = new TextReader.for_memory ((char[]) b.data, (int) b.get_data_size (), "/gxml_memory");
     Idle.add (read_child_nodes_stream_async.callback);
    yield;
    yield read_child_nodes_async (_node);
    tr = null;
  }
  /**
   * Reads all child nodes as string
   */
  public string read_unparsed () throws GLib.Error {
    if (tr == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    string s = tr.read_inner_xml ();
    return s;
  }
  /**
   * Use parser to go to next parsed node.
   */
  public bool move_next_node () throws GLib.Error {
    if (tr == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    int res = tr.read ();
    if (res == -1)
      throw new ParserError.INVALID_DATA_ERROR (_("Can't read node data at line: %d"), tr.get_parser_line_number ());
    if (res == 0) {
      return false;
    }
    return true;
  }
  /**
   * Check if current node has children.
   */
  public bool current_is_empty_element () {
    if (tr == null) return false;
    // TODO:  throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    return tr.is_empty_element () == 1;
  }
  /**
   * Check if current node found by parser, is a {@link DomElement}
   */
  public bool current_is_element () {
    if (tr == null) return false;
    // TODO:  throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    return (tr.node_type () == Xml.ReaderType.ELEMENT);
  }
  /**
   * Check if current node found by parser, is a {@link DomDocument}
   */
  public bool current_is_document() {
    if (tr == null) return false;
    // TODO:  throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    return (tr.node_type () == Xml.ReaderType.DOCUMENT);
  }
  /**
   * Returns current node's local name, found by parser.
   */
  public string current_node_name () {
    if (tr == null) return "";
    // TODO:  throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    return tr.const_local_name ();
  }
  /**
   * Creates a new {@link DomElement} and append it as a child of parent.
   *

   * It should set current namespace, taking care about set namespace prefix.
   */
  public DomElement? create_element (DomNode parent) throws GLib.Error {
    if (tr == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    DomElement n = null;
    string prefix = tr.prefix ();
    if (prefix != null) {
      string nsuri = tr.lookup_namespace (prefix);
      n = _document.create_element_ns (nsuri, tr.prefix () +":"+ tr.const_local_name ());
    } else
      n = _document.create_element (tr.const_local_name ());
    parent.append_child (n);
    return n;
  }
  public void read_element (DomElement element) throws GLib.Error {
    if (tr == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    var nattr = tr.attribute_count ();
    for (int i = 0; i < nattr; i++) {
      var c = tr.move_to_attribute_no (i);
      if (c != 1) {
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Parsing ERROR: Fail to move to attribute number: %i at line: %d"), i, tr.get_parser_line_number ());
      }
      if (tr.is_namespace_decl () == 1) {
        string nsp = tr.const_local_name ();
        string aprefix = tr.prefix ();
        tr.read_attribute_value ();
        if (tr.node_type () == Xml.ReaderType.TEXT) {
          string ansuri = tr.read_string ();
          string ansp = nsp;
          if (nsp != "xmlns")
            ansp = aprefix+":"+nsp;
          element.set_attribute_ns ("http://www.w3.org/2000/xmlns/",
                                               ansp, ansuri);
        }
      } else {
        var attrname = tr.const_local_name ();
        string prefix = tr.prefix ();
        if (prefix == null && ":" in attrname) {
          string[] sname = attrname.split (":");
          prefix = sname[0];
          attrname = sname[1];
        }
        tr.read_attribute_value ();
        if (tr.node_type () == Xml.ReaderType.TEXT) {
          var attrval = tr.read_string ();
          string attn = attrname;
          if (prefix != null) attn = prefix+":"+attrname;
          if (prefix != null) {
            string nsuri = null;
            if (prefix == "xmlns")
              nsuri = "http://www.w3.org/2000/xmlns/";
            if (prefix == "xml")
              nsuri = "http://www.w3.org/XML/1998/namespace/";
            else if (prefix == "xsi")
              nsuri = "http://www.w3.org/2001/XMLSchema-instance/";
            else
              nsuri = tr.lookup_namespace (prefix);
            element.set_attribute_ns (nsuri, prefix+":"+attrname, attrval);
          } else {
            element.set_attribute (attrname, attrval);
          }
        }
      }
    }
  }
  public bool read_child_node (DomNode parent) throws GLib.Error {
    if (tr == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextReader was set"));
    DomNode n = null;
    bool ret = true;
    var t = tr.node_type ();
    switch (t) {
    case Xml.ReaderType.NONE:
      move_next_node ();
      break;
    case Xml.ReaderType.ATTRIBUTE:
      break;
    case Xml.ReaderType.TEXT:
      var txtval = tr.read_string ();
      if (!(parent is DomDocument)) {
        n = _document.create_text_node (txtval);
        parent.append_child (n);
      }
      break;
    case Xml.ReaderType.CDATA:
      break;
    case Xml.ReaderType.ENTITY_REFERENCE:
      break;
    case Xml.ReaderType.ENTITY:
      break;
    case Xml.ReaderType.PROCESSING_INSTRUCTION:
      var pit = tr.const_local_name ();
      var pival = tr.value ();
      n = _document.create_processing_instruction (pit,pival);
      parent.append_child (n);
      break;
    case Xml.ReaderType.COMMENT:
      var commval = tr.value ();
      n = _document.create_comment (commval);
      parent.append_child (n);
      break;
    case Xml.ReaderType.DOCUMENT:
      ret = false;
      break;
    case Xml.ReaderType.DOCUMENT_TYPE:
      var bf = new Xml.Buffer ();
      var xn = tr.current_node ();
      bf.node_dump (xn->doc, xn, 0, 0);
      string sids = bf.content ();
      var reg = new GLib.Regex ("^<!DOCTYPE\\s*((([a-z]*|[A-Z]*))|(([a-z]*|[A-Z]*)\\s*PUBLIC\\s*(?<pid> \".*\")\\s*(?<sid> \".*\")))\\s*>");
			GLib.MatchInfo info = null;
			if (!reg.match (sids, RegexMatchFlags.ANCHORED, out info)) {
				warning (_("Invalid sequence for document type definition: "+sids));
				return false;
			}
			string pid = info.fetch_named ("pid");
			if (pid == "") pid = null;
			if (pid != null) pid = pid.replace ("\"","").chomp ().strip ();
			string sid = info.fetch_named ("sid");
			if (sid == "") sid = null;
			if (sid != null) sid = sid.replace ("\"","").chomp ().strip ();
      n = new GXml.DocumentType (_document, tr.const_local_name (), pid, sid);
      parent.append_child (n);
      break;
    case Xml.ReaderType.DOCUMENT_FRAGMENT:
      ret = false;
      break;
    case Xml.ReaderType.NOTATION:
      break;
    case Xml.ReaderType.WHITESPACE:
      break;
    case Xml.ReaderType.SIGNIFICANT_WHITESPACE:
      var stxtval = tr.read_string ();
      if (!(parent is DomDocument)) {
        n = _document.create_text_node (stxtval);
        parent.append_child (n);
      }
      break;
    case Xml.ReaderType.END_ELEMENT:
      ret = false;
      break;
    case Xml.ReaderType.END_ENTITY:
      ret = false;
      break;
    case Xml.ReaderType.XML_DECLARATION:
      ret = false;
      break;
    case Xml.ReaderType.ELEMENT:
      ret = false;
      break;
    }
    return ret;
  }

  private string dump () throws GLib.Error {
    int size;
    Xml.Doc doc = null;
    tw = new TextWriter.doc (out doc);
    if (_node is DomDocument) tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (_node is DomDocument) {
      if (((DomDocument) node).document_element == null) {
        tw.end_document ();
      }
    }
    start_node (_node);
    tw.end_element ();
    tw.end_document ();
    tw.flush ();
    string str;
    doc.dump_memory (out str, out size);
    tw = null;
    return str;
  }
  private void start_node (GXml.DomNode node)
    throws GLib.Error
  {
    if (tw == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextWriter initialized"));
    int size = 0;
    if (node is GXml.DomElement) {
      var element_node = (DomElement) node;
      if (element_node.namespace_uri != null) {
          string lpns = (node.parent_node).lookup_prefix (element_node.namespace_uri);
          if (lpns == element_node.prefix
              && element_node.prefix != null) {
            tw.start_element (node.node_name);
          }
          else
            tw.start_element_ns (element_node.prefix,
                                 element_node.local_name,
                                 element_node.namespace_uri);
      } else
        tw.start_element (element_node.local_name);

    // GXml.Object serialization
    var lp = ((GXml.Object) node).get_properties_list ();
    foreach (ParamSpec pspec in lp) {
      string attname = pspec.get_nick ().replace ("::","");
      string val = null;
      if (pspec.value_type.is_a (typeof (GXml.Property))) {
        Value v = Value (pspec.value_type);
        node.get_property (pspec.name, ref v);
        GXml.Property gp = v.get_object () as GXml.Property;
        if (gp == null) continue;
        val = gp.value;
      } else {
        val = ((GXml.Object) node).get_property_string (pspec);
      }
      if (val == null) continue;
      size += tw.write_attribute (attname, val);
      size += tw.end_attribute ();
      if (size > 1500)
        tw.flush ();
    }
    // DomElement attributes
    var keys = element_node.attributes.keys;
    foreach (string ak in keys) {
      var prop = element_node.attributes.get (ak) as GXml.Attr;
      if (prop == null) {
        continue;
      }
      if (prop.is_referenced) {
        continue;
      }
      string v = prop.value;
      if (v == null) {
        continue;
      }
      if ("xmlns:" in ak) {
        string ns = element_node.namespace_uri;
        if (ns != null) {
          string[] strs = ak.split (":");
          if (strs.length == 2) {
            string nsp = strs[1];
            if (ns == v && nsp == element_node.prefix) {
              continue;
            }
          }
        }
      }
      size += tw.write_attribute (ak, v);
      size += tw.end_attribute ();
      if (size > 1500)
        tw.flush ();
    }
  }
  // Non Elements
    foreach (GXml.DomNode n in node.child_nodes) {
      write_node (n);
    }
  }

  private async string dump_async () throws GLib.Error {
    int size;
    Xml.Doc doc = null;
    tw = new TextWriter.doc (out doc);
    if (_node is DomDocument) tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (_node is DomDocument) {
      if (((DomDocument) node).document_element == null) {
        tw.end_document ();
      }
    }
    Idle.add (dump_async.callback);
    yield;
    yield start_node_async (_node);
    Idle.add (dump_async.callback);
    yield;
    tw.end_element ();
    tw.end_document ();
    tw.flush ();
    Idle.add (dump_async.callback);
    yield;
    string str;
    doc.dump_memory (out str, out size);
    tw = null;
    return str;
  }
  private async void start_node_async (GXml.DomNode node)
    throws GLib.Error
  {
    if (tw == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextWriter initialized"));
    int size = 0;
    if (node is GXml.DomElement) {
      var element_node = (GXml.DomElement) node;
      if (element_node.namespace_uri != null) {
          string lpns = (node.parent_node).lookup_prefix (element_node.namespace_uri);
          if (lpns == element_node.prefix
              && element_node.prefix != null) {
            tw.start_element (node.node_name);
          }
          else
            tw.start_element_ns (element_node.prefix,
                                 element_node.local_name,
                                 element_node.namespace_uri);
      } else
        tw.start_element (element_node.local_name);
    Idle.add (start_node_async.callback);
    yield;
    // GXml.Object serialization
    var lp = ((GXml.Object) node).get_properties_list ();
    foreach (ParamSpec pspec in lp) {
      Idle.add (start_node_async.callback);
      yield;
      string attname = pspec.get_nick ().replace ("::","");
      string val = null;
      if (pspec.value_type.is_a (typeof (GXml.Property))) {
        Value v = Value (pspec.value_type);
        node.get_property (pspec.name, ref v);
        GXml.Property gp = v.get_object () as GXml.Property;
        if (gp == null) continue;
        val = gp.value;
      } else {
        val = ((GXml.Object) node).get_property_string (pspec);
      }
      if (val == null) continue;
      size += tw.write_attribute (attname, val);
      size += tw.end_attribute ();
      if (size > 1500)
        tw.flush ();
    }
    // DomElement attributes
    foreach (string ak in element_node.attributes.keys) {
      Idle.add (start_node_async.callback);
      yield;
      string v = ((Gee.HashMap<string,string>) element_node.attributes).get (ak);
      if ("xmlns:" in ak) {
        string ns = element_node.namespace_uri;
        if (ns != null) {
          string[] strs = ak.split (":");
          if (strs.length == 2) {
            string nsp = strs[1];
            if (ns == v && nsp == element_node.prefix) {
              continue;
            }
          }
        }
      }
      size += tw.write_attribute (ak, v);
      size += tw.end_attribute ();
      if (size > 1500)
        tw.flush ();
    }
  }
  // Non Elements
    foreach (GXml.DomNode n in node.child_nodes) {
      Idle.add (start_node_async.callback);
      yield;
      write_node (n);
    }
  }
  private void write_node (DomNode n) throws GLib.Error {
    if (tw == null)
      throw new ParserError.INVALID_DATA_ERROR (_("Internal Error: No TextWriter initialized"));
    int size = 0;
    if (n is GXml.DomElement) {
      start_node (n);
      size += tw.end_element ();
      if (size > 1500)
        tw.flush ();
    }
    if (n is GXml.DomText) {
    size += tw.write_string (n.node_value);
    if (size > 1500)
      tw.flush ();
    }
    if (n is GXml.DomComment) {
      size += tw.write_comment (n.node_value);
      if (size > 1500)
        tw.flush ();
    }
    if (n is GXml.DomProcessingInstruction) {
      size += tw.write_pi (((DomProcessingInstruction) n).target,
                          ((DomProcessingInstruction) n).data);
      if (size > 1500)
        tw.flush ();
    }
    if (n is GXml.DomDocumentType) {
      size += tw.write_dtd (((DomDocumentType) n).name,
                          ((DomDocumentType) n).public_id,
                          ((DomDocumentType) n).system_id,
                          null);
      if (size > 1500)
        tw.flush ();
    }
  }
}

