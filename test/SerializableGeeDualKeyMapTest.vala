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

class Spaces : SerializableObjectModel, SerializableMapDualKey<string,string>
{
  public string get_map_primary_key  () { return owner; }
  public string get_map_secondary_key () { return name; }
  public string name { get; set; }
  public string owner { get; set; }
  public Spaces.full ( string owner, string name)
  {
    this.name = name;
    this.owner = owner;
  }
  public override string to_string () { return name; }
}

class SerializableGeeDualKeyMapTest : GXmlTest
{

  class BallFill : SerializableObjectModel
  {
    public string name { get; set; default = "Fill"; }
    public void set_text (string txt) { serialized_xml_node_value = txt; }
    public override string to_string () { return name; }
    public override string node_name () { return "BallFill"; }
    public override bool serialize_use_xml_node_value () { return true; }
  }

  class Ball : SerializableObjectModel, SerializableMapDualKey<string,string>
  {
    public string name { get; set; default = "Ball"; }
    public string size { get; set; default = "medium"; }
    public BallFill ballfill { get; set; }
    public override string to_string () { return name; }
    public override string node_name () { return "Ball"; }
    public string get_map_primary_key () { return size; }
		public string get_map_secondary_key () { return name; }
    public class DualMap : SerializableDualKeyMap<string,string,Ball> {
      public override bool deserialize_proceed () { return false; }
    }
  }

  class SmallBag : SerializableObjectModel, SerializableMapDualKey<string,string>
  {
    public string name { get; set; default = "SmallBag"; }
    public string cash { get; set; default = "money"; }
    public Ball.DualMap balls { get; set; default = new Ball.DualMap (); }
    public override string to_string () { return name; }
    public override string node_name () { return "SmallBag"; }
    public string get_map_primary_key () { return cash; }
		public string get_map_secondary_key () { return name; }
    public class DualMap : SerializableDualKeyMap<string,string,SmallBag> {
      public override bool deserialize_proceed () { return false; }
    }
  }

