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
    public Book.document (DomDocument doc) {
      _document = doc;
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
    public BookRegister.document (DomDocument doc) {
      _document = doc;
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
  public class BookStore : GomElement {
    public GomHashMap books { get; set; }
    construct {
      _local_name = "BookStore";
    }
    public string to_string () {
      var parser = new XParser (this);
      return parser.write_string ();
    }
  }
  public class Motor : GomElement {
    public On is_on { get; set; }
    public Torque torque { get; set; }
    public Speed speed { get; set; }
    public TensionType tension_type { get; set; }
    public Tension tension { get; set; }
    construct {
      _local_name = "Motor";
    }
    public string to_string () {
      var parser = new XParser (this);
      return parser.write_string ();
    }
    public enum Enum {
      AC,
      DC
    }
    public class On : GomBoolean {
      construct {
        _attribute_name = "On";
      }
    }
    public class Torque : GomDouble {
      construct {
        _attribute_name = "Torque";
      }
    }
    public class Speed : GomFloat {
      construct {
        _attribute_name = "Speed";
      }
    }
    public class TensionType : GomEnum {
      construct {
        _enum_type = typeof (Enum);
        _attribute_name = "TensionType";
      }
    }
    public class Tension : GomInt {
      construct {
        _attribute_name = "Tension";
      }
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
      GLib.message ("DOC:"+s);
      assert ("<BookStand Classification=\"Science\"/>" in s);
      assert (bs.registers == null);
      var br = new BookRegister ();
      bs.registers = new GomArrayList.initialize (bs,br.local_name);
      s = bs.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<BookStand Classification=\"Science\"/>" in s);
      try {
        bs.registers.add (br);
        assert_not_reached ();
      } catch {}
      br = new BookRegister.document (bs.owner_document);
      br.year = 2016;
      bs.registers.add (br);
      s = bs.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/></BookStand>" in s);
      var br2 = new BookRegister.document (bs.owner_document);
      bs.registers.add (br2);
      br2.year = 2010;
      bs.append_child (bs.owner_document.create_element ("Test"));
      var br3 = new BookRegister.document (bs.owner_document);
      bs.registers.add (br3);
      br3.year = 2000;
      s = bs.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/><BookRegister Year=\"2010\"/><Test/><BookRegister Year=\"2000\"/></BookStand>" in s);
      assert ((bs.registers.get_item (0) as BookRegister).year == 2016);
      assert ((bs.registers.get_item (1) as BookRegister).year == 2010);
      assert ((bs.registers.get_item (2) as BookRegister).year == 2000);
    });
    Test.add_func ("/gxml/gom-serialization/write/property-hashmap", () => {
      var bs = new BookStore ();
      string s = bs.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<BookStore/>" in s);
      assert (bs.books == null);
      var b = new Book ();
      bs.books = new GomHashMap.initialize (bs,b.local_name,"name");
      s = bs.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<BookStore/>" in s);
      try {
        bs.books.set (b);
        assert_not_reached ();
      } catch {}
      b = new Book.document (bs.owner_document);
      try {
        bs.books.set (b);
        assert_not_reached ();
      } catch {}
      b.name = "Title1";
      bs.books.set (b);
      s = bs.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<BookStore><Book Name=\"Title1\"/></BookStore>" in s);
      var b2 = new Book.document (bs.owner_document);
      b2.name = "Title2";
      bs.books.set (b2);
      bs.append_child (bs.owner_document.create_element ("Test"));
      var b3 = new Book.document (bs.owner_document);
      b3.name = "Title3";
      bs.books.set (b3);
      s = bs.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<BookStore><Book Name=\"Title1\"/><Book Name=\"Title2\"/><Test/><Book Name=\"Title3\"/></BookStore>" in s);
      assert (bs.books.get("Title1") != null);
      assert (bs.books.get("Title2") != null);
      assert (bs.books.get("Title3") != null);
      assert ((bs.books.get("Title1") as Book).name == "Title1");
      assert ((bs.books.get("Title2") as Book).name == "Title2");
      assert ((bs.books.get("Title3") as Book).name == "Title3");
    });
    Test.add_func ("/gxml/gom-serialization/write/gom-property", () => {
      var m = new Motor ();
      string s = m.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<Motor/>" in s);
      m.is_on = new Motor.On ();
      s = m.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<Motor On=\"false\"/>" in s);
      m.torque = new Motor.Torque ();
      s = m.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<Motor On=\"false\" Torque=\"0.0000\"/>" in s);
      m.speed = new Motor.Speed ();
      s = m.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"0.0000\"/>" in s);
      m.tension_type = new Motor.TensionType ();
      s = m.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"0.0000\" TensionType=\"ac\"/>" in s);
      m.tension = new Motor.Tension ();
      s = m.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"0.0000\" TensionType=\"ac\" Tension=\"0\"/>" in s);
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
