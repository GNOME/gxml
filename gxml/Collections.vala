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
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GomCollection}
 */
public interface GXml.GomList : Object, GomCollection, Traversable<DomElement>, Iterable<DomElement> {}

/**
 * Inteface to be implemented by {@link GomElement} derived classes
 * in order to provide a string to be used in {@link GomHashMap} as key.
 *
 * If {@link GomHashMap} has set its {@link GomHashMap.attribute_key}
 * its value has precedence over this method.
 */
public interface GXml.MappeableElement : Object, DomElement {
  public abstract string get_map_key ();
}

/**
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GomCollection}
 */
public interface GXml.GomMap : Object, GomCollection, Traversable<DomElement>, Iterable<DomElement> {
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
 * Inteface to be implemented by {@link GomElement} derived classes
 * in order to provide a strings to be used in {@link GomHashPairedMap} as keys.
 */
public interface GXml.MappeableElementPairKey : Object, DomElement {
  public abstract string get_map_primary_key ();
  public abstract string get_map_secondary_key ();
}


/**
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GomCollection}
 */
public interface GXml.GomPairedMap : Object, GomCollection, Traversable<DomElement>, Iterable<DomElement> {
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
 * Inteface to beimplemented by {@link GomElement} derived classes
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
 * {@link Gee.Iterable} and {@link Gee.Traversable} implementation of {@link GomCollection}
 */
public interface GXml.GomThreeMap : Object, GomCollection, Traversable<DomElement>, Iterable<DomElement> {
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