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


public class GXml.StreamReader : GLib.Object {
  uint8[] buf = new uint8[2];
  public size_t xml_def_pos_start { get; set; }
  public size_t xml_def_pos_end { get; set; }
  public size_t doc_type_pos_start { get; set; }
  public size_t doc_type_pos_end { get; set; }
  public size_t root_pos_start { get; set; }
  public size_t root_pos_end { get; set; }
  public size_t current_pos { get; set; }
  public DataInputStream stream { get; }
  public Cancellable? cancellable { get; set; }
  public bool has_xml_dec { get; set; }
  public bool has_doc_type_dec { get; set; }
  public bool has_misc { get; set; }
  public bool has_root { get; set; }
  public DomDocument document { get; }

  public StreamReader (InputStream istream) {
    _stream = new DataInputStream (istream);
    buf[0] = '\0';
    buf[1] = '\0';
  }
  private inline uint8 read_byte () throws GLib.Error {
    buf[0] = stream.read_byte (cancellable);
    return buf[0];
  }
  public inline string read_upto (string str) throws GLib.Error {
    string bstr = stream.read_upto (str, -1, null, cancellable);
    return bstr;
  }
  private inline char cur_char () {
    return (char) buf[0];
  }
  private inline uint8 cur_byte () {
    return buf[0];
  }
  public DomDocument read () throws GLib.Error {
    _document = new Document ();
    internal_read ();
    return document;
  }
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
    var re = read_root_element ();
    document.append_child (re);
  }
  public GXml.Element read_root_element () throws GLib.Error {
    return read_element (true);
  }
  public GXml.Element read_element (bool children) throws GLib.Error {
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
    e = (GXml.Element) document.create_element ((string) oname_buf.get_data ());
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
        } else if (children) {
          var ce = read_element (false);
          e.append_child (ce);
        } else {
          dbuf.put_byte ('<', cancellable);
          dbuf.put_byte (cur_byte (), cancellable);
        }
      } else {
        dbuf.put_byte (cur_byte (), cancellable);
      }
    }
  }
  public void read_xml_dec () throws GLib.Error  {
    while (cur_char () != '>') {
      read_byte ();
    }
    skip_spaces ();
  }
  public bool is_space (char c) {
    return c == 0x20 || c == 0x9 || c == 0xA || c == ' ' || c == '\t' || c == '\n';
  }
  public inline void skip_spaces () throws GLib.Error {
    read_byte ();
    while (is_space (cur_char ())) {
      read_byte ();
    }
  }
}
