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
 * Represent any value as string but a list of options by default to select from.
 * property to be added as a {@link GXml.Attr} to a {@link GXml.Element}.
 *
 * All values are stored in an array to get access to it by its position using
 * {@link SerializableValueList.get_value}.
 */
public class GXml.SerializableValueList : SerializableObjectModel, SerializableProperty
{
  private string _val = null;
  private string _name = null;
  private ArrayList<string> _values = null;
  public SerializableValueList (string name) { _name = name; }
  /**
   * Add a list of string values to select from.
   */
  public virtual void add_values (string[] vals)
  {
    if (_values == null) _values = new ArrayList<string> ();
    for (int i = 0; i < vals.length; i++) {
      _values.add (vals[i]);
    }
  }
  /**
   * Get the string value at a given index. This operation does not change
   * the actual value.
   */
  public string? get_value_at (int index)
  {
    if (_values == null) return null;
    if (index < 0 || index >= _values.size) return null;
    return _values.get (index);
  }
  /**
   * Sets value to the one at a given position.
   */
  public void select_value_at (int index)
  {
    _val = get_value_at (index);
  }
  /**
   * Get an array of string values in list.
   */
  public virtual string[] get_values () {
    if (_values == null) return {""};
    return _values.to_array ();
  }
  /**
   * Checks if the actual value is in the values list.
   */
  public bool is_value ()
  {
    if (_values == null) return false;
    foreach (string s in _values) {
      if (s == _val) return true;
    }
    return false;
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
    default_serializable_property_deserialize_property (node);
    return node;
  }
  public override bool deserialize_property (GXml.Node property_node)
                                              throws GLib.Error
  {
    default_serializable_property_deserialize_property (property_node);
    return true;
  }
  public override string to_string () { return _val; }
}