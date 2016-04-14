/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* SerializableInt.vala
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
 * Represent any double presition float property to be added as a {@link GXml.Attribute} to a {@link GXml.Element}
 *
 * This object can be used when the property could be removed from serialization, specially if missing
 * on XML have some missing and avoidable.
 */
public class GXml.SerializableDouble : Object, SerializableProperty
{
  protected string _val = null;
  protected int _fraction = -1;

  construct { Init.init (); }

  public int get_fraction () { return _fraction; }
  public void set_fraction (int fraction) {
    int v = fraction;
    if (v < 0) _fraction = -1;
    _fraction = v;
  }
  public double get_value () { return double.parse (_val); }
  public void set_value (double val) { _val = val.to_string (); }
  public string get_serializable_property_value () { return _val; }
  public void set_serializable_property_value (string? val) { _val = val; }
  public string to_string () {
    if (_val != null) return (double.parse (_val)).to_string ();
    return "";
  }
  public string format (string f)
  {
    if (_val != null) return f.printf (double.parse (_val));
    return "";
  }
}
