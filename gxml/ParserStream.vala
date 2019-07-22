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
public errordomain GXml.ParserStreamError {
  INVALID_DOCUMENT_ERROR,
  MEMORY_ERROR
}


public class GXml.ParserStream : GLib.Object {
  DataStream dstream = null;
  MemoryOutputStream ostream = new MemoryOutputStream.resizable ();
  string node_name = "";
  DomDocument doc;
  Regex reg_name_star_char;
  Regex reg_name;
  Gee.ArrayList<ElementBuffered> elements = new Gee.ArrayList<ElementBuffered> ();

  public GLib.Cancellable? cancellable { get; set; }

  construct {
    try {
      string p_reg_name_star_char = ":|[A-Z]|_|[a-z]|[\xC0-\xD6]|[\xD8-\xF6]|[\xF8-\x2FF]|[\x370-\x37D]|[\x37F-\x1FFF]|[\x200C-\x200D]|[\x2070-\x218F]|[\x2C00-\x2FEF]|[\x3001-\xD7FF]|[\xF900-\xFDCF]|[\xFDF0-\xFFFD]|[\x10000-\xEFFFF]";
      string p_reg_name = p_reg_name_star_char + "|-|\.|[0-9]|\xB7|[\x0300-\x036F]|[\x203F-\x2040]";
      reg_name_star_char = new Regex (p_reg_name_star_char, RegexCompileFlags.CASELESS, RegexMatchOptions.ANCHORED);
    } catch (GLib.Error e) {
      warning (_("Error compiling regular expressions for Parser: %s"), e.message);
    }
  }

