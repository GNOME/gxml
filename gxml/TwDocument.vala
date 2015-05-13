/* Element.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
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

public class GXml.TwDocument : GXml.TwNode, GXml.Document
{
  GXml.Element _root = null;
  construct {
    _name = "#document";
  }
  public TwDocument () {}
  public TwDocument.for_path (string file)
  {
    var f = File.new_for_path (file);
    this.file = f;
  }
  // GXml.Node
  public override bool set_namespace (string uri, string? prefix)
  {
    _namespaces.add (new TwNamespace (this, uri, prefix));
    return true;
  }
  public override GXml.Document document { get { return this; } }
  // GXml.Document
  public bool indent { get; set; default = false; }
  public bool ns_top { get; set; default = false; }
  public bool prefix_default_ns { get; set; default = false; }
  public GLib.File file { get; set; }
  public GXml.Node root {
    get {
      if (_root == null) {
        int found = 0;
        for (int i = 0; i < childs.size; i++) {
          GXml.Node n = childs.get (i);
          if (n is GXml.Element) {
            found++;
            if (found == 1)
              _root = (GXml.Element) n;
          }
        }
        if (found > 1) {
          GLib.warning ("Document have more than one root GXmlElement. Using first found");
        }
      }
      return _root;
    }
  }
  public GXml.Node create_comment (string text)
  {
    var c = new TwComment (this, text);
    return c;
  }
  public GXml.Node create_pi (string target, string data)
  {
    var pi = new TwProcessingInstruction (this, target, data);
    return pi;
  }
  public GXml.Node create_element (string name)
  {
    return new TwElement (this, name);
  }
  public GXml.Node create_text (string text)
  {
    var t = new TwText (this, text);
    return t;
  }
  public GXml.Node create_cdata (string text)
  {
    var t = new TwCDATA (this, text);
    return t;
  }
  public bool save (GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    if (file == null) return false;
    return save_to (file, cancellable);
  }
  public bool save_to (GLib.File f, GLib.Cancellable? cancellable = null)
  {
    var tw = new Xml.TextWriter.filename (f.get_path ());
    write_document (tw);
    return true;
  }
  public virtual void write_document (Xml.TextWriter tw)
  {
    tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (root == null) {
      tw.end_document ();
    }
#if DEBUG
    GLib.message ("Starting writting Document Root node");
#endif
    start_node (tw, root, true);
#if DEBUG
    GLib.message ("Ending writting Document Root node");
#endif
    tw.end_element ();
#if DEBUG
    GLib.message ("Ending Document");
#endif
    tw.end_document ();
    tw.flush ();
  }
  public virtual void start_node (Xml.TextWriter tw, GXml.Node node, bool root)
  {
    int size = 0;
#if DEBUG
    GLib.message (@"Starting Node: start Node: '$(node.name)'");
#endif
    if (node is GXml.Element) {
#if DEBUG
    GLib.message (@"Starting Element... '$(node.name)'");
    GLib.message (@"Element Document is Null... '$((node.document == null).to_string ())'");
    GLib.message (@"Namespaces in Element... '$(node.namespaces.size)'");
#endif
      if (root) {
        if (node.document.namespaces.size > 0) {
          var dns = node.document.namespaces.get (0);
          assert (dns != null);
          if (prefix_default_ns)
            tw.start_element_ns (dns.prefix, node.name, dns.uri);
          else {
            // Write default namespace no prefix
            tw.start_element (node.name);
            if (dns.prefix == null)
              tw.write_attribute ("xmlns",dns.uri);
            else
              tw.write_attribute ("xmlns:"+dns.prefix,dns.uri);
          }
          if (node.document.namespaces.size > 1 && node.document.ns_top) {
            for (int i = 1; i < node.document.namespaces.size; i++) {
              GXml.Namespace ns = node.document.namespaces.get (i);
              tw.write_attribute ("xmlns:"+ns.prefix, ns.uri);
            }
          }
        }
        else
          tw.start_element (node.name);
      }
      else {
        if (node.namespaces.size > 0) {
#if DEBUG
      GLib.message ("Starting Element: start with NS");
#endif
          if (node.document.namespaces.first ().uri == node.ns_uri () && !node.document.prefix_default_ns) {
            // Don't prefix. Using default namespace and prefix_default_ns = false
            tw.start_element (node.name);
          }
          else
            tw.start_element_ns (node.ns_prefix (), node.name, node.ns_uri ());
        } else {
#if DEBUG
      GLib.message ("Starting Element: start no NS");
#endif
          tw.start_element (node.name);
        }
      }
#if DEBUG
    GLib.message ("Starting Element: writting attributes");
#endif
      foreach (GXml.Node attr in node.attrs.values) {
        if (attr.namespaces.size > 0) {
#if DEBUG
    GLib.message ("Starting Element: write attribute with NS");
#endif
          size += tw.write_attribute_ns (attr.ns_prefix (), attr.name, attr.ns_uri (), attr.value);
        }
        else {
#if DEBUG
    GLib.message ("Starting Element: write attribute no NS");
#endif
          size += tw.write_attribute (attr.name, attr.value);
        }
        if (size > 1500)
          tw.flush ();
      }
#if DEBUG
    GLib.message (@"Starting Element: writting Node '$(node.name)' childs");
#endif
      foreach (GXml.Node n in node.childs) {
#if DEBUG
    GLib.message (@"Child Node is: $(n.get_type ().name ())");
#endif
        if (n is GXml.Element) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting Node '$(n.name)'");
#endif
          start_node (tw, n, false);
          size += tw.end_element ();
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.Text) {
          //GLib.message ("Writting Element's contents");
          size += tw.write_string (node.value);
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.Comment) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting Comment '$(n.value)'");
#endif
          size += tw.write_comment (n.value);
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.CDATA) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting CDATA '$(n.value)'");
#endif
          size += Xmlx.text_writer_write_cdata (tw, n.value);
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.ProcessingInstruction) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting ProcessingInstruction '$(n.value)'");
#endif
          size += Xmlx.text_writer_write_pi (tw, ((ProcessingInstruction) n).target, ((ProcessingInstruction) n).data);
          if (size > 1500)
            tw.flush ();
        }
      }
    }
  }
  public override string to_string ()
  {
#if DEBUG
    GLib.message ("TwDocument: to_string ()");
#endif
    Xml.Doc doc = new Xml.Doc ();
    Xml.TextWriter tw = Xmlx.new_text_writer_doc (ref doc);
    write_document (tw);
    string str;
    int size;
    doc.dump_memory (out str, out size);
    return str;
  }
}
