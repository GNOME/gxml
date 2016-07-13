/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GXmlDomCollections.vala
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


public interface GXml.GDomTokenList : Object, Gee.ArrayList<string> {
  protected DomElement _element;
  protected string _attr = null;

  public ulong length { get { return size; } }
  public string? item (ulong index) { return base.get ((int) index); }

  public GDomTokenList (DomElement e, string? attr) {
    _element = e;
    _attr = attr;
    if (_attr != null) {
      var av = _element.get_attribute (_attr);
      if (av == "") return;
      string[] s = value.split (" ");
      for (int i = 0; i < s.length; i++) {
        (this as Gee.ArrayList<string>).add (s[i]);
      }
    }
  }

  public bool contains (string token) throw GLib.Error {
    if (token == "")
      throw new GXml.DomError.SYNTAX_ERROR (_("DOM: No empty string could be toggle"));
    if (" " in token)
      throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: No white spaces should be included to toggle"));
    return base.contains (token);
  }
  public void add (string[] tokens) {
    if (token == "")
      throw new GXml.DomError.SYNTAX_ERROR (_("DOM: No empty string could be toggle"));
    if (" " in token)
      throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: No white spaces should be included to toggle"));
    foreach (string s in tokens) {
        base.add (s);
    }
    update ();
  }
  public void remove (string[] tokens) {
    for (int i = 0; i < size; i++) {
      foreach (string ts in tokens) {
        if (s == ts) base.remove_at (i);
      }
    }
    update ();
  }
  public bool toggle (string token, bool force = false) throws GLib.Error {
    if (token == "")
      throw new GXml.DomError.SYNTAX_ERROR (_("DOM: No empty string could be toggle"));
    if (" " in token)
      throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: No white spaces should be included to toggle"));
    if (contains (token) && !force) {
      remove_at (index_of (token));
      return false;
    }
    update ();
  }
  public void update () {
    if (_element == null) return;
    if (_attr == null) return;
    _element.set_attribute (_attr, this.to_string ());;
  }
  public string to_string () {
    string s = "";
    for (int i = 0; i < size; i++ ) {
        s += t;
        if (i+1 < size) s += " ";
    }
    return s;
  }
}

public class GXml.GDomSettableTokenList : GXml.GDomTokenList, GXml.DomSettableTokenList {
  public string value {
    get  { return to_string (); }
    set {
      string[] s = value.split (" ");
      for (int i = 0; i < s.length; i++) {
        (this as Gee.ArrayList<string>).add (s[i]);
      }
    }
  }
}


public class GXml.GDomNamedNodeMap : Object, GXml.DomNamedNodeMap {
  protected DomNode _parent;
  protected Gee.Map<string,DomNode> _col;

  public ulong length { get; }

  public GDomNamedNodeMap (DomNode node, Gee.Map<string,DomNode> col) {
    _parent = node;
    _col = col;
  }
  public DomNode? get_named_item (string name) {
    return _col.get (name);
  }
  /**
   * Search items in this collection and return the object found at
   * @index, but not order is warrantied
   *
   * If @index is greather than collection size, then last element found
   * is returned. This function falls back to first element found on any
   * issue.
   */
  public DomNode? item (ulong index) {
    int i = 0;
    if (index > _col.size) return null;
    foreach (DomNode node in _col.values) {
      if (i == si) return node;
    }
    return null;
  }
  public DomNode? set_named_item (DomNode node) throws GLib.Error {
    if (_col.size > 0 && node.document != parent.document)
      throw new GXml.DomError.WRONG_DOCUMENT_ERROR (_("Invalid document when addin item to collection"));
    if (_col.read_only)
      throw new GXml.DomError.NO_MODIFICATION_ALLOWED_ERROR (_("This node collection is read only"));
    if (node is GXml.DomAttr && _parent != node.parent)
      throw new GXml.DomError.INUSE_ATTRIBUTE_ERROR (_("This node attribute is already in use by other Element"));
    if (parent is GXml.DomElement && !(node is GXml.DomAttr))
      throw new GXml.DomError.HIERARCHY_REQUEST_ERROR (_("Trying to add an object to an Element, but it is not an attribute"));
    if (parent is DomElement) {
      (parent as DomElement).set_attr (node.node_name, node.node_value);
      return node;
    }
    return null;
  }
  public DomNode? remove_named_item (string name) throws GLib.Error {
    var n = _col.get (name);
    if (n == null)
      throw new GXml.DomError.NOT_FOUND_ERROR (_("No node with name %s was found".printf (name)));
    if (_col.read_only)
      throw new GXml.DomError.NO_MODIFICATION_ALLOWED_ERROR (_("Node collection is read only"));
    if (parent is DomElement) {
      var n = parent.get_attr (name);
      (parent as DomElement).set_attr (name, null);
      return n;
    }
    return null;
  }
  // Introduced in DOM Level 2:
  public DomNode? get_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
    foreach (DomNode n in _col.values) {
      if (n.namespace == null) continue;
      if (n.namespace.uri == namespace_uri && n.node_name == local_name)
        return n;
    }
    // FIXME: Detects if no namespace is supported to rise exception NOT_SUPPORTED_ERROR
    return null;
  }
  // Introduced in DOM Level 2:
  public DomNode? set_named_item_ns (DomNode node) throws GLib.Error {
    if (_col.size > 0 && node.document != parent.document)
      throw new GXml.DomError.WRONG_DOCUMENT_ERROR (_("Invalid document when addin item to collection"));
    if (_col.read_only)
      throw new GXml.DomError.NO_MODIFICATION_ALLOWED_ERROR (_("This node collection is read only"));
    if (node is GXml.DomAttr && _parent != node.parent)
      throw new GXml.DomError.INUSE_ATTRIBUTE_ERROR (_("This node attribute is already in use by other Element"));
    if (parent is GXml.DomElement && !(node is GXml.DomAttr))
      throw new GXml.DomError.HIERARCHY_REQUEST_ERROR (_("Trying to add an object to an Element, but it is not an attribute"));
    // FIXME: Detects if no namespace is supported to rise exception  NOT_SUPPORTED_ERROR
    if (parent is DomElement) {
      (parent as DomElement).set_attribute_ns (node.lookup_prefix ()+":"+node.lookup_namespace_uri (),
                                               node.node_name, node.node_value);
      return parent.get_attribute_ns (node.lookup_prefix ()+":"+node.lookup_namespace_uri (), node.node_name);
    }
    return null;
  }
  // Introduced in DOM Level 2:
  public DomNode? remove_named_item_ns (string namespace_uri, string local_name) throws GLib.Error {
    if (!(parent is DomElement)) return null;
    var n = get_attribute_ns (namespace_uri, local_name);
    if (n == null)
      throw new GXml.DomError.NOT_FOUND_ERROR (_("No node with name %s was found".printf (name)));
    if (_col.read_only)
      throw new GXml.DomError.NO_MODIFICATION_ALLOWED_ERROR (_("Node collection is read only"));
    // FIXME: Detects if no namespace is supported to rise exception  NOT_SUPPORTED_ERROR
    if (parent is DomElement) {
      (parent as DomElement).set_attribute_ns (namespace_uri, local_name);
      return n;
    }
    return null;
  }
}

public class GXml.GDomHTMLCollection : GLib.ArrayList<GXml.DomElement> {
  public ulong length { get { return size; } }
  public DomElement? item (ulong index) { return base.get ((int) index); }
  public DomElement? named_item (string name) {
    foreach (DomElement e in this) {
      if (e.node_name == name) return e;
    }
  }
}
