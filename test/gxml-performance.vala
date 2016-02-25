/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*-  */
/* librescl
 *
 * Copyright (C) 2013-2015 Daniel Espinosa <esodan@gmail.com>
 *
 * librescl is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * librescl is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using GXml;

class Name : SerializableObjectModel
{
  public string get_name () { return serialized_xml_node_value; }
  public void   set_name (string name) { serialized_xml_node_value = name; }
  public override bool serialize_use_xml_node_value () { return true; }
  public override string to_string () { return serialized_xml_node_value; }
}

class Email : SerializableObjectModel
{
  public string get_mail () { return serialized_xml_node_value; }
  public void   set_mail (string email) { serialized_xml_node_value = email; }
  public override bool serialize_use_xml_node_value () { return true; }
  public override string to_string () { return serialized_xml_node_value; }
}

class Author : SerializableObjectModel
{
  public Name name   { get; set; }
  public Email email { get; set; }
  public override string to_string () { return @"\"$(name.get_name ())\"<$(email.get_mail ())>"; }
  public class Array : SerializableArrayList<Author> {}
}

class Authors : SerializableContainer
{
  public string number { get; set; }
  public Author.Array array { get; set; }
  public override void init_containers ()
  {
    if (array == null)
      array = new Author.Array ();
  }
  public override string to_string () { return @"$(get_type ().name ())"; }
}

class Inventory : SerializableObjectModel, SerializableMapDualKey<int,string>
{
  public int number { get; set; }
  public int row { get; set; }
  public string inventory { get; set; }
  public int get_map_primary_key  () { return number; }
  public string get_map_secondary_key () { return inventory; }
  public override string to_string () { return @"||$(number.to_string ())|$(row.to_string ())|$(inventory)||"; }
  public class DualKeyMap : SerializableDualKeyMap<int, string, Inventory> {}
}

class Category : SerializableObjectModel, SerializableMapKey<string>
{
  public string name { get; set; }
  public string get_map_key () { return name; }
  public override string to_string () { return "Category: "+name; }
  public class Map : SerializableHashMap<string,Category> {}
}


class Resume : SerializableObjectModel, SerializableMapKey<string>
{
  public string chapter { get; set; }
  public string text { get; set; }
  public string get_map_key () { return chapter; }
  public override string to_string () { return "Chapter: "+chapter+"\n"+text; }
  public class Map : SerializableTreeMap<string,Resume> {}
}

class Book : SerializableContainer
{
  public string year { get; set; }
  public string isbn { get; set; }
  public Name   name { get; set; }
  public Authors authors { get; set; }
  public Inventory.DualKeyMap inventory_registers { get; set; }
  public Category.Map categories { get; set; }
  public Resume.Map resumes { get; set; }
  public override string to_string () { return @"$(name.get_name ()), $(year)"; }
  public override void init_containers ()
  {
    if (inventory_registers == null)
      inventory_registers = new Inventory.DualKeyMap ();
    if (categories == null)
      categories = new Category.Map ();
    if (resumes == null)
      resumes = new Resume.Map ();
  }
  public class Array : SerializableArrayList<Book> {}
}

class BookStore : SerializableContainer
{
  public string name { get; set; }
  public Book.Array books { get; set; }
  public override void init_containers ()
  {
    if (books == null)
      books = new Book.Array ();
  }
  public override string to_string () { return name; }
}

public class Performance
{
  // ArrayList
  class AElement : SerializableObjectModel
  {
    public string name { get; set; }
    public AElement.named (string name) { this.name = name; }
    public override string to_string () { return name; }
    public class Array : SerializableArrayList<AElement> {
      public bool enable_deserialize { get; set; default = false; }
      public override bool deserialize_proceed () { return enable_deserialize; }
    }
  }

  class CElement : SerializableObjectModel {
    public AElement.Array elements { get; set; default = new AElement.Array (); }
    public override string node_name () { return "CElement"; }
    public override string to_string () { return "CElement"; }
  }
  // HashMap
  
  class HElement : SerializableObjectModel, SerializableMapKey<string>
  {
    public string name { get; set; }
    public string get_map_key () { return name; }
    public override string node_name () { return "HElement"; }
    public override string to_string () { return "HElement:"+name; }
    public class HashMap : SerializableHashMap<string,HElement> {
      public bool enable_deserialize { get; set; default = false; }
      public override bool deserialize_proceed () { return enable_deserialize; }
    }
  }
  class HcpElement : SerializableObjectModel {
    public HElement.HashMap elements { get; set; default = new HElement.HashMap (); }
    public override string node_name () { return "HcpElement"; }
    public override string to_string () { return "HcpElement"; }
  }
  class HcsElement : SerializableObjectModel {
    public HElement.HashMap elements { get; set; default = new HElement.HashMap (); }
    public override string node_name () { return "HcsElement"; }
    public override string to_string () { return "HcsElement"; }
  }
  class HTopElement : SerializableObjectModel {
    [Description (nick="HcpElement")]
    public HcpElement elements1 { get; set; default = new HcpElement (); }
    [Description (nick="HcsElement")]
    public HcsElement elements2 { get; set; default = new HcsElement (); }
    public override string node_name () { return "HTopElement"; }
    public override string to_string () { return "HToplement"; }
    public override bool property_use_nick () { return true; }
  }
  // TreeMap
  class HTElement : SerializableObjectModel, SerializableMapKey<string>
  {
    public string name { get; set; }
    public string get_map_key () { return name; }
    public override string node_name () { return "HElement"; }
    public override string to_string () { return "HElement"; }
    public class TreeMap : SerializableTreeMap<string,HTElement> {
      public bool enable_deserialize { get; set; default = false; }
      public override bool deserialize_proceed () { return enable_deserialize; }
    }
  }
  class HTCElement : SerializableObjectModel {
    public HTElement.TreeMap elements1 { get; set; default = new HTElement.TreeMap (); }
    public HTElement.TreeMap elements2 { get; set; default = new HTElement.TreeMap (); }
    public override string node_name () { return "HCElement"; }
    public override string to_string () { return "HCElement"; }
  }
  // DualKeyMap
  class DHElement : SerializableObjectModel, SerializableMapDualKey<string,string>
  {
    public string name { get; set; }
    public string key { get; set; }
    public string get_map_primary_key  () { return key; }
    public string get_map_secondary_key () { return name; }
    public override string node_name () { return "DHElement"; }
    public override string to_string () { return "DHElement"; }
    public class DualKeyMap : SerializableDualKeyMap<string,string,DHElement> {
      public bool enable_deserialize { get; set; default = false; }
      public override bool deserialize_proceed () { return enable_deserialize; }
    }
  }
  class DHCElement : SerializableObjectModel {
    public DHElement.DualKeyMap elements1 { get; set; default = new DHElement.DualKeyMap (); }
    public DHElement.DualKeyMap elements2 { get; set; default = new DHElement.DualKeyMap (); }
    public override string node_name () { return "DHCElement"; }
    public override string to_string () { return "DHCElement"; }
  }
  /**
   * Iterate recursively through all node and children nodes in document.
   */
  public static void iterate (GXml.Node node) {
    foreach (GXml.Node n in node.children) {
      int i = node.children.size;
      string name = n.name;
      string val = n.value;
#if DEBUG
      GLib.message ("Node: "+name+" Val: "+val+ " Children: "+i.to_string ());
#endif
      if (i > 0)
        Performance.iterate (n);  
    }
  }
  public static void add_tests ()
  {
#if ENABLE_PERFORMANCE_TESTS
    Test.add_func ("/gxml/performance/read/xdocument", 
    () => {
      try {
        Test.timer_start ();
        double time;
        var d = new xDocument.from_path (GXmlTest.get_test_dir () + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Load large document: %g seconds", time);
        Test.timer_start ();
        iterate (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Itirate over all loaded nodes: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });Test.add_func ("/gxml/performance/read/gdocument", 
    () => {
      try {
        Test.timer_start ();
        double time;
        var d = new GDocument.from_path (GXmlTest.get_test_dir () + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Load large document: %g seconds", time);
        Test.timer_start ();
        iterate (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Itirate over all loaded nodes: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/deserialize/xdocument", 
    () => {
      try {
        double time;
        Test.timer_start ();
        var d = new xDocument.from_path (GXmlTest.get_test_dir () + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "open document from path: %g seconds", time);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "deserialize/performance: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });

    Test.add_func ("/gxml/performance/serialize/xdocument",
    () => {
      try {
        double time;
        Test.timer_start ();
        var d = new xDocument.from_path (GXmlTest.get_test_dir () + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "open document from path: %g seconds", time);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "deserialize/performance: %g seconds", time);
        Test.timer_start ();
        var d2 = new xDocument ();
        bs.serialize (d2);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "serialize/performance: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/deserialize/gdocument", 
    () => {
      try {
        double time;
        Test.timer_start ();
        var d = new GDocument.from_path (GXmlTest.get_test_dir () + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "open document from path: %g seconds", time);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "deserialize/performance: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });

    Test.add_func ("/gxml/performance/serialize/gdocument",
    () => {
      try {
        double time;
        Test.timer_start ();
        var d = new GDocument.from_path (GXmlTest.get_test_dir () + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "open document from path: %g seconds", time);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "deserialize/performance: %g seconds", time);
        Test.timer_start ();
        var d2 = new xDocument ();
        bs.serialize (d2);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "serialize/performance: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/serialize/tw-document",
    () => {
      try {
        double time;
        Test.timer_start ();
        var d = new GDocument.from_path (GXmlTest.get_test_dir () + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "open document from path: %g seconds", time);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "standard deserialize/performance: %g seconds", time);
        Test.timer_start ();
        var d2 = new TwDocument.for_path (GXmlTest.get_test_dir () + "/test-large.xml");
        bs.serialize (d2);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "TwDocument serialize/performance: %g seconds", time);
        Test.timer_start ();
        var nf = GLib.File.new_for_path (GXmlTest.get_test_dir () + "/test-large-tw.xml");
        d2.indent = true;
        d2.save_as (nf);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "TwDocument Write to disk serialize/performance: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/arraylist/post-deserialization/disable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new CElement ();
        for (int i = 0; i < 500000; i++) {
          var e = new AElement ();
          ce.elements.add (e);
        }
        ce.serialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var cep = new CElement ();
        cep.elements.enable_deserialize = false;
        cep.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling deserialize_children()...");
        Test.timer_start ();
        cep.elements.deserialize_children ();
        assert (!cep.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/arraylist/post-deserialization/enable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new CElement ();
        for (int i = 0; i < 500000; i++) {
          var e = new AElement ();
          ce.elements.add (e);
        }
        ce.serialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Enable collection deserialization...");
        Test.timer_start ();
        var cet = new CElement ();
        cet.elements.enable_deserialize = true;
        cet.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Enable Deserialize Collection. Deserialized from doc: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/hashmap/post-deserialization/disable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new HTopElement ();
        for (int i = 0; i < 125000; i++) {
          var e1 = new HElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.elements.set (e1.name, e1);
          var e2 = new HElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.elements.set (e2.name, e2);
        }
        assert (ce.elements1.elements.size == 125000);
        assert (ce.elements2.elements.size == 125000);
        ce.serialize (d);
        assert (d.root != null);
        assert (d.root.children.size == 2);
        assert (d.root.children[0].children.size == 125000);
        assert (d.root.children[1].children.size == 125000);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var cep = new HTopElement ();
        cep.elements1.elements.enable_deserialize = false;
        cep.elements2.elements.enable_deserialize = false;
        cep.deserialize (d);
        assert(cep.elements1.elements.size == 0);
        assert(cep.elements2.elements.size == 0);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling C1 deserialize_children()...");
        Test.timer_start ();
        assert (cep.elements1.elements.deserialize_children ());
        assert (cep.elements1.elements.size == 125000);
        assert (!cep.elements1.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C1: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
        Test.message ("Calling C2 deserialize_children()...");
        Test.timer_start ();
        cep.elements2.elements.deserialize_children ();
        assert (!cep.elements2.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C2: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/hashmap/post-deserialization/enable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new HTopElement ();
        for (int i = 0; i < 125000; i++) {
          var e1 = new HElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.elements.set (e1.name, e1);
          var e2 = new HElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.elements.set (e2.name, e2);
        }
        ce.serialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Enable collection deserialization...");
        Test.timer_start ();
        var cep = new HTopElement ();
        cep.elements1.elements.enable_deserialize = true;
        cep.elements2.elements.enable_deserialize = true;
        cep.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        assert (!cep.elements1.elements.deserialize_children ());
        assert (!cep.elements2.elements.deserialize_children ());
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/treemap/post-deserialization/disable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new HTCElement ();
        for (int i = 0; i < 125000; i++) {
          var e1 = new HTElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.set (e1.name, e1);
          var e2 = new HTElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.set (e2.name, e2);
        }
        ce.serialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var cep = new HTCElement ();
        cep.elements1.enable_deserialize = false;
        cep.elements2.enable_deserialize = false;
        cep.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling C1 deserialize_children()...");
        Test.timer_start ();
        cep.elements1.deserialize_children ();
        assert (!cep.elements1.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C1: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
        Test.message ("Calling C2 deserialize_children()...");
        Test.timer_start ();
        cep.elements2.deserialize_children ();
        assert (!cep.elements2.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C2: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/treemap/post-deserialization/enable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new HTCElement ();
        for (int i = 0; i < 125000; i++) {
          var e1 = new HTElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.set (e1.name, e1);
          var e2 = new HTElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.set (e2.name, e2);
        }
        ce.serialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Enable collection deserialization...");
        Test.timer_start ();
        var cep = new HTCElement ();
        cep.elements1.enable_deserialize = true;
        cep.elements2.enable_deserialize = true;
        cep.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        assert (!cep.elements1.deserialize_children ());
        assert (!cep.elements2.deserialize_children ());
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/dualkeymap/post-deserialization/disable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new DHCElement ();
        for (int i = 0; i < 125000; i++) {
          var e1 = new DHElement ();
          e1.key = "E1";
          e1.name = "1E"+i.to_string ();
          ce.elements1.set (e1.key, e1.name, e1);
          var e2 = new DHElement ();
          e2.key = "E2";
          e2.name = "2E"+i.to_string ();
          ce.elements2.set (e2.key, e2.name, e2);
        }
        ce.serialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var cep = new DHCElement ();
        cep.elements1.enable_deserialize = false;
        cep.elements2.enable_deserialize = false;
        cep.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling C1 deserialize_children()...");
        Test.timer_start ();
        cep.elements1.deserialize_children ();
        assert (!cep.elements1.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C1: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
        Test.message ("Calling C2 deserialize_children()...");
        Test.timer_start ();
        cep.elements2.deserialize_children ();
        assert (!cep.elements2.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C2: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/dualkeymap/post-deserialization/enable",
    () => {
      try {
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new TwDocument ();
        var ce = new DHCElement ();
        for (int i = 0; i < 125000; i++) {
          var e1 = new DHElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.set (e1.key, e1.name, e1);
          var e2 = new DHElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.set (e2.key, e2.name, e2);
        }
        ce.serialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Enable collection deserialization...");
        Test.timer_start ();
        var cep = new DHCElement ();
        cep.elements1.enable_deserialize = true;
        cep.elements2.enable_deserialize = true;
        cep.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        assert (!cep.elements1.deserialize_children ());
        assert (!cep.elements2.deserialize_children ());
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/hashmap/post-deserialization/disable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new HTopElement ();
        for (int i = 0; i < 30000; i++) {
          var e1 = new HElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.elements.set (e1.name, e1);
          var e2 = new HElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.elements.set (e2.name, e2);
        }
        assert (ce.elements1.elements.size == 30000);
        assert (ce.elements2.elements.size == 30000);
        ce.serialize (d);
        d.save_as (f);
        assert (d.root != null);
        assert (d.root.children.size == 2);
        assert (d.root.children[0].children.size == 30000);
        assert (d.root.children[1].children.size == 30000);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new HTopElement ();
        cep.elements1.elements.enable_deserialize = false;
        cep.elements2.elements.enable_deserialize = false;
        cep.deserialize (gd);
        assert(cep.elements1.elements.size == 0);
        assert(cep.elements2.elements.size == 0);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling C1 deserialize_children()...");
        Test.timer_start ();
        assert (cep.elements1.elements.deserialize_children ());
        assert (cep.elements1.elements.size == 30000);
        assert (!cep.elements1.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C1: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
        Test.message ("Calling C2 deserialize_children()...");
        Test.timer_start ();
        cep.elements2.elements.deserialize_children ();
        assert (!cep.elements2.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C2: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/hashmap/post-deserialization/enable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new HTopElement ();
        for (int i = 0; i < 30000; i++) {
          var e1 = new HElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.elements.set (e1.name, e1);
          var e2 = new HElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.elements.set (e2.name, e2);
        }
        assert (ce.elements1.elements.size == 30000);
        assert (ce.elements2.elements.size == 30000);
        ce.serialize (d);
        d.save_as (f);
        assert (d.root != null);
        assert (d.root.children.size == 2);
        assert (d.root.children[0].children.size == 30000);
        assert (d.root.children[1].children.size == 30000);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Enable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new HTopElement ();
        cep.elements1.elements.enable_deserialize = true;
        cep.elements2.elements.enable_deserialize = true;
        cep.deserialize (gd);
        assert(cep.elements1.elements.size == 30000);
        assert(cep.elements2.elements.size == 30000);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument Enable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling C1 deserialize_children()...");
        Test.timer_start ();
        assert (cep.elements1.elements.size == 30000);
        assert (!cep.elements1.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C1: Enable Deserialize Collection. Deserialized from NODE: %g seconds", time);
        Test.message ("Calling C2 deserialize_children()...");
        Test.timer_start ();
        assert (!cep.elements2.elements.deserialize_children ());
        assert (!cep.elements2.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C2: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/arraylist/post-deserialization/disable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new CElement ();
        for (int i = 0; i < 30000; i++) {
          var e = new AElement ();
          ce.elements.add (e);
        }
        ce.serialize (d);
        d.save_as (f);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new CElement ();
        cep.elements.enable_deserialize = false;
        cep.deserialize (gd);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling deserialize_children()...");
        Test.timer_start ();
        cep.elements.deserialize_children ();
        assert (!cep.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/arraylist/post-deserialization/enable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new CElement ();
        for (int i = 0; i < 30000; i++) {
          var e = new AElement ();
          ce.elements.add (e);
        }
        ce.serialize (d);
        d.save_as (f);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new CElement ();
        cep.elements.enable_deserialize = true;
        cep.deserialize (gd);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Enable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling deserialize_children()...");
        Test.timer_start ();
        cep.elements.deserialize_children ();
        assert (!cep.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Enable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
#endif
  }
}
