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

// GOM Collection Definitions
class GomName : GomElement
{
  construct { try { initialize ("Name"); } catch { assert_not_reached (); } }
  public string get_name () { return this.text_content; }
  public void   set_name (string name) { this.text_content = name; }
}

class GomEmail : GomElement
{
  construct {  try { initialize ("Email"); } catch { assert_not_reached (); } }
  public string get_mail () { return this.text_content; }
  public void   set_mail (string email) { text_content = email; }
}

class GomAuthor : GomElement
{
  public Name name { get; set; }
  public Email email { get; set; }
  construct { try { initialize ("Author"); } catch { assert_not_reached (); } }
  public class Array : GomArrayList {
    construct { try { initialize (typeof (GomAuthor)); }
    catch { assert_not_reached (); } }
  }
}

class GomAuthors : GomElement
{
  public string number { get; set; }
  construct { try { initialize ("Authors"); } catch { assert_not_reached (); } }
  public GomAuthor.Array array { get; set; }
}

class GomInventory : GomElement
{
  [Description (nick="::Number")]
  public int number { get; set; }
  [Description (nick="::Row")]
  public int row { get; set; }
  [Description (nick="::Inventory")]
  public string inventory { get; set; }
  construct { try { initialize ("Inventory"); } catch { assert_not_reached (); } }
  // FIXME: Add DualKeyMap implementation to GOM
  public class DualKeyMap : GomHashMap {
    construct {
      try { initialize_with_key (typeof (GomInventory), "number"); }
      catch { assert_not_reached (); }
    }
  }
}

class GomCategory : GomElement
{
  [Description (nick="::Name")]
  public string name { get; set; }
  construct { try { initialize ("Category"); } catch { assert_not_reached (); } }
  public class Map : GomHashMap {
    construct {
      try { initialize_with_key (typeof (GomInventory), "name");  }
      catch { assert_not_reached (); }
    }
  }
}


class GomResume : GomElement
{
  [Description (nick="::Chapter")]
  public string chapter { get; set; }
  [Description (nick="::Text")]
  public string text { get; set; }
  construct { try { initialize ("Resume"); } catch { assert_not_reached (); } }
  public class Map : GomHashMap {
    construct {
      try { initialize_with_key (typeof (GomInventory), "chapter"); }
      catch { assert_not_reached (); }
    }
  }
}

class GomBook : GomElement
{
  [Description(nick="::Year")]
  public string year { get; set; }
  [Description(nick="::ISBN")]
  public string isbn { get; set; }
  public GomName   name { get; set; }
  public GomAuthors authors { get; set; }
  public GomInventory.DualKeyMap inventory_registers { get; set; }
  public GomCategory.Map categories { get; set; }
  public GomResume.Map resumes { get; set; }
  construct {
    try { initialize ("Book"); } catch { assert_not_reached (); }
  }
  public class Array : GomArrayList {
    construct {
      try { initialize (typeof (GomBook)); }
      catch { assert_not_reached (); }
    }
  }
}

