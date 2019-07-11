/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016-2019  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

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
 * Implementation of {@link DomNodeIterator}
 */
public class GXml.NodeIterator : GLib.Object, GXml.DomNodeIterator {
  protected DomNode _root;
  protected DomNode _reference_node;
  protected bool _pointer_before_reference_node;
  protected int _what_to_show;

  public NodeIterator (DomNode n, int what_to_show) {
    _root = n;
    _reference_node = _root;
    _what_to_show = what_to_show;
  }
  public DomNode root { get { return _root; } }
  public DomNode reference_node { get { return _reference_node; } }
  public bool pointer_before_reference_node { get { return _pointer_before_reference_node; } }
  public int what_to_show { get { return _what_to_show; } }

  public DomNode? next_node() { return null; } // FIXME
  public DomNode? previous_node() { return null; } // FIXME

  public void detach() { return; } // FIXME
}
