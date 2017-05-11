/* TNode.vala
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
 * DOM1 Base node abstract class implemeting {@link GXml.Node} interface, not tied to libxml-2.0 library.
 */
public abstract class GXml.TNode : Object, GXml.Node
{
  protected string _name = null;
  protected string _value = null;
  protected GXml.Document _doc;
  protected GXml.Node _parent;
  protected GXml.NodeType _node_type = GXml.NodeType.INVALID;
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
      var nns = new TNamespace (document, uri, prefix);
      document.namespaces.add (nns);
      namespaces.add (nns);
    }
    return true;
  }
  public virtual string to_string () { return get_type ().name (); }
  public virtual Gee.Map<string,GXml.Node> attrs { owned get { return new Gee.HashMap<string,GXml.Node> () as Gee.Map<string,GXml.Node>; } }
  public virtual Gee.BidirList<GXml.Node> children_nodes { owned get { return new TChildrenList (this) as Gee.BidirList<GXml.Node>; } }
  public virtual GXml.Document document { get { return _doc; } }
  public virtual string name { owned get { return _name.dup (); } }
  public virtual Gee.List<GXml.Namespace> namespaces { owned get { return new Gee.ArrayList<GXml.Node> () as Gee.List<GXml.Namespace>; } }
  public virtual GXml.NodeType type_node { get { return _node_type; } }
  public virtual string value { owned get { return _value.dup (); } set  { _value = value; } }
  public virtual GXml.Node parent {
    owned get {
      GXml.Node nullnode = null;
      if (_parent == null) return nullnode;
      return (GXml.Node) _parent.ref ();
    }
  }
  public virtual void set_parent (GXml.Node node) { _parent = node; }
  
  protected class TChildrenList : AbstractBidirList<GXml.Node> {
    private GXml.Node _parent;
    private Gee.ArrayList<GXml.Node> list = new Gee.ArrayList<GXml.Node> ();

    public TChildrenList (GXml.Node e) {
      _parent = e;
    }

    public inline override Gee.BidirListIterator<GXml.Node> bidir_list_iterator () { return list.bidir_list_iterator (); }

    public inline override new GXml.Node @get (int index) { return list.get (index); }
    public inline override int index_of (GXml.Node item) { return list.index_of (item); }
    public inline override void insert (int index, GXml.Node item) { list.insert (index, item); }
    public inline override Gee.ListIterator<GXml.Node> list_iterator () { return list.list_iterator (); }
    public inline override GXml.Node remove_at (int index) { return list.remove_at (index); }
    public inline override new void @set (int index, GXml.Node item) { list.set (index, item); }
    public inline override Gee.List<GXml.Node>? slice (int start, int stop) { return list.slice (start, stop); }

    public override bool add (GXml.Node item) {
#if DEBUG
      GLib.message ("Is TNode: "+(item is TNode).to_string ());
      GLib.message ("Setting new parent to TNode: "+item.name);
#endif
      (item as GXml.TNode).set_parent (_parent);
#if DEBUG
      GLib.message ("Adding new TNode: "+item.name);
#endif
      return list.add (item);
    }
    public inline override void clear () { list.clear (); }
    public inline override bool contains (GXml.Node item) { return list.contains (item); }
    public inline override Gee.Iterator<GXml.Node> iterator () { return list.iterator (); }
    public inline override bool remove (GXml.Node item) { return list.remove (item); }
    public inline override bool read_only { get { return list.read_only; } }
    public inline override int size { get { return list.size; } }
  }
}
