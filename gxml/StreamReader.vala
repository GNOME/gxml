/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* ParserStream.vala
 *
 * Copyright (C) 2019  Daniel Espinosa <esodan@gmail.com>
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

public errordomain GXml.StreamReaderError {
  INVALID_DOCUMENT_ERROR
}

/**
 * Parser using a on the fly-post-parsing technique
 *
 * This parser takes or creates a {@link Document}, search
 * and adds the root XML element as a {@link Element};
 * then search and add all children {@link Element}.
 *
 * The root element is added without any attribute and
 * without any content or children; the same hapends with all
 * children.
 *
 * After call {@link read} or {@link read_document},
 * Root's and its children's content and its attributes
 * are stored as a string in a {@link GLib.MemoryOutputStream}
 * object at {@link GXml.Element.read_buffer}.
 *
 * If you want all attributes and children's children,
 * you should call {@link GXml.Element.parse_buffer},
 * which execute children's {@link GXml.Element.parse_buffer}
 * all asyncronically.
 */
public class GXml.StreamReader : GLib.Object {
  uint8[] buf = new uint8[2];
  Gee.HashMap<string,GXml.Collection> root_collections = new Gee.HashMap<string,GXml.Collection> ();
  /**
   * The stream where data is read from
   * to parse and fill {@link GXml.Element.read_buffer}
   */
  public DataInputStream stream { get; }
  /**
   * Use it to cancel the parse and fill process
   */
  public Cancellable? cancellable { get; set; }
  /**
   * Current {@link DomDocument} used to read to.
   */
  public DomDocument document { get; }
  /**
   * Create a new {@link StreamReader} object.
   */
  public StreamReader (InputStream istream) {
    _stream = new DataInputStream (istream);
    buf[0] = '\0';
    buf[1] = '\0';
  }
  private inline uint8 read_byte () throws GLib.Error {
    buf[0] = stream.read_byte (cancellable);
    return buf[0];
  }
  private inline string read_upto (string str) throws GLib.Error {
    string bstr = stream.read_upto (str, -1, null, cancellable);
    return bstr;
  }
  private inline char cur_char () {
    return (char) buf[0];
  }
  private inline uint8 cur_byte () {
    return buf[0];
  }
  /**
   * Creates a new {@link DomDocument} and parse the stream to.
   */
  public DomDocument read () throws GLib.Error {
    _document = new Document ();
    internal_read ();
    return document;
  }
  /**
   * Use a {@link DomElement} to initialize {@link document}
   */
  public void read_document (DomDocument doc) throws GLib.Error {
    _document = doc;
    internal_read ();
  }
  private void internal_read () throws GLib.Error {
    read_byte ();
    if (cur_char () != '<') {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: should start with '<'"));
    }
    read_byte ();
    if (is_space (cur_char ())) {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: unexpected character before node's name"));
    }
    if (cur_char () == '?') {
      read_xml_dec ();
      if (cur_char () != '<') {
        throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: unexpected character '%c'"), cur_char ());
      }
      read_byte ();
      if (is_space (cur_char ())) {
        throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: unexpected character before node's name"));
      }
    }
    read_root_element ();
  }
  private GXml.Element read_root_element () throws GLib.Error {
    return read_element (true);
  }
  private GXml.Element read_element (bool children, GXml.Element? parent = null) throws GLib.Error {
    if (parent != null) {
      if (!(parent is GXml.Object)) {
        throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Parent '%s' is not implemeting GXml.Object interface"), parent.get_type ().name ());
      }
    }
    GXml.Element e = null;
    var buf = new MemoryOutputStream.resizable ();
    var dbuf = new DataOutputStream (buf);
    var oname_buf = new MemoryOutputStream (new uint8[1024]);
    var name_buf = new DataOutputStream (oname_buf);

    dbuf.put_byte ('<');
    dbuf.put_byte (cur_byte ());

    name_buf.put_byte (cur_byte ());
    dbuf.put_byte (read_byte ());
    bool is_empty = false;
    while (cur_char () != '>') {
      if (is_space (cur_char ())) {
        break;
      }
      if (cur_char () == '/') {
        dbuf.put_byte (cur_char ());
        string rest = read_upto (">");
        dbuf.put_string (rest);
        dbuf.put_byte (read_byte ());
        is_empty = true;
        break;
      }
      name_buf.put_byte (cur_byte (), cancellable);
      dbuf.put_byte (read_byte ());
    }
    name_buf.put_byte ('\0', cancellable);
    if (document.document_element == null) {
      e = (document as GXml.Document).search_root_element_property ();
    }
    if (e == null) {
      e = (GXml.Element) document.create_element ((string) oname_buf.get_data ());
      if (document.document_element == null) {
        document.append_child (e);
      }
    }
    if (document.document_element == e && parent == null) {
      foreach (ParamSpec pspec in
                (e as GXml.Object).get_property_element_list ()) {
        if (!(pspec.value_type.is_a (typeof (Collection)))) continue;
        Collection col;
        Value vc = Value (pspec.value_type);
        e.get_property (pspec.name, ref vc);
        col = vc.get_object () as Collection;
        if (col == null) {
          col = GLib.Object.new (pspec.value_type,
                            "element", e) as Collection;
          vc.set_object (col);
          e.set_property (pspec.name, vc);
        }
        if (col.items_type == GLib.Type.INVALID
            || !(col.items_type.is_a (typeof (GXml.Object)))) {
          throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Collection '%s' hasn't been constructed properly: items' type property was not set at construction time or set to invalid type"), col.get_type ().name ());
        }
        if (col.items_name == "" || col.items_name == null) {
          throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Collection '%s' hasn't been constructed properly: items' name property was not set at construction time"), col.get_type ().name ());
        }
        if (col.element == null || !(col.element is GXml.Object)) {
          throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Collection '%s' hasn't been constructed properly: element property was not set at construction time"), col.get_type ().name ());
        }
        if (!(col.element is GXml.Object)) {
          throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Invalid object of type '%s' doesn't implement GXml.Object interface: can't be handled by the collection"), col.element.get_type ().name ());
        }
        root_collections.set (col.items_name.down (), col);
      }
    }
    e.read_buffer = buf;
    if (is_empty) {
      return e;
    }
    while (true) {
      read_byte ();
      if (cur_char () == '<') {
        read_byte ();
        if (cur_char () == '/') {
          dbuf.put_byte ('<');
          dbuf.put_byte (cur_byte ());
          string closetag = stream.read_upto (">", -1, null, cancellable);
          dbuf.put_string (closetag);
          dbuf.put_byte (read_byte ());
          if (closetag == (string) oname_buf.get_data ()) {
            return e;
          }
        } else if (children && parent == null) {
          GXml.Element ce = read_element (false, e);;
          var col = root_collections.get (ce.local_name.down ());
          if (col != null) {
            var cobj = GLib.Object.new (col.items_type,
                                  "owner-document", document) as Element;
            cobj.read_buffer = ce.read_buffer;
            e.append_child (cobj);
            col.append (cobj);
          } else {
            foreach (ParamSpec pspec in
                (e as GXml.Object).get_property_element_list ()) {
              if (pspec.value_type.is_a (typeof (Collection))) continue;
              var obj = GLib.Object.new (pspec.value_type,
                                    "owner-document", document) as Element;
              message ("%s == %s", obj.local_name, ce.local_name.down ());
              if (obj.local_name.down ()
                     == ce.local_name.down ()) {
                Value v = Value (pspec.value_type);
                v.set_object (obj);
                e.set_property (pspec.name, v);
                obj.read_buffer = ce.read_buffer;
                ce = obj;
              }
            }
            e.append_child (ce);
          }
        } else {
          dbuf.put_byte ('<', cancellable);
          dbuf.put_byte (cur_byte (), cancellable);
        }
      } else {
        dbuf.put_byte (cur_byte (), cancellable);
      }
    }
  }
  private void read_xml_dec () throws GLib.Error  {
    while (cur_char () != '>') {
      read_byte ();
    }
    skip_spaces ();
  }
  private bool is_space (char c) {
    return c == 0x20 || c == 0x9 || c == 0xA || c == ' ' || c == '\t' || c == '\n';
  }
  private inline void skip_spaces () throws GLib.Error {
    read_byte ();
    while (is_space (cur_char ())) {
      read_byte ();
    }
  }
}
