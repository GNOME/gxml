/* GElement.vala
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

/**
 * Class implemeting {@link GXml.Element} interface, not tied to libxml-2.0 library.
 */
public class GXml.GElement : GXml.GNode, GXml.Element
{
  public GElement (GDocument doc, Xml.Node *node) {
    _node = node;
    _doc = doc;
  }
  // GXml.Node
  public override string value
  {
    owned get {
      return content;
    }
    set { content = value; }
  }
  // GXml.Element
  public void set_attr (string aname, string avalue)
  {
    if (":" in aname) {
      string[] cname = aname.split(":");
      if (cname.length > 2) return;
      bool found = false;
      foreach (Namespace ns in namespaces) {
        if (ns.prefix == cname[0]) found = true;
      }
      if (!found) return;
    }
    var a = _node->set_prop (aname, avalue);
  }
  public GXml.Node get_attr (string name)
  {
    if (_node == null) return null;
    var a = _node->has_prop (name);
    if (a == null) return null;
    Test.message ("Element Prop: "+a->name);
    return new GAttribute (_doc, a);
  }
  public void normalize () {}
  public string content {
    owned get {
      return _node->get_content ().dup ();
    }
    set {
      _node->set_content (value);
    }
  }
  public string tag_name { owned get { return _node->name.dup (); } }
}
