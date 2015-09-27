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
using Gee;

public class GXml.SerializableValueList : SerializableObjectModel, SerializableProperty
{
  private string _val = null;
  private string _name = null;
  private ArrayList<string> _values = null;
  public SerializableValueList.with_name (string name) { _name = name; }
  public void add_values (string[] vals)
  {
    if (_values == null) _values = new ArrayList<string> ();
    for (int i = 0; i < vals.length; i++) {
      _values.add (vals[i]);
    }
  }
  public string? get_value_at (int index)
  {
    if (_values == null) return null;
    if (index < 0 || index >= _values.size) return null;
    return _values.get (index);
  }
  public void select_value_at (int index)
  {
    _val = get_value_at (index);
  }
  public string[] get_values () { return _values.to_array (); }
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