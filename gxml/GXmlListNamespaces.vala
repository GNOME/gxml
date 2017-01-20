/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* GXmlListNamespaces.vala
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
 * A {@link Gee.AbstractList} implementation to access {@link Xml.Ns} namespaces collection
 */
public class GXml.GListNamespaces : Gee.AbstractList<GXml.Namespace>
{
  private GDocument _doc;
  private Xml.Node *_node;
  public GListNamespaces (GDocument doc, Xml.Node *node) {
    _node = node;
    _doc = doc;
  }
  // List
  public override new GXml.Namespace @get (int index) {
    GXml.Namespace nullns = null;
    if (_node == null) return nullns;
    var ns = _node->ns_def;
    int i = 0;
    while (ns != null) {
      if (i == index) {
        return new GNamespace (ns);
      }
      ns = ns->next;
      i++;
    }
    return nullns;
  }
  public override int index_of (GXml.Namespace item) {
    if (_node == null) return -1;
    if (!(item is GNamespace)) return -1;
    var ns = _node->ns_def;
    int i = 0;
    while (ns != null) {
      if (((GNamespace) item).get_internal_ns () == ns) return i;
      ns = ns->next;
      i++;
    }
    return -1;
  }
  public override void insert (int index, GXml.Namespace item) {}
  public override Gee.ListIterator<GXml.Namespace> list_iterator () { return new Iterator (_node); }
  public override GXml.Namespace remove_at (int index) {
    GXml.Namespace nullns = null;
    return nullns;
  }
  public override new void @set (int index, GXml.Namespace item) {}
  public override Gee.List<GXml.Namespace>? slice (int start, int stop) {
    var l = new ArrayList<GXml.Namespace> ();
    if (_node == null) return l;
    var ns = _node->ns_def;
    int i = 0;
    while (ns != null) {
      if (i >= start && i <= stop) {
        l.add (new GNamespace (ns));
      }
      ns = ns->next;
      i++;
    }
    return l;
  }
  // Collection
  public override bool add (GXml.Namespace item) {
    if (!(item is Namespace)) return false;
    if (_node == null) return false;
    return (_node->new_ns (((Namespace) item).uri, ((Namespace) item).prefix)) != null;
  }
  public override void clear () {}
  public override bool contains (GXml.Namespace item) {
    if (!(item is GNamespace)) return false;
    if (_node == null) return false;
    var ns = _node->ns_def;
    while (ns != null) {
      if (ns == ((GNamespace) item).get_internal_ns ()) return true;
    }
    return false;
  }
  public override Gee.Iterator<GXml.Namespace> iterator () { return new Iterator (_node); }
  public override bool remove (GXml.Namespace item) { return false; }
  public override bool read_only { get { return false; } }
  public override int size {
    get {
      if (_node == null) return -1;
      var ns = _node->ns_def;
      int i = 0;
      while (ns != null) {
        i++;
        ns = ns->next;
      }
      return i;
    }
  }
  public class Iterator : Object, Gee.Traversable<GXml.Namespace>, Gee.Iterator<GXml.Namespace>,
                          Gee.ListIterator<GXml.Namespace> {
    private Xml.Node *_node;
    private Xml.Ns *_current;
    private int i = -1;
    public Iterator (Xml.Node *node) {
      _node = node;
    }
    // ListIterator
    public void add (GXml.Namespace item) {
      if (_node == null) return;
      if (!(item is GXml.Namespace)) return;
      var ns = (GXml.Namespace) item;
      _node->new_ns (ns.uri, ns.prefix);
    }
    public int index () { return i; }
    public new void @set (GXml.Namespace item) {}
    // Iterator
    public new GXml.Namespace @get () { return new GNamespace (_current); }
    public bool has_next ()  {
      if (_node->ns_def == null) return false;
      if (_current != null)
        if (_current->next == null) return false;
      return true;
    }
		public bool next () {
      if (_node->ns_def == null) return false;
      if (_current == null)
        _current = _node->ns_def;
      if (_current->next == null) return false;
      _current = _current->next;
      return true;
    }
    public void remove () {}
    public bool read_only { get { return false; } }
    public bool valid { get { return (_current != null); } }
    // Traversable
    public new bool @foreach (Gee.ForallFunc<GXml.Namespace> f) {
      while (has_next ()) {
        next ();
        if (!f(@get())) return false;
      }
      return true;
    }
  }
}
