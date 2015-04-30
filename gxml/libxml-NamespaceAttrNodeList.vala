/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
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
// FIXME: Port this class as an implementation of Gee interfaces
internal abstract class GXml.AbstractNamespaceAttrNodeList : Object,
  Gee.Traversable<Namespace>, Gee.Iterable<Namespace>, Gee.Collection<Namespace>
{
  protected unowned BackedNode node;

  internal AbstractNamespaceAttrNodeList (BackedNode root) {
    this.node = root;
  }
  public bool add (Namespace item) { return false; }
  public void clear ()
  {
    foreach (Namespace ns in this) {
      remove (ns);
    }
  }
  public bool contains (Namespace nspace)
  {
    foreach (Namespace ns in this) {
      if (nspace.uri == ns.uri && nspace.prefix == ns.prefix) return true;
    }
    return false;
  }
  public bool remove (Namespace ns) {  return false; }
  public bool read_only { get { return true; } }
  public Gee.Collection<Namespace> read_only_view
  {
    owned get { return new NamespaceAttrNodeList (this.node); }
  }
  public int size {
    get {
      int i = 0;
      Xml.Ns* cur = node.node->ns;
      while (cur != null) {
        i++;
        cur = cur->next;
      }
      return i;
    }
  }
  public Gee.Iterator<Namespace> iterator () { return new Iterator (this); }

  public new bool @foreach (Gee.ForallFunc<Namespace> f) {
    return iterator ().foreach (f);
  }
  // Iterator
  internal class Iterator : Object,
    Gee.Traversable<Namespace>, Gee.Iterator<Namespace>
  {
    protected AbstractNamespaceAttrNodeList nl;
    protected Xml.Ns* cur = null;
    protected int i = -1;
    public Iterator (AbstractNamespaceAttrNodeList nl)
    {
      this.nl = nl;
    }
    public new Namespace @get ()
    {
      return (Namespace) new NamespaceAttr (cur, nl.node.owner_document);
    }
    public bool has_next ()
    {
      if (cur == null) {
        if (nl.node.node == null) return false;
        if (nl.node.node->ns == null) return false;
        return true;
      }
      if (cur->next == null) return false;
      return true;
    }
		public bool next ()
    {
      if (cur == null) {
        if (nl.node.node == null) return false;
        if (nl.node.node->ns == null) return false;
        cur = nl.node.node->ns;
        i++;
      }
      if (cur->next == null) return false;
      cur = cur->next;
      return true;
    }
    public void remove () { return; }
    public bool read_only { get { return true; } }
    public bool valid
    {
      get {
        if (cur == null) return false;
        return true;
      }
    }
    public new bool @foreach (Gee.ForallFunc<Namespace> f)
    {
      while (has_next ()) {
        next ();
        if (!f(@get())) return false;
      }
      return true;
    }
  }
}

internal class GXml.NamespaceAttrNodeList : AbstractNamespaceAttrNodeList,
  Gee.List<Namespace>
{
  public NamespaceAttrNodeList (BackedNode root) {
    base (root);
  }
  public new Namespace @get (int index)
  {
    Xml.Ns* cur = null;
    if (this.node.node != null) {
      if (node.node->ns != null) {
        cur = node.node->ns;
        int i = 0;
        while (cur != null) {
          if (index == i) break;
          cur = cur->next;
          i++;
        }
      }
    }
    return (Namespace) new NamespaceAttr (cur, node.owner_document);
  }
  public int index_of (Namespace item)
  {
    int i = -1;
    Xml.Ns* cur = null;
    if (node.node != null) {
      cur = node.node->ns;
      while (cur != null) {
        i++;
        if (item.uri == cur->href && item.prefix == cur->prefix) break;
        cur = cur->next;
      }
    }
    return i;
  }
  public void insert (int index, Namespace item) { return; }
  public new Gee.ListIterator<Namespace> list_iterator () { return new Iterator (this); }
  public Namespace remove_at (int index) { return get (index); }
  public new void @set (int index, Namespace item) { return; }
  public Gee.List<Namespace>? slice (int start, int stop) { return null; }
  public new Gee.List<Namespace> read_only_view
  {
    owned get { return new NamespaceAttrNodeList (this.node); }
  }
  internal class Iterator : AbstractNamespaceAttrNodeList.Iterator,
    Gee.ListIterator<Namespace>
  {
    public Iterator (NamespaceAttrNodeList l) { base (l); }
    public void add (Namespace item) { return; }
    public int index () { return i; }
    public new void @set (Namespace item) { return; }
  }
}
