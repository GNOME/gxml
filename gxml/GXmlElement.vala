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
    if (_node == null) return;
    if (":" in aname) return;
    _node->set_prop (aname, avalue);
  }
  public GXml.Node get_attr (string name)
  {
    if (_node == null) return null;
    string prefix = "";
    string n = name;
    if (":" in name) {
      string[] pp = name.split (":");
      if (pp.length != 2) return null;
      Test.message ("Checking for namespaced attribute: "+name);
      prefix = pp[0];
      n = pp[1];
    }
    var ps = _node->properties;
    Test.message ("Name= "+n+" Prefix= "+prefix);
    while (ps != null) {
      Test.message ("At Attribute: "+ps->name);
      if (ps->name == n) {
        if (ps->ns == null && prefix == "") return new GAttribute (_doc, ps);
        if (ps->ns == null) continue;
        if (ps->ns->prefix == prefix)
          return new GAttribute (_doc, ps);
      }
      ps = ps->next;
    }
    return null;
  }
  public void set_ns_attr (Namespace ns, string name, string uri) {
    if (_node == null) return;
    var ins = _node->doc->search_ns (_node, ns.prefix);
    if (ins != null) {
      _node->set_ns_prop (ins, name, uri);
      return;
    }
  }
  public GXml.Node get_ns_attr (string name, string uri) {
    if (_node == null) return null;
    var a = _node->has_ns_prop (name, uri);
    if (a == null) return null;
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
  public void remove_attr (string name) {
    if (_node == null) return;
    var a = _node->has_prop (name);
    if (a == null) return;
    a->remove ();
  }
  public string tag_name { owned get { return _node->name.dup (); } }
  public override string to_string () {
    var buf = new Xml.Buffer ();
    buf.node_dump (_node->doc, _node, 1, 0);
    return buf.content ().dup ();
  }
}
