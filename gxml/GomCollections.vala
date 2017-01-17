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
  public abstract Queue<int> nodes_index { get; }
  /**
   * A {@link DomElement} with all child elements in collection. Only
   * {@link GomElement} objects are supported.
   */
  public abstract DomElement element { get; construct set; }
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   *
   * Used when reading to add elements to collection.
   */
  public abstract string items_name { get; }
  /**
   * A {@link Type} of {@link DomElement} child objects of {@link element},
   * which could be contained in this collection.
   *
   * Type should be an {@link GomObject}.
   */
  public abstract Type items_type { get; construct set; }
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
    if (nodes_index.length == 0)
      return null;
    if (index < 0 || index >= nodes_index.length)
      throw new DomError.INDEX_SIZE_ERROR
                  (_("Invalid index for elements in array list"));
    int i = nodes_index.peek_nth (index);
    if (i < 0 || i >= element.child_nodes.size)
      throw new DomError.INDEX_SIZE_ERROR
                  (_("Invalid index reference for child elements in array list"));
    var e = element.child_nodes.get (i);
    if (e != null)
      if (!(e is GomElement))
        throw new DomError.INVALID_NODE_TYPE_ERROR
              (_("Referenced object's type is invalid. Should be a GXmlGomElement"));
    return (DomElement?) e;
  }
  /**
   * Adds a {@link DomElement} node to this collection. Depending on type of
   * collection, this method will take information from node to initialize
   * how to find it.
   */
  public abstract void append (DomElement node) throws GLib.Error;
  /**
   * Number of items referenced in {@link nodes_index}
   */
  public virtual int length { get { return (int) nodes_index.get_length (); } }
  /**
   * Initialize collection to use a given {@link GomElement} derived type.
   * Internally, this method create an instance of given type to initialize
   * {@link items_type} and {@link items_name}.
   *
   * This method can be used at construction time of classes implementing
   * {@link GomCollection} to initialize object type to refer in collection.
   */
  public abstract void initialize (GLib.Type t) throws GLib.Error;
  /**
   * Creates a new instance of {@link items_type}, with same
   * {@link DomNode.owner_document} than {@link element}
   *
   * Returns: a new instance object or null if type is not a {@link GomElement} or no parent has been set
   */
  public virtual GomElement? create_item () {
    if (items_type.is_a (GLib.Type.INVALID)) return null;
    if (!items_type.is_a (typeof (GomElement))) return null;
    if (element == null) return null;
    return Object.new (items_type,
                      "owner_document", element.owner_document) as GomElement;
  }
}

/**
 * Base class for collections implemeting {@link GomCollection}, priving basic
 * infrastructure.
 */
public abstract class GXml.BaseCollection : Object {
  /**
   * A collection of node's index refered. Don't modify it manually.
   */
  protected Queue<int> _nodes_index = new Queue<int> ();
  /**
   * Element used to refer of containier element. You should define it at construction time
   * our set it as a construction property.
   */
  protected GomElement _element;
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   *
   * Used when reading to add elements to collection. You can set it at construction time,
   * by, for example, instantaiting a object of the type {@link GomCollection.items_type}
   * then use {@link GomElement.local_name}'s value.
   */
  protected string _items_name = "";
  /**
   * Objects' type to be referenced by this collection and to deserialize objects.
   * Derived classes, can initilize this value at constructor or as construct property.
   *
   * Used when reading and at initialization time, to know {@link GomElement.local_name}
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
  public Queue<int> nodes_index { get { return _nodes_index; } }
  /**
   * {@inheritDoc}
   */
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
  /**
   * {@inheritDoc}
   */
  public void initialize (GLib.Type items_type) throws GLib.Error {
    if (!items_type.is_a (typeof (GomElement))) {
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Invalid atempt to initialize a collection using an unsupported type. Only GXmlGomElement is supported"));
    }
    var o = Object.new (items_type) as GomElement;
    _items_name = o.local_name;
    _items_type = items_type;
  }
  /**
   * Initialize an {@link GomArrayList} to use an element as children's parent.
   * Searchs for all nodes, calling {@link GomCollection.search}
   * with {@link GomCollection.items_type}, using its
   * {@link DomElement.local_name} to find it.
   *
   * Implemenation classes, should initialize collection to hold a {@link GomElement}
   * derived type using {@link GomCollection.initialize}.
   */
  public void initialize_element (GomElement element) throws GLib.Error {
    _element = element;
    search ();
  }
  /**
   * Adds an {@link DomElement} of type {@link GomObject} as a child of
   * {@link element}
   */
  public abstract void append (DomElement node) throws GLib.Error;
  /**
   * Search for all child nodes in {@link element} of type {@link GomElement}
   * with a {@link GomElement.local_name} equal to {@link GomCollection.items_name},
   * to add it to collection.
   *
   * Implementations could add additional restrictions to add element to collection.
   */
  public abstract void search () throws GLib.Error;
}

/**
 * A class impementing {@link GomCollection} to store references to
 * child {@link DomElement} of {@link element}, using an index.
 */
public class GXml.GomArrayList : GXml.BaseCollection, GomCollection {
  /**
   * {@inheritDoc}
   */
  public override void append (DomElement node) throws GLib.Error {
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
    _nodes_index.push_tail (_element.child_nodes.size - 1);
  }
  /**
   * Search for all child nodes in {@link element} of type {@link GomElement}
   * with a {@link GomElement.local_name} equal to {@link GomCollection.items_name},ç
   * to add it to collection.
   */
  public override void search () throws GLib.Error {
    for (int i = 0; i < _element.child_nodes.size; i++) {
      var n = _element.child_nodes.get (i);
      if (n is GomObject) {
        if ((n as DomElement).local_name.down () == items_name.down ()) {
          GLib.message ("Adding node:"+n.node_name);
          _nodes_index.push_tail (i);
        }
      }
    }
  }
}

/**
 * A class impementing {@link GomCollection} to store references to
 * child {@link DomElement} of {@link element}, using an attribute in
 * items as key.
 */
public class GXml.GomHashMap : GXml.BaseCollection, GXml.GomCollection {
  /**
   * A hashtable with all keys as string to node's index refered. Don't modify it manually.
   */
  protected HashTable<string,int> _hashtable = new HashTable<string,int> (str_hash,str_equal);
  /**
   * Element used to refer of containier element. You should define it at construction time
   * our set it as a construction property.
   */
  protected string _attribute_key;
  /**
   * An attribute's name in items to be added and used to retrieve a key to
   * used in collection.
   */
  public string attribute_key {
    get { return _attribute_key; } construct set { _attribute_key = value; }
  }
  /**
   * Convenient function to initialize a {@link GomHashMap} collection, using
   * given element, items' type and name.
   */
  public void initialize_element_with_key (GomElement element,
                                  GLib.Type items_type,
                                  string attribute_key) throws GLib.Error
  {
    initialize (items_type);
    initialize_element (element);
    _attribute_key = attribute_key;
    search ();
  }

  /**
   * Convenient function to initialize a {@link GomHashMap} collection, using
   * given element, items' type and name.
   *
   * Using this method at construction time of derived classes.
   */
  public void initialize_with_key (GLib.Type items_type,
                                  string attribute_key) throws GLib.Error
  {
    initialize (items_type);
    _attribute_key = attribute_key;
    search ();
  }
  /**
   * Sets an {@link DomElement} of type {@link GomObject} as a child of
   * {@link element}, requires new item to have defined an string attribute
   * to be used as key. Attribute should have the name: {@link attribute_key}
   */
  public override void append (DomElement node) throws GLib.Error {
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
    _nodes_index.push_tail (index);
    GLib.message ("Key:"+key+" Index: "+index.to_string ());
    _hashtable.insert (key, index);
  }
  /**
   * Returns an {@link DomElement} in the collection using a string key.
   */
  public new DomElement? get (string key) {
    if (!_hashtable.contains (key)) return null;
    var i = _hashtable.get (key);
    GLib.message ("Key:"+key+" item:"+i.to_string ());
    return _element.child_nodes.get (i) as DomElement;
  }
  /**
   * Search for all child nodes in {@link element} of type {@link GomElement}
   * with an attribute {@link attribute_name} set, to add it to collection.
   */
  public override void search () throws GLib.Error {
    for (int i = 0; i < _element.child_nodes.size; i++) {
      var n = _element.child_nodes.get (i);
      if (n is GomObject) {
        if ((n as DomElement).local_name.down () == items_name.down ()) {
          string key = (n as DomElement).get_attribute (attribute_key);
          if (key != null) {
            _nodes_index.push_tail (i);
            _hashtable.insert (key, i);
          }
        }
      }
    }
  }
}
