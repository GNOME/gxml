/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* GXmlHashMapAttr.vala
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
 * Implementation of {@link Gee.AbstractMap} to handle {@link Xml.Node} attributes
 */
public class GXml.GHashMapAttr : Gee.AbstractMap<string,GXml.Node>
{
  private GDocument _doc;
  private Xml.Node *_node;
  public GHashMapAttr (GDocument doc, Xml.Node *node) {
    _node = node;
    _doc = doc;
  }
  
  public class Entry : Gee.Map.Entry<string,GXml.Node> {
    private GXml.GDocument _doc;
    private Xml.Attr *_attr;
    private GAttribute oattr;
    public Entry (GDocument doc, Xml.Attr *attr) {
      _attr = attr;
      _doc = doc;
      oattr = new GAttribute (_doc, _attr);
    }
    public override string key { get { return _attr->name; } }
    public override bool read_only { get { return true; } }
    public override GXml.Node value {
      get { return oattr; }
      set {}
    }
  }
  public override void clear () {
    if (_node == null) return;
    var p = _node->properties;
    while (p != null) {
      var pn = p;
      p = p->next;
      pn->remove ();
    }
  }
  public override GXml.Node @get (string key) {
    if (_node == null) return null;
    if (":" in key) {
      string[] pp = key.split (":");
      if (pp.length != 2) return null;
      var ps = _node->properties;
      var prefix = pp[0];
      var n = pp[1];
      while (ps != null) {
        if (ps->name == n) {
          if (ps->ns == null) continue;
          if (ps->ns->prefix == prefix)
            return new GAttribute (_doc, ps);
        }
        ps = ps->next;
      }
    }
    var p = _node->has_prop (key);
    if (p == null) return null;
    // Check property found has Ns, then try to find one without it to return instead
    if (p->ns != null) {
      var npns = _node->has_ns_prop (key, null);
      if (npns != null)
        return new GAttribute (_doc, npns);
    }
    return new GAttribute (_doc, p);
  }
  public override bool has (string key, GXml.Node value) { return has_key (key); }
  public override bool has_key (string key) {
    if (_node == null) return false;
    var p = _node->properties;
    while (p != null) {
      if (p->name == key) return true;
    }
    return false;
  }
  public override Gee.MapIterator<string,GXml.Node> map_iterator () { return new Iterator (_doc, _node); }
  public override void @set (string key, GXml.Node value) {
    if (_node == null) return;
    _node->new_prop (key, value.@value);
  }
  public override bool unset (string key, out GXml.Node value = null) {
    if (_node == null) return false;
    var p = _node->has_prop (key);
    if (p == null) return false;
    p->remove ();
    value = null;
    return true;
  }
  public override Gee.Set<Gee.Map.Entry<string,GXml.Node>> entries {
    owned get {
      var l = new Gee.HashSet<Entry> ();
      if (_node == null) return l;
      var p = _node->properties;
      while (p != null) {
        var e = new Entry (_doc, p);
        l.add (e);
        p = p->next;
      }
      return l;
    }
  }
  public override Gee.Set<string> keys {
    owned get {
      var l = new Gee.HashSet<string> ();
      if (_node == null) return l;
      var p = _node->properties;
      while (p != null) {
        l.add (p->name.dup ());
      }
      return l;
    }
  }
  public override bool read_only { get { return false; } }
  public override int size {
    get {
      var p = _node->properties;
      int i = 0;
      while (p != null) {
        p = p->next;
        i++;
      }
      return i;
    }
  }
  public override Gee.Collection<GXml.Node> values {
    owned get {
      var l = new ArrayList<GXml.Node> ();
      var p = _node->properties;
      while (p != null) {
        l.add (new GAttribute (_doc, p));
        p = p->next;
      }
      return l;
    }
  }
  public class Iterator : Object, MapIterator<string,GXml.Node> {
    private GXml.GDocument _doc;
    private Xml.Node *_node;
    private Xml.Attr *_current;

    public Iterator (GXml.GDocument doc, Xml.Node *node) {
      _node = node;
      _current = null;
      _doc = doc;
    }

    public string get_key () {
      if (_current != null) _current->name.dup ();
      return null;
    }
    public GXml.Node get_value () {
      return new GAttribute (_doc, _current);
    }
    public bool has_next () {
      if (_node->properties == null) return false;
      if (_current != null)
        if (_current->next == null) return false;
      return true;
    }
    public bool next () {
      if (_node->properties == null) return false;
      if (_current == null)
        _current = _node->properties;
      if (_current->next == null) return false;
      _current = _current->next;
      return true;
    }
    public void set_value (GXml.Node value) {
      if (_current == null) return;
      if (_current->name == value.name) {
        var p = _node->properties;
        while (p != null) {
          if (p->name == value.name) {
            _node->set_prop (value.name, @value.value);
          }
        }
      }
    }
    public void unset () {
      if (_current == null) return;
      _node->set_prop (_current->name, null);
    }
    public bool mutable { get { return false; } }
    public bool read_only { get { return false; } }
    public bool valid { get { return _current != null; } }
  }
}
