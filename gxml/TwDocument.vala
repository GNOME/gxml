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
  Gee.ArrayList<GXml.Node> _namespaces = new Gee.ArrayList<GXml.Node> ();
  GXml.Element _root = null;
  public TwDocument (string file)
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
  public GXml.Node root { get { return _root; } }
  public bool save (GLib.Cancellable? cancellable)
  {
    var tw = new Xml.TextWriter.filename (file.get_path ());
    tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (root == null) tw.end_document ();
    start_node (tw, root);
    tw.write_string (root.value);
    tw.end_element ();
    tw.end_document ();
    return true;
  }
  public void start_node (Xml.TextWriter tw, GXml.Node node)
  {
    if (node is GXml.Element) {
      if (node.namespaces.size > 0) {
        tw.start_element_ns (root.ns_prefix (), root.name, root.ns_uri ());
      } else {
        tw.start_element (root.name);
      }
      foreach (GXml.Node attr in attrs.values) {
        if (attr.namespaces.size > 0)
          tw.write_attribute_ns (attr.ns_prefix (), attr.name, attr.ns_uri (), attr.value);
        else
          tw.write_attribute (attr.name, attr.value);
      }
      foreach (GXml.Node n in childs) {
        if (n is GXml.Element) {
          start_node (tw, n);
          tw.write_string (n.value);
          tw.end_element ();
        }
      }
    }
    if (node is GXml.Comment) {
      tw.write_comment (node.value);
    }
  }
}
