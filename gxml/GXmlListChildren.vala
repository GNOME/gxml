/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* GXmlListChildren.vala
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
 * A {@link Gee.AbstractBidirList} implementation to access {@link Xml.Node} collection
 */
public class GXml.GListChildren : AbstractBidirList<GXml.Node>,
            DomNodeList, DomHTMLCollection
{
  private GXml.GDocument _doc;
  private Xml.Node *_node;
  public GListChildren (GDocument doc, Xml.Node* node) {
    _node = node;
    _doc = doc;
  }
  public new override Gee.BidirListIterator<GXml.Node> bidir_list_iterator () {
    return new Iterator (_doc, _node);
  }
  // List
  public override GXml.Node @get (int index) {
    if (_node == null) return null;
    var n = _node->children;
    int i = 0;
    while (n != null) {
      if (i == index) {
        return GNode.to_gnode (_doc, n);
      }
      i++;
      n = n->next;
    }
    return null;
  }
  public override int index_of (GXml.Node item) {
    if (_node == null) return -1;
    if (!(item is GNode)) return -1;
    var n = _node->children;
    int i = 0;
    while (n != null) {
      if (n == ((GNode) item).get_internal_node ()) return i;
      n = n->next;
      i++;
    }
    return -1;
  }
  /**
   * Insert @item before @index
   */
  public override void insert (int index, GXml.Node item) {
    var n = @get (index);
    if (n == null) return;
    (n as GXml.GNode).get_internal_node ()->add_prev_sibling ((item as GXml.GNode).get_internal_node ());
  }
  public override  Gee.ListIterator<GXml.Node> list_iterator () { return new Iterator (_doc, _node); }
  /**
   * Removes a node at @index. This method never returns a valid pointer.
   */
  public override GXml.Node remove_at (int index) {
    if (index > size || index < 0) return null;
    var n = @get (index);
    if (n == null) return null;
    var np = (n as GXml.GNode).get_internal_node ();
    np->unlink ();
    delete np;
    return null;
  }
  /**
   * This method is ignored by default.
   */
  public override void @set (int index, GXml.Node item) {}
  public override Gee.List<GXml.Node>? slice (int start, int stop) {
    var l = new ArrayList<GXml.Node> ();
    if (_node == null) return l;
    var n = _node->children;
    int i = 0;
    while (n != null) {
      if (i >= start && i <= stop) {
        l.add (GNode.to_gnode (_doc, n));
      }
      n = n->next;
      i++;
    }
    return l;
  }
  public override bool add (GXml.Node item) {
    if (_node == null) return false;
    if (!(item is GNamespace))
      return (_node->add_child (((GNode) item).get_internal_node ())) != null;
    var ns = (GXml.Namespace) item;
    return (_node->new_ns (ns.uri, ns.prefix)) != null;
  }
  public override void clear () {
    if (_node == null) return;
    _node->children->free_list ();
  }
  public override bool contains (GXml.Node item) {
    if (_node == null) return false;
    if (!(item is GXml.GNode)) return false;
    var n = _node->children;
    while (n != null) {
      if (n == ((GXml.GNode) item).get_internal_node ()) return true;
      n = n->next;
    }
    return false;
  }
  public override Gee.Iterator<GXml.Node> iterator () { return new Iterator (_doc, _node); }
  public override bool remove (GXml.Node item) {
    if (_node == null) return false;
    if (!(item is GXml.GNode)) return false;
    var n = _node->children;
    while (n != null) {
      if (n == ((GXml.GNode) item).get_internal_node ()) {
        n->unlink ();
        delete n;
        return true;
      }
      n = n->next;
    }
    return false;
  }
  public override int size {
    get {
      if (_node == null) return -1;
      int i = 0;
      var n = _node->children;
      while (n != null) {
        i++;
        n = n->next;
      }
      return i;
    }
  }
  public override bool read_only { get { return false; } }
  // Iterator
  public class Iterator : Object, Traversable<GXml.Node>,
                          Gee.Iterator<GXml.Node>,
                          Gee.BidirIterator<GXml.Node>,
                          Gee.ListIterator<GXml.Node>,
                          BidirListIterator<GXml.Node> {
    private GDocument _doc;
    private Xml.Node *_node;
    private Xml.Node *_current;
    private int i = 0;
    public Iterator (GDocument doc, Xml.Node *node) {
      _node = node;
      _current = _node->children;
      _doc = doc;
    }
    /**
     * This method is ignored by default.
     */
    public void insert (GXml.Node item) {}
    // ListIterator
    /**
     * This method is ignored by default.
     */
    public void add (GXml.Node item) {}
    public int index () { return i; }
    /**
     * This method is ignored by default.
     */
    public new void @set (GXml.Node item) {}
    // Iterator
    public new GXml.Node @get () { return GNode.to_gnode (_doc, _node); }
    public bool has_next () {
      if (_node == null) return false;
      if (_node->children == null) return false;
      if (_current != null)
        if (_current->next != null) return true;
      return (_node->children->next != null);
    }
    public bool next () {
      if (!has_next ()) return false;
      if (_node->children == null) return false;
      if (_current == null)
        _current = _node->children;
      if (_current->next == null) return false;
      _current = _current->next;
      return true;
    }
    public void remove () {
      if (_current == null) return;
      var n = _current;
      _current = _current->prev;
      n->unlink ();
      delete n;
    }
    public bool read_only { get { return false; } }
    public bool valid { get { return (_current != null); } }
    public new bool @foreach (Gee.ForallFunc<GXml.Node> f) {
      while (has_next ()) {
        next ();
        if (!f(@get())) return false;
      }
      return true;
    }
    public bool first () {
      if (_node == null) return false;
      if (_node->children == null) return false;
      return (_current = _node->children) != null;
    }
    public bool has_previous () {
      if (_node == null) return false;
      if (_node->children == null) return false;
      if (_current == null) return false;
      if (_current->prev == null) return false;
      return true;
    }
    public bool last () {
      if (_node == null) return false;
      if (_node->children == null) return false;
      _current = _node->children;
      while (_current->next != null) {
        _current = _current->next;
      }
      return true;
    }
    public bool previous () {
      if (_node == null) return false;
      if (_node->children == null) return false;
      if (_current == null) {
        _current = _node->children;
        return true;
      }
      while (_current->prev != null) {
        _current = _current->prev;
      }
      return true;
    }
  }
  // DomNodeList implementation
  public DomNode? item (ulong index) { return (DomNode) @get ((int) index); }
  public ulong length { get { return (ulong) size; } }
  // DomHTMLCollection
  public new GXml.DomElement? get_element (int index) {
    if (index > this.size || index < 0) return null;
    var e = this.get (index);
    if (!(e is DomNode)) return null;
    return (GXml.DomElement) e;
  }
}

