/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2018 Daniel Espinosa <esodan@gmail.com>
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
 * A DOM4 interface to keep references to {@link DomElement} children of a {@link element}
 */
public interface GXml.Collection : Object
{
  /**
   * A list of child {@link DomElement} objects of {@link element}
   */
  public abstract GLib.Queue<int> nodes_index { get; }
  /**
   * A {@link GXml.DomElement} with all child elements in collection.
   */
  public abstract GXml.DomElement element { get; construct set; }
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   *
   * Used when reading to add elements to collection.
   */
  public abstract string items_name { get; }
  /**
   * A {@link GLib.Type} of {@link DomElement} child objects of {@link element},
   * which could be contained in this collection.
   *
   * Type should be an {@link GomObject}.
   */
  public abstract Type items_type { get; construct set; }
  /**
   * Search and add references to all {@link GomObject} nodes as child of
   * {@link element} with same, case insensitive, name of {@link items_name}
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
      if (!(e is GXml.DomElement))
        throw new DomError.INVALID_NODE_TYPE_ERROR
              (_("Referenced object's type is invalid. Should be a GXmlDomElement"));
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
   * Initialize collection to use a given {@link GXml.Collection} derived type.
   * Internally, this method create an instance of given type to initialize
   * {@link items_type} and {@link items_name}.
   *
   * This method can be used at construction time of classes implementing
   * {@link GXml.Collection} to initialize object type to refer in the collection.
   */
  public abstract void initialize (GLib.Type t) throws GLib.Error;
  /**
   * Creates a new instance of {@link items_type}, with same
   * {@link DomNode.owner_document} than {@link element}. New instance
   * is not set as a child of collection's {@link element}; to do so,
   * use {@link append}
   *
   * Returns: a new instance object or null if type is not a {@link DomElement} or no parent has been set
   */
  public virtual DomElement? create_item () {
    if (items_type.is_a (GLib.Type.INVALID)) return null;
    if (!items_type.is_a (typeof (DomElement))) return null;
    if (element == null) return null;
    return Object.new (items_type,
                      "owner_document", element.owner_document) as DomElement;
  }
  /**
   * Validate if given node and index, should be added to collection.
   *
   * Implementations should use this method to perform any action before
   * element is added to collection, like setup internal pointers to given
   * index, in order to get access to referenced node.
   *
   * Return: true if node and index should be added to collection.
   */
  public abstract bool validate_append (int index, DomElement element) throws GLib.Error;
  /**
   * Clear this collection in prepareation for a search
   */
  public abstract void clear () throws GLib.Error;
}

/**
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GXml.Collection}
 */
public interface GXml.List : Object, Collection, Traversable<DomElement>, Iterable<DomElement> {}

/**
 * Inteface to be implemented by {@link GXml.Collection} derived classes
 * in order to provide a string to be used in {@link GomHashMap} as key.
 *
 * If {@link GomHashMap} has set its {@link GomHashMap.attribute_key}
 * its value has precedence over this method.
 */
public interface GXml.MappeableElement : Object, DomElement {
  public abstract string get_map_key ();
}

/**
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GXml.Collection}
 */
public interface GXml.Map : Object, GXml.Collection, Traversable<DomElement>, Iterable<DomElement> {
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as key.
   */
  public abstract string attribute_key { get; construct set; }
  /**
   * Returns an {@link DomElement} in the collection using a string key.
   */
  public abstract DomElement? item (string key);
  /**
   * Returns true if @key is used in collection.
   */
  public abstract bool has_key (string key);
  /**
   * Returns list of keys used in collection.
   */
  public abstract Set<string> keys_set { owned get; }
}



/**
 * Inteface to be implemented by {@link GXml.Collection} derived classes
 * in order to provide a strings to be used in {@link GomHashPairedMap} as keys.
 */
public interface GXml.MappeableElementPairKey : Object, DomElement {
  public abstract string get_map_primary_key ();
  public abstract string get_map_secondary_key ();
}


/**
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GXml.Collection}
 */
public interface GXml.PairedMap : Object, GXml.Collection, Traversable<DomElement>, Iterable<DomElement> {
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as primary key.
   */
  public abstract string attribute_primary_key { get; construct set; }
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as secondary key.
   */
  public abstract string attribute_secondary_key { get; construct set; }
  /**
   * Returns list of primary keys used in collection.
   */
  public abstract Set<string> primary_keys_set { owned get; }
  /**
   * Returns an {@link DomElement} in the collection using given string keys.
   */
  public abstract DomElement? item (string primary_key, string secondary_key);
  /**
   * Returns true if @key is used in collection as primery key.
   */
  public abstract bool has_primary_key (string key);
  /**
   * Returns true if @key is used in collection as secondary key
   * with @pkey as primary.
   */
  public abstract bool has_secondary_key (string pkey, string key);
  /**
   * Returns list of secondary keys used in collection with @pkey as primary key.
   */
  public abstract Set<string> secondary_keys_set (string pkey);
}


/**
 * Inteface to beimplemented by {@link GXml.Collection} derived classes
 * in order to provide a string to be used in {@link GomHashThreeMap} as key.
 *
 * If {@link GomHashMap} has set its {@link GomHashMap.attribute_key}
 * its value has precedence over this method.
 */
public interface GXml.MappeableElementThreeKey : Object, DomElement {
  /**
   * Returns primary key of collection.
   */
  public abstract string get_map_pkey ();
  /**
   * Returns secundary key of collection.
   */
  public abstract string get_map_skey ();
  /**
   * Returns third key of collection.
   */
  public abstract string get_map_tkey ();
}

/**
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GXml.Collection}
 */
public interface GXml.ThreeMap : Object, GXml.Collection, Traversable<DomElement>, Iterable<DomElement> {
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as primary key.
   */
  public abstract string attribute_primary_key { get; construct set; }
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as secondary key.
   */
  public abstract string attribute_secondary_key { get; construct set; }
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as third key.
   */
  public abstract string attribute_third_key { get; construct set; }
  /**
   * Returns list of primary keys used in collection.
   */
  public abstract Set<string> primary_keys_set { owned get; }
  /**
   * Returns an {@link DomElement} in the collection using given string keys.
   */
  public abstract DomElement? item (string primary_key, string secondary_key, string third_key);
  /**
   * Returns true if @key is used in collection as primery key.
   */
  public abstract bool has_primary_key (string key);
  /**
   * Returns true if @key is used in collection as secondary key
   * with @pkey as primary.
   */
  public abstract bool has_secondary_key (string pkey, string key);
  /**
   * Returns true if @key is used in collection as third key with secondary key
   * and pkey as primary.
   */
  public abstract bool has_third_key (string pkey, string skey, string key);
  /**
   * Returns list of secondary keys used in collection with @pkey as primary key.
   */
  public abstract Set<string> secondary_keys_set (string pkey);
  /**
   * Returns list of third keys used in collection with pkey as primary key
   * and skey as secondary key.
   */
  public abstract Set<string> third_keys_set (string pkey, string skey);
}
