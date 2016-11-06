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
   * A {@link DomElement} with all child elements in collection. Only
   *{@link GomElement} objects are supported.
   */
  public abstract DomElement element { get; construct set; }
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   */
  public abstract string items_name { get; construct set; }
  /**
   * Search and add references to all {@link GomObject} nodes as child of
   * {@link element} with same, case insensitive, name of {@link element_name}
   */
  public abstract void search () throws GLib.Error;
  /**
   * Gets a child {@link DomElement} of {@link element} referenced in
   * {@link nodes_index}.
   */
  public virtual DomElement? get_item (int index) throws GLib.Error {
    unowned List<int> i = nodes_index.nth (index);
    if (i == null) return null;
    var e = element.child_nodes.get (i.data);
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
  protected string _items_name;
  public List<int> nodes_index { get { return _nodes_index; } }
  public DomElement element {
    get { return _element; }
    construct set {
      if (value != null) {
        if (value is GomElement)
          _element = value as GomElement;
        else
          GLib.warning (_("Invalid element type only GXmlGomElement is supported"));
      }
    }
  }
  public string items_name {
    get { return _items_name; } construct set { _items_name = value; }
  }

  public GomArrayList.initialize (GomElement element, string items_name) {
    _element = element;
    _items_name = items_name;
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
  public void search () throws GLib.Error {
    for (int i = 0; i < _element.child_nodes.size; i++) {
      var n = _element.child_nodes.get (i);
      if (n is GomObject) {
        if ((n as DomElement).local_name.down () == items_name.down ()) {
          _nodes_index.append (i);
        }
      }
    }
  }
}


public class GXml.GomHashMap : Object, GomCollection {
  protected List<int> _nodes_index = new List<int> ();
  protected HashTable<string,int> _hashtable = new HashTable<string,int> (str_hash,str_equal);
  protected GomElement _element;
  protected string _items_name;
  protected string _attribute_key;
  public List<int> nodes_index { get { return _nodes_index; } }
  public DomElement element {
    get { return _element; }
    construct set {
      if (value != null) {
        if (value is GomElement)
          _element = value as GomElement;
        else
          GLib.warning (_("Invalid element type only GXmlGomElement is supported"));
      }
    }
  }
  public string items_name {
    get { return _items_name; } construct set { _items_name = value; }
  }
  public string attribute_key {
    get { return _attribute_key; } construct set { _attribute_key = value; }
  }

  public GomHashMap.initialize (GomElement element,
                                  string items_name,
                                  string attribute_key) {
    _element = element;
    _items_name = items_name;
    _attribute_key = attribute_key;
  }
  /**
   * Adds an {@link DomElement} of type {@link GomObject} as a child of
   * {@link element}
   */
  public new void set (DomElement node) throws GLib.Error {
    if (!(node is GomElement))
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Invalid atempt to set unsupported type. Only GXmlGomElement is supported"));
    if (node.owner_document != _element.owner_document)
      throw new DomError.HIERARCHY_REQUEST_ERROR
                (_("Invalid atempt to set a node with a different parent document"));
    var key = node.get_attribute (attribute_key);
    if (key == null)
      throw new DomError.HIERARCHY_REQUEST_ERROR
                (_("Invalid atempt to set a node without key attribute"));
    _element.append_child (node);
    if (_element.child_nodes.size == 0)
      throw new DomError.QUOTA_EXCEEDED_ERROR
                (_("Invalid atempt to add a node with a different parent document"));
    var index = _element.child_nodes.size - 1;
    _nodes_index.append (index);
    GLib.message ("Key:"+key+" Index: "+index.to_string ());
    _hashtable.insert (key, index);
  }
  public new DomElement? get (string key) {
    if (!_hashtable.contains (key)) return null;
    var i = _hashtable.get (key);
    GLib.message ("Key:"+key+" item:"+i.to_string ());
    return _element.child_nodes.get (i) as DomElement;
  }
  public void search () throws GLib.Error {
    for (int i = 0; i < _element.child_nodes.size; i++) {
      var n = _element.child_nodes.get (i);
      if (n is GomObject) {
        if ((n as DomElement).local_name.down () == items_name.down ()) {
          if ((n as DomElement).get_attribute (attribute_key) != null) {
            this.set (n as DomElement);
          }
        }
      }
    }
  }
}
