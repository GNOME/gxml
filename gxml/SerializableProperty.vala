/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* SerializableProperty.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;
/**
 * Represent any property to be added as a {@link GXml.Attr} to a {@link GXml.Element}
 *
 * On implementations of {@link GXml.Serializable}, consider to detect if the object to
 * serialize/deserialize is of kind {@link GXml.SerializableProperty} and call
 * {@link GXml.Serializable.serialize_property} instead of {@link GXml.Serializable.serialize}
 * to fill automatically {@link GXml.SerializableProperty.serializable_property_name} and
 * {@link GXml.SerializableProperty.serializable_property_value}.
 */
public interface GXml.SerializableProperty : Object, Serializable
{
  /**
  * Value to be set to a {@link GXml.Attr}, to be added to a {@link GXml.Element}
  */
  public abstract string get_serializable_property_value ();
  /**
  * Set value to be set to a {@link GXml.Attr}, to be added to a {@link GXml.Element}
  *
  * If value is set to @null then the property will be ignored by default and no
  * property will be set to given {@link GXml.Element}
  */
  public abstract void set_serializable_property_value (string? val);
  /**
   * Name to be set to a {@link GXml.Attr}, to be added to a {@link GXml.Element}
   */
  public abstract string get_serializable_property_name ();
  /**
   * Sets name to be set to a {@link GXml.Attr}, to be added to a {@link GXml.Element}
   */
  public abstract void set_serializable_property_name (string name);
  /**
   * Default serialization method to add a {@link GXml.Attr} to a {@link GXml.Element}
   *
   * If {@link GXml.SerializableProperty.get_serializable_property_value} returns {@link null}
   * given {@link GXml.Node} is not modified.
   *
   * Implementators should call this method instead of {@link Serializable.default_serialize}.
   */
  public virtual GXml.Node? default_serializable_property_serialize (GXml.Node node) throws GLib.Error
    requires (get_serializable_property_name () != null)
  {
    if (get_serializable_property_value () == null) return node;
    if (node is GXml.Attribute && node.name == get_serializable_property_name ()) {
      ((GXml.Attribute) node).value = get_serializable_property_value ();
      return node;
    }
    ((GXml.Element) node).set_attr (get_serializable_property_name (), get_serializable_property_value ());
    return node;
  }
  /**
   * Default serialization method to add a {@link GXml.Attr} to a {@link GXml.Element}
   *
   * If {@link GXml.SerializableProperty.get_serializable_property_value} returns {@link null}
   * given {@link GXml.Node} is not modified.
   *
   * Implementators should override {@link Serializable.serialize_property} to call
   * this method on serialization.
   */
  public virtual GXml.Node? default_serializable_property_serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    if (get_serializable_property_value () == null) return element;
    ((GXml.Element) element).set_attr (prop.name, get_serializable_property_value ());
    return element;
  }
  /**
   * Tryies to deserialize from a {@link GXml.Node} searching a {@link GXml.Attr}
   * with the name returned by {@link GXml.SerializableProperty.get_serializable_property_name}
   */
  public virtual GXml.Node? default_serializable_property_deserialize (GXml.Node node)
                                      throws GLib.Error
    requires (get_serializable_property_name () != null)
  {
    GXml.Attribute attr = null;
    if (node is GXml.Attribute)
      attr = (GXml.Attribute) node;
    if (node is GXml.Element)
      attr = (GXml.Attribute) ((GXml.Element) node).attrs.get (get_serializable_property_name ());
    if (attr == null) return node;
    if (attr.name == get_serializable_property_name ())
      set_serializable_property_value (attr.value);
    return node;
  }
}