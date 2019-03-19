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
 * Represent any property to be added as a {@link GXml.Attribute} to a {@link GXml.Element}
 *
 * The actual value stored and returned by {@link GXml.SerializableProperty.get_serializable_property_value}
 * is the actual string in the XML property, this means may the value could differ from the spected value
 * on some implementations like {@link GXml.SerializableInt}. Take a look in each implementations about
 * retured values.
 *
 * Implementations of {@link GXml.SerializableProperty}, could be used to provide more flexibility
 * when parsing {@link GXml.Attribute} properties values and to exclude to be serialized if they have not
 * been created in the holding objects.
 */
[Version (deprecated = true, deprecated_since = "0.18", replacement = "GXml.GromProperty")]
public interface GXml.SerializableProperty : Object
{
  /**
  * Value to be set to a {@link GXml.Attribute}, to be added to a {@link GXml.Element}
  */
  public abstract string get_serializable_property_value ();
  /**
  * Set value to be set to a {@link GXml.Attribute}, to be added to a {@link GXml.Element}
  *
  * If value is set to @null then the property will be ignored by default and no
  * property will be set to given {@link GXml.Element}.
  *
  * Some implementations stores the value without any convertion at all; then if the value,
  * from XML property, makes no sense for the property type, you should take care
  * to use the provided API from them to convert it.
  */
  public abstract void set_serializable_property_value (string? val);
  /**
   * Tryies to deserialize from a {@link GXml.Node} searching a {@link GXml.Attribute}
   * with the name provided in @param prop or its nick if @nick is true,
   * if not set, then {@link GLib.ParamSpec} name should used. If @param nick is set to true,
   * then {@link GLib.ParamSpec} nick is used as name.
   */
  public virtual bool deserialize_property (GXml.Node property_node, ParamSpec prop, bool nick)
    throws GLib.Error
  { return default_serializable_property_deserialize_property (property_node, prop, nick); }
  /**
   * Serialization method to add a {@link GXml.Attribute} to a {@link GXml.Element}, using {@link GLib.ParamSpec}
   * name or nick, if @param nick is set to true, as the attribute's name.
   *
   * If {@link GXml.SerializableProperty.get_serializable_property_value} returns null
   * given {@link GXml.Node} should not be modified.
   */
  public virtual GXml.Node? serialize_property (GXml.Node property_node, ParamSpec prop, bool nick)
    throws GLib.Error
  { return default_serializable_property_serialize_property (property_node, prop,nick); }
  /**
   * Default serialization method to add a {@link GXml.Attribute} to a {@link GXml.Element}
   *
   * If {@link GXml.SerializableProperty.get_serializable_property_value} returns null
   * given {@link GXml.Node} is not modified.
   */
  public GXml.Node? default_serializable_property_serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop, bool nick)
                                        throws GLib.Error
  {
    if (get_serializable_property_value () == null) return element;
    string name = "";
    if (nick &&
        prop.get_nick () != null &&
        prop.get_nick () != "")
      name = prop.get_nick ();
    else
      name = prop.get_name ();
    if (!(element is GXml.Element)) {
      GLib.warning (_("Trying to serialize to a non GXmlElement!"));
      return element;
    }
    ((GXml.Element) element).set_attr (name, get_serializable_property_value ());
    return element;
  }
  /**
   * Tryies to deserialize from a {@link GXml.Node} searching a {@link GXml.Attribute}
   * with the name in @param prop or from its nick if @nick is true.
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
      GLib.warning (_("No attribute found to deserialize from"));
#endif
      return false;
    }
    if (attr.name == null) {
      GLib.warning (_("XML Attribute name is not set, when deserializing to: %s"), this.get_type ().name ());
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
