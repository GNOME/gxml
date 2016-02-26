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

class SerializableGeeTreeMapTest : GXmlTest
{
  class Space : SerializableObjectModel, SerializableMapKey<string>
  {
    public string get_map_key () { return name; }
    public string name { get; set; }
    public Space.named (string name) { this.name = name; }
    public override string node_name () { return "space"; }
    public override string to_string () { return name; }
    public class Collection : SerializableTreeMap<string,Space> {}
  }

  class SpaceContainer : SerializableContainer
  {
    public string owner { get; set; }
    public Space.Collection storage { get; set; }
    public override string node_name () { return "spacecontainer"; }
    public override string to_string () { return owner; }
// SerializableContainer overrides
    public override void init_containers () {
      if (storage == null)
        storage = new Space.Collection ();
    }
  }


  class BallFill : SerializableObjectModel
  {
    public string name { get; set; default = "Fill"; }
    public void set_text (string txt) { serialized_xml_node_value = txt; }
    public override string to_string () { return name; }
    public override string node_name () { return "BallFill"; }
    public override bool serialize_use_xml_node_value () { return true; }
  }

  class Ball : SerializableObjectModel, SerializableMapKey<string>
  {
    public string name { get; set; default = "Ball"; }
    public BallFill ballfill { get; set; }
    public override string to_string () { return name; }
    public override string node_name () { return "Ball"; }
    public string get_map_key () { return name; }
    public class TreeMap : SerializableTreeMap<string,Ball> {
      public override bool deserialize_proceed () { return false; }
    }
  }

  class SmallBag : SerializableObjectModel, SerializableMapKey<string>
  {
    public string name { get; set; default = "SmallBag"; }
    public Ball.TreeMap balls { get; set; default = new Ball.TreeMap (); }
    public override string to_string () { return name; }
    public override string node_name () { return "SmallBag"; }
    public string get_map_key () { return name; }
    public class TreeMap : SerializableTreeMap<string,SmallBag> {
      public override bool deserialize_proceed () { return false; }
    }
  }

