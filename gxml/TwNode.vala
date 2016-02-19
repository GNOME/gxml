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

/**
 * Base node abstract class implemeting {@link GXml.Node} interface, not tied to libxml-2.0 library.
 */
public abstract class GXml.TwNode : Object, GXml.Node
{
  protected string _name = null;
  protected string _value = null;
  protected GXml.Document _doc;
  protected GXml.Node _parent;
  internal Xml.TextWriter *tw;

	construct { Init.init (); }

  // GXml.Node
  public virtual bool set_namespace (string uri, string? prefix)
  {
    bool found = false;
    foreach (GXml.Namespace ns in document.namespaces) {
      if (ns.uri == uri && ns.prefix == prefix) {
        namespaces.add (ns);
        found = true;
      }
    }
    if (!found) {
      var nns = new TwNamespace (document, uri, prefix);
      document.namespaces.add (nns);
      namespaces.add (nns);
    }
    return true;
  }
  public virtual string to_string () { return get_type ().name (); }
  public virtual Gee.Map<string,GXml.Node> attrs { owned get { return new Gee.HashMap<string,GXml.Node> (); } }
  public virtual Gee.BidirList<GXml.Node> children { owned get { return new TwChildrenList (this); } }
  public virtual GXml.Document document { get { return _doc; } }
  public virtual string name { owned get { return _name.dup (); } }
  public virtual Gee.List<GXml.Namespace> namespaces { owned get { return new Gee.ArrayList<GXml.Node> (); } }
  public virtual GXml.NodeType type_node { get { return GXml.NodeType.DOCUMENT; } }
  public virtual string value { owned get { return _value.dup (); } set  { _value = value; } }
  public virtual GXml.Node parent { owned get { return _parent; } }
  public virtual void set_parent (GXml.Node node) { _parent = node; }
  
  protected class TwChildrenList : Gee.ArrayList<GXml.Node> {
    GXml.Node _parent;
    protected TwChildrenList (GXml.Node e) {
      _parent = e;
    }
    protected new bool add (GXml.Node node) {
      (node as GXml.TwNode).set_parent (_parent);
      return base.add (node);
    }
  }
}