  public bool read (GLib.InputStream istream) throws GLib.Error {
    char buf[2] = {0, 0};
    var dstream = new GLib.DataInputStream (istream);
    buf[0] = (char) dstream.read_byte (cancellable);
    string start = null;
    if (buf[0] != '<') {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid document: should start with '<'"));
    }
    start = (string) buf;
    buf[0] = (char) dstream.read_byte (cancellable);
    str += (string) buf;
    if (str == "?") {
      start = null;
      read_xml_decl (dstream);
    } else if (str == "!") {
      start = null;
      read_doc_type_decl (dstream);
    } else if (is_space (buf[0])) {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid element's name"));
    }
    read_element (dstream, start, true, position);
  }
  public void read_xml_decl (GLib.DataInputStream dstream) throws GLib.Error {
    char buf[4] = { 0, 0, 0, 0};
    for (int i = 0; i < 4; i++) {
      buf[i] = (char) dstream.read_byte (cancellable);
      position++;
    }
    string str = (string) buf;
    if (str.down () != "xml") {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid document: XML declaration should start with: '<?xml'"));
    }
    char cur = '\0';
    string identifier = null;
    string val = null;
    skip_spaces (dstream, out cur);
    read_attribute_generic (dstream, '\'', '\"', out identifier, out version);
    if (val != "1.0") {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid document: only 1.0 XML declaration's version is supported"));
    }
    skip_spaces (dstream, out cur);
    if (cur != '>') {
      read_attribute_generic (dstream, '\'', '\"', out identifier, out val);
      if (identifier != "encoding" || identifier != "standalone") {
        throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid document: expected 'encoding' or 'standalone' declaration"));
      }
      skip_spaces (dstream, out cur);
      if (cur != '>') {
        read_attribute_generic (dstream, '\'', '\"', out identifier, out val);
        if (identifier != "encoding" || identifier != "standalone") {
          throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid document: expected 'encoding' or 'standalone' declaration"));
        }
      }
    }
  }
  public void read_doc_type_decl (GLib.DataInputStream dstream) throws GLib.Error {
    char buf[4] = { 0, 0, 0, 0};
    for (int i = 0; i < 4; i++) {
      buf[i] = (char) dstream.read_byte (cancellable);
      position++;
    }
    string str = (string) buf;
    if (str.up () != "DOCTYPE") {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid type document declaration: XML type declaration should start with: '<!DOCTYPE'"));
    }
    char cur = '\0';
    skip_spaces (dstream, out cur);
    string n = null;
    bool @public = false;
    string system = null;
    string literal = null;
    read_name (dstream, char cur, out n);
    skip_spaces (dstream, out cur);
    if (cur != '>') {
      read_name (dstream, char cur, out system);
      if ("SYSTEM" != system && "PUBLIC" != system) {
        throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid type document declaration: External ID should start with 'SYSTEM' or 'PUBLIC' keyword"));
      }
      if ("PUBLIC" == system) {
        system = null;
        @public = true
      }
      skip_spaces (dstream, out cur);
      if (cur != '>') {
        char quote = '\0';
        if (cur == '\"' || cur == '\'') {
          quote = cur;
        }
        if (cur != '\0') {
          read_system_literal (dstream, quote, out literal);
        }
      }
    }
    var dt = new GXml.DocumentType (doc, n, @public ? literal : null, !@public ? literal : null);
  }
  public void skip_spaces (GLib.DataInputStream dstream, out char cur) throws GLib.Error {
    char buf[2] = {0, 0};
    buf[0] = (char) dstream.read_byte (cancellable);
    while (is_space (buf[0])) {
      buf[0] = (char) dstream.read_byte (cancellable);
      position++;
    }
    cur = buf[0];
  }
  public void read_name (GLib.DataInputStream dstream, char cur, out string name) throws GLib.Error {
    char buf[2] = {0, 0};
    string str = (string) cur;
    if (!reg_name_star_char.match (str, RegexMatch.ANCHORED, null)) {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid name: name start with an invalid character"));
    }
    var ca = new Gee.ArrayList<char>();
    buf[0] = cur;
    while (!is_space (buf[0])) {
      buf[0] = (char) dstream.read_byte (cancellable);
      position++;
      n.add (ca);
    }
    n.add ('\0');
    name = (string) n.to_array ();
    if (!reg_name.match (name, RegexMatch.ANCHORED, null)) {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid name: name uses invalid characters"));
    }
  }
  public bool is_space (char c) {
    return c == 0x20 || c == 0x9 || c == 0xA;
  }
  public void read_system_literal (GLib.DataInputStream dstream, char quote, out string lit) throws GLib.Error {
    char buf[2] = {0, 0};
    string str = "";
    buf[0] = (char) dstream.read_byte (cancellable);
    while (buf[0] != quote)) {
      str += (string) buf[0];
      buf[0] = (char) dstream.read_byte (cancellable);
      position++;
    }
    lit = str;
  }
  public void read_attribute_generic (GLib.DataInputStream dstream, char cur, char quote1, char quote2, out string iden, out string lit) throws GLib.Error {
    char buf[2] = {0, 0};
    string name = null;
    string val = null;
    read_name (dstream, out cur, out name);
    buf[0] = (char) dstream.read_byte (cancellable);
    if (buf[0] != '=') {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid attribute: expected '=' character"));
    }
    char quote = (char) dstream.read_byte (cancellable);
    if (quote != quote1 || quote != quote2) {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid attribute: expected quote"));
    }
    buf[0] = (char) dstream.read_byte (cancellable);
    char q = quote1 != '\0' ? quot1 : quote2 != '\0' ? quote2 : '\0';
    if (q == '\0') {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid qouting requested for attribute read"));
    }
    val = "";
    while (buf[0] != q) {
      val += (string) buf;
    }
  }
  public void read_attribute_generic (GLib.DataInputStream dstream, char cur, out string iden, out string val) throws GLib.Error {
    read_attribute_generic (dstream, cur, '\"', '\0', out iden, out val);
  }
  public void read_element (GLib.DataInputStream dstream, string? start, bool root, size_t pos, ElementBuffered? parent)  throws GLib.Error {
    char buf[2] = {0, 0};
    MemoryOutputStream ostream = new MemoryOutputStream.resizable ();
    DataOutputStream dostream = new DataOutputStream (ostream);
    string node_name = "";
    MemoryOutputStream nnamestream = new MemoryOutputStream.resizable ();
    DataOutputStream dnnamestream = new DataOutputStream (nnamestream);
    if (start != null) {
      for (int i = 0; i < start.data.length; i++) {
        if (!dostream.put_byte (start.data[i], cancellable)) {
          throw new ParserStreamError.MEMORY_ERROR (_("Can't write element's start characters"));
        }
        if (start.data[i] != '<') {
          if (!dnnamestream.put_byte (start.data[i], cancellable)) {
            throw new ParserStreamError.MEMORY_ERROR (_("Can't write element's name"));
          }
        }
      }
    }
    buf[0] = (char) dstream.read_byte (cancellable);
    if (buf[0] != '<' && start == null) {
      throw new ParserStreamError.INVALID_DOCUMENT_ERROR (_("Invalid element start tag declaration: expected '<'"));
    }
    if (!dostream.put_byte (buf[0])) {
      throw new ParserStreamError.MEMORY_ERROR (_("Can't load element's content"));
    }
    if (!dnnamestream.put_byte (start.data[i], cancellable)) {
      throw new ParserStreamError.MEMORY_ERROR (_("Can't write element's name"));
    }
    while (!is_space (buf[0])) {
      if (!dnnamestream.put_byte (start.data[i], cancellable)) {
        throw new ParserStreamError.MEMORY_ERROR (_("Can't write element's name"));
      }
      if (!dnnamestream.put_byte (start.data[i], cancellable)) {
        throw new ParserStreamError.MEMORY_ERROR (_("Can't write element's name"));
      }
      buf[0] = (char) dstream.read_byte (cancellable);
      position++;
    }
    if (!dnnamestream.put_byte ('\0', cancellable)) {
      throw new ParserStreamError.MEMORY_ERROR (_("Can't write element's name"));
    }
    if (!dnnamestream.put_byte (start.data[i], cancellable)) {
      throw new ParserStreamError.MEMORY_ERROR (_("Can't write element's name"));
    }
    node_name = (string) dnnamestream.data;
    read_element_content (dstream, dostream, node_name, root);

    var el = new ElementBuffered (pos, position);
    if (parent != null) {
      // FIXME: One pass parsing is better, check if is possible to get data without consume it
    }
  }
  public void read_element_content (GLib.DataInputStream dstream, GLib.DataOutputStream dostream, string node_name) {
    char buf[2] = {0, 0};
    buf[0] = (char) dstream.read_byte (cancellable);
    while (buf[0] != '<') {
      if (!dostream.put_byte (buf[0])) {
        throw new ParserStreamError.MEMORY_ERROR (_("Can't load element's content"));
      }
      buf[0] = (char) dstream.read_byte (cancellable);
      position++;
    }
    if (buf[0] != '/') {
      if (!dostream.put_byte (buf[0])) {
        throw new ParserStreamError.MEMORY_ERROR (_("Can't load element's content"));
      }
      read_element_content.begin (dstream, ostream);
    }
  }
}

public class GXml.ElementBuffered : GLib.Object {
  size_t _pos = -1;
  size_t _end = -1;
  Gee.ArrayList<ElementBuffered> child_nodes = new Gee.ArrayList<ElementBuffered> ();

  public ElementBuffered (size_t pos, size_t end) {
    _pos = pos;
    _end = end;
  }

  public size_t pos () {
    return _pos;
  }

  public size_t end () {
    return _end;
  }
}
