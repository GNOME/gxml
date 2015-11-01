/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* SerializableBool.vala
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
 * Represent any boolean property to be added as a {@link GXml.Attribute} to a {@link GXml.Element}
 *
 */
public class GXml.SerializableBool : Object, SerializableProperty
{
  private string _val = null;

	construct { Init.init (); }
  /**
   * Parse the stored value, from the XML property, to a {@link int}. This parsing
   * may is different from the actual stored string. If can't be parsed to a valid
   * boolean, this method will always return false.
   */
  public bool get_value () {
    if (_val.down () == "true") return true;
    if (_val.down () == "false") return false;
    return false;
  }
  /**
   * Given boolean value is parsed to string and then stored.
   */
  public void set_value (bool val) { _val = val.to_string (); }
  // SerializableProperty implementations
  public string get_serializable_property_value () { return _val; }
  public void set_serializable_property_value (string? val) { _val = val; }
  /**
   * Parse actual stored string to a boolean and returns the result. See {@link get_value}
   */
  public string to_string () { return get_value ().to_string (); }
}
