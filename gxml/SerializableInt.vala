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
 * Represent any boolean property to be added as a {@link GXml.Attr} to a {@link GXml.Element}
 *
 */
public class GXml.SerializableInt : GXml.SerializableDouble
{
  public SerializableInt (string name) { _name = name; }
  public new int get_value () { return (int) double.parse (_val); }
  public new void set_value (int val) { _val = val.to_string (); }
  public override string to_string () {
    if (_val != null) return ((int) double.parse (_val)).to_string ();
    return "";
  }
}