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
  protected FileIOStream _doc_iostream;
  GXml.Element _root = null;
  public TwDocument ()
  {
    try  {
      file = GLib.File.new_tmp (null, out _doc_iostream);
    } catch (GLib.Error e) {
      GLib.warning ("Couldn't create temporaly file for TwDocument:"+e.message);
    }
  }
  public TwDocument.for_path (string file)
  {
    var f = File.new_for_path (file);
    this.file = f;
  }
  // GXml.Node
  public override bool set_namespace (string uri, string prefix)
  {
    _namespaces.add (new TwNamespace (this, uri, prefix));
    return true;
  }
  public override GXml.Document document { get { return this; } }
  // GXml.Document
  public bool indent { get; set; default = false; }
  public GXml.Node create_comment (string text)
  {
    var c = new TwComment (this, text);
    if (root == null)
      return c;
    root.childs.add (c);
    return c;
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
          GLib.warning ("Document have more than one GXmlElement. Using first found");
        }
      }
      return _root;
    }
  }
  public bool save (GLib.Cancellable? cancellable = null)
    throws GLib.Error
    requires (file != null)
  {
    return save_to (file, cancellable);
  }
  public bool save_to (GLib.File f, GLib.Cancellable? cancellable = null)
  {
    var tw = new Xml.TextWriter.filename (f.get_path ());
    tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (root == null) {
      tw.end_document ();
      return true;
    }
#if DEBUG
    GLib.message ("Starting writting Document Root node");
#endif
    start_node (tw, root);
#if DEBUG
    GLib.message ("Writting Document Root node's contents");
#endif
    tw.write_string (root.value);
#if DEBUG
    GLib.message ("Ending writting Document Root node");
#endif
    tw.end_element ();
#if DEBUG
    GLib.message ("Ending Document");
#endif
    tw.end_document ();
    tw.flush ();
    return true;
  }
  public void start_node (Xml.TextWriter tw, GXml.Node node)
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
      if (node.namespaces.size > 0) {
#if DEBUG
    GLib.message ("Starting Element: start with NS");
#endif
        tw.start_element_ns (node.ns_prefix (), node.name, node.ns_uri ());
      } else {
#if DEBUG
    GLib.message ("Starting Element: start no NS");
#endif
        tw.start_element (node.name);
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
        if (n is GXml.Element) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting Node '$(n.name)'");
#endif
          start_node (tw, n);
          if (n.value != null)
            tw.write_string (n.value);
          size += tw.end_element ();
          if (size > 1500)
            tw.flush ();
        }
      }
    }
    if (node is GXml.Comment) {
      size += tw.write_comment (node.value);
      if (size > 1500)
        tw.flush ();
    }
    if (node is GXml.Text) {
      size += tw.write_string (node.value);
      if (size > 1500)
        tw.flush ();
    }
  }
  public override string to_string ()
  {
    GLib.message ("TwDocument: to_string ()");
    try {
      var f = GLib.File.new_tmp (null, null);
      save_to (f);
      uint8 buffer[10000];
      var istream = f.read ();
      istream.read (buffer);
      istream.close ();
      f.delete ();
      return (string) buffer;
    } catch (GLib.Error e) {
#if DEBUG
      GLib.message ("Error on stringify this TwDocuent: "+e.message);
#endif
    }
    return "";
  }
}
