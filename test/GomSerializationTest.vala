/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

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

using GXml;

class GomSerializationTest : GXmlTest  {
  public class Book : GomElement {
    public string name { get; set; }
    public Book () {
      var d = new GomDocument ();
      base (d, "Book");
      d.append_child (this);
    }
    public string to_string () { return (_document as GomDocument).to_string (); }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/gom-serialization/write", () => {
      var b = new Book ();
      GLib.message ("DOC:"+b.to_string ());
    });
  }
}