class GomBookStore : GomElement
{
  [Description (nick="::name")]
  public string name { get; set; }
  public GomBook.Array books { get; set; }
  construct {
    try { initialize ("BookStore"); } catch { assert_not_reached (); }
  }
  public string to_string () {
    var parser = new XParser (this);
    string s = "";
    try {
      s = parser.write_string ();
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    return s;
  }
}

class GomSerializationTest : GXmlTest  {
  public class Book : GomElement {
    [Description (nick="::Name")]
    public string name { get; set; }
    construct { try { initialize ("Book"); } catch { assert_not_reached (); } }
    public Book.document (DomDocument doc) {
      _document = doc;
    }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
    }
  }
  public class Computer : GomElement {
    [Description (nick="::Model")]
    public string model { get; set; }
    public string ignore { get; set; } // ignored property
    construct { try { initialize ("Computer"); } catch { assert_not_reached (); } }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
    }
  }
  public class Taxes : GomElement {
    [Description (nick="::monthRate")]
    public double month_rate { get; set; }
    [Description (nick="::TaxFree")]
    public bool tax_free { get; set; }
    [Description (nick="::Month")]
    public Month month { get; set; }
    construct { try { initialize ("Taxes"); } catch { assert_not_reached (); } }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
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
      try { initialize ("BookRegister"); }
      catch { assert_not_reached (); }
    }
    public BookRegister.document (DomDocument doc) {
      _document = doc;
    }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
    }
  }
  public class BookStand : GomElement {
    [Description (nick="::Classification")]
    public string classification { get; set; default = "Science"; }
    public Registers registers { get; set; }
    public Books books { get; set; }
    construct {
      try { initialize ("BookStand"); } catch { assert_not_reached (); }
    }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
    }
  }

  public class Registers : GomArrayList {
    construct {
      try { initialize (typeof (BookRegister)); }
      catch { assert_not_reached (); }
    }
  }
  public class Books : GomHashMap {
    construct {
      try { initialize_with_key (typeof (Book), "Name"); }
      catch { assert_not_reached (); }
    }
  }
  public class BookStore : GomElement {
    [Description (nick="::Name")]
    public string name { get; set; }
    public Books books { get; set; }
    construct {
      try { initialize ("BookStore"); } catch { assert_not_reached (); }
    }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
    }
  }
  public class Motor : GomElement {
    [Description (nick="::On")]
    public On is_on { get; set; }
    [Description (nick="::Torque")]
    public Torque torque { get; set; }
    [Description (nick="::Speed")]
    public Speed speed { get; set; }
    [Description (nick="::TensionType")]
    public TensionType tension_type { get; set; }
    [Description (nick="::Tension")]
    public Tension tension { get; set; }
    [Description (nick="::Model")]
    public Model model { get; set; }
    construct { try { initialize ("Motor"); } catch { assert_not_reached (); } }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
    }
    public enum TensionTypeEnum {
      AC,
      DC
    }
    public class On : GomBoolean {}
    public class Torque : GomDouble {
      construct {
        try { initialize ("Torque"); } catch { assert_not_reached (); }
      }
    }
    public class Speed : GomFloat {
      construct {
        try { initialize ("Speed"); } catch { assert_not_reached (); }
      }
    }
    public class TensionType : GomEnum {
      construct {
        try { initialize_enum ("TensionType", typeof (TensionTypeEnum)); }
        catch { assert_not_reached (); }
      }
    }
    public class Tension : GomInt {
      construct {
        try { initialize ("Tension"); } catch { assert_not_reached (); }
      }
    }
    public class Model : GomArrayString {
      construct {
        initialize ("Model");;
        initialize_strings ({"MODEL1","MODEL2"});
      }
    }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/gom-serialization/write/properties", () => {
    try {
      var b = new Book ();
      var parser = new XParser (b);
      string s = parser.write_string ();
      assert (s != null);
      assert ("<Book/>" in s);
      b.name = "My Book";
      assert (b.get_attribute ("name") == "My Book");
      s = b.to_string ();
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
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
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
    });
    Test.add_func ("/gxml/gom-serialization/write/property-long-name", () => {
    try {
      var t = new Taxes ();
      string s = t.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
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
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/write/property-arraylist", () => {
    try {
      var bs = new BookStand ();
      string s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"/>" in s);
      assert (bs.owner_document != null);
      assert  (bs.registers == null);
      bs.registers = new Registers ();
      bs.registers.initialize_element (bs);
      s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"/>" in s);
      try {
        var br = new BookRegister ();
        bs.registers.append (br);
        assert_not_reached ();
      } catch {}
      var br2 = bs.registers.create_item () as BookRegister;
      br2.year = 2016;
      bs.registers.append (br2);
      s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/></BookStand>" in s);
      var br3 = bs.registers.create_item () as BookRegister;
      bs.registers.append (br3);
      br3.year = 2010;
      bs.append_child (bs.owner_document.create_element ("Test"));
      var br4 = bs.registers.create_item () as BookRegister;
      bs.registers.append (br4);
      br4.year = 2000;
      s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/><BookRegister Year=\"2010\"/><Test/><BookRegister Year=\"2000\"/></BookStand>" in s);
      assert ((bs.registers.get_item (0) as BookRegister).year == 2016);
      assert ((bs.registers.get_item (1) as BookRegister).year == 2010);
      assert ((bs.registers.get_item (2) as BookRegister).year == 2000);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/write/property-hashmap", () => {
    try {
      var bs = new BookStore ();
      string s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStore/>" in s);
      assert (bs.books == null);
      bs.books = new Books ();
      bs.books.initialize_element (bs);
      s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStore/>" in s);
      var b = new Book ();
      try {
        bs.books.append (b);
        assert_not_reached ();
      } catch {}
      b = new Book.document (bs.owner_document);
      b.name = "Title1";
      bs.books.append (b);
      s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStore><Book Name=\"Title1\"/></BookStore>" in s);
      var b2 = new Book.document (bs.owner_document);
      b2.name = "Title2";
      bs.books.append (b2);
      bs.append_child (bs.owner_document.create_element ("Test"));
      var b3 = new Book.document (bs.owner_document);
      b3.name = "Title3";
      bs.books.append (b3);
      s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStore><Book Name=\"Title1\"/><Book Name=\"Title2\"/><Test/><Book Name=\"Title3\"/></BookStore>" in s);
      assert (bs.books.get("Title1") != null);
      assert (bs.books.get("Title2") != null);
      assert (bs.books.get("Title3") != null);
      assert ((bs.books.get("Title1") as Book).name == "Title1");
      assert ((bs.books.get("Title2") as Book).name == "Title2");
      assert ((bs.books.get("Title3") as Book).name == "Title3");
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/write/gom-property", () => {
    try {
      var m = new Motor ();
      string s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor/>" in s);
      m.is_on = new Motor.On ();
      s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor On=\"false\"/>" in s);
      m.torque = new Motor.Torque ();
      s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor On=\"false\" Torque=\"0.0000\"/>" in s);
      m.speed = new Motor.Speed ();
      s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"0.0000\"/>" in s);
      assert (m.tension_type == null);
      m.tension_type = new Motor.TensionType ();
      s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"0.0000\" TensionType=\"ac\"/>" in s);
      m.tension = new Motor.Tension ();
      s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"0.0000\" TensionType=\"ac\" Tension=\"0\"/>" in s);
      m.is_on.set_boolean (true);
      m.torque.set_double (3.1416);
      m.speed.set_float ((float) 3600.1011);
      m.tension_type.set_enum ((int) Motor.TensionTypeEnum.DC);
      m.tension.set_integer (125);
      s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor On=\"true\" Torque=\"3.1416\" Speed=\"3600.1011\" TensionType=\"dc\" Tension=\"125\"/>" in s);
      m.model = new Motor.Model ();
      assert (m.model != null);
      assert (m.model.value != null);
      assert (m.model.value == "");
      m.model.value = "Model3";
      assert (m.model.value == "Model3");
      s = m.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<Motor On=\"true\" Torque=\"3.1416\" Speed=\"3600.1011\" TensionType=\"dc\" Tension=\"125\" Model=\"Model3\"/>" in s);
      assert (!m.model.is_valid_value ());
      assert (m.model.search ("MODEL1"));
      m.model.value = "MODEL1";
      assert (m.model.is_valid_value ());
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/read/properties", () => {
    try {
      var b = new Book ();
      var parser = new XParser (b);
      parser.read_string ("<book name=\"Loco\"/>", null);
      string s = parser.write_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("Doc:"+s);
#endif
      assert (b != null);
      assert (b.child_nodes != null);
      assert (b.child_nodes.size == 0);
      assert (b.attributes != null);
      assert (b.attributes.size == 0);
      assert (b.name != null);
#if DEBUG
      assert (b.name == "Loco");
#endif
      s = parser.write_string ();
      assert (s != null);
      assert ("<Book Name=\"Loco\"/>" in s);
#if DEBUG
      GLib.message ("Doc:"+s);
#endif
      b.name = "My Book";
      assert (b.get_attribute ("name") == "My Book");
      s = b.to_string ();
      assert ("<Book Name=\"My Book\"/>" in s);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/read/bad-node-name", () => {
      var b = new Book ();
      b.read_from_string ("<chair name=\"Tall\"/>");
#if DEBUG
      var parser = new XParser (b);
      GLib.message ("Read: "+parser.write_string ());
#endif
      assert (b.name == null);
      assert (b.child_nodes.size == 0);
      assert (b.owner_document.document_element != null);
      assert (b.owner_document.document_element.node_name == "Book");
    });
    Test.add_func ("/gxml/gom-serialization/read/object-property", () => {
    try {
      var b = new BookRegister ();
      string s = b.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<BookRegister Year=\"0\"/>" in s);
      b.read_from_string ("<bookRegister><Book/></bookRegister>");
      s = b.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<BookRegister Year=\"0\"><Book/></BookRegister>" in s);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/read/gom-property", () => {
    try {
      var m = new Motor ();
      string s = m.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<Motor/>" in s);
      var parser = new XParser (m);
      parser.read_string ("<Motor On=\"true\" Torque=\"3.1416\" Speed=\"3600.1011\" TensionType=\"dc\" Tension=\"125\"/>", null);
      s = m.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<Motor " in s);
      assert ("On=\"true\"" in s);
      assert ("Torque=\"3.1416\"" in s);
      assert ("Speed=\"3600.1011\"" in s);
      assert ("TensionType=\"dc\"" in s);
      assert ("Tension=\"125\"" in s);
      assert ("/>" in s);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/read/property-arraylist", () => {
    try {
      var bs = new BookStand ();
      string s = bs.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"/>" in s);
      var parser = new XParser (bs);
      parser.read_string ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/><BookRegister Year=\"2010\"/><Test/><BookRegister Year=\"2000\"/></BookStand>", null);
      s = bs.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
      GLib.message ("Registers: "+bs.registers.length.to_string ());
#endif
      assert (bs.registers != null);
      assert (bs.registers.length == 3);
      assert (bs.registers.nodes_index.peek_nth (0) == 0);
      assert (bs.registers.nodes_index.peek_nth (1) == 1);
      assert (bs.registers.nodes_index.peek_nth (2) == 3);
      assert (bs.registers.get_item (0) != null);
      assert (bs.registers.get_item (0) is DomElement);
      assert (bs.registers.get_item (0) is BookRegister);
      assert (bs.registers.get_item (1) != null);
      assert (bs.registers.get_item (1) is DomElement);
      assert (bs.registers.get_item (1) is BookRegister);
      assert (bs.registers.get_item (2) != null);
      assert (bs.registers.get_item (2) is DomElement);
      assert (bs.registers.get_item (2) is BookRegister);
      assert ((bs.registers.get_item (0) as BookRegister).year == 2016);
      assert ((bs.registers.get_item (1) as BookRegister).year == 2010);
      assert ((bs.registers.get_item (2) as BookRegister).year == 2000);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/read/property-hashmap", () => {
    try {
      var bs = new BookStand ();
      string s = bs.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"/>" in s);
      bs.read_from_string ("<bookStand Classification=\"Science\"><book name=\"Title1\"/><book name=\"Title2\"/><Test/><book name=\"Title3\"/></bookStand>");
      //assert (bs.registers == null);
      assert (bs.books != null);
      s = bs.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      GLib.message ("Books: "+bs.books.length.to_string ());
      assert (bs.books.length == 3);
      assert (bs.books.nodes_index.peek_nth (0) == 0);
      assert (bs.books.nodes_index.peek_nth (1) == 1);
      assert (bs.books.nodes_index.peek_nth (2) == 3);
      assert (bs.books.get_item (0) != null);
      assert (bs.books.get_item (0) is DomElement);
      assert (bs.books.get_item (0) is Book);
      assert (bs.books.get_item (1) != null);
      assert (bs.books.get_item (1) is DomElement);
      assert (bs.books.get_item (1) is Book);
      assert (bs.books.get_item (2) != null);
      assert (bs.books.get_item (2) is DomElement);
      assert (bs.books.get_item (2) is Book);
      assert ((bs.books.get_item (0) as Book).name == "Title1");
      assert ((bs.books.get_item (1) as Book).name == "Title2");
      assert ((bs.books.get_item (2) as Book).name == "Title3");
      assert (bs.books.get ("Title1") != null);
      assert (bs.books.get ("Title1") is DomElement);
      assert (bs.books.get ("Title1") is Book);
      assert (bs.books.get ("Title2") != null);
      assert (bs.books.get ("Title2") is DomElement);
      assert (bs.books.get ("Title2") is Book);
      assert (bs.books.get ("Title3") != null);
      assert (bs.books.get ("Title3") is DomElement);
      assert (bs.books.get ("Title3") is Book);
      assert (bs.books.get ("Title4") == null);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/gom-serialization/multiple-child-collections",
    () => {
      try {
        double time;
        GomDocument doc;
        var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR + "/test-collection.xml");
        assert (f.query_exists ());
        Test.timer_start ();
        var bs = new GomBookStore ();
        assert (bs != null);
#if DEBUG
        GLib.message (">>>>>>>>Empty XML:"+bs.to_string ());
#endif
        bs.read_from_file (f);
        assert (bs.books != null);
        assert (bs.books.element != null);
        assert (bs.books.items_type.is_a (typeof(GomBook)));
        assert (bs.books.items_name == "Book");
        assert (bs.local_name == "BookStore");
        assert (bs.get_attribute ("name") != null);
        assert (bs.name != null);
        assert (bs.name == "The Great Book");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "deserialize/performance: %g seconds", time);
#if DEBUG
        GLib.message (">>>>>>>>XML:"+bs.to_string ());
#endif
        var of = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR + "/test-large-new.xml");
        Test.timer_start ();
        // Check read structure
#if DEBUG
        GLib.message ("Document Root: "+bs.owner_document.document_element.node_name);
#endif
        assert (bs.owner_document.document_element.node_name.down () == "bookstore");
#if DEBUG
        GLib.message ("Root Child nodes: "+bs.child_nodes.length.to_string ());
#endif
        assert (bs.child_nodes.length == 7);
        var ns = bs.get_elements_by_tag_name ("Book");
#if DEBUG
        GLib.message ("Query Books: "+ns.length.to_string ());
        GLib.message ("Books: "+bs.books.length.to_string ());
#endif
        assert (ns.length == 3);
        /*assert (bs.books.length > 0);
        var b = bs.books.get_item (0) as GomBook;
        assert (b != null);
        assert (b.year == "2015");*/
        bs.write_file (of);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Serialize/performance: %g seconds", time);
        assert (of.query_exists ());
        try { of.delete (); } catch { assert_not_reached (); }

      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
  }
}
