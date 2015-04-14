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
  public override void init_properties ()
  {
    default_init_properties ();
  }
  public override string to_string () { return name; }
}

class SerializableGeeDualKeyMapTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/serializable_dual_key_map/api",
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
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
      }
    });
    Test.add_func ("/gxml/serializable/serializable_dual_key_map/serialize",
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
        var doc = new Document ();
        var root = doc.create_element ("root");
        doc.append_child (root);
        c.serialize (root);
        if (!root.has_child_nodes ()) {
          stdout.printf (@"ERROR: root node have no childs $(doc)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        bool found3 = false;
        bool found4 = false;
        int nodes = 0;
        int i = 0;
        foreach (GXml.xNode n in root.child_nodes) {
          nodes++;
          if (n is Element && n.node_name == "spaces") {
            i++;
            var name = ((Element) n).get_attribute_node ("name");
            var owner = ((Element) n).get_attribute_node ("owner");
            if (name != null && owner != null) {
              if (name.node_value == "Big" && owner.node_value == "Floor") found1 = true;
              if (name.node_value == "Small" && owner.node_value == "Wall") found2 = true;
              if (name.node_value == "Bigger" && owner.node_value == "Floor") found3 = true;
              if (name.node_value == "Smallest" && owner.node_value == "Wall") found4 = true;
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
    Test.add_func ("/gxml/serializable/serializable_dual_key_map/deserialize",
    () => {
      try {
        var doc = new Document.from_string ("""<?xml version="1.0"?>
<root><spaces name="Small" owner="Wall"/><spaces name="Smallest" owner="Wall"/><spaces name="Big" owner="Floor"/><spaces name="Bigger" owner="Floor"/><spark /></root>""");
        var c = new SerializableDualKeyMap<string,string,Spaces> ();
        c.deserialize (doc.document_element);
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
    Test.add_func ("/gxml/serializable/serializable_dual_key_map/de-se-deserialize",
    () => {
      try {
        var idoc = new Document.from_string ("""<?xml version="1.0"?>
<root><spaces name="Small" owner="Wall"/><spaces name="Smallest" owner="Wall"/><spaces name="Big" owner="Floor"/><spaces name="Bigger" owner="Floor"/><spark /></root>""");
        var ic = new SerializableDualKeyMap<string,string,Spaces> ();
        ic.deserialize (idoc.document_element);
        if (ic.size != 4) {
          stdout.printf (@"ERROR: Incorrect size (1st deserialize). Expected 4, got: $(ic.size)\n$idoc\n");
          assert_not_reached ();
        }
        var doc = new Document.from_string ("""<?xml version="1.0"?>
<root />""");
        ic.serialize (doc.document_element);
        var c =  new SerializableDualKeyMap<string,string,Spaces> ();
        c.deserialize (doc.document_element);
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
  }
}
