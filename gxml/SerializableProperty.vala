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
   * Tryies to deserialize from a {@link GXml.Node} searching a {@link GXml.Attr}
   * with the name returned by {@link GXml.SerializableProperty.get_serializable_property_name},
   * if not set, then {@link GLib.ParamSpec} name should used. If {@param nick} is set to true,
   * then {@link GLib.ParamSpec} nick is used as name.
   */
  public virtual bool deserialize_property (GXml.Node property_node, ParamSpec prop, bool nick)
    throws GLib.Error
  { return default_serializable_property_deserialize_property (property_node, prop, nick); }
  /**
   * Serialization method to add a {@link GXml.Attr} to a {@link GXml.Element}, using {@link ParamSpec}
   * name or nick, if {@param nick} is set to true, as the attribute's name.
   *
   * If {@link GXml.SerializableProperty.get_serializable_property_value} returns {@link null}
   * given {@link GXml.Node} should not be modified.
   */
  public virtual GXml.Node? serialize_property (GXml.Node property_node, ParamSpec prop, bool nick)
    throws GLib.Error
  { return default_serializable_property_serialize_property (property_node, prop,nick); }
  /**
   * Default serialization method to add a {@link GXml.Attr} to a {@link GXml.Element}
   *
   * If {@link GXml.SerializableProperty.get_serializable_property_value} returns {@link null}
   * given {@link GXml.Node} is not modified.
   *
   * Implementators should override {@link Serializable.serialize_property} to call
   * this method on serialization.
   */
  public GXml.Node? default_serializable_property_serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop, bool nick)
                                        throws GLib.Error
  {
    if (get_serializable_property_value () == null) return element;
    string name = "";
    Test.message ("Use nick: "+nick.to_string ());
    if (nick &&
        prop.get_nick () != null &&
        prop.get_nick () != "")
      name = prop.get_nick ();
    else
      name = prop.get_name ();
    Test.message ("Property to set:"+name+" - with value: "+get_serializable_property_value ());
    ((GXml.Element) element).set_attr (name, get_serializable_property_value ());
    return element;
  }
  /**
   * Tryies to deserialize from a {@link GXml.Node} searching a {@link GXml.Attr}
   * with the name returned by {@link GXml.SerializableProperty.get_serializable_property_name},
   * if not set {@link GLib.ParamSpec} name is used.
   */
  public bool default_serializable_property_deserialize_property (GXml.Node property_node,
                                                                  ParamSpec prop, bool nick)
    throws GLib.Error
  {
    GXml.Attribute attr = null;
    if (property_node is GXml.Attribute)
      attr = (GXml.Attribute) property_node;
    if (attr == null) {
#if DEBUG
      GLib.warning ("No attribute found to deserialize from");
#endif
      return false;
    }
    if (attr.name == null) {
      GLib.warning ("XML Attribute name is not set, when deserializing to: "+this.get_type ().name ());
      return false;
    }
    string name = "";
    if (nick &&
        prop.get_nick () != null &&
        prop.get_nick () != "")
      name = prop.get_nick ();
    else
      name = prop.get_name ();
    if (attr.name.down () == name.down ())
      set_serializable_property_value (attr.value);
    return true;
  }
}