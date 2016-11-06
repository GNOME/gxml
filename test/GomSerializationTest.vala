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
    public string to_string () {
      var parser = new XParser (this);
      return parser.write_string ();
    }
  }
  public class Computer : GomElement {
    [Description (nick="::Model")]
    public string model { get; set; }
    public string ignore { get; set; } // ignored property
    construct {
      _local_name = "Computer";
    }
    public string to_string () {
      var parser = new XParser (this);
      return parser.write_string ();
    }
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
    public string to_string () {
      var parser = new XParser (this);
      return parser.write_string ();
    }
    public enum Month {
      JANUARY,
      FEBRUARY
    }
  }
  public class BookRegister : GomElement {
    [Description (nick="::Year")]
    public int year { get; set; }
    public Book book { get; set; }
    construct {
      _local_name = "BookRegister";
    }
    public string to_string () {
      var parser = new XParser (this);
      return parser.write_string ();
    }
  }
  public class BookStand : GomElement {
    [Description (nick="::Classification")]
    public string classification { get; set; default = "Science"; }
    public GomArrayList registers { get; set; }
    construct {
      _local_name = "BookStand";
    }
    public string to_string () {
      var parser = new XParser (this);
      return parser.write_string ();
    }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/gom-serialization/write/properties", () => {
      var b = new Book ();
      var parser = new XParser (b);
      string s = parser.write_string ();
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
      assert (c.get_attribute ("ignore") == null);
      s = c.to_string ();
      GLib.message ("DOC:"+s);
    });
    Test.add_func ("/gxml/gom-serialization/write/property-long-name", () => {
      var t = new Taxes ();
      string s = t.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<Taxes " in s);
      assert ("monthRate=\"0\"" in s);
      assert ("Month=\"january\"" in s);
      assert ("TaxFree=\"false\"" in s);
      t.month_rate = 16.5;
      assert ("16.5" in "%.2f".printf (t.month_rate));
      assert ("16.5" in t.get_attribute ("monthrate"));
      t.month = Taxes.Month.FEBRUARY;
      assert (t.month == Taxes.Month.FEBRUARY);
      assert (t.get_attribute ("month") == "february");
      t.tax_free = true;
      assert (t.tax_free == true);
      assert (t.get_attribute ("taxfree") == "true");
      s = t.to_string ();
      assert ("<Taxes " in s);
      assert ("monthRate=\"16.5\"" in s);
      assert ("Month=\"february\"" in s);
      assert ("TaxFree=\"true\"" in s);
      GLib.message ("DOC:"+s);
    });
    Test.add_func ("/gxml/gom-serialization/write/property-arraylist", () => {
      var bs = new BookStand ();
      string s = bs.to_string ();
      assert (s != null);
      assert ("<BookStand Classification=\"Science\"/>" in s);
      GLib.message ("DOC:"+s);
      var br = new BookRegister ();
      br.year = 2016;
      assert (bs.registers == null);
      bs.registers = new GomArrayList.initialize (bs,br.local_name);
      s = bs.to_string ();
      assert (s != null);
      assert ("<BookStand Classification=\"Science\"/>" in s);
      GLib.message ("DOC:"+s);
    });
    Test.add_func ("/gxml/gom-serialization/read/properties", () => {
      var b = new Book ();
      var parser = new XParser (b);
      parser.read_string ("<book name=\"Loco\"/>", null);
      string s = parser.write_string ();
      assert (s != null);
      GLib.message ("Doc:"+s);
      assert (b.child_nodes.size == 0);
      assert (b.attributes.size == 0);
      assert (b.name == "Loco");
      s = parser.write_string ();
      assert (s != null);
      assert ("<Book Name=\"Loco\"/>" in s);
      GLib.message ("Doc:"+s);
      b.name = "My Book";
      assert (b.get_attribute ("name") == "My Book");
      s = b.to_string ();
      assert ("<Book Name=\"My Book\"/>" in s);
    });
    Test.add_func ("/gxml/gom-serialization/read/bad-node-name", () => {
      var b = new Book ();
      var parser = new XParser (b);
      try {
        parser.read_string ("<Chair name=\"Tall\"/>", null);
        assert_not_reached ();
      } catch {}
    });
    Test.add_func ("/gxml/gom-serialization/read/object-property", () => {
      var b = new BookRegister ();
      string s = b.to_string ();
      GLib.message ("doc:"+s);
      assert ("<BookRegister Year=\"0\"/>" in s);
      var parser = new XParser (b);
      parser.read_string ("<BookRegister><Book/></BookRegister>", null);
      s = b.to_string ();
      GLib.message ("doc:"+s);
      assert ("<BookRegister Year=\"0\"><Book/></BookRegister>" in s);
    });
  }
}
