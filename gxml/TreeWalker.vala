/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GDocument.vala
 *
 * Copyright (C) 2018  Daniel Espinosa <esodan@gmail.com>
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

/**
 * Implementation of {@link DomTreeWalker}
 */
public class GXml.TreeWalker : GLib.Object, GXml.DomTreeWalker {
  protected DomNode _root;
  protected int _what_to_show;
  protected  DomNode _current_node = null;

  public DomNode root { get { return root; } }
  public int what_to_show { get { return _what_to_show; } }
  public DomNode current_node { get { return _current_node; } }

  public TreeWalker (DomNode root, int w) {
    _root = root;
    _what_to_show = w;
    _current_node = root;
  }

  public DomNode? parent_node() {
    if (current_node == null) return null;
    var p = current_node.parent_node;
    if (p == null) return null;
    if (accept_node (p) != DomNodeFilter.Filter.ACCEPT) {
      return null;
    }
    if (p == root) return  null;
    _current_node = p;
    return _current_node;
  }
  public DomNode? first_child () {
    return traverse (true);
  }
  public DomNode? last_child () {
    return traverse (false);
  }
  public DomNode? previous_sibling () {
    return traverse_sibling (false);
  }
  public DomNode? next_sibling () {
    return traverse_sibling (true);
  }
  public DomNode? previous_node () { return null; }// FIXME
  public DomNode? next_node () { return null; }// FIXME

  private DomNode? traverse (bool first) {
    if (current_node == null) return null;
    DomNode n = null;
    if (first) {
      n = current_node.first_child;
    } else {
      n = current_node.last_child;
    }
    if (n == null) return null;
    while (n != null) {
      var res = DomNodeFilter.Filter.ACCEPT;
      res = accept_node (n);
      if (res == DomNodeFilter.Filter.ACCEPT) {
        _current_node = n;
        return _current_node;
      }
      if (res == DomNodeFilter.Filter.SKIP) {
        DomNode c = null;
        if (first) {
          c = n.first_child;
        } else {
          c = n.last_child;
        }
        if (c != null) {
          n = c;
          continue;
        }
        DomNode s = null;
        if (first) {
          s = n.next_sibling;
        } else {
          s = n.previous_sibling;
        }
        if (s != null) {
          n = s;
          continue;
        }
        if (n.parent_node == null
            || n.parent_node == root
            || n.parent_node == current_node) {
          return null;
        } else {
          n = n.parent_node;
        }
      }
    }
    return null;
  }
  private DomNode? traverse_sibling (bool next) {
    if (current_node == null) return null;
    if (current_node == root) return null;
    DomNode s = null;
    if (next) {
      s = current_node.next_sibling;
    } else {
      s = current_node.previous_sibling;
    }
    DomNode n = s;
    while (n != null) {
      var res = DomNodeFilter.Filter.ACCEPT;
      res = accept_node (n);
      if  (res == DomNodeFilter.Filter.ACCEPT) {
        _current_node = n;
        return _current_node;
      }
      DomNode c = null;
      if (next) {
        c = n.first_child;
      } else {
        c = n.last_child;
      }
      if  (res == DomNodeFilter.Filter.REJECT || c == null) {
        if (next) {
          s = n.next_sibling;
        } else {
          s = n.previous_sibling;
        }
      }
      n = n.parent_node;
      if (n == null || n == root) return null;
      if (accept_node (n) == DomNodeFilter.Filter.ACCEPT) {
        return null;
      }
    }
    return s; // FIXME:
  }
}
