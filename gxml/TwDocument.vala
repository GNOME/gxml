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
    tw = new Xml.TextWriter.filename (file);
    tw->start_document ();
  }
  // GXml.Node
  public override bool set_namespace (string uri, string prefix)
  {
    _namespaces.add (new TwNamespace (this, uri, prefix));
    return true;
  }
  public override GXml.Document document { get { return this; } }
  // GXml.Document
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
    // TODO:
    return false;
  }
}
