/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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
 * An interface to keep references to {@link DomElement} in a {@link element}
 * child nodes. Only {@link GomObject} are supported. It can be filled out
 * using {@link update}.
 */
public interface GXml.GomCollection : Object
{
  /**
   * A list of child {@link DomElement} objects of {@link element}
   */
  public abstract List<int> nodes_index { get; }
  /**
   * A {@link DomElement} with all child elements.
   */
  public abstract DomElement element { get; construct set; }
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   */
  public abstract string element_name { get; construct set; }
  /**
   * Gets a child {@link DomElement} of {@link element} referenced in
   * {@link nodes_index}.
   */
  public virtual DomElement? get_item (int index) throws GLib.Error {
    var e = element.child_nodes.get (index);
    if (e != null)
      if (!(e is GomElement))
        throw new DomError.INVALID_NODE_TYPE_ERROR
              (_("Referenced object's type is invalid. Should be a GXmlGomElement"));
    return (DomElement?) e;
  }
  /**
   * Number of items referenced in {@link nodes_index}
   */
  public virtual int length { get { return (int) nodes_index.length; } }
}

public class GXml.GomArrayList : Object, GomCollection {
  protected List<int> _nodes_index = new List<int> ();
  protected GomElement _element;
  protected string _element_name;
  public List<int> nodes_index { get { return _nodes_index; } }
  public DomElement element {
    get { return _element; }
    construct set {
      if (value is GomElement)
        _element = value as GomElement;
      else
        GLib.warning (_("Invalid element type only GXmlGomElement is supported"));
    }
  }
  public string element_name {
    get { return _element_name; } construct set { _element_name = value; }
  }

  /**
   * Adds an {@link DomElement} of type {@link GomObject} as a child of
   * {@link element}
   */
  public void add (DomElement node) throws GLib.Error {
    if (!(node is GomElement))
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Invalid atempt to add unsupported type. Only GXmlGomElement is supported"));
    if (node.owner_document != _element.owner_document)
      throw new DomError.HIERARCHY_REQUEST_ERROR
                (_("Invalid atempt to add a node with a different parent document"));
    _element.append_child (node);
    if (_element.child_nodes.size == 0)
      throw new DomError.QUOTA_EXCEEDED_ERROR
                (_("Invalid atempt to add a node with a different parent document"));
    _nodes_index.append (_element.child_nodes.size - 1);
  }
}
