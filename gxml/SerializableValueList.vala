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
 * {@link SerializableValueList.get_value_at}.
 *
 * Is recommended to initilize your list from a fixed array to avoid to have a list
 * for each object in memory, do it by initialize the internal variable
 * {@link GXml.SerializableValueList._vals}, at construct {} clause to point a fixed
 * array of strings.
 */
public class GXml.SerializableValueList : SerializableObjectModel, SerializableProperty
{
  
  private string _val = null;
  private string _name = null;
  protected string[] _vals = null;
  protected ArrayList<string> extra = null;
  /**
   * Return a {@link Gee.List} with all possible selection strings.
   *
   * If no values where defined at construction time and no values
   * have been added, then this will return an empty list.
   */
  public virtual Gee.List<string> get_values () {
    var l = new ArrayList<string> ();
    if (extra != null) l.add_all (extra);
    if (_vals == null) return l;
    for (int i = 0; i < _vals.length; i++) {
      l.add (_vals[i]);
    }
    return l;
  }
  /**
   * Creates a new {@link GXml.SerializableValueList} with the given
   * property name.
   *
   * If no values where defined at construction time and no values
   * have been added, then this will return an empty list.
   */
  public SerializableValueList (string name) { _name = name; }
  /**
   * Add a list of string values to select from.
   * 
   * This values are added to the ones already defined at construct time.s
   */
  public virtual void add_values (string[] vals)
  {
		if (extra == null) extra = new ArrayList<string> ();
		for (int i = 0; i < vals.length; i++) {
	    extra.add (vals[i]);
	  }
  }
  /**
   * Get the string value at a given index. This operation does not change
   * the actual value.
   */
  public virtual string? get_value_at (int index)
  {
    var v = get_values ();
    if (index < 0 || index > v.size || !(index < v.size)) return null;
    return v.get (index);
  }
  /**
   * Sets actual value to the one at a given position.
   */
  public virtual void select_value_at (int index)
  {
    _val = get_value_at (index);
  }
  /**
   * Get an array of string values in list.
   *
   * If no values were defined at construction time and
   * no values were added this return {@link null}
   */
  public virtual string[] get_values_array () {
    return get_values ().to_array ();
  }
  /**
   * Checks if the actual value is in the values list.
   */
  public virtual bool is_value ()
  {
    return get_values ().contains (_val);
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