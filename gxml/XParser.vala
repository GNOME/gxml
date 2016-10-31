/* TNode.vala
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
 * {@link Parser} implementation using libxml2 engine
 */
public class GXml.XParser : Object, GXml.Parser {
  private DomDocument _document;
  private TextReader tr;
  private Xml.TextWriter tw;

  public DomDocument document { get { return _document; } }

  public bool indent { get; set; }

  public XParser (DomDocument doc) { _document = doc; }

  public void write (GLib.File f, GLib.Cancellable? cancellable) throws GLib.Error {}
  public void write_stream (OutputStream stream, GLib.Cancellable? cancellable) throws GLib.Error {}
  public string write_string () throws GLib.Error  {
    return dump ();
  }
  public void read_string (string str, GLib.Cancellable? cancellable) throws GLib.Error {
    StringBuilder s = new StringBuilder (str);
    tr = new TextReader.for_memory ((char[]) s.data, (int) s.len, "/gxml_memory");
  }


  public void read (GLib.File file,  GLib.Cancellable? cancellable) throws GLib.Error {
    if (!file.query_exists ())
      throw new GXml.DocumentError.INVALID_FILE (_("File doesn't exist"));
    read_stream (file.read (), cancellable);
  }

  public void read_stream (GLib.InputStream istream,
                          GLib.Cancellable? cancellable) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
#if DEBUG
    GLib.message ("FILE:"+(string)b.data);
#endif
    tr = new TextReader.for_memory ((char[]) b.data, (int) b.get_data_size (), "/gxml_memory");
    while (read_node (_document));
  }


  /**
   * Parse current node in {@link Xml.TextReader}.
   *
   * Returns: a {@link GXml.Node} respresenting current parsed one.
   */
  public bool read_node (DomNode node) throws GLib.Error {
    GXml.DomNode n = null;
    string prefix, nsuri;
    if (tr.read () != 1) return false;
    if (tr.next () != 1) return false;
    var t = tr.node_type (); // FIXME: Convert to NodeType and store
#if DEBUG
    GLib.message ("ReadNode: Current Node:"+node.node_name);
#endif
    switch (t) {
    case Xml.ReaderType.NONE:
#if DEBUG
      GLib.message ("Type NONE");
#endif
      if (tr.read () != 1) return false;
      break;
    case Xml.ReaderType.ELEMENT:
      bool isempty = (tr.is_empty_element () == 1);
#if DEBUG
      if (isempty) GLib.message ("Is Empty node:"+node.node_name);
      GLib.message ("ReadNode: Element: "+tr.const_local_name ());
#endif
      if (isempty) {
        return true;;
      }
      var cont = true;
      while (cont) {
        if (tr.read () != 1) return false;
        t = tr.node_type ();
        if (t == Xml.ReaderType.END_ELEMENT) {
          if (tr.const_local_name () == n.node_name) {
            cont = false;
          }
        }
      }
      return true;
#if DEBUG
      //GLib.message ("ReadNode: next node:"+n.to_string ());
      //GLib.message ("ReadNode: next node attributes:"+(tr.has_attributes ()).to_string ());
#endif
      prefix = tr.prefix ();
      if (prefix != null) {
        nsuri = tr.lookup_namespace (prefix);
        n = _document.create_element_ns (nsuri, tr.prefix () + tr.const_local_name ());
      } else
        n = _document.create_element (tr.const_local_name ());
      node.append_child (n);
      var nattr = tr.attribute_count ();
#if DEBUG
      GLib.message ("Number of Attributes:"+nattr.to_string ());
#endif
      for (int i = 0; i < nattr; i++) {
        var c = tr.move_to_attribute_no (i);
#if DEBUG
        GLib.message ("Current Attribute: "+i.to_string ());
#endif
        if (c != 1) {
          throw new DomError.HIERARCHY_REQUEST_ERROR (_("Parsing ERROR: Fail to move to attribute number: %i").printf (i));
        }
        if (tr.is_namespace_decl () == 1) {
#if DEBUG
          GLib.message ("Is Namespace Declaration...");
#endif
          string nsp = tr.const_local_name ();
          prefix = tr.prefix ();
          tr.read_attribute_value ();
          if (tr.node_type () == Xml.ReaderType.TEXT) {
            nsuri = tr.read_string ();
            (n as DomElement).set_attribute_ns (nsuri, prefix+":"+nsp, nsuri);
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
              (n as DomElement).set_attribute_ns (nsuri, prefix+":"+attrname, attrval);
            } else
              (n as DomElement).set_attribute (attrname, attrval);
          }
        }
      }
      if (isempty) return true;
      while (read_node (n) == true);
#if DEBUG
      //GLib.message ("Current Document: "+node.document.to_string ());
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
      n = _document.create_text_node (txtval);
      node.append_child (n);
      break;
    case Xml.ReaderType.CDATA:
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
      n = node.owner_document.create_processing_instruction (pit,pival);
      node.append_child (n);
      break;
    case Xml.ReaderType.COMMENT:
      var commval = tr.value ();
#if DEBUG
      GLib.message ("Type COMMENT");
      GLib.message ("ReadNode: Comment Node : '"+commval+"'");
#endif
      n = node.owner_document.create_comment (commval);
      node.append_child (n);
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
      return false;
    case Xml.ReaderType.END_ENTITY:
#if DEBUG
      GLib.message ("Type END_ENTITY");
#endif
      return false;
    case Xml.ReaderType.XML_DECLARATION:
#if DEBUG
      GLib.message ("Type XML_DECLARATION");
#endif
      break;
    }
    return true;
  }

  private string dump () throws GLib.Error {
    int size;
    Xml.Doc doc = new Xml.Doc ();
    tw = Xmlx.new_text_writer_doc (ref doc);
    tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (_document.document_element == null) {
      tw.end_document ();
    }
    var dns = new ArrayList<string> ();
#if DEBUG
    GLib.message ("Starting writting Document child nodes");
#endif
    start_node (_document);
#if DEBUG
    GLib.message ("Ending writting Document child nodes");
#endif
    tw.end_element ();
#if DEBUG
    GLib.message ("Ending Document");
#endif
    tw.end_document ();
    tw.flush ();
    string str;
    doc.dump_memory (out str, out size);
    return str;
  }
  private void start_node (GXml.DomNode node)
    throws GLib.Error
  {
    int size = 0;
#if DEBUG
    GLib.message (@"Starting Node: start Node: '$(node.node_name)'");
#endif
    if (node is GXml.DomElement) {
#if DEBUG
      GLib.message (@"Starting Element... '$(node.node_name)'");
      GLib.message (@"Element Document is Null... '$((node.owner_document == null).to_string ())'");
#endif
      if ((node as DomElement).prefix != null || (node as DomElement).namespace_uri != null)
        tw.start_element_ns ((node as DomElement).prefix, (node as DomElement).local_name, (node as DomElement).node_name);
      else // Don't prefix. Using default namespace and prefix_default_ns = false
        tw.start_element (node.node_name);
    foreach (GXml.DomNode attr in (node as DomElement).attributes.values) {
#if DEBUG
        GLib.message (@"Starting Element '$(node.node_name)': write attribute '$((attr as DomAttr).local_name)'");
#endif
      if ((attr as DomAttr).prefix != null)
        size += tw.write_attribute_ns ((attr as DomAttr).prefix,
                                        (attr as DomAttr).local_name,
                                        (attr as DomAttr).namespace_uri,
                                        attr.node_value);
      else
        size += tw.write_attribute (attr.node_name, attr.node_value);
      if (size > 1500)
        tw.flush ();
    }
  }
  // Non Elements
#if DEBUG
    GLib.message (@"Starting Element: writting Node '$(node.node_name)' children");
#endif
    foreach (GXml.DomNode n in node.child_nodes) {
#if DEBUG
      GLib.message (@"Child Node is: $(n.get_type ().name ())");
#endif
      if (n is GXml.DomElement) {
#if DEBUG
      GLib.message (@"Starting Child Element: writting Node '$(n.node_name)'");
#endif
        start_node (n);
        size += tw.end_element ();
        if (size > 1500)
          tw.flush ();
      }
      if (n is GXml.DomText) {
      //GLib.message ("Writting Element's contents");
      size += tw.write_string (n.node_value);
      if (size > 1500)
        tw.flush ();
      }
      if (n is GXml.DomComment) {
#if DEBUG
      GLib.message (@"Starting Child Element: writting Comment '$(n.node_value)'");
#endif
        size += tw.write_comment (n.node_value);
        if (size > 1500)
          tw.flush ();
      }
      if (n is GXml.DomProcessingInstruction) {
  #if DEBUG
      GLib.message (@"Starting Child Element: writting ProcessingInstruction '$(n.node_value)'");
  #endif
        size += Xmlx.text_writer_write_pi (tw, (n as DomProcessingInstruction).target,
                                          (n as DomProcessingInstruction).data);
        if (size > 1500)
          tw.flush ();
      }
    }
  }
}
