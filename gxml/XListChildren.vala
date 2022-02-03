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
public class GXml.XListChildren : AbstractBidirList<GXml.DomNode>,
            DomNodeList, DomHTMLCollection
{
  private GXml.XDocument _doc;
  private Xml.Node *_node;
  public XListChildren (XDocument doc, Xml.Node* node) {
    _node = node;
    _doc = doc;
  }
  public new override Gee.BidirListIterator<GXml.DomNode> bidir_list_iterator () {
    return new Iterator (_doc, _node);
  }
  // List
  public override GXml.DomNode @get (int index) {
    GXml.DomNode nullnode = null;
    if (_node == null) return nullnode;
    var n = _node->children;
    int i = 0;
    while (n != null) {
      if (i == index) {
        return XNode.to_gnode (_doc, n, false);
      }
      i++;
      n = n->next;
    }
    return nullnode;
  }
  public override int index_of (GXml.DomNode item) {
    if (_node == null) return -1;
    if (!(item is XNode)) return -1;
    var n = _node->children;
    int i = 0;
    while (n != null) {
      if (n == ((XNode) item).get_internal_node ()) return i;
      n = n->next;
      i++;
    }
    return -1;
  }
  /**
   * Insert @item before @index
   */
  public override void insert (int index, GXml.DomNode item) {
    var n = @get (index);
    if (n == null) return;
    ((XNode) item).release_node ();
    ((GXml.XNode) n).get_internal_node ()->add_prev_sibling (((GXml.XNode) item).get_internal_node ());
  }
  public override  Gee.ListIterator<GXml.DomNode> list_iterator () { return new Iterator (_doc, _node); }
  /**
   * Removes a node at @index. This method never returns a valid pointer.
   */
  public override GXml.DomNode remove_at (int index) {
    GXml.DomNode nullnode = null;
    if (index > size || index < 0) return nullnode;
    var n = @get (index);
    if (n == null) return nullnode;
    var np = ((GXml.XNode) n).get_internal_node ();
    np->unlink ();
    ((GXml.XNode) n).take_node ();
    return n;
  }
  /**
   * This method is ignored by default.
   */
  public override void @set (int index, GXml.DomNode item) {}
  public override Gee.List<GXml.DomNode>? slice (int start, int stop) {
    var l = new Gee.ArrayList<GXml.DomNode> ();
    if (_node == null) return l;
    var n = _node->children;
    int i = 0;
    while (n != null) {
      if (i >= start && i <= stop) {
        l.add (XNode.to_gnode (_doc, n, false));
      }
      n = n->next;
      i++;
    }
    return l;
  }
  public override bool add (GXml.DomNode item) {
    if (_node == null) return false;
    ((XNode) item).release_node ();
    return (_node->add_child (((XNode) item).get_internal_node ())) != null;
  }
  public override void clear () {
    if (_node == null) return;
    _node->children->free_list ();
  }
  public override bool contains (GXml.DomNode item) {
    if (_node == null) return false;
    if (!(item is GXml.XNode)) return false;
    var n = _node->children;
    while (n != null) {
      if (n == ((GXml.XNode) item).get_internal_node ()) return true;
      n = n->next;
    }
    return false;
  }
  public override Gee.Iterator<GXml.DomNode> iterator () { return new Iterator (_doc, _node); }
  public override bool remove (GXml.DomNode item) {
    if (_node == null) return false;
    if (!(item is GXml.XNode)) return false;
    var n = _node->children;
    while (n != null) {
      if (n == ((GXml.XNode) item).get_internal_node ()) {
        n->unlink ();
        ((GXml.XNode) item).take_node ();
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
  public class Iterator : GLib.Object, Traversable<GXml.DomNode>,
                          Gee.Iterator<GXml.DomNode>,
                          Gee.BidirIterator<GXml.DomNode>,
                          Gee.ListIterator<GXml.DomNode>,
                          BidirListIterator<GXml.DomNode> {
    private XDocument _doc;
    private Xml.Node *_node;
    private Xml.Node *_current;
    private int i = 0;
    public Iterator (XDocument doc, Xml.Node *node) {
      _node = node;
      _current = _node->children;
      _doc = doc;
    }
    /**
     * This method is ignored by default.
     */
    public void insert (GXml.DomNode item) {}
    // ListIterator
    /**
     * This method is ignored by default.
     */
    public void add (GXml.DomNode item) {}
    public int index () { return i; }
    /**
     * This method is ignored by default.
     */
    public new void @set (GXml.DomNode item) {}
    // Iterator
    public new GXml.DomNode @get () { return XNode.to_gnode (_doc, _node, false); }
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
    public new bool @foreach (Gee.ForallFunc<GXml.DomNode> f) {
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
  public DomNode? item (int index) { return (DomNode) @get (index); }
  public int length { get { return size; } }
  // DomHTMLCollection
  public new GXml.DomElement? get_element (int index) {
    if (index > this.size || index < 0) return null;
    var e = this.get (index);
    if (!(e is DomNode)) return null;
    return (GXml.DomElement) e;
  }
}

