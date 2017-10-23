/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* XParser.vala
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
public class GXml.XParser : Object, GXml.Parser {
  private DomDocument _document;
  private DomNode _node;
  private TextReader tr;
  private Xml.TextWriter tw;

  public bool backup { get; set; }
  public bool indent { get; set; }

  public DomNode node { get { return _node; } }


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
  }

  public void write_stream (OutputStream stream,
                            GLib.Cancellable? cancellable = null) throws GLib.Error {
    var buf = new Xml.Buffer ();
    tw = new TextWriter.memory (buf);
    if (_node is DomDocument) tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (_node is DomDocument) {
      if ((_node as DomDocument).document_element == null)
        tw.end_document ();
    }
    start_node (_node);
    tw.end_element ();
    tw.end_document ();
    tw.flush ();
    var s = new GLib.StringBuilder ();
    s.append (buf.content ());
    var b = new GLib.MemoryInputStream.from_data (s.data, null);
    stream.splice (b, GLib.OutputStreamSpliceFlags.NONE);
    stream.close ();
    tw = null;
  }
  public async void write_stream_async (OutputStream stream,
                            GLib.Cancellable? cancellable = null) throws GLib.Error {
    var buf = new Xml.Buffer ();
    tw = new TextWriter.memory (buf);
    if (_node is DomDocument) tw.start_document ();
    tw.set_indent (indent);
    Idle.add (write_stream_async.callback);
    yield;
    // Root
    if (_node is DomDocument) {
      if ((_node as DomDocument).document_element == null)
        tw.end_document ();
    }
    Idle.add (write_stream_async.callback);
    yield;
    start_node (_node);
    tw.end_element ();
    tw.end_document ();
    Idle.add (write_stream_async.callback);
    yield;
    tw.flush ();
    Idle.add (write_stream_async.callback);
    yield;
    var s = new GLib.StringBuilder ();
    s.append (buf.content ());
    Idle.add (write_stream_async.callback);
    yield;
    var b = new GLib.MemoryInputStream.from_data (s.data, null);
    stream.splice (b, GLib.OutputStreamSpliceFlags.NONE);
    stream.close ();
    tw = null;
  }

  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML
   */
  public InputStream
  create_stream (GLib.Cancellable? cancellable = null) throws GLib.Error {
    var buf = new Xml.Buffer ();
    tw = new TextWriter.memory (buf);
    if (_node is DomDocument) tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (_node is DomDocument) {
      if ((_node as DomDocument).document_element == null)
        tw.end_document ();
    }
    start_node (_node);
    tw.end_element ();
    tw.end_document ();
    tw.flush ();
    var s = new GLib.StringBuilder ();
    s.append (buf.content ());
    tw = null;
    return new GLib.MemoryInputStream.from_data ((uint8[]) s.str.dup (), null);
  }
  /**
   * Creates asynchronically an {@link GLib.InputStream} to write a string representation
   * in XML
   */
  public async InputStream
  create_stream_async (GLib.Cancellable? cancellable = null) throws GLib.Error {
    var buf = new Xml.Buffer ();
    tw = new TextWriter.memory (buf);
    if (_node is DomDocument) tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (_node is DomDocument) {
      if ((_node as DomDocument).document_element == null)
        tw.end_document ();
    }
    Idle.add (create_stream_async.callback);
    yield;
    yield start_node_async (_node);
    tw.end_element ();
    tw.end_document ();
    tw.flush ();
    Idle.add (create_stream_async.callback);
    yield;
    var s = new GLib.StringBuilder ();
    s.append (buf.content ());
    tw = null;
    Idle.add (create_stream_async.callback);
    yield;
    return new GLib.MemoryInputStream.from_data ((uint8[]) s.str.dup (), null);
  }

  public string write_string () throws GLib.Error  {
    return dump ();
  }
  public async string write_string_async () throws GLib.Error  {
    return yield dump_async ();
  }
  public void read_string (string str, GLib.Cancellable? cancellable) throws GLib.Error {
    if (str == "")
      throw new ParserError.INVALID_DATA_ERROR (_("Invalid document string, it is empty or is not allowed"));
    var stream = new GLib.MemoryInputStream.from_data (str.data);
    read_stream (stream, cancellable);
  }
  public async void read_string_async (string str, GLib.Cancellable? cancellable) throws GLib.Error {
    if (str == "")
      throw new ParserError.INVALID_DATA_ERROR (_("Invalid document string, it is empty or is not allowed"));
    var stream = new GLib.MemoryInputStream.from_data (str.data);
    Idle.add (read_string_async.callback);
    yield;
    yield read_stream_async (stream, cancellable);
  }


  public void read_stream (GLib.InputStream istream,
                          GLib.Cancellable? cancellable = null) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    tr = new TextReader.for_memory ((char[]) b.data, (int) b.get_data_size (), "/gxml_memory");
    read_node (_node);
    tr = null;
  }
  public async void read_stream_async (GLib.InputStream istream,
                          GLib.Cancellable? cancellable = null) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    Idle.add (read_stream_async.callback);
    yield;
    tr = new TextReader.for_memory ((char[]) b.data, (int) b.get_data_size (), "/gxml_memory");
    read_node (_node);
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
      while (true) {
        if (current_is_element ()
            &&
            (current_node_name ().down () == (node as DomElement).local_name.down ())) {
          break;
        }
        if (!current_is_document ()) {
          read_child_node (_document);
        }
        if (!move_next_node ()) break;
      }
      read_element (node as DomElement);
    }
    if (current_is_element () && (node is DomDocument))
      read_child_element (node);
    else {
      if (node is GomElement) {
        if ((node as GomElement).parse_children)
          read_child_nodes (node);
        else {
          (node as GomElement).unparsed = read_unparsed ();
          //warning ("Unparsed text: "+(node as GomObject).unparsed);
          move_next_node ();
        }
      }
    }
  }
  public void read_child_nodes_stream (GLib.InputStream istream,
                          GLib.Cancellable? cancellable = null) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    tr = new TextReader.for_memory ((char[]) b.data, (int) b.get_data_size (), "/gxml_memory");
    read_child_nodes (_node);
    tr = null;
  }
  public async void read_child_nodes_stream_async (GLib.InputStream istream,
                          GLib.Cancellable? cancellable = null) throws GLib.Error {
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
      throw new ParserError.INVALID_DATA_ERROR (_("Can't read node data"));
    if (res == 0) {
      return false;
    }
    return true;
  }
  /**
   * Check if current node has childs.
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
        throw new DomError.HIERARCHY_REQUEST_ERROR (_("Parsing ERROR: Fail to move to attribute number: %i").printf (i));
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
        tr.read_attribute_value ();
        if (tr.node_type () == Xml.ReaderType.TEXT) {
          var attrval = tr.read_string ();
          bool processed = false;
          if (node is GomObject) {
            processed = (element as GomObject).set_attribute (attrname, attrval);
          }
          if (!processed) {
            if (prefix != null) {
              string nsuri = null;
              if (prefix == "xml")
                nsuri = "http://www.w3.org/2000/xmlns/";
              else
                nsuri = tr.lookup_namespace (prefix);
              element.set_attribute_ns (nsuri, prefix+":"+attrname, attrval);
            } else
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
      ret = false;
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
      if ((node as DomDocument).document_element == null) {
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
      if ((node as DomElement).namespace_uri != null) {
          string lpns = (node.parent_node).lookup_prefix ((node as DomElement).namespace_uri);
          if (lpns == (node as DomElement).prefix
              && (node as DomElement).prefix != null) {
            tw.start_element (node.node_name);
          }
          else
            tw.start_element_ns ((node as DomElement).prefix,
                                 (node as DomElement).local_name,
                                 (node as DomElement).namespace_uri);
      } else
        tw.start_element ((node as DomElement).local_name);

    // GomObject serialization
    var lp = (node as GomObject).get_properties_list ();
    foreach (ParamSpec pspec in lp) {
      string attname = pspec.get_nick ().replace ("::","");
      string val = null;
      if (pspec.value_type.is_a (typeof (GomProperty))) {
        Value v = Value (pspec.value_type);
        node.get_property (pspec.name, ref v);
        GomProperty gp = v.get_object () as GomProperty;
        if (gp == null) continue;
        val = gp.value;
      } else {
        val = (node as GomObject).get_property_string (pspec);
      }
      if (val == null) continue;
      size += tw.write_attribute (attname, val);
      size += tw.end_attribute ();
      if (size > 1500)
        tw.flush ();
    }
    // DomElement attributes
    foreach (string ak in (node as DomElement).attributes.keys) {
      string v = ((node as DomElement).attributes as HashMap<string,string>).get (ak);
      if ("xmlns:" in ak) {
        string ns = (node as DomElement).namespace_uri;
        if (ns != null) {
          string[] strs = ak.split (":");
          if (strs.length == 2) {
            string nsp = strs[1];
            if (ns == v && nsp == (node as DomElement).prefix) {
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
      if ((node as DomDocument).document_element == null) {
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
      if ((node as DomElement).namespace_uri != null) {
          string lpns = (node.parent_node).lookup_prefix ((node as DomElement).namespace_uri);
          if (lpns == (node as DomElement).prefix
              && (node as DomElement).prefix != null) {
            tw.start_element (node.node_name);
          }
          else
            tw.start_element_ns ((node as DomElement).prefix,
                                 (node as DomElement).local_name,
                                 (node as DomElement).namespace_uri);
      } else
        tw.start_element ((node as DomElement).local_name);
    Idle.add (start_node_async.callback);
    yield;
    // GomObject serialization
    var lp = (node as GomObject).get_properties_list ();
    foreach (ParamSpec pspec in lp) {
      Idle.add (start_node_async.callback);
      yield;
      string attname = pspec.get_nick ().replace ("::","");
      string val = null;
      if (pspec.value_type.is_a (typeof (GomProperty))) {
        Value v = Value (pspec.value_type);
        node.get_property (pspec.name, ref v);
        GomProperty gp = v.get_object () as GomProperty;
        if (gp == null) continue;
        val = gp.value;
      } else {
        val = (node as GomObject).get_property_string (pspec);
      }
      if (val == null) continue;
      size += tw.write_attribute (attname, val);
      size += tw.end_attribute ();
      if (size > 1500)
        tw.flush ();
    }
    // DomElement attributes
    foreach (string ak in (node as DomElement).attributes.keys) {
      Idle.add (start_node_async.callback);
      yield;
      string v = ((node as DomElement).attributes as HashMap<string,string>).get (ak);
      if ("xmlns:" in ak) {
        string ns = (node as DomElement).namespace_uri;
        if (ns != null) {
          string[] strs = ak.split (":");
          if (strs.length == 2) {
            string nsp = strs[1];
            if (ns == v && nsp == (node as DomElement).prefix) {
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
  private void write_node (DomNode n) {
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
      size += tw.write_pi ((n as DomProcessingInstruction).target,
                          (n as DomProcessingInstruction).data);
      if (size > 1500)
        tw.flush ();
    }
    if (n is GXml.DomDocumentType) {
      message ("Document Type:");
      size += tw.write_document_type ((n as DomDocumentType).name,
                          (n as DomDocumentType).public_id,
                          (n as DomDocumentType).system_id,
                          "");
      if (size > 1500)
        tw.flush ();
    }
  }
}
