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
public errordomain GXml.StreamReaderError {
  INVALID_DOCUMENT_ERROR
}


public class GXml.StreamReader : GLib.Object {
  public size_t xml_def_pos_start { get; set; }
  public size_t xml_def_pos_end { get; set; }
  public size_t doc_type_pos_start { get; set; }
  public size_t doc_type_pos_end { get; set; }
  public size_t root_pos_start { get; set; }
  public size_t root_pos_end { get; set; }
  public size_t current_pos { get; set; }
  public DataOutputStream buffer { get; }
  public DataInputStream stream { get; }
  public Cancellable? cancellable { get; set; }
  public bool has_xml_dec { get; set; }
  public bool has_doc_type_dec { get; set; }
  public bool has_root { get; set; }
  public void read () throws GLib.Error {
    char buf[2] = {0, 0};
    int64 pos = -1;
    buf[0] = (char) stream.read_byte (cancellable);
    if (buf[0] != '<') {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: should start with '<'"));
    }
    pos = stream.tell ();
    buf[0] = (char) stream.read_byte (cancellable);
    if (buf[0] == '?') {
      buf[0] = (char) stream.read_byte (cancellable);
      if (buf[0] == 'x') {
        string xmldef = stream.read_line (null, cancellable);
        xmldef = "<?"+xmldef;
        validate_xml_definition ();
        has_xml_dec = true;
      } else {
        stream.seek (-2, SeekType.CUR, cancellable);
        buf[0] = (char) stream.read_byte (cancellable);
        read_misc (buf[0]);
      }
    }
    while (!has_root) {
      buf[0] = (char) stream.read_byte (cancellable);
      if (buf[0] != '<') {
        throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: expected '<' character"));
      }
      buf[0] = (char) stream.read_byte (cancellable);
      if (buf[0] == '!' || buf[0] == '?') {
        read_misc (buf[0]);
      } else {
        has_root = true;
      }
    }
    if (is_space (buf[0])) {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: unexpected character"));
    }
    read_element ();
  }
  public bool read_misc (char c) throws GLib.Error {
    char buf[2] = {0, 0};
    if (c == '!') {
      int64 pos = stream.tell () - 1;
      buf[0] = (char) stream.read_byte (cancellable);
      if (buf[0] == 'D') {
        doc_type_pos_start = (size_t) pos;
        string doctype = stream.read_upto (">", -1, null, cancellable);
        doctype = "<!"+doctype+">";
        buf[0] = (char) stream.read_byte (cancellable);
        validate_doc_type_definition ();
        has_doc_type_dec = true;
        doc_type_pos_end = (size_t) stream.tell ();
      } else if (c == '-') {
        buf[0] = (char) stream.read_byte (cancellable);
        if (buf[0] == '-') {
          string comment = stream.read_upto ("-->", -1, null, cancellable);
          comment += "<!--"+comment+"-->";
          buf[0] = (char) stream.read_byte (cancellable);
          buf[0] = (char) stream.read_byte (cancellable);
          buf[0] = (char) stream.read_byte (cancellable);
        } else {
          throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: expected '-' character"));
        }
      }
    } else if (buf[0] == '?') {
      string pi = stream.read_upto ("?>", -1, null, cancellable);
      pi += "<?"+pi+"?>";
      buf[0] = (char) stream.read_byte (cancellable);
      buf[0] = (char) stream.read_byte (cancellable);
    }
    return true;
  }
  /**
   * Reads an element name, attributes and content as string
   *
   * Expects a one byte consumed from {@link stream}, because
   * it seeks back one byte in order to read the element's name.
   *
   * Returns: A string representing the current node
   */
  public string read_element (bool is_root = true) throws GLib.Error {
    string str = "";
    char buf[2] = {0, 0};
    if (is_root) {
      root_pos_start = (size_t) (stream.tell () - 1);
    }
    stream.seek (-1, SeekType.CUR, cancellable);
    string name = stream.read_upto (" ", -1, null, cancellable);
    string atts = stream.read_upto (">", -1, null, cancellable);
    stream.read_byte (cancellable);
    str = "<"+name+atts+">";
    if (is_root) {
      string content = stream.read_upto ("<", -1, null, cancellable);
      buf[0] = (char) stream.read_byte (cancellable);
      str += content;
      buf[0] = (char) stream.read_byte (cancellable);
      if (buf[0] == '/') {
        string closetag = stream.read_upto (">", -1, null, cancellable);
        buf[0] = (char) stream.read_byte (cancellable);
        root_pos_end = (size_t) stream.tell ();
        str += closetag + ">";
      } else {
        read_element (false);
      }
    } else {
      string cltag = "</"+name;
      string content = stream.read_upto (cltag, -1, null, cancellable);
      str += content;
      for (int i = 0; i < cltag.data.length; i++) {
        stream.read_byte (cancellable);
      }
      root_pos_end = (size_t) stream.tell ();
      str += cltag;
    }
    return str;
  }
  public bool is_space (char c) {
    return c == 0x20 || c == 0x9 || c == 0xA;
  }
  public bool validate_xml_definition () throws GLib.Error {
    return true;
  }
  public bool validate_doc_type_definition () throws GLib.Error {
    return true;
  }
}
