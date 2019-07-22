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
  public bool has_misc { get; set; }
  public bool has_root { get; set; }
  public DomDocument document { get; }
  public Promise<DomElement> root_element { get; }

  public StreamReader (InputStream istream) {
    _stream = new DataInputStream (istream);
    _root_element = new Promise<DomElement> ();
  }

  public DomDocument read () throws GLib.Error {
    _document = new Document ();
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
    if (!has_xml_dec && !has_doc_type_dec && !has_misc) {
      stream.seek (-2, SeekType.CUR, cancellable);
    }
    while (!has_root) {
      buf[0] = (char) stream.read_byte (cancellable);
      message ("Current: '%c' - Pos: %ld", buf[0], (long) stream.tell ());
      if (buf[0] != '<') {
        throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: expected '<' character"));
      }
      buf[0] = (char) stream.read_byte (cancellable);
      message ("Current: '%c' - Pos: %ld", buf[0], (long) stream.tell ());
      if (buf[0] == '!' || buf[0] == '?') {
        read_misc (buf[0]);
      } else {
        has_root = true;
      }
    }
    if (is_space (buf[0])) {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: unexpected character"));
    }
    string res = read_element (document, true);
    message ("Root string: %s", res);
    return document;
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
   * Expects a two byte consumed from {@link stream}, because
   * it seeks back one byte in order to read the element's name.
   *
   * Returns: A string representing the current node
   */
  public string read_element (DomNode parent, bool is_root = true) throws GLib.Error {
    string str = "";
    char buf[2] = {0, 0};
    if (is_root) {
      root_pos_start = (size_t) (stream.tell () - 1);
    }
    stream.seek (-2, SeekType.CUR, cancellable);
    buf[0] = (char) stream.read_byte (cancellable);
    message ("Current: '%c' - Pos: %ld", buf[0], (long) stream.tell ());
    if (buf[0] != '<') {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Elements should start with '<' characters"));
    }
    buf[0] = (char) stream.read_byte (cancellable);
    string name = "";
    while (buf[0] != '>') {
      if (is_space (buf[0])) {
        break;
      }
      if (buf[0] == '/') {
        string rest = stream.read_upto (">", -1, null, cancellable);
        buf[0] = (char) stream.read_byte (cancellable);
        var ee = document.create_element (name);
        parent.append_child (ee);
        return "<"+name+"/"+rest+(string) buf;
      }
      name += (string) buf;
      buf[0] = (char) stream.read_byte (cancellable);
    }
    message ("Element's name found: %s", name);
    string atts = "";
    while (buf[0] != '>') {
      atts += (string) buf;
      buf[0] = (char) stream.read_byte (cancellable);
    }
    var e = document.create_element (name);
    parent.append_child (e);
    message ("Element's attributes found: %s", atts);
    str = "<"+name+atts;
    str += ">";
    if (atts[atts.length - 1] == '/') {
      (e as Element).unparsed = str;
     return str;
    }
    message ("Element's declaration head: %s", str);
    message ("Current: %s", (string) buf);
    while (true) {
      string content = "";
      buf[0] = (char) stream.read_byte (cancellable);
      while (buf[0] != '<') {
        content += (string) buf;
        buf[0] = (char) stream.read_byte (cancellable);
      }
      str += content;
      message ("Current Element's content for '%s': '%s'", name, content);
      buf[0] = (char) stream.read_byte (cancellable);
      if (buf[0] == '/') {
        string closetag = stream.read_upto (">", -1, null, cancellable);
        buf[0] = (char) stream.read_byte (cancellable);
        if (is_root) {
          root_pos_end = (size_t) stream.tell ();
        }
        message ("CloseTAG: %s", closetag);
        if (closetag == name) {
          str = str + "</"+closetag+">";
          (e as Element).unparsed = str;
          return str;
        }
      }
      message ("Reading Child for %s", name);
      string nnode = read_element (e, false);
      if (!is_root) {
        str += nnode;
      }
    }
  }
  public bool is_space (char c) {
    return c == 0x20 || c == 0x9 || c == 0xA || c == ' ' || c == '\t' || c == '\n';
  }
  public bool validate_xml_definition () throws GLib.Error {
    return true;
  }
  public bool validate_doc_type_definition () throws GLib.Error {
    return true;
  }
}
