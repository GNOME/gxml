/* TwText.vala
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

/**
 * Class implemeting {@link GXml.Text} interface, not tied to libxml-2.0 library.
 */
public class GXml.TwText : GXml.TwNode, GXml.Text
{
  private string _str = null;
  construct {
    _name = "#text";
  }
  public TwText (GXml.Document d, string text)
    requires (d is GXml.TwDocument)
  {
    _doc = d;
    ((TwDocument) document).tw = ((TwDocument) d).tw;
    _str = text;
  }
  // GXml.Node
  public override string @value {
    get { return _str; }
    set { _str = value; }
  }
  // GXml.Text
  public string str { get { return _str; } }
}
