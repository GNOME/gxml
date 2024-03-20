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
class ThreeKeys : GXml.Element {
  private ThreeKey.Map _map;
  public ThreeKey.Map map {
    get {
      if (_map == null)
        set_instance_property ("map");
      return _map;
    }
    set {
      if (_map != null)
        try { clean_property_elements ("map"); }
        catch (GLib.Error e) { warning ("Error: "+e.message); }
      _map = value;
    }
  }
  construct { try { initialize ("ThreeKeys"); } catch { assert_not_reached (); } }
}
class ThreeKey : GXml.Element, MappeableElementThreeKey {
  [Description (nick="::ID")]
  public string id { get; set; }
  [Description (nick="::Code")]
  public string code { get; set; }
  [Description (nick="::name")]
  public string name { get; set; }
  construct { try { initialize ("ThreeKey"); } catch { assert_not_reached (); } }
  public string get_map_pkey () { return id; }
  public string get_map_skey () { return code; }
  public string get_map_tkey () { return name; }
  public class Map : GXml.HashThreeMap {
    construct {
      try { initialize (typeof (ThreeKey)); }
      catch (GLib.Error e) { message ("Error: "+e.message); }
    }
  }
}
class Operations : GXml.Element {
  private Operation.Map _map;
  public Operation.Map map {
    get {
      if (_map == null)
        set_instance_property ("map");
      return _map;
    }
    set {
      if (_map != null)
        try { clean_property_elements ("map"); }
        catch (GLib.Error e) { warning ("Error: "+e.message); }
      _map = value;
    }
  }
  construct { try { initialize ("Operations"); } catch { assert_not_reached (); } }
}
class Operation : GXml.Element, MappeableElementPairKey {
  [Description (nick="::ID")]
  public string id { get; set; }
  [Description (nick="::Code")]
  public string code { get; set; }
  construct { try { initialize ("Operation"); } catch { assert_not_reached (); } }
  public string get_map_primary_key () { return id; }
  public string get_map_secondary_key () { return code; }
  public class Map : GXml.HashPairedMap {
    construct {
      try { initialize (typeof (Operation)); }
      catch (GLib.Error e) { message ("Error: "+e.message); }
    }
  }
}
class GomName : GXml.Element
{
  construct { try { initialize ("Name"); } catch { assert_not_reached (); } }
}

class GomEmail : GXml.Element
{
  construct {  try { initialize ("Email"); } catch { assert_not_reached (); } }
}

class GomAuthor : GXml.Element
{
  public GomName name { get; set; }
  public GomEmail email { get; set; }
  construct { try { initialize ("Author"); } catch { assert_not_reached (); } }
  public class Array : GXml.ArrayList {
    construct { try { initialize (typeof (GomAuthor)); }
    catch { assert_not_reached (); } }
  }
}

class GomAuthors : GXml.Element
{
  public string number { get; set; }
  construct { try { initialize ("Authors"); } catch { assert_not_reached (); } }
  public GomAuthor.Array array { get; set; }
}

class GomInventory : GXml.Element
{
  [Description (nick="::Number")]
  public int number { get; set; }
  [Description (nick="::Row")]
  public int row { get; set; }
  [Description (nick="::Inventory")]
  public string inventory { get; set; }
  construct { try { initialize ("Inventory"); } catch { assert_not_reached (); } }
  // FIXME: Add DualKeyMap implementation to GOM
  public class DualKeyMap : GXml.HashMap {
    construct {
      try { initialize_with_key (typeof (GomInventory), "number"); }
      catch { assert_not_reached (); }
    }
  }
}

class GomCategory : GXml.Element
{
  [Description (nick="::Name")]
  public string name { get; set; }
  construct { try { initialize ("Category"); } catch { assert_not_reached (); } }
  public class Map : GXml.HashMap {
    construct {
      try { initialize_with_key (typeof (GomCategory), "name");  }
      catch { assert_not_reached (); }
    }
  }
}


class GomResume : GXml.Element
{
  [Description (nick="::Chapter")]
  public string chapter { get; set; }
  [Description (nick="::Text")]
  public string text { get; set; }
  construct { try { initialize ("Resume"); } catch { assert_not_reached (); } }
  public class Map : GXml.HashMap {
    construct {
      try { initialize_with_key (typeof (GomResume), "chapter"); }
      catch { assert_not_reached (); }
    }
  }
}

class GomBook : GXml.Element
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
  public class Array : GXml.ArrayList {
    construct {
      try { initialize (typeof (GomBook)); }
      catch { assert_not_reached (); }
    }
  }
}

class GomBookStore : GXml.Element
{
  [Description (nick="::name")]
  public string name { get; set; }
  public GomBook.Array books { get; set; }
  construct {
    try { initialize ("BookStore"); } catch { assert_not_reached (); }
  }
}

class GomBasicTypes : GXml.Element {
  [Description (nick="::text")]
  public string text { get; set; }
  [Description (nick="::integer")]
  public int integer { get; set; }
  [Description (nick="::realDouble")]
  public double real_double { get; set; }
  [Description (nick="::realFloat")]
  public float real_float { get; set; }
  [Description (nick="::unsignedInteger")]
  public uint unsigned_integer { get; set; }
  [Description (nick="::Boolean")]
  public bool boolean { get; set; }
  construct {
    try { initialize ("GomBasicTypes"); } catch { assert_not_reached (); }
  }
}

