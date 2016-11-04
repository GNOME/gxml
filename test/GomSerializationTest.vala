/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
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
    [Description (nick="::Name")]
    public string name { get; set; }
    construct {
      _local_name = "Book";
    }
    public string to_string () { return (_document as GomDocument).to_string (); }
  }
  public class Computer : GomElement {
    [Description (nick="::Model")]
    public string model { get; set; }
    public string ignore { get; set; } // ignored property
    construct {
      _local_name = "Computer";
    }
    public string to_string () { return (_document as GomDocument).to_string (); }
  }
  public class Taxes : GomElement {
    [Description (nick="::monthRate")]
    public double month_rate { get; set; }
    [Description (nick="::TaxFree")]
    public bool tax_free { get; set; }
    [Description (nick="::Month")]
    public Month month { get; set; }
    construct {
      _local_name = "Taxes";
    }
    public string to_string () { return (_document as GomDocument).to_string (); }
    public enum Month {
      JANUARY,
      FEBRUARY
    }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/gom-serialization/write/properties", () => {
      var b = new Book ();
      string s = b.to_string ();
      assert (s != null);
      assert ("<Book/>" in s);
      b.name = "My Book";
      assert (b.get_attribute ("name") == "My Book");
      s = b.to_string ();
      GLib.message ("DOC:"+s);
    });
    Test.add_func ("/gxml/gom-serialization/write/property-ignore", () => {
      var c = new Computer ();
      string s = c.to_string ();
      assert (s != null);
      assert ("<Computer/>" in s);
      c.model = "T3456-E";
      c.ignore = "Nothing";
      assert (c.model == "T3456-E");
      assert (c.get_attribute ("model") == "T3456-E");
      assert (c.ignore == "Nothing");
      assert (c.get_attribute ("ignore") == "Nothing");
      s = c.to_string ();
      GLib.message ("DOC:"+s);
    });
    Test.add_func ("/gxml/gom-serialization/write/property-long-name", () => {
      var t = new Taxes ();
      string s = t.to_string ();
      assert (s != null);
      assert ("<Taxes monthRate=\"0\" Month=\"january\" TaxFree=\"false\"/>" in s);
      t.month_rate = 16.5;
      assert ("16.5" in "%.2f".printf (t.month_rate));
      assert ("16.5" in t.get_attribute ("month-rate"));
      t.month = Taxes.Month.FEBRUARY;
      assert (t.month == Taxes.Month.FEBRUARY);
      assert (t.get_attribute ("month") == "february");
      t.tax_free = true;
      assert (t.tax_free == true);
      assert (t.get_attribute ("tax-free") == "true");
      s = t.to_string ();
      GLib.message ("DOC:"+s);
    });
  }
}
