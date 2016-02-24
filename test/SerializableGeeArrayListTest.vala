/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/**
 *
 *  GXml.Serializable.BasicTypeTest
 *
 *  Authors:
 *
 *       Daniel Espinosa <esodan@gmail.com>
 *
 *
 *  Copyright (c) 2013-2015 Daniel Espinosa
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using GXml;
using Gee;

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

class SerializableGeeArrayListTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/serializable_array_list/api",
    () => {
      try {
        var c = new SerializableArrayList<AElement> ();
        var o1 = new AElement.named ("Big");
        var o2 = new AElement.named ("Small");
        c.add (o1);
        c.add (o2);
        bool found1 = false;
        bool found2 = false;
        foreach (AElement o in c) {
          if (o.name == "Big") found1 = true;
          if (o.name == "Small") found2 = true;
        }
        if (!found1) {
          stdout.printf (@"Big is not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"Small is not found\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
      }
    });
    Test.add_func ("/gxml/serializable/serializable_array_list/serialize",
    () => {
      try {
        var c = new SerializableArrayList<AElement> ();
        var o1 = new AElement.named ("Big");
        var o2 = new AElement.named ("Small");
        c.add (o1);
        c.add (o2);
        var doc = new TwDocument ();
        var root = doc.create_element ("root");
        doc.children.add (root);
        c.serialize (root);
        assert (root.children.size == 2);
        bool found1 = false;
        bool found2 = false;
        foreach (GXml.Node n in root.children) {
          if (n is Element && n.name == "aelement") {
            var name = n.attrs.get ("name");
            if (name != null) {
              if (name.value == "Big") found1 = true;
              if (name.value == "Small") found2 = true;
            }
          }
        }
        if (!found1) {
          stdout.printf (@"ERROR: Big space node was not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: Small space node was not found\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/serializable_array_list/deserialize",
    () => {
      try {
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
  <root><aelement name="Big"/><aelement name="Small"/></root>""");
        var c = new SerializableArrayList<AElement> ();
        c.deserialize (doc.root);
        if (c.size != 2) {
          stdout.printf (@"ERROR: incorrect size must be 2 got: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (AElement o in c) {
          if (o.name == "Big") found1 = true;
          if (o.name == "Small") found2 = true;
        }
        if (!found1) {
          stdout.printf (@"ERROR: Big key value is not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: Small key value is not found\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/serializable_array_list/deserialize-serialize",
    () => {
      try {
        var idoc = new GDocument.from_string ("""<?xml version="1.0"?>
    <root>
      <aelement name="Big"/>
      <aelement name="Small"/>
      <aelement name="Wall">FAKE1</aelement>
    </root>""");
        var iroot = idoc.root;
        var ic = new SerializableArrayList<AElement> ();
        ic.deserialize (iroot);
        var doc = new TwDocument ();
        var root = doc.create_element ("root");
        doc.children.add (root);
        ic.serialize (root);
        var c = new SerializableArrayList<AElement> ();
        c.deserialize (root);
        assert (c.size == 3);
        int count_elements = 0;
        foreach (AElement e in c)
          count_elements++;
        assert (count_elements == 3);
        string[] s = {"Big","Small","Wall"};
#if DEBUG
        GLib.message ("Dump deserialized from document...");
        for (int k = 0; k < c.size; k++) {
          string str = "";
          if (c.get (k).name != null) str = c.get (k).name;
          GLib.message (@"Expected name = $(s[k]) got: $(str)");
        }
#endif
        for (int j = 0; j < c.size; j++) {
          assert (s[j] == c.get (j).name);
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/serializable_array_list/deserialize-node-names",
    () => {
      try {
        var d = new GDocument.from_path (GXmlTestConfig.TEST_DIR + "/test-collection.xml");
        var bs = new BookStore ();
        bs.deserialize (d);
        assert (bs.name == "The Great Book");
        assert (bs.books.size == 3);
        var b = bs.books.first ();
        assert (b != null);
        assert (b.name != null);
        assert (b.name.get_name () == "Book1");
        assert (b.year == "2015");
        assert (b.authors != null);
        assert (b.authors.array != null);
        assert (b.authors.array.size == 2);
        var a = b.authors.array.first ();
        assert (a != null);
        assert (a.name != null);
        assert (a.name.get_name () == "Fred");
        assert (a.email != null);
        assert (a.email.get_mail () == "fweasley@hogwarts.co.uk");
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/serializable_array_list/post-deserialization/disable",
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
        assert (cep.elements.is_prepared ());
        Test.message ("Calling deserialize_children()...");
        Test.timer_start ();
        cep.elements.deserialize_children ();
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/serializable_array_list/post-deserialization/enable",
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
  }
}
