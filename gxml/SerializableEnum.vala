/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* SerializableValueList.vala
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
 * Represent any value as string but a list of enum values by default to select from.
 * property to be added as a {@link GXml.Attr} to a {@link GXml.Element}.
 *
 * This class makes easy to create enumerations with its representation to string,
 * but limited to the actual values of the enumeration, making it flexible for
 * values not supported now but possible because some extensions. Can be added
 * an extension element in the enumeration and return it when the supported values
 * are not met with the string representation in the property.
 */
public class GXml.SerializableEnum : SerializableObjectModel, SerializableProperty
{
  protected string _val = null;
  protected string _name = null;
  protected GLib.Type _enumtype;
  public SerializableEnum.with_name (string name) { _name = name; }
  public void set_enum_type (GLib.Type type)
    requires (type.is_a (Type.ENUM))
  { _enumtype = type; }
  public GLib.Type get_enum_type () { return _enumtype; }
  public EnumValue? parse (string str)
  {
    if (!_enumtype.is_a (Type.ENUM)) return null;
    return Enumeration.parse (_enumtype, str);
  }
  public EnumValue? from_value (int val)
  {
    if (!_enumtype.is_a (Type.ENUM)) return null;
    var vals = Enumeration.to_array (_enumtype);
    if (vals == null) return null;
    for (int i = 0; i < vals.length; i++) {
      var e = vals[i];
      if (e.value == val) return e;
    }
    return null;
  }
  public string get_serializable_property_value () { return _val; }
  public void set_serializable_property_value (string? val) { _val = val; }
  public string get_serializable_property_name () { return _name; }
  public void set_serializable_property_name (string name) { _name = name; }
  public override GXml.Node? serialize (GXml.Node node) throws GLib.Error
  {
    return default_serializable_property_serialize (node);
  }
  public override GXml.Node? serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return default_serializable_property_serialize_property (element, prop);
  }
  public override GXml.Node? deserialize (GXml.Node node)
                                      throws GLib.Error
  {
    return default_serializable_property_deserialize (node);
  }
  public override bool deserialize_property (GXml.Node property_node)
                                              throws GLib.Error
  {
    default_serializable_property_deserialize (property_node);
    return true;
  }
  public override string to_string () { return _val; }
}