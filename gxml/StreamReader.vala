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
  INVALID_DOCUMENT_ERROR,
  DATA_READ_ERROR
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
  DataInputStream _stream = null;
  DomDocument _document = null;
  bool start = true;
  /**
   * The stream where data is read from
   * to parse and fill {@link GXml.Element.read_buffer}
   */
  public DataInputStream stream { get { return _stream; } }
  /**
   * Use it to cancel the parse and fill process
   */
  public Cancellable? cancellable { get; set; }
  /**
   * Current {@link DomDocument} used to read to.
   */
  public DomDocument document { get { return _document; } }
  /**
   * Creates a new {@link StreamReader} object.
   */
  public StreamReader (InputStream istream) {
    _stream = new DataInputStream (istream);
    buf[0] = '\0';
    buf[1] = '\0';
  }
  /**
   * Creates a new {@link StreamReader} object and
   * initialize {@link document} with given document
   */
  public StreamReader.for_document (InputStream istream, DomDocument document) {
    _stream = new DataInputStream (istream);
    buf[0] = '\0';
    buf[1] = '\0';
    _document = document;
  }
  /**
   * Reads the content of a stream to {@link document}.
   *
   * If {@link document} was not set, treates a new {@link DomDocument}
   *
   * Returns: {@link document}'s value
   */
  public DomDocument read () throws GLib.Error {
    if (_document == null) {
        _document = new Document ();
    }

    internal_read ();
    return _document;
  }
  /**
   * Use a {@link DomDocument} to initialize {@link document}
   * and parse its contents to
   */
  public void read_document (DomDocument doc) throws GLib.Error {
    _document = doc;
    internal_read ();
  }
  private inline bool read_byte () throws GLib.Error {
    try {
        buf[0] = stream.read_byte (cancellable);
    } catch {
        buf[0] = '\0';
        return false;
    }

    return true;
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
  private void internal_read () throws GLib.Error {
    start = true;
    parse_doc_nodes ();
    read_root_element ();
    if (!read_byte ()) {
        return;
    }

    parse_doc_nodes ();
  }

    public void parse_doc_nodes () throws GLib.Error
    {
        if (!read_byte ()) {
            return;
        }

        while (true) {
            if (cur_char () != '<') {
                throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: expected '<' character"));
            }

            if (!read_byte ()) {
                return;
            }

            if (is_space (cur_char ())) {
                throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid document: unexpected space character before node's name"));
            }
            if (cur_char () != '?' && cur_char () != '!') {
                return;
            }
            if (cur_char () == '?') {
                if (start) {
                    parse_xml_dec ();
                    start = false;
                    read_text_node ();
                    continue;
                } else {
                    parse_pi_dec ();
                    read_text_node ();
                    continue;
                }
            } else if (cur_char () == '!') {
                parse_comment_dec ();
                read_text_node ();
                message ("Stoped at: %c", cur_char ());
                continue;
            }
        }
    }

  private GXml.Element read_root_element () throws GLib.Error {
    return read_element (true);
  }
  private GXml.Element read_element (bool children, GXml.Element? parent = null) throws GLib.Error {
    if (parent != null) {
      if (!(parent is GXml.Object)) {
        throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Parent '%s' is not implementing GXml.Object interface"), parent.get_type ().name ());
      }
    }
    GXml.Element e = null;
    var buffer = new MemoryOutputStream.resizable ();
    var dbuf = new DataOutputStream (buffer);
    var oname_buf = new MemoryOutputStream (new uint8[1024]);
    var name_buf = new DataOutputStream (oname_buf);

    dbuf.put_byte ('<');
    dbuf.put_byte (cur_byte ());

    name_buf.put_byte (cur_byte ());
    if (!read_byte ()) {
        throw new StreamReaderError.DATA_READ_ERROR
                      (_("Can't continue parsing due to error reading data"));
    }

    dbuf.put_byte (cur_byte ());
    bool is_empty = false;
    while (cur_char () != '>') {
      if (is_space (cur_char ())) {
        break;
      }

      if (cur_char () == '/') {
        dbuf.put_byte (cur_char ());
        string rest = read_upto (">");
        dbuf.put_string (rest);
        if (!read_byte ()) {
            break;
        }

        dbuf.put_byte (cur_byte ());
        is_empty = true;
        break;
      }
      name_buf.put_byte (cur_byte (), cancellable);
      if (!read_byte ()) {
        break;
      }

      dbuf.put_byte (cur_byte ());
    }

    name_buf.put_byte ('\0', cancellable);
    if (document.document_element == null) {
      e = ((GXml.Document) document).search_root_element_property ();
    }

    if (e == null) {
      e = (GXml.Element) document.create_element ((string) oname_buf.get_data ());
      if (document.document_element == null) {
        document.append_child (e);
      }
    }

    if (document.document_element == e && parent == null) {
      foreach (ParamSpec pspec in
                ((GXml.Object) e).get_property_element_list ())
      {
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
    e.read_buffer = buffer;
    if (is_empty) {
      return e;
    }
    while (true) {
      if (!read_byte ()) {
        break;
      }

      if (cur_char () == '<') {
        if (!read_byte ()) {
          break;
        }

        if (cur_char () == '/') {
          dbuf.put_byte ('<');
          dbuf.put_byte (cur_byte ());
          string closetag = stream.read_upto (">", -1, null, cancellable);
          dbuf.put_string (closetag);
          if (!read_byte ()) {
            break;
          }

          dbuf.put_byte (cur_byte ());
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
                ((GXml.Object) e).get_property_element_list ()) {
              if (pspec.value_type.is_a (typeof (Collection))) continue;
              var obj = GLib.Object.new (pspec.value_type,
                                    "owner-document", document) as Element;
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

    return e;
  }
  private void parse_xml_dec () throws GLib.Error  {
    while (cur_char () != '>') {
      if (!read_byte ()) {
        return;
      }
    }

    read_byte ();
  }
  private void parse_comment_dec () throws GLib.Error  {
    if (!read_byte ()) {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid comment declaration"));;
    }

    if (cur_char () != '-') {
        throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid comment declaration"));
    }

    if (!read_byte ()) {
        return;
    }

    if (cur_char () != '-') {
        throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid comment declaration"));
    }

    GLib.StringBuilder comment = new GLib.StringBuilder ("");
    if (!read_byte ()) {
        return;
    }

    while (cur_char () != '>') {
      comment.append_c (cur_char ());
      if (!read_byte ()) {
        break;
      }


      if (cur_char () == '-') {
          if (!read_byte ()) {
            break;
          }

          if (cur_char () == '-') {
            if (!read_byte ()) {
              break;
            }

            if (cur_char () == '-') {
              throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid comment declaration"));
            } else if (cur_char () == '>') {
              break;
            }
          }
          comment.append_c ('-');
      }
    }
    var c = document.create_comment (comment.str);
    document.append_child (c);
  }
  private void parse_pi_dec () throws GLib.Error
  {
    if (!read_byte ()) {
      return;
    }

    GLib.StringBuilder str = new GLib.StringBuilder ("");
    while (!is_space (cur_char ())) {
      if (cur_char () == '?') {
          throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid Processing Instruction's target declaration"));
      }

      str.append_c (cur_char ());
      if (!read_byte ()) {
        return;
      }
    }
    string target = str.str;
    str.assign ("");
    while (cur_char () != '?') {
      str.append_c (cur_char ());
      if (!read_byte ()) {
        return;
      }
    }
    var pi = document.create_processing_instruction (target, str.str);
    document.append_child (pi);
    if (!read_byte ()) {
      return;
    }

    if (cur_char () != '>') {
      throw new StreamReaderError.INVALID_DOCUMENT_ERROR (_("Invalid Processing Instruction's close declaration"));
    }
  }
  private void read_text_node () throws GLib.Error  {
    GLib.StringBuilder text = new GLib.StringBuilder ("");
    if (!read_byte ()) {
      return;
    }

    if (!is_space (cur_char ())) {
        return;
    }
    while (is_space (cur_char ())) {
      text.append_c (cur_char ());
      try {
        read_byte ();
      } catch {
          return;
      }
    }

    var t = document.create_text_node (text.str);
    document.append_child (t);
  }
  private bool is_space (char c) {
    return c == 0x20 || c == 0x9 || c == 0xA || c == ' ' || c == '\t' || c == '\n';
  }
}
