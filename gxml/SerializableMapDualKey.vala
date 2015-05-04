/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* SerializableGeeTreeModel.vala
 *
 * Copyright (C) 2013  Daniel Espinosa <esodan@gmail.com>
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
using GXml;
/**
 * Serializable Framework. Interface to get two keys to be used to store {@link Serializable} objects.
 * 
 * This interface must be implemented by classes derived from {@link GXml.SerializableDualKeyMap}.
 */
public interface GXml.SerializableMapDualKey<P,S> : Object
{
  /**
   * Implement this function to return the value to be used as primary key on
   * {@link SerializableDualKeyMap} containers.
   */
  public abstract P get_map_primary_key  ();
  /**
   * Implement this function to return the value to be used as secondary key on
   * {@link SerializableDualKeyMap} containers.
   */
  public abstract S get_map_secondary_key ();
}
