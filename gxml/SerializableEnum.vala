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

public errordomain GXml.SerializableEnumError {
  INVALID_VALUE_ERROR,
  PARSE_ERROR
}

/**
 * Represent any value as string but a list of enum values by default to select from.
 * property to be added as a {@link GXml.Attribute} to a {@link GXml.Element}.
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
  protected GLib.Type _enumtype;

	construct { Init.init (); }

  public SerializableEnum.with_enum (GLib.Type type)
  {
    _enumtype = type;
  }
  public void set_enum_type (GLib.Type type)
    requires (type.is_a (Type.ENUM))
  { _enumtype = type; }
  public GLib.Type get_enum_type () { return _enumtype; }
  public void parse (string str) throws GLib.Error
  {
    if (!_enumtype.is_a (Type.ENUM)) return;
    var e = Enumeration.parse (_enumtype, str);
    if (e == null) return;
    _val = Enumeration.get_nick_camelcase (_enumtype, e.value);
  }
  public void parse_integer (int v) throws GLib.Error
  {
    if (!_enumtype.is_a (Type.ENUM)) return;
    var e = Enumeration.parse_integer (_enumtype, v);
    if (e == null) return;
    _val = Enumeration.get_nick_camelcase (_enumtype, e.value);
  }
  public int to_integer () throws GLib.Error
  {
    if (_val == null)
      throw new SerializableEnumError.INVALID_VALUE_ERROR (_("Value can't be parsed to a valid enumeration's value. Value is not set"));
    var e = Enumeration.parse (_enumtype, _val);
    if (e == null)
      throw new SerializableEnumError.INVALID_VALUE_ERROR (_("Value can't be parsed to a valid enumeration's value"));
    return e.value;
  }
  public string get_serializable_property_value () { return _val; }
  public void set_serializable_property_value (string? val) { _val = val; }
  public override string to_string () { return _val; }
}