/* GHtmlDocument.vala
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
 * Class implemeting {@link GXml.Document} interface, not tied to libxml-2.0 library.
 *
 * This class use {@link Xml.TextWriter} to write down XML documents using
 * its contained {@link GXml.Node} childs or other XML structures.
 */
public class GXml.GDocument : GXml.GNode, GXml.Document
{
  protected Xml.Doc* doc;
  protected Xml.Buffer _buffer;

  public GDocument () {
    doc = new Xml.Doc ();
  }
  public GDocument.from_path (string path, int options = 0) throws GLib.Error {
    this.from_file (File.new_for_path (path), options);
  }

  public GDocument.from_uri (string uri, int options = 0) throws GLib.Error {
    this.from_file (File.new_for_uri (uri), options);
  }

  public GDocument.from_file (GLib.File file, int options = 0, Cancellable? cancel = null) throws GLib.Error {
    if (!file.query_exists ())
      throw new DocumentError.INVALID_DOCUMENT_ERROR (_("File doesn't exists"));
    var b = new MemoryOutputStream.resizable ();
    b.splice (file.read (), 0);
    this.from_string ((string) b.data, options);
  }

  public GDocument.from_string (string str, int options = 0) throws GLib.Error {
    Xmlx.reset_last_error ();
    doc = Xml.Parser.parse_memory (str, (int) str.length);
    var e = Xmlx.get_last_error ();
    if (e != null) {
      var errmsg = "Parser Error for string";
      string s = libxml2_error_to_string (e);
      if (s != null)
        errmsg = ".  ";
      throw new GXml.Error.PARSER (errmsg);
    }
    if (doc == null)
      doc = new Xml.Doc ();
  }
  public GDocument.from_stream (GLib.InputStream istream) throws GLib.Error {
    var b = new MemoryOutputStream.resizable ();
    b.splice (istream, 0);
    if (b.data == null)
      throw new DocumentError.INVALID_DOCUMENT_ERROR ("stream doesn't provide data'");
    this.from_string ((string) b.data);
  }
  public GDocument.from_doc (Xml.Doc doc) { this.doc = doc; }
  // GXml.Node
  public override bool set_namespace (string uri, string? prefix)
  {
    var root = doc->get_root_element ();
    if (root != null) {
      var ns = root->new_ns (uri, prefix);
      return (ns != null);
    }
    return false;
  }
  // GXml.Node
  public override Gee.Map<string,GXml.Node> attrs { owned get { return new GHashMapAttr (this, (Xml.Node*) doc); } }
  public override Gee.BidirList<GXml.Node> children { owned get { return new GListChildren (this, (Xml.Node*) doc); } }
  public override Gee.List<GXml.Namespace> namespaces { owned get { return new GListNamespaces (this, (Xml.Node*) doc); } }
  public override GXml.Document document { get { return this; } }
  // GXml.Document
  public bool indent { get; set; default = false; }
  public bool ns_top { get; set; default = false; }
  public bool prefix_default_ns { get; set; default = false; }
  public bool backup { get; set; default = true; }
  public GLib.File file { get; set; }
  public GXml.Node root {
    owned get {
      var r = doc->get_root_element ();
      if (r == null) {
        int found = 0;
        for (int i = 0; i < childs.size; i++) {
          GXml.Node n = childs.get (i);
          if (n is GXml.Element) {
            found++;
            if (found == 1)
              return n;
          }
        }
        if (found > 1) {
          GLib.warning ("Document have more than one root GXmlElement. Using first found");
        }
      } 
      return new GElement (this, r);
    }
  }
  public GXml.Node create_comment (string text)
  {
    var c = doc->new_comment (text);
    return new GComment (this, c);
  }
  public GXml.Node create_pi (string target, string data)
  {
    var pi = doc->new_pi (target, data);
    return new GProcessingInstruction (this, pi);
  }
  public GXml.Node create_element (string name) throws GLib.Error
  {
    Xmlx.reset_last_error ();
    var el = doc->new_raw_node (null, name, null);
    var e = Xmlx.get_last_error ();
    if (e != null) {
      var errmsg = "Parser Error for string";
      string s = libxml2_error_to_string (e);
      if (s != null)
        errmsg = ".  ";
      throw new GXml.Error.PARSER (errmsg);
    }
    return new GElement (this, el);
  }
  public GXml.Node create_text (string text)
  {
    var t = doc->new_text (text);
    return new GText (this, t);
  }
  public GXml.Node create_cdata (string text)
  {
    var cd = doc->new_cdata_block (text, text.length);
    return new GCDATA (this, cd);
  }
  public override string to_string ()
  {
#if DEBUG
    GLib.message ("TwDocument: to_string ()");
#endif
    Xml.Doc doc = new Xml.Doc ();
    Xml.TextWriter tw = Xmlx.new_text_writer_doc (ref doc);
    TwDocument.write_document (this, tw);
    string str;
    int size;
    doc.dump_memory (out str, out size);
    return str;
  }
  /**
   * Uses libxml2 internal dump to memory function over owned 
   */
  public string libxml_to_string () {
    string buffer;
    doc->dump_memory (out buffer);
    return buffer.dup ();
  }
  public virtual bool save (GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    return save_as (file, cancellable);
  }
  public virtual bool save_as (GLib.File f, GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    return TwDocument.tw_save_as (this, f, cancellable);
  }
}
