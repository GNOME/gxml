/* TwAttribute.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;

public class GXml.TwAttribute : GXml.TwNode, GXml.Attribute
{
  public TwAttribute (GXml.Document d, string name, string value)
    requires (d is TwDocument)
  {
    _doc = d;
    ((TwDocument) document).tw = ((TwDocument) d).tw;
    _name = name;
    _value = value;
  }
  // GXml.Attribute
  public override string name { get { return _name; } }
  public override string @value { get { return _value; } set  { _value = value;} }
}
