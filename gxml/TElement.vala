/* TElement.vala
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

/**
 * Class implemeting {@link GXml.Element} interface, not tied to libxml-2.0 library.
 */
public class GXml.TElement : GXml.TNode, GXml.Element
{
  protected Gee.HashMap<string,GXml.Node> _attrs;
  protected TNode.TChildrenList _children;
  protected Gee.ArrayList<GXml.Node> _namespaces;
  private string _content = null;
  public TElement (GXml.Document d, string name)
    requires (d is TDocument)
  {
    _doc = d;
    _name = name;
  }
  // GXml.Node
  public override string value
  {
    owned get {
      calculate_content ();
      return _content.dup ();
    }
    set { update_content (value); }
  }
  public override Gee.Map<string,GXml.Node> attrs {
    owned get {
      if (_attrs == null) _attrs = new Gee.HashMap<string,GXml.Node> ();
      return _attrs.ref () as Gee.Map<string,GXml.Node>;
    }
  }
  public override Gee.BidirList<GXml.Node> children_nodes {
    owned get {
      if (_children == null) _children  = new TChildrenList (this);
      return _children.ref () as Gee.BidirList<GXml.Node>;
    }
  }
  public override Gee.List<GXml.Namespace> namespaces {
    owned get {
      if (_namespaces == null) _namespaces = new Gee.ArrayList<GXml.Node> ();
      return _namespaces.ref () as Gee.List<GXml.Namespace>;
    }
  }
  // GXml.Element
  public void set_attr (string name, string value)
  {
    if (":" in name) return;
    var att = new TAttribute (document, name, value);
    att.set_parent (this);
    attrs.set (name, att);
  }
  public GXml.Node get_attr (string name) { return attrs.get (name); }
  public GXml.Node get_ns_attr (string name, string uri) {
    foreach (GXml.Node a in attrs.values) {
      if (a.name == name)
        if (((Attribute) a).namespace != null)
          if (((Attribute) a).namespace.uri == uri) return (GXml.Node) a;
    }
    return null;
  }
  public void set_ns_attr (string ns, string name, string value) {
    var att = new TAttribute (document, name, value);
    string prefix = null;
    string uri = "";
    if (":" in ns) {
      string[] s = ns.split (":");
      prefix = s[0];
      uri = s[1];
    } else
      uri = ns;
    att.set_namespace (uri, prefix);
    att.set_parent (this);
    string p = "";
    if (prefix != null) p = prefix;
    attrs.set (p+":"+name, att);
  }
  public void remove_attr (string name) {
    if (attrs.has_key (name)) attrs.unset (name);
  }
  public void remove_ns_attr (string name, string uri) { // TODO: Test me!
    string prefix = "";
    string nuri = "";
    if (":" in uri) {
      string[] s = uri.split(":");
      prefix = s[0];
      nuri = uri;
    } else
      nuri = uri;
    foreach (GXml.Node a in attrs.values) {
      if (a.name == name)
        if (((Attribute) a).namespace != null)
          if (((Attribute) a).namespace.uri == nuri)
            attrs.unset (prefix+":"+a.name);
    }
  }
  public void normalize () {}
  public string content {
    owned get {
      calculate_content ();
      return _content.dup ();
    }
    set {
      update_content (value);
    }
  }
  public string tag_name { owned get { return name; } }
  private void calculate_content ()
  {
    _content = "";
    foreach (GXml.Node n in children_nodes) {
      if (n is Text) {
        _content += n.value;
      }
    }
  }
  private void update_content (string? val)
  {
    // Remove all GXml.Text elements
    for (int i = 0; i < children_nodes.size; i++) {
      var n = children_nodes.get (i);
      if (n is Text) {
        //GLib.message (@"Removing Text at: $i");
        children_nodes.remove_at (i);
      }
    }
    if (val != null) {
      var t = document.create_text (val);
      this.children_nodes.add (t);
    }
  }
}