interface Item : GLib.Object, GXml.Object {}


class Items : GXml.ArrayList, GXml.CollectionParent {
  construct {
    try { initialize (typeof (Item)); } catch (GLib.Error e) { warning  ("Error: %s", e.message); }
  }
  // Override supported types
  public GLib.HashTable<string,GLib.Type> types {
    owned get {
      var c = new GLib.HashTable<string,GLib.Type> (str_hash, str_equal);
      GXml.CollectionParent.add_supported_types (c, items_type,
                                                {
                                                typeof (Monitor),
                                                typeof (Keyword),
                                                typeof (Cpu)
                                                });
      return c;
    }
  }
}

class Monitor : GXml.Element, Item {
  [Description (nick="::size")]
  public int size { get; set; }
  construct {
    try { initialize ("Monitor"); } catch (GLib.Error e) { warning  ("Error: %s", e.message); }
  }
}
class Keyword : GXml.Element, Item {
  [Description (nick="::language")]
  public string size { get; set; }
  construct {
    try { initialize ("Keyword"); } catch (GLib.Error e) { warning  ("Error: %s", e.message); }
  }
}
class Cpu : GXml.Element, Item {
  [Description (nick="::language")]
  public string size { get; set; }
  construct {
    try { initialize ("Cpu"); } catch (GLib.Error e) { warning  ("Error: %s", e.message); }
  }
}

interface Container : GLib.Object, GXml.Object {}

class StoreShelf : GXml.Element, Container {
  [Description (nick="::Id")]
  public int id { get; set; default = 1; }
  public Items items { get; set; }
  construct {
    try {
      initialize ("Shelf");
      set_instance_property ("items");
    } catch (GLib.Error e) { warning  ("Error: %s", e.message); }
  }
}

class Containers : GXml.ArrayList, GXml.CollectionParent {
  construct {
    var s = new StoreShelf ();
    try { initialize (typeof (Container)); } catch (GLib.Error e) { warning  ("Error: %s", e.message); }
  }
  // Override supported types
  public GLib.HashTable<string,GLib.Type> types {
    owned get {
      var c = new GLib.HashTable<string,GLib.Type> (str_hash, str_equal);
      GXml.CollectionParent.add_supported_type (c, items_type, typeof (StoreShelf));
      assert (c.contains ("shelf"));
      assert (c.lookup ("shelf") != GLib.Type.INVALID);
      assert (((GLib.Type) c.lookup ("shelf")) == typeof (StoreShelf));
      return c;
    }
  }
}
class ComputerStore : GXml.Element {
  [Description (nick="::name")]
  public string name { get; set; }
  public Containers containers { get; set; default = new Containers (); }
  construct {
    try {
      initialize ("ComputerStore");
      set_instance_property ("containers");
    } catch (GLib.Error e) { warning  ("Error: %s", e.message); }
  }
}

