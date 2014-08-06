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
/**
 * Any {link GXml.Serializable} class having a collection managed list of {link GXml.Node} must implement this
 * abstract class.
 */
public abstract class GXml.SerializableContainer : SerializableObjectModel
{
  /**
   * Implementors must implement this function and initialize any Serializable container.
   *
   * Gee Serializable clases requires to be initialized with required typed objects to contain 
   * its collections and Serializable interface don't know required type. Then you must use this
   * function to initialize any Serializable collection objects in order to serialize/deserialize
   * all {link GXml.Node} to given clases.
   */
  public abstract void init_containers ();
}

/**
 * Fake interface to be implemented by any collection.
 */
public interface GXml.SerializableCollection : Object, Serializable
{
  public virtual bool is_collection () { return true; }
}
