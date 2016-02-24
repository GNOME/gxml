/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
 *
 * Copyright (C) 2014  Daniel Espinosa <esodan@gmail.com>
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
 * Any {@link GXml.Serializable} class having a collection managed list of
 * {@link GXml.Node} must implement this abstract class.
 * 
 * Gee Serializable clases requires to be initialized with required typed objects to contain 
 * its collections and Serializable interface don't know required type. Then you must use this
 * function to initialize any Serializable collection objects in order to serialize/deserialize
 * all {@link GXml.Node} to given clases.
 */
public abstract class GXml.SerializableContainer : SerializableObjectModel
{
	construct { Init.init (); }
  /**
   * Implementors must implement this function and initialize any Serializable container.
   */
  public abstract void init_containers ();
}

/**
 * Serializable Framework. interface to be implemented by any collection of {@link Serializable} objects.
 */
public interface GXml.SerializableCollection : Object, Gee.Traversable<Serializable>, Serializable
{
  /**
   * Returns true if the collection should be deserialized from a {@link GXml.Node}'s children
   * when {@link GXml.Serializable.deserialize} is called. For large collection of nodes
   * this could impact in performance; return false and use {@link GXml.SerializableCollection.deserialize_children}
   * when you need to deserialize all nodes to access them.
   */
  public abstract bool deserialize_proceed ();
  /**
   * Returns true if the collection was deserialized from a {@link GXml.Node}'s children.
   */
  public abstract bool deserialized ();
  /**
   * Returns true if the collection is able to deserialize from a {@link GXml.Node}'s children.
   */
  public abstract bool is_prepared ();
  /**
   * Executes a deserialization from a {@link GXml.Node}. After this operation
   * {@link GXml.SerializableCollection.deserialized} should return true. This
   * operation should not be executed if {@link GXml.SerializableCollection.is_prepared}
   * return false;
   *
   * This could override existing objects in collection.
   */
  public abstract bool deserialize_node (GXml.Node node) throws GLib.Error;
  /**
   * Executes a deserialization from all children nodes in a {@link GXml.Node}. After this operation
   * {@link GXml.SerializableCollection.deserialized} should return true. This
   * operation should not be executed if {@link GXml.SerializableCollection.is_prepared}
   * return false;
   *
   * This could override existing objects in collection.
   */
  public abstract bool deserialize_children () throws GLib.Error;
  /**
   * Convenient function to detect Serializable Collections.
   */
  public virtual bool is_collection () { return true; }
}