class SerializationTest : GLib.Object  {
  public class Book : GXml.Element {
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
  public class Computer : GXml.Element {
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
  public class Taxes : GXml.Element {
    [Description (nick="::monthRate")]
    public double month_rate { get; set; }
    [Description (nick="::TaxFree")]
    public bool tax_free { get; set; }
    [Description (nick="::Month")]
    public Month month { get; set; }
    [Description (nick="::PayDate")]
    public GXml.Date pay_date { get; set; }
    [Description (nick="::Timestamp")]
    public GXml.DateTime timestamp { get; set; }
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
  public class BookRegister : GXml.Element,
                              MappeableElement,
                              MappeableElementPairKey,
                              MappeableElementThreeKey {
    private Book _book = null;
    [Description (nick="::Year")]
    public int year { get; set; }
    [Description (nick="::Cover")]
    public string cover { get; set; }
    public Book book {
      get { return _book; }
      set {
        try {
          clean_property_elements ("book");
          _book = value;
          append_child (_book);
        } catch (GLib.Error e) {
          warning (e.message);
          assert_not_reached ();
        }
      }
    }
    construct {
      try { initialize ("BookRegister"); }
      catch { assert_not_reached (); }
    }
    public BookRegister.document (DomDocument doc) {
      _document = doc;
    }
    public string get_map_key () {
      if (book == null) return "";
      return "%d".printf (year)+"-"+book.name;
    }
    public string get_map_primary_key () { return "%d".printf (year); }
    public string get_map_secondary_key () {
      if (book == null) return "";
      return book.name;
    }
    public string get_map_pkey () { return get_map_primary_key (); }
    public string get_map_skey () { return get_map_secondary_key (); }
    public string get_map_tkey () { return cover; }
    public Book create_book (string name) {
      return GLib.Object.new (typeof (Book),
                        "owner-document", this.owner_document,
                        "name", name)
                        as Book;
    }
    public string to_string () {
      var parser = new XParser (this);
      string s = "";
      try {
        s = parser.write_string ();
        assert (s != "");
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
      return s;
    }
  }
  public class BookStand : GXml.Element {
    HashRegisters _hashmap_registers = null;
    HashPairRegisters _hashpair_registers = null;
    HashThreeRegisters _hashthree_registers = null;
    [Description (nick="::Classification")]
    public string classification { get; set; default = "Science"; }
    public Dimension dimension_x { get; set; }
    [Description (nick="::DimensionY")]
    public DimensionY dimension_y { get; set; }
    [Description (nick="DimensionZ")]
    public DimensionZ dimension_z { get; set; }
    public Registers registers { get; set; }
    public HashRegisters hashmap_registers {
      get {
        if (_hashmap_registers == null)
          _hashmap_registers = GLib.Object.new (typeof (HashRegisters),"element",this)
                              as HashRegisters;
        return _hashmap_registers;
      }
      set {
        _hashmap_registers = value;
      }
    }
    public HashPairRegisters hashpair_registers {
      get {
        if (_hashpair_registers == null)
          _hashpair_registers = GLib.Object.new (typeof (HashPairRegisters),"element",this)
                              as HashPairRegisters;
        return _hashpair_registers;
      }
      set {
        _hashpair_registers = value;
      }
    }
    public HashThreeRegisters hashthree_registers {
      get {
        if (_hashthree_registers == null)
          _hashthree_registers = GLib.Object.new (typeof (HashThreeRegisters),"element",this)
                              as HashThreeRegisters;
        return _hashthree_registers;
      }
      set {
        _hashthree_registers = value;
      }
    }
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
    public class Dimension : GXml.Element {
      [Description (nick="::Length")]
      public double length { get; set; default = 1.0; }
      [Description (nick="::Type")]
      public string dtype { get; set; default = "x"; }
      construct {
        try { initialize ("Dimension"); } catch { assert_not_reached (); }
      }
    }
    public class DimensionY : Dimension {
      construct {
        dtype = "y";
      }
    }
    public class DimensionZ : Dimension {
      construct {
        dtype = "z";
      }
    }
  }

  public class Registers : GXml.ArrayList {
    construct {
      try { initialize (typeof (BookRegister)); }
      catch { assert_not_reached (); }
    }
  }
  public class HashRegisters : GXml.HashMap {
    construct {
      try { initialize (typeof (BookRegister)); }
      catch { assert_not_reached (); }
    }
  }
  public class HashPairRegisters : GXml.HashPairedMap {
    construct {
      try { initialize (typeof (BookRegister)); }
      catch { assert_not_reached (); }
    }
  }
  public class HashThreeRegisters : GXml.HashThreeMap {
    construct {
      try { initialize (typeof (BookRegister)); }
      catch { assert_not_reached (); }
    }
  }
  public class Books : GXml.HashMap {
    construct {
      try { initialize_with_key (typeof (Book), "Name"); }
      catch { assert_not_reached (); }
    }
  }
  public class BookStore : GXml.Element {
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
  public class Motor : GXml.Element {
    [Description (nick="::On")]
    public On is_on { get; set; }
    [Description (nick="::Torque")]
    public Torque torque { get; set; }
    [Description (nick="::Speed")]
    public Speed speed { get; set; }
    [Description (nick="::TensionType")]
    public TensionType tension_type { get; set; }
    [Description (nick="::TensionSupply")]
    public TensionSupply tension_supply { get; set; }
    [Description (nick="::TensionClassification")]
    public TensionClassification tension_class { get; set; }
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
    public enum TensionSupplyEnum {
      DEFAULT,
      FROM_WALL,
      FROM_FLOOR
    }
    public enum TensionClassificationEnum {
      ONE,
      TWO,
      THREE
    }
    public class On : GXml.Boolean {}
    public class Torque : GXml.Double {}
    public class Speed : GXml.Float {}
    public class TensionType : GXml.Enum {
      construct {
        try { initialize_enum (typeof (TensionTypeEnum)); }
        catch { assert_not_reached (); }
      }
    }
    public class TensionSupply : GXml.Enum {
      construct {
        use_nick = true;
        camel_case = true;
        try { initialize_enum (typeof (TensionSupplyEnum)); }
        catch { assert_not_reached (); }
      }
    }
    public class TensionClassification : GXml.Enum {
      construct {
        upper_case = true;
        try { initialize_enum (typeof (TensionClassificationEnum)); }
        catch { assert_not_reached (); }
      }
    }
    public class Tension : GXml.Int {}
    public class Model : GXml.ArrayString {
      construct {
        initialize_strings ({"MODEL1","MODEL2"});
      }
    }
  }
  public static int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/gxml/serialization/write/properties", () => {
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
    Test.add_func ("/gxml/serialization/write/property-ignore", () => {
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
    Test.add_func ("/gxml/serialization/write/property-long-name", () => {
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
    });
    Test.add_func ("/gxml/serialization/write/property-date", () => {
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
      t.pay_date = new GXml.Date ();
      var d = GLib.Date ();
      d.set_dmy ((DateDay) 1, (DateMonth) 2, (DateYear) 2017);
      assert (d.valid ());
      assert (t.pay_date != null);
      t.pay_date.set_date (d);
      assert (t.pay_date.get_date ().valid ());
      assert (t.pay_date.value != null);
      assert (t.pay_date.value == "2017-02-01");
      t.pay_date.value = "2023-3-10";
      assert (t.pay_date.get_date ().valid ());
      assert (t.pay_date.value != null);
      assert (t.pay_date.value == "2023-03-10");
      t.pay_date.value = "2075-3-17";
      assert (t.pay_date.get_date ().valid ());
      assert (t.pay_date.value != null);
      assert (t.pay_date.value == "2075-03-17");
      s = t.to_string ();
      assert (s != null);
      assert ("PayDate=\"2075-03-17\"" in s);
      var gd = new GXml.Date ();
      gd.value = "2076-03-17";
      assert (gd.get_date ().valid ());
      assert (gd.value == "2076-03-17");
    });
    Test.add_func ("/gxml/serialization/read/property-date", () => {
    try {
      var t = new Taxes ();
      t.read_from_string ("<Taxes PayDate=\"2050-12-09\"/>");
      string s = t.to_string ();
      assert (s != null);
//#if DEBUG
      GLib.message ("DOC:"+s);
//#endif
      assert ("<Taxes " in s);
      assert ("monthRate=\"0\"" in s);
      assert ("Month=\"january\"" in s);
      assert ("TaxFree=\"false\"" in s);
      assert (t.pay_date != null);
      assert (t.pay_date.get_date ().valid ());
      assert (t.pay_date.value != null);
      assert (t.pay_date.value == "2050-12-09");
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/write/property-datetime", () => {
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
      t.timestamp = new GXml.DateTime ();
      var d = new GLib.DateTime.local (2017,2,10,14,14,20.345);
#if DEBUG
      s = t.to_string ();
      assert (s != null);
      GLib.message ("DOC:"+s);
#endif
      assert (t.timestamp != null);
      t.timestamp.set_datetime (d);
      assert (t.timestamp != null);
      assert (t.timestamp.value != null);
      assert (t.timestamp.value == "2017-02-10T14:14:20");
      t.timestamp.value = "2023-03-10T15:23:10.356";
      assert (t.timestamp.value != null);
      assert (t.timestamp.value == "2023-03-10T15:23:10");
      string s2 = t.to_string ();
      assert (s2 != null);
#if DEBUG
      GLib.message ("DOC:"+s2);
#endif
      assert ("Timestamp=\"2023-03-10T15:23:10\"" in s2);
    });
    Test.add_func ("/gxml/serialization/write/property-arraylist", () => {
    try {
      var bs = new BookStand ();
      string s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"/>" in s);
      assert (bs.owner_document != null);
      assert (bs.registers == null);
      assert (bs.set_instance_property ("registers"));
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
      assert (((BookRegister) bs.registers.get_item (0)).year == 2016);
      assert (((BookRegister) bs.registers.get_item (1)).year == 2010);
      assert (((BookRegister) bs.registers.get_item (2)).year == 2000);
      assert (bs.set_instance_property("Dimension-X"));
      assert (bs.dimension_x != null);
      assert (bs.dimension_x.length == 1.0);
      s = bs.to_string ();
      assert (s != null);
//#if DEBUG
      GLib.message ("DOC:"+s);
//#endif
      assert ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/><BookRegister Year=\"2010\"/><Test/><BookRegister Year=\"2000\"/><Dimension Length=\"1\" Type=\"x\"/></BookStand>" in s);
      assert (bs.set_instance_property("DimensionY"));
      assert (bs.dimension_y != null);
      assert (bs.dimension_y.length == 1.0);
      s = bs.to_string ();
      assert (s != null);
//#if DEBUG
      GLib.message ("DOC:"+s);
//#endif
      assert ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/><BookRegister Year=\"2010\"/><Test/><BookRegister Year=\"2000\"/><Dimension Length=\"1\" Type=\"x\"/><Dimension Length=\"1\" Type=\"y\"/></BookStand>" in s);
      assert (bs.set_instance_property("::DimensionZ"));
      assert (bs.dimension_z != null);
      assert (bs.dimension_z.length == 1.0);
      s = bs.to_string ();
      assert (s != null);
//#if DEBUG
      GLib.message ("DOC:"+s);
//#endif
      assert ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/><BookRegister Year=\"2010\"/><Test/><BookRegister Year=\"2000\"/><Dimension Length=\"1\" Type=\"x\"/><Dimension Length=\"1\" Type=\"y\"/><Dimension Length=\"1\" Type=\"z\"/></BookStand>" in s);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/write/property-hashmap", () => {
    try {
      var bs = new BookStore ();
      string s = bs.to_string ();
      assert (s != null);
#if DEBUG
      GLib.message ("DOC:"+s);
#endif
      assert ("<BookStore/>" in s);
      assert (bs.books == null);
      bs.set_instance_property ("books");
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
      assert (((Book) bs.books.get("Title1")).name == "Title1");
      assert (((Book) bs.books.get("Title2")).name == "Title2");
      assert (((Book) bs.books.get("Title3")).name == "Title3");
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/mappeable", () => {
    try {
      var bs = new BookStand ();
      assert (bs.hashmap_registers != null);
      var br = bs.hashmap_registers.create_item () as BookRegister;
      var book = br.create_book ("Book1");
      br.book = book;
      br.year = 2017;
      bs.hashmap_registers.append (br);
      assert (bs.hashmap_registers.length == 1);
      assert (bs.hashmap_registers.has_key ("2017-Book1"));
      var b1 = bs.hashmap_registers.get ("2017-Book1") as BookRegister;
      assert (b1 != null);
      assert (b1.year == 2017);
      assert (b1.book != null);
      assert (b1.book.name == "Book1");
      assert (b1.child_nodes.length == 1);
      var book2 = b1.create_book ("Book2");
      b1.append_child (book2);
      assert (b1.child_nodes.length == 2);
      b1.book = book2;
      assert (b1.child_nodes.length == 1);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/write/mappeablepairedkey", () => {
    try {
      var bs = new BookStand ();
      assert (bs.hashpair_registers != null);
      var br = bs.hashpair_registers.create_item () as BookRegister;
      var book = br.create_book ("Book1");
      assert (book.name == "Book1");
      br.book = book;
      br.year = 2017;
      assert (bs.hashpair_registers.length == 0);
      bs.hashpair_registers.append (br);
      assert (bs.hashpair_registers.length == 1);
      var b1 = bs.hashpair_registers.get ("2017","Book1") as BookRegister;
      assert (b1 != null);
      assert (b1.year == 2017);
      assert (b1.book != null);
      assert (b1.book.name == "Book1");
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/write/mappeablethreekey", () => {
    try {
      var bs = new BookStand ();
      assert (bs.hashthree_registers != null);
      var br = bs.hashthree_registers.create_item () as BookRegister;
      var book = br.create_book ("Book1");
      assert (book.name == "Book1");
      br.book = book;
      br.year = 2017;
      br.cover = "SYSTEMS";
      assert (br.get_map_pkey () == "2017");
      assert (br.get_map_skey () == "Book1");
      assert (br.cover == "SYSTEMS");
      assert (br.get_map_tkey () == "SYSTEMS");
      assert (bs.hashthree_registers.length == 0);
      bs.hashthree_registers.append (br);
      assert (bs.hashthree_registers.length == 1);

      foreach (string pk in bs.hashthree_registers.primary_keys_set) {
        message (pk);
        foreach (string sk in bs.hashthree_registers.secondary_keys_set (pk)) {
          message (sk);
          foreach (string tk in bs.hashthree_registers.third_keys_set (pk, sk)) {
            message (tk);
          }
        }
      }

      assert (bs.hashthree_registers.has_primary_key ("2017"));
      assert (bs.hashthree_registers.has_secondary_key ("2017", "Book1"));
      assert (bs.hashthree_registers.has_third_key ("2017", "Book1", "SYSTEMS"));
      var b1 = bs.hashthree_registers.get ("2017","Book1", "SYSTEMS") as BookRegister;
      assert (b1 != null);
      assert (b1.year == 2017);
      assert (b1.book != null);
      assert (b1.book.name == "Book1");
      assert (b1.cover == "SYSTEMS");
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/write/property", () => {
      var m = new Motor ();
      string s = m.to_string ();
      assert (s != null);
      assert ("<Motor/>" in s);
      m.is_on = new Motor.On ();
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"false\"/>" in s);
      m.torque = new Motor.Torque ();
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"false\" Torque=\"0.0000\"/>" in s);
      m.speed = new Motor.Speed ();
      m.speed.set_double (1.0);
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"1.0000\"/>" in s);
      assert (m.speed != null);
      assert (m is GXml.Object);
      assert (m.speed is GXml.Property);
      assert (m.speed.get_double () == 1.0);
      assert (m.speed.value != null);
      assert (m.speed.value == "1.0000");
      assert (m.get_attribute ("speed") != null);

      assert (m.tension_type == null);
      m.tension_type = new Motor.TensionType ();
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"1.0000\" TensionType=\"ac\"/>" in s);
      assert (m.tension_type != null);
      assert (m.tension_type.value == "ac");

      assert (m.tension_supply == null);
      m.tension_supply = new Motor.TensionSupply ();
      m.tension_supply.@value = "fromwall";
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"1.0000\" TensionType=\"ac\" TensionSupply=\"FromWall\"/>" in s);
      assert (m.tension_supply != null);
      assert (m.tension_supply.@value == "FromWall");
      m.tension_supply.@value = "UnkNown";
      assert (m.tension_supply.@value == "UnkNown");
      m.tension_supply = null;

      assert (m.tension_class == null);
      m.tension_class = new Motor.TensionClassification ();
      m.tension_class.@value = "one";
      s = m.to_string ();
      message (s);
      assert (s != null);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"1.0000\" TensionType=\"ac\" TensionClassification=\"ONE\"/>" in s);
      assert (m.tension_class != null);
      assert (m.tension_class.value == "ONE");
      m.tension_class = null;

      m.tension = new Motor.Tension ();
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"false\" Torque=\"0.0000\" Speed=\"1.0000\" TensionType=\"ac\" Tension=\"0\"/>" in s);
      m.is_on.set_boolean (true);
      m.torque.set_double (3.1416);
      m.speed.set_float ((float) 3600.1011);
      m.tension_type.set_enum ((int) Motor.TensionTypeEnum.DC);
      m.tension.set_integer (125);
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"true\" Torque=\"3.1416\" Speed=\"3600.1011\" TensionType=\"dc\" Tension=\"125\"/>" in s);
      m.model = new Motor.Model ();
      assert (m.model != null);
      assert (m.model.value != null);
      assert (m.model.value == "");
      m.model.value = "Model3";
      assert (m.model.value == "Model3");
      s = m.to_string ();
      assert (s != null);
      assert ("<Motor On=\"true\" Torque=\"3.1416\" Speed=\"3600.1011\" TensionType=\"dc\" Tension=\"125\" Model=\"Model3\"/>" in s);
      assert (!m.model.is_valid_value ());
      assert (m.model.search ("MODEL1"));
      m.model.value = "MODEL1";
      assert (m.model.is_valid_value ());
    });
    Test.add_func ("/gxml/serialization/read/properties", () => {
    try {
      var b = new Book ();
      var parser = new XParser (b);
      parser.read_string ("<book name=\"Loco\"/>");
      string s = parser.write_string ();
      assert (s != null);
      GLib.message ("Doc:"+s);
      assert (b != null);
      assert (b.child_nodes != null);
      assert (b.child_nodes.size == 0);
      assert (b.attributes != null);
      assert (b.attributes.size == 1);
      assert (b.name != null);
      assert (b.name == "Loco");
      s = parser.write_string ();
      assert (s != null);
      assert ("<Book Name=\"Loco\"/>" in s);
      GLib.message ("Doc:"+s);
      b.name = "My Book";
      assert (b.get_attribute ("name") == "My Book");
      s = b.to_string ();
      assert ("<Book Name=\"My Book\"/>" in s);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/read/bad-node-name", () => {
      try {
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
      } catch (GLib.Error e) {
        GLib.message ("Error: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serialization/read/object-property", () => {
    try {
      var b = new BookRegister ();
      string s = b.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<BookRegister Year=\"0\"/>" in s);
      b.read_from_string ("<bookRegister><Book/></bookRegister>");
      s = b.to_string ();
//#if DEBUG
      GLib.message ("doc:"+s);
//#endif
      assert ("<BookRegister Year=\"0\"><Book/></BookRegister>" in s);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/read/property", () => {
    try {
      var m = new Motor ();
      string s = m.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<Motor/>" in s);
      var parser = new XParser (m);
      parser.read_string ("<Motor On=\"true\" Torque=\"3.1416\" Speed=\"3600.1011\" TensionType=\"dc\" Tension=\"125\"/>");
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
      assert (m.is_on != null);
      assert (m.is_on.get_boolean() == true);
      assert (m.torque != null);
      assert (m.torque.get_double () == 3.1416);
      assert (m.speed != null);
      assert (m.speed.get_double () == 3600.1011);
      assert (m.tension != null);
      assert (m.tension.get_integer () == 125);
      assert (m.tension_type != null);
      assert (m.tension_type.value == "dc");
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/read/property-arraylist", () => {
    try {
      var bs = new BookStand ();
      string s = bs.to_string ();
#if DEBUG
      GLib.message ("doc:"+s);
#endif
      assert ("<BookStand Classification=\"Science\"/>" in s);
      var parser = new XParser (bs);
      parser.read_string ("<BookStand Classification=\"Science\"><BookRegister Year=\"2016\"/><BookRegister Year=\"2010\"/><Test/><BookRegister Year=\"2000\"/></BookStand>");
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
      assert (((BookRegister) bs.registers.get_item (0)).year == 2016);
      assert (((BookRegister) bs.registers.get_item (1)).year == 2010);
      assert (((BookRegister) bs.registers.get_item (2)).year == 2000);
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/read/property-hashmap", () => {
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
      GLib.message ("doc:"+s);
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
      assert (((Book) bs.books.get_item (0)).name == "Title1");
      assert (((Book) bs.books.get_item (1)).name == "Title2");
      assert (((Book) bs.books.get_item (2)).name == "Title3");
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
    Test.add_func ("/gxml/serialization/multiple-child-collections",
    () => {
      try {
        double time;
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
    Test.add_func ("/gxml/serialization/collections/hashpairedmap/keys",
    () => {
      try {
        var ops = new Operations ();
        assert (ops.map != null);
        assert (ops.map.length == 0);
        var op1 = ops.map.create_item () as Operation;
        assert (op1 is Operation);
        op1.id = "a1";
        op1.code = "b1";
        ops.map.append (op1);
        assert (ops.map.length == 1);
        var top1 = ops.map.get ("a1", "b1") as Operation;
        assert (top1 is Operation);
        assert (top1.id == "a1");
        assert (top1.code == "b1");
        var pkeys1 = ops.map.get_primary_keys ();
        assert (pkeys1.length () == 1);
        var op2 = ops.map.create_item () as Operation;
        assert (op2 is Operation);
        op2.id = "a1";
        op2.code = "b2";
        ops.map.append (op2);
        var op3 = ops.map.create_item () as Operation;
        assert (op2 is Operation);
        op3.id = "a2";
        op3.code = "b1";
        ops.map.append (op3);
        assert (ops.map.length == 3);
        var op4 = ops.map.create_item () as Operation;
        assert (op4 is Operation);
        op4.id = "a2";
        op4.code = "b2";
        ops.map.append (op4);
        assert (ops.map.length == 4);
        message (ops.write_string ());
        var pkeys2 = ops.map.get_primary_keys ();
        assert (pkeys2.length () == 2);
        foreach (string pk in pkeys2) { message (pk); }
        var skeys1 = ops.map.get_secondary_keys ("a1");
        foreach (string pk in skeys1) { message (pk); }
        assert (skeys1.length () == 2);
        op4.remove ();
        ops.map.search ();
        assert (ops.map.length == 3);
        var op3t = ops.map.get ("a2", "b1");
        assert (op3t != null);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serialization/collections/hashthreemap/keys",
    () => {
      try {
        var ks = new ThreeKeys ();
        assert (ks.map != null);
        assert (ks.map.length == 0);
        var k1 = ks.map.create_item () as ThreeKey;
        assert (k1 is ThreeKey);
        k1.id = "a1";
        k1.code = "b1";
        k1.name = "name1";
        ks.map.append (k1);
        assert (ks.map.length == 1);
        var tk1 = ks.map.get ("a1", "b1", "name1") as ThreeKey;
        assert (tk1 is ThreeKey);
        assert (tk1.id == "a1");
        assert (tk1.code == "b1");
        assert (tk1.name == "name1");
        var pkeys1 = ks.map.get_primary_keys ();
        assert (pkeys1.length () == 1);
        var k2 = ks.map.create_item () as ThreeKey;
        assert (k2 is ThreeKey);
        k2.id = "a1";
        k2.code = "b2";
        k2.name = "name2";
        ks.map.append (k2);
        var k3 = ks.map.create_item () as ThreeKey;
        assert (k3 is ThreeKey);
        k3.id = "a2";
        k3.code = "b1";
        k3.name = "name3";
        ks.map.append (k3);
        assert (ks.map.length == 3);
        var k4 = ks.map.create_item () as ThreeKey;
        assert (k4 is ThreeKey);
        k4.id = "a2";
        k4.code = "b2";
        k4.name = "name3";
        ks.map.append (k4);
        assert (ks.map.length == 4);
        message (ks.write_string ());
        var pkeys2 = ks.map.get_primary_keys ();
        assert (pkeys2.length () == 2);
        foreach (string pk in pkeys2) { message (pk); }
        var skeys1 = ks.map.get_secondary_keys ("a1");
        foreach (string pk in skeys1) { message (pk); }
        assert (skeys1.length () == 2);
        k4.remove ();
        ks.map.search ();
        var k3t = ks.map.get ("a2", "b1", "name3");
        assert (k3t != null);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serialization/basic-types",
    () => {
      try {
        var bt = new GomBasicTypes ();
        message (bt.write_string ());
        bt.text = "Text";
        bt.integer = -1;
        bt.unsigned_integer = 1;
        bt.real_float = (float) 1.1;
        bt.real_double = 2.2;
        message (bt.write_string ());
        assert (bt.attributes.size == 5);
        assert (bt.unsigned_integer == 1);
        assert (bt.get_attribute ("text") == "Text");
        assert (bt.get_attribute ("integer") == "-1");
        message ("realFloat = %s", bt.get_attribute ("realFloat"));
        assert (bt.get_attribute ("realFloat") == "1.1");
        message ("unsignedInteger = %s", bt.get_attribute ("unsignedInteger"));
        assert (bt.get_attribute ("unsignedInteger") == "1");
        var bt2 = new GomBasicTypes ();
        bt2.read_from_string (bt.write_string ());
        assert (bt2.text == "Text");
        assert (bt2.integer == -1);
        message (bt2.unsigned_integer.to_string ());
        assert (bt2.unsigned_integer == 1);
        assert (bt2.real_float == (float) 1.1);
        assert (bt2.real_double == 2.2);
        bt2.real_double = 100.0;
        assert (bt2.real_double == 100.0);
        var bt3 = new GomBasicTypes ();
        bt3.read_from_string (bt2.write_string ());
        assert (bt3.text == "Text");
        assert (bt3.integer == -1);
        assert (bt3.unsigned_integer == 1);
        assert (bt3.real_float == (float) 1.1);
        assert (bt3.real_double == 100.0);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serialization/collection/iteration", () => {
    try {
      var bs = new BookStore ();
      assert (bs.books == null);
      bs.set_instance_property ("books");
      int n = 1;
      for (int i = 0; i < 10; i++) {
        var b = bs.books.create_item () as Book;
        assert (b != null);
        b.name = "Title %d".printf (n);
        n++;
        bs.books.append (b);
      }
      message (bs.write_string ());
      n = 1;
      foreach (DomElement e in bs.books) {
        assert (((Book) e) != null);
        assert (((Book) e).name == "Title %d".printf (n));
        n++;
      }
      var bst = new BookStand ();
      bst.set_instance_property ("registers");
      var r = bst.registers;
      assert (r.items_type.is_a (typeof (BookRegister)));
      n = 1;
      for (int i = 0; i < 10; i++) {
        var b = r.create_item () as BookRegister;
        assert (b != null);
        b.year = 2000 + n;
        n++;
        r.append (b);
      }
      n = 1;
      foreach (DomElement e in r) {
        assert (((BookRegister) e) != null);
        assert (((BookRegister) e).year == 2000 + n);
        n++;
      }
      bst.set_instance_property ("hashmap-registers");
      var hr = bst.hashmap_registers;
      n = 1;
      for (int i = 0; i < 10; i++) {
        var b = hr.create_item () as BookRegister;
        assert (b != null);
        b.set_instance_property ("book");
        b.book.name = "book%d".printf (n);
        b.year = 2000 + n;
        n++;
        hr.append (b);
      }
      n = 1;
      foreach (DomElement e in hr) {
        assert (((BookRegister) e) != null);
        assert (((BookRegister) e).year == 2000 + n);
        n++;
      }

      bst.set_instance_property ("hashpair-registers");
      var hpr = bst.hashpair_registers;
      n = 1;
      for (int i = 0; i < 10; i++) {
        var b = hpr.create_item () as BookRegister;
        assert (b != null);
        b.set_instance_property ("book");
        b.book.name = "book%d".printf (n);
        b.year = 2000 + n;
        n++;
        hpr.append (b);
      }
      n = 1;
      foreach (DomElement e in hpr) {
        assert (((BookRegister) e) != null);
        assert (((BookRegister) e).book.name == "book%d".printf (n));
        assert (((BookRegister) e).year ==  2000 + n);
        n++;
      }

      bst.set_instance_property ("hashthree-registers");
      var htr = bst.hashthree_registers;
      n = 1;
      for (int i = 0; i < 10; i++) {
        var b = htr.create_item () as BookRegister;
        assert (b != null);
        b.set_instance_property ("book");
        b.book.name = "book%d".printf (n);
        b.year = 2000 + n;
        b.cover = "cover%d".printf (n);
        n++;
        htr.append (b);
      }
      n = 1;
      foreach (DomElement e in htr) {
        assert (((BookRegister) e) != null);
        assert (((BookRegister) e).book.name == "book%d".printf (n));
        assert (((BookRegister) e).year == 2000 + n);
        assert (((BookRegister) e).cover == "cover%d".printf (n));
        n++;
      }
    } catch (GLib.Error e) {
      GLib.message ("Error: "+e.message);
      assert_not_reached ();
    }
    });
    Test.add_func ("/gxml/serialization/attribute-gobject", () => {
      var tk = new ThreeKey ();
      assert (tk.code == null);
      assert (tk.get_attribute ("Code") == null);
      tk.code = "code";
      assert (tk.get_attribute ("Code") == "code");
    });
    Test.add_func ("/gxml/serialization/collection-parent/list/read", () => {
      try {
        var cs = new ComputerStore ();
        assert (cs.containers.types.contains ("shelf"));
        assert (cs.containers.types.lookup ("shelf") == typeof (StoreShelf));
        string str = """
  <ComputerStore><Shelf Id="2"><Cpu/></Shelf></ComputerStore>
  """;
        cs.read_from_string (str);
        bool found_shelf = false;
        bool found_cpu = false;
        foreach (GXml.DomNode n in cs.child_nodes) {
          message ("Found Type: %s", n.get_type ().name ());
          if (n is StoreShelf) {
            found_shelf = true;
            foreach (GXml.DomNode cn in n.child_nodes) {
              message ("Found Type: %s", n.get_type ().name ());
              if (cn is Cpu) {
                found_cpu = true;
              }
            }
          }
        }
        assert (found_shelf);
        assert (found_cpu);
        message ("Read:\n%s", cs.write_string ());
        assert ("""<ComputerStore><Shelf Id="2"><Cpu/></Shelf></ComputerStore>""" in cs.write_string ());
        str = """
  <ComputerStore><Shelf Id="2"><Cpu/><Monitor size="32"/><Keyword/></Shelf></ComputerStore>
  """;
        cs = new ComputerStore ();
        cs.read_from_string (str);
        message ("Read:\n%s", cs.write_string ());
        assert ("""<ComputerStore><Shelf Id="2"><Cpu/><Monitor size="32"/><Keyword/></Shelf></ComputerStore>""" in cs.write_string ());
        found_shelf = false;
        bool found_monitor = false;
        bool found_keyword = false;
        found_cpu = false;
        foreach (GXml.DomNode n in cs.child_nodes) {
          message ("Found Type: %s", n.get_type ().name ());
          if (n is StoreShelf) {
            found_shelf = true;
            foreach (GXml.DomNode cn in n.child_nodes) {
              message ("Found Type: %s", n.get_type ().name ());
              if (cn is Monitor) {
                found_monitor = true;
                assert (((Monitor) cn).size == 32);
              }
              if (cn is Keyword) {
                found_keyword = true;
              }
              if (cn is Cpu) {
                found_cpu = true;
              }
            }
          }
        }
        assert (found_shelf);
        assert (found_monitor);
        assert (found_keyword);
        assert (found_cpu);
      } catch (GLib.Error e) {
        warning ("Error: %s", e.message);
      }
    });

		Test.run ();

		return 0;
  }
}