  class BigBag : SerializableObjectModel
  {
    public string name { get; set; default = "ball"; }
    public SmallBag.TreeMap bags { get; set; default = new SmallBag.TreeMap (); }
    public override string to_string () { return name; }
    public override string node_name () { return "BigBag"; }
  }


  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/treemap/api",
    () => {
        var c = new SerializableTreeMap<string,Space> ();
        var o1 = new Space.named ("Big");
        var o2 = new Space.named ("Small");
        c.set (o1.name, o1);
        c.set (o2.name, o2);
        bool found1 = false;
        bool found2 = false;
        foreach (Space o in c.values) {
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
        found1 = found2 = false;
        foreach (string k in c.keys) {
          if ((c.@get (k)).name == "Big") found1 = true;
          if ((c.@get (k)).name == "Small") found2 = true;
        }
        if (!found1) {
          stdout.printf (@"Big key value is not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"Small key value is not found\n");
          assert_not_reached ();
        }
    });
    Test.add_func ("/gxml/serializable/treemap/serialize",
    () => {
      try {
        var c = new SerializableTreeMap<string,Space> ();
        var o1 = new Space.named ("Big");
        var o2 = new Space.named ("Small");
        c.set (o1.name, o1);
        c.set (o2.name, o2);
        var doc = new TwDocument ();
        var root = doc.create_element ("root");
        doc.children.add (root);
        c.serialize (root);
        assert (root.children.size == 2);
        bool found1 = false;
        bool found2 = false;
        foreach (GXml.Node n in root.children) {
          if (n is Element && n.name == "space") {
            var name = n.attrs.get ("name");
            if (name != null) {
              if (name.value == "Big") found1 = true;
              if (name.value == "Small") found2 = true;
            }
          }
        }
        if (!found1) {
          stdout.printf (@"ERROR: Big space node is not found\n$(doc)\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: Small space node is not found\n$(doc)\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/treemap/deserialize",
    () => {
      try {
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
  <root><space name="Big"/><space name="Small"/></root>""");
        var c = new SerializableTreeMap<string,Space> ();
        c.deserialize (doc.root);
        if (c.size != 2) {
          stdout.printf (@"ERROR: incorrect size must be 2 got: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (string k in c.keys) {
          if ((c.@get (k)).name == "Big") found1 = true;
          if ((c.@get (k)).name == "Small") found2 = true;
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
    Test.add_func ("/gxml/serializable/treemap/container_class/deserialize",
    () => {
      try {
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
  <spacecontainer owner="Earth"><space name="Big"/><space name="Small"/></spacecontainer>""");
        var c = new SpaceContainer ();
        c.deserialize (doc);
        if (c.owner != "Earth") {
          stdout.printf (@"ERROR: owner must be 'Earth' got: $(c.owner)\n$(doc)\n");
          assert_not_reached ();
        }
        if (c.storage == null) {
          stdout.printf (@"ERROR: storage doesn't exist\n$(doc)\n");
          assert_not_reached ();
        }
        if (c.storage.size != 2) {
          stdout.printf (@"ERROR: Size must be 2 got: $(c.storage.size)\n$(doc)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (string k in c.storage.keys) {
          if ((c.storage.@get (k)).name == "Big") found1 = true;
          if ((c.storage.@get (k)).name == "Small") found2 = true;
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
    Test.add_func ("/gxml/serializable/treemap/containder_class/serialize",
    () => {
      try {
        var c = new SpaceContainer ();
        var o1 = new Space.named ("Big");
        var o2 = new Space.named ("Small");
        c.storage = new Space.Collection ();
        c.storage.set (o1.name, o1);
        c.storage.set (o2.name, o2);
        var doc = new TwDocument ();
        c.serialize (doc);
        if (doc.root == null) {
          stdout.printf (@"ERROR: doc have no root node\n$(doc)\n");
          assert_not_reached ();
        }
        if (doc.root.name != "spacecontainer") {
          stdout.printf (@"ERROR: bad doc root node's name: $(doc.root.name)\n$(doc)\n");
          assert_not_reached ();
        }
        var root = doc.root;
        assert (root.children.size == 2);
        bool found1 = false;
        bool found2 = false;
        foreach (GXml.Node n in root.children) {
          if (n is Element && n.name == "space") {
            var name = n.attrs.get ("name");
            if (name != null) {
              if (name.value == "Big") found1 = true;
              if (name.value == "Small") found2 = true;
            }
          }
        }
        if (!found1) {
          stdout.printf (@"ERROR: Big space node is not found\n$(doc)\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: Small space node is not found\n$(doc)\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/treemap/deserialize-node-names",
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
        assert (b.resumes != null);
        assert (b.resumes.size == 2);
        var r = b.resumes.get ("II");
        assert (r != null);
        assert (r.chapter == "II");
        assert (r.text == "Nothing to say");
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/treemap/post-deserialization/serialize/contents",
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
            sbag.balls.set (b.name,b);
          }
          assert (sbag.balls.size == 2);
          bag.bags.set (sbag.name, sbag);
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
        GLib.message (d.to_string ());
        // Deserialize
        var bagt = new BigBag ();
        bagt.deserialize (d);
        assert (bagt.bags.size == 0);
        assert (bagt.bags.deserialize_children ());
        assert (bagt.bags.size == 2);
        assert (bagt.bags.get("SmallBag1").balls.deserialize_children ());
        assert (bagt.bags.get("SmallBag1").balls.size == 2);
        assert (bagt.bags.get("SmallBag1").balls.get("Ball1").name == "Ball1");
        assert (bagt.bags.get("SmallBag1").balls.get("Ball1").ballfill !=null);
        assert (bagt.bags.get("SmallBag1").balls.get("Ball1").ballfill.serialized_xml_node_value !=null);
        assert (bagt.bags.get("SmallBag1").balls.get("Ball1").ballfill.serialized_xml_node_value =="golden dust");
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
        GLib.message ("SECOND:"+d2.to_string ());
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