  class BigBag : SerializableObjectModel
  {
    public string name { get; set; default = "ball"; }
    public SmallBag.DualMap bags { get; set; default = new SmallBag.DualMap (); }
    public override string to_string () { return name; }
    public override string node_name () { return "BigBag"; }
  }

  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/dualkeymap/api",
    () => {
        var c = new SerializableDualKeyMap<string,string,Spaces> ();
        var o1 = new Spaces.full ("Floor", "Big");
        var o2 = new Spaces.full ("Wall", "Small");
        var o3 = new Spaces.full ("Floor", "Bigger");
        var o4 = new Spaces.full ("Wall","Smallest");
        c.set (o1.owner, o1.name, o1);
        c.set (o2.owner, o2.name, o2);
        c.set (o3.owner, o3.name, o3);
        c.set (o4.owner, o4.name, o4);
        if (c.size != 4) {
          stdout.printf (@"SIZE: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        bool found3 = false;
        bool found4 = false;
        foreach (Spaces s in c.values ()) {
          if (s.owner == "Floor" && s.name == "Big")
            found1 = true;
          if (s.owner == "Wall" && s.name == "Small")
            found2 = true;
          if (s.owner == "Floor" && s.name == "Bigger")
            found3 = true;
          if (s.owner == "Wall" && s.name == "Smallest")
            found4 = true;
        }
        if (!found1) {
          stdout.printf (@"Not found 'Floor' & 'Big':\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"Not found 'Wall' & 'Small':\n");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"Not found 'Floor' & 'Bigger':\n");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"Not found 'Wall' & 'Smallest':\n");
          assert_not_reached ();
        }
        found1 = found3 = false;
        foreach (Spaces s in c.values_for_key ("Floor")) {
          if (s.owner == "Floor" && s.name == "Big")
            found1 = true;
          if (s.owner == "Floor" && s.name == "Bigger")
            found3 = true;
        }
        if (!found1) {
          stdout.printf (@"Not found 'Floor' & 'Big':\n");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"Not found 'Floor' & 'Bigger':\n");
          assert_not_reached ();
        }
        found2 = found4 = true;
        foreach (string k2 in c.secondary_keys ("Wall")) {
          var s = c.get ("Wall", k2);
          if (s.owner == "Wall" && s.name == "Small")
            found2 = true;
          if (s.owner == "Wall" && s.name == "Smallest")
            found4 = true;
        }
        if (!found2) {
          stdout.printf (@"Not found 'Wall' & 'Small':\n");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"Not found 'Wall' & 'Smallest':\n");
          assert_not_reached ();
        }
    });
    Test.add_func ("/gxml/serializable/dualkeymap/serialize",
    () => {
      try {
        var c = new SerializableDualKeyMap<string,string,Spaces> ();
        var o1 = new Spaces.full ("Floor", "Big");
        var o2 = new Spaces.full ("Wall", "Small");
        var o3 = new Spaces.full ("Floor", "Bigger");
        var o4 = new Spaces.full ("Wall","Smallest");
        c.set (o1.owner, o1.name, o1);
        c.set (o2.owner, o2.name, o2);
        c.set (o3.owner, o3.name, o3);
        c.set (o4.owner, o4.name, o4);
        var doc = new TwDocument ();
        var root = doc.create_element ("root");
        doc.children.add (root);
        c.serialize (root);
        assert (root.children.size == 4);
        bool found1 = false;
        bool found2 = false;
        bool found3 = false;
        bool found4 = false;
        int nodes = 0;
        int i = 0;
        foreach (GXml.Node n in root.children) {
          nodes++;
          if (n is Element && n.name == "spaces") {
            i++;
            var name = n.attrs.get ("name");
            var owner = n.attrs.get ("owner");
            if (name != null && owner != null) {
              if (name.value == "Big" && owner.value == "Floor") found1 = true;
              if (name.value == "Small" && owner.value == "Wall") found2 = true;
              if (name.value == "Bigger" && owner.value == "Floor") found3 = true;
              if (name.value == "Smallest" && owner.value == "Wall") found4 = true;
            }
          }
        }
        if (i != 4) {
          stdout.printf (@"ERROR: Incorrect number of space nodes. Expected 4, got: $nodes\n$(doc)");
          assert_not_reached ();
        }
        // Consider that root node contents have a valid GXml.Text one
        if (nodes != 4) {
          stdout.printf (@"ERROR: Incorrect number of nodes. Expected 5, got: $nodes\n$(doc)");
          assert_not_reached ();
        }
        if (!found1) {
          stdout.printf (@"ERROR: 'Big' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: 'Small' / 'Wall' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"ERROR: 'Bigger' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"ERROR: 'Smallest' / 'Wall' not found\n$(doc)");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/dualkeymap/deserialize",
    () => {
      try {
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
<root><spaces name="Small" owner="Wall"/><spaces name="Smallest" owner="Wall"/><spaces name="Big" owner="Floor"/><spaces name="Bigger" owner="Floor"/><spark /></root>""");
        var c = new SerializableDualKeyMap<string,string,Spaces> ();
        c.deserialize (doc.root);
        if (c.size != 4) {
          stdout.printf (@"ERROR: incorrect size must be 4 got: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        bool found3 = false;
        bool found4 = false;
        foreach (Spaces s in c.values ()) {
          if (s.owner == "Floor" && s.name == "Big") found1 = true;
          if (s.owner == "Wall" && s.name == "Small") found2 = true;
          if (s.owner == "Floor" && s.name == "Bigger") found3 = true;
          if (s.owner == "Wall" && s.name == "Smallest") found4 = true;
        }
        if (!found1) {
          stdout.printf (@"ERROR: 'Big' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: 'Small' / 'Wall' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"ERROR: 'Bigger' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"ERROR: 'Smallest' / 'Wall' not found\n$(doc)");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/dualkeymap/de-se-deserialize",
    () => {
      try {
        var idoc = new GDocument.from_string ("""<?xml version="1.0"?>
<root><spaces name="Small" owner="Wall"/><spaces name="Smallest" owner="Wall"/><spaces name="Big" owner="Floor"/><spaces name="Bigger" owner="Floor"/><spark /></root>""");
        var ic = new SerializableDualKeyMap<string,string,Spaces> ();
        ic.deserialize (idoc.root);
        if (ic.size != 4) {
          stdout.printf (@"ERROR: Incorrect size (1st deserialize). Expected 4, got: $(ic.size)\n$idoc\n");
          assert_not_reached ();
        }
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
<root />""");
        ic.serialize (doc.root);
        var c =  new SerializableDualKeyMap<string,string,Spaces> ();
        c.deserialize (doc.root);
        if (c.size != 4) {
          stdout.printf (@"ERROR: Incorrect size. Expected 4, got: $(c.size)\n$doc\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/dualkeymap/deserialize-node-names",
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
        assert (b.inventory_registers != null);
        assert (b.inventory_registers.size == 4);
        var ir = b.inventory_registers.get (1,"K001");
        assert (ir != null);
        assert (ir.number == 1);
        assert (ir.inventory == "K001");
        assert (ir.row == 5);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/dualkeymap/post-deserialization/serialize/contents",
    () => {
      try {
        // Construct Bag contents
        var bag = new BigBag ();
        assert (bag.bags != null);
        for (int i = 0; i < 2; i++) {
          var sbag = new SmallBag ();
          sbag.name = "SmallBag"+i.to_string ();
          assert (sbag.balls != null);
          for (int j = 0; j < 2; j++) {
            var b = new Ball ();
            b.name = "Ball"+j.to_string ();
            b.ballfill = new BallFill ();
            b.ballfill.set_text ("golden dust");
            sbag.balls.set (b.size, b.name,b);
          }
          assert (sbag.balls.size == 2);
          bag.bags.set (sbag.cash, sbag.name, sbag);
        }
        assert (bag.bags.size == 2);
        // Construct XML
        var d = new GDocument ();
        bag.serialize (d);
        assert (d.root != null);
        assert (d.root.name == "BigBag");
        assert (d.root.children.size == 2);
        assert (d.root.children[0].name == "SmallBag");
        assert (d.root.children[0].children.size == 2);
        assert (d.root.children[0].children[0].name == "Ball");
        assert (d.root.children[0].children[0].children.size == 1);
        assert (d.root.children[0].children[0].children[0].name == "BallFill");
        assert (d.root.children[0].children[0].children[0].children.size == 1);
        assert (d.root.children[0].children[0].children[0].children[0] is Text);
        assert (d.root.children[0].children[0].children[0].children[0].value == "golden dust");
        //GLib.message (d.to_string ());
        // Deserialize
        var bagt = new BigBag ();
        bagt.deserialize (d);
        assert (bagt.bags.size == 0);
        assert (bagt.bags.deserialize_children ());
        assert (bagt.bags.size == 2);
        assert (bagt.bags.get("money","SmallBag1").balls.deserialize_children ());
        assert (bagt.bags.get("money","SmallBag1").balls.size == 2);
        assert (bagt.bags.get("money","SmallBag1").balls.get("medium","Ball1").name == "Ball1");
        assert (bagt.bags.get("money","SmallBag1").balls.get("medium","Ball1").ballfill !=null);
        assert (bagt.bags.get("money","SmallBag1").balls.get("medium","Ball1").ballfill.serialized_xml_node_value !=null);
        assert (bagt.bags.get("money","SmallBag1").balls.get("medium","Ball1").ballfill.serialized_xml_node_value =="golden dust");
        var bag3 = new BigBag ();
        bag3.deserialize (d);
        assert (bag3.bags.size == 0);
        assert (bag3.bags.deserialize_children ());
        assert (bag3.bags.size == 2);
        bag3.deserialize (d);
        assert (!bag3.bags.deserialized ());
        // Serialize
        var bag2 = new BigBag ();
        bag2.deserialize (d);
        assert (!bag2.bags.deserialized ());
        var d2 = new GDocument ();
        bag2.serialize (d2);
        //GLib.message ("SECOND:"+d2.to_string ());
        assert (d2.root != null);
        assert (d2.root.name == "BigBag");
        assert (d2.root.children.size == 2);
        assert (d2.root.children[0].name == "SmallBag");
        assert (d2.root.children[0].children.size == 2);
        assert (d2.root.children[0].children[0].name == "Ball");
        assert (d2.root.children[0].children[0].children.size == 1);
        assert (d2.root.children[0].children[0].children[0].name == "BallFill");
        assert (d2.root.children[0].children[0].children[0].children.size == 1);
        assert (d2.root.children[0].children[0].children[0].children[0] is GXml.Text);
        assert (d2.root.children[0].children[0].children[0].children[0].value == "golden dust");
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
  }
}
