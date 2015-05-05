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

public abstract class GXml.TwNode : Object, GXml.Node
{
  protected Gee.HashMap<string,GXml.Node> _attrs = new Gee.HashMap<string,GXml.Node> ();
  protected Gee.ArrayList<GXml.Node> _childs = new Gee.ArrayList<GXml.Node> ();
  protected Gee.ArrayList<GXml.Node> _namespaces = new Gee.ArrayList<GXml.Node> ();
  protected string _name = null;
  protected string _value = null;
  protected GXml.Document _doc;
  internal Xml.TextWriter *tw;

  // GXml.Node
  public virtual bool set_namespace (string uri, string prefix)
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
  public virtual Gee.Map<string,GXml.Node> attrs { get { return _attrs; } }
  public virtual Gee.BidirList<GXml.Node> childs { get { return _childs; } }
  public virtual GXml.Document document { get { return _doc; } }
  public virtual string name { get { return _name; } }
  public virtual Gee.List<GXml.Namespace> namespaces { get { return _namespaces; } }
  public virtual GXml.NodeType type_node { get { return GXml.NodeType.DOCUMENT; } }
  public virtual string value { get { return _value; } set  { _value = value; } }
}
