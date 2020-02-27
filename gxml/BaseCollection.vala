/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* BaseCollection.vala
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

using Gee;

/**
 * Base class for collections implementing {@link Collection}, providing basic
 * infrastructure.
 *
 * Collections properties should be initialized with current container element
 * in order to be able to add new references to elements. Use {@link initialize_element}
 * to set parent element and {@link search} to find elements for collection.
 */
public abstract class GXml.BaseCollection : GLib.Object, Traversable<DomElement>, Iterable<DomElement>, Collection {
  /**
   * A collection of node's index referred. Don't modify it manually.
   */
  protected GLib.Queue<int> _nodes_index = new GLib.Queue<int> ();
  /**
   * Element used to refer of containier element. You should define it at construction time
   * our set it as a construction property.
   */
  protected GXml.Element _element;
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   *
   * Used when reading to add elements to collection. You can set it at construction time,
   * by, for example, instantiating a object of the type {@link Collection.items_type}
   * then use {@link GXml.Element.local_name}'s value.
   */
  protected string _items_name = "";
  /**
   * Objects' type to be referenced by this collection and to deserialize objects.
   * Derived classes, can initialize this value at constructor or as construct property.
   *
   * Used when reading and at initialization time, to know {@link GXml.Element.local_name}
   * at runtime.
   */
  protected GLib.Type _items_type = GLib.Type.INVALID;
  /**
   * {@inheritDoc}
   */
  public string items_name { get { return _items_name; } }
  /**
   * {@inheritDoc}
   */
  public Type items_type {
    get { return _items_type; } construct set { _items_type = value; }
  }
  /**
   * {@inheritDoc}
   */
  public GLib.Queue<int> nodes_index { get { return _nodes_index; } }
  /**
   * {@inheritDoc}
   */
  public DomElement element {
    get { return _element as DomElement; }
    construct set {
      if (value is GXml.Element)
        _element = value as GXml.Element;
    }
  }
  /**
   * {@inheritDoc}
   */
  public void initialize (GLib.Type items_type) throws GLib.Error {
    if (!items_type.is_a (typeof (GXml.DomElement))
        && !items_type.is_a (typeof (GXml.Object))) {
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Invalid attempt to initialize a collection using an unsupported type. Only GXmlGXml.Element is supported"));
    }
    if (!items_type.is_abstract () && items_type.is_instantiatable ()) {
      var o = GLib.Object.new (items_type) as GXml.Element;
      _items_name = o.local_name;
    }
    _items_type = items_type;
  }
  /**
   * Initialize an {@link Collection} to use an element as children's parent.
   * Searches for all nodes, calling {@link Collection.search}
   * with {@link Collection.items_type}, using its
   * {@link DomElement.local_name} to find it.
   *
   * Implementation classes, should initialize collection to hold a {@link GXml.Element}
   * derived type using {@link Collection.initialize}.
   */
  public void initialize_element (GXml.Element e) throws GLib.Error {
    _element = e;
  }

  /**
   * Adds an {@link DomElement} of type {@link GXml.Object} as a child of
   * {@link element}.
   *
   * Object is always added as a child of {@link element}
   * but just added to collection if {@link validate_append} returns true;
   */
  public void append (DomElement node) throws GLib.Error {
    if (_element == null)
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Parent Element is invalid. Set 'element' property at construction time"));
    if (!(node is GXml.Element))
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Invalid attempt to set unsupported type. Only GXmlGXml.Element is supported"));
    if (node.owner_document != _element.owner_document)
      throw new DomError.HIERARCHY_REQUEST_ERROR
                (_("Invalid attempt to set a node with a different parent document"));
    if (node.parent_node == null)
      _element.append_child (node);
    if (_element.child_nodes.size == 0)
      throw new DomError.QUOTA_EXCEEDED_ERROR
                (_("Node element not appended as child of parent. No node added to collection"));
    var index = _element.child_nodes.size - 1;
    if (!validate_append (index, node)) return;
    _nodes_index.push_tail (index);
  }
  /**
   * Search for all child nodes in {@link element} of type {@link GXml.Element}
   * with a {@link GXml.Element.local_name} equal to {@link Collection.items_name},
   * to add it to collection. This method calls {@link clear} first.
   *
   * Implementations could add additional restrictions to add element to collection.
   */
  public void search () throws GLib.Error {
    _nodes_index.clear ();
    clear ();
    if (_element == null)
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Parent Element is invalid. Set 'element' property at construction time"));
    for (int i = 0; i < _element.child_nodes.size; i++) {
      var n = _element.child_nodes.get (i);
      if (n is GXml.Object) {
        if (((DomElement) n).local_name.down () == items_name.down ()) {
          if (validate_append (i, n as DomElement))
            _nodes_index.push_tail (i);
        }
      }
    }
  }
  /**
   * {@inheritDoc}
   */
  public abstract bool validate_append (int index, DomElement element) throws GLib.Error;
  /**
   * {@inheritDoc}
   */
  public virtual void clear () throws GLib.Error {}

  // Traversable Interface
  public bool @foreach (ForallFunc<DomElement> f) {
    var i = iterator ();
    return i.foreach (f);
  }
  // Iterable Interface
  public Iterator<DomElement> iterator () { return new CollectionIterator (this); }
  // For Iterable interface implementation
  private class CollectionIterator : GLib.Object, Traversable<DomElement>, Iterator<DomElement> {
    private int pos;
    private Collection _collection;
    public bool read_only { get { return false; } }
    public bool valid { get { return (pos >= 0 && pos < _collection.length); } }

    public CollectionIterator (Collection col) {
      _collection = col;
      pos = -1;
    }

    public new DomElement @get ()
      requires (pos >= 0 && pos < _collection.length) {
      DomElement e = null;
      try {
        e = _collection.get_item (pos);
      } catch (GLib.Error e) {
        warning (_("Error: %s").printf (e.message));
      }
      return e;
    }
    public bool has_next () { return (pos + 1 < _collection.length); }
    public bool next () {
      if (!has_next ()) return false;
      pos++;
      return true;
    }
    public void remove () {
      DomElement e = null;
      try {
        e = _collection.get_item (pos);
        if (e == null) return;
        e.remove ();
        _collection.search ();
      } catch (GLib.Error e) {
        warning (_("Error: %s").printf (e.message));
      }
    }

    public bool @foreach (ForallFunc<DomElement> f) {
      while (has_next ()) {
        next ();
        if (!f (get ())) return false;
      }
      return true;
    }
  }
}

