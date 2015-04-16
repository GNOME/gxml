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

class SerializableGeeHashMapTest : GXmlTest
{
  class Space : SerializableObjectModel, SerializableMapKey<string>
  {
    public string get_map_key () { return name; }
    public string name { get; set; }
    public Space.named (string name) { this.name = name; }
    public void set_value (string str) { serialized_xml_node_value = str; }
    public string get_value () {
      if (serialized_xml_node_value == null)
        serialized_xml_node_value = "";
      return serialized_xml_node_value;
    }
    // Required when you want to use serialized_xml_node_value
    public override bool serialize_use_xml_node_value () { return true; }
    public override string node_name () { return "space"; }
    public override string to_string () { return name; }
    public class Collection : SerializableHashMap<string,Space> {}
  }

  class SpaceContainer : SerializableContainer
  {
    public string owner { get; set; }
    public Space.Collection storage { get; set; }
    public override string node_name () { return "spacecontainer"; }
    public override string to_string () { return owner; }
    // SerializableContainer: Init containers
    public override void init_containers () {
      if (storage == null)
        storage = new Space.Collection ();
    }
  }

  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/serializable_hash_map/api",
    () => {
      try {
        var c = new SerializableHashMap<string,Space> ();
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
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
      }
    });
    Test.add_func ("/gxml/serializable/serializable_hash_map/serialize",
    () => {
      try {
        var c = new SerializableHashMap<string,Space> ();
        var o1 = new Space.named ("Big");
        o1.set_value ("FAKE TEXT");
        var o2 = new Space.named ("Small");
        o2.set_value ("FAKE TEXT");
        c.set (o1.name, o1);
        c.set (o2.name, o2);
        var doc = new xDocument ();
        var root = doc.create_element ("root");
        doc.childs.add (root);
        c.serialize ((xNode)root);
        if (root.childs.size == 0) {
          stdout.printf (@"ERROR: root node have no childs $(doc)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (GXml.Node n in root.childs) {
          if (n is Element && n.name == "space") {
            var name = n.attrs.get ("name");
            if (name != null) {
              if (name.value == "Big") found1 = true;
              if (name.value == "Small") found2 = true;
            }
            if (n.childs.size > 0) {
              foreach (GXml.Node nd in n.childs) {
                if (nd is Text) {
                  if (nd.value != "FAKE TEXT") {
                    stdout.printf (@"ERROR: node content don't much. Expected 'FAKE TEXT', got: $(nd.value)\n$(doc)\n");
                    assert_not_reached ();
                  }
                }
              }
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
    Test.add_func ("/gxml/serializable/serializable_hash_map/deserialize",
    () => {
      try {
        var doc = new xDocument.from_string ("""<?xml version="1.0"?>
  <root><space name="Big"/><space name="Small"/></root>""");
        var c = new SerializableHashMap<string,Space> ();
        c.deserialize (doc.document_element);
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
    Test.add_func ("/gxml/serializable/serializable_hash_map/container_class/deserialize",
    () => {
      try {
        var doc = new xDocument.from_string ("""<?xml version="1.0"?>
  <spacecontainer owner="Earth"><space name="Big"/><space name="Small"/></spacecontainer>""");
        var c = new SpaceContainer ();
        c.deserialize (doc);
        if (c.owner != "Earth") {
          stdout.printf (@"ERROR: owner must be 'Earth' got: $(c.owner)\n$(doc)\n");
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
    Test.add_func ("/gxml/serializable/serializable_hash_map/containder_class/serialize",
    () => {
      try {
        var c = new SpaceContainer ();
        var o1 = new Space.named ("Big");
        var o2 = new Space.named ("Small");
        c.storage = new Space.Collection ();
        c.storage.set (o1.name, o1);
        c.storage.set (o2.name, o2);
        var doc = new xDocument ();
        c.serialize (doc);
        if (doc.document_element == null) {
          stdout.printf (@"ERROR: doc have no root node\n$(doc)\n");
          assert_not_reached ();
        }
        if (doc.document_element.node_name != "spacecontainer") {
          stdout.printf (@"ERROR: bad doc root node's name: $(doc.document_element.node_name)\n$(doc)\n");
          assert_not_reached ();
        }
        var root = doc.root;
        if (root.childs.size == 0) {
          stdout.printf (@"ERROR: root node have no childs $(doc)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (GXml.Node n in root.childs) {
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
    Test.add_func ("/gxml/serializable/serializable_hash_map/deserialize-serialize",
    () => {
      try {
        var idoc = new xDocument.from_string ("""<?xml version="1.0"?>
    <spacecontainer owner="Earth">
      <space name="Big"/>
      <space name="Big">FAKE1</space>
      <space name="Small"/>
      <space name="Yum1">FAKE2</space>
      <space name="Yum2">FAKE3</space>
      <space name="Yum3">FAKE4</space>
      <space name="Yum3">FAKE5</space>
    </spacecontainer>""");
        var isc = new SpaceContainer ();
        isc.deserialize (idoc);
        var doc = new xDocument ();
        isc.serialize (doc);
        var sc = new SpaceContainer ();
        sc.deserialize (doc);
        if (sc.storage == null) {
          stdout.printf (@"ERROR: No storage found\n");
          assert_not_reached ();
        }
        if (sc.storage.size != 5) {
          stdout.printf (@"ERROR: wrong storage size. Expected 5, got: $(sc.storage.size)\n");
          assert_not_reached ();
        }
        int i = 0;
        foreach (Space s in sc.storage.values)
          i++;
        if (i != 5) {
          stdout.printf (@"ERROR: wrong storage size counted. Expected 5, got: $(sc.storage.size)\n");
          assert_not_reached ();
        }
        var s1 = sc.storage.get ("Big");
        if (s1 == null) {
          stdout.printf (@"ERROR: space 'Big' not found\n");
          assert_not_reached ();
        }
        if (s1.get_value () != "FAKE1") {
          stdout.printf (@"ERROR: wrong s1 text. Expected 'FAKE1', got: $(s1.get_value ())\n");
          assert_not_reached ();
        }
        var s2 = sc.storage.get ("Small");
        if (s2 == null) {
          stdout.printf (@"ERROR: space 'Small' not found\n");
          assert_not_reached ();
        }
        if (s2.get_value () != "") {
          stdout.printf (@"ERROR: wrong s2 text. Expected '', got: '$(s2.get_value ())'\n");
          assert_not_reached ();
        }
        var s3 = sc.storage.get ("Yum1");
        if (s3 == null) {
          stdout.printf (@"ERROR: space 'Yum1' not found\n");
          assert_not_reached ();
        }
        if (s3.get_value () != "FAKE2") {
          stdout.printf (@"ERROR: wrong s3 text. Expected 'FAKE2', got: $(s3.get_value ())\n");
          assert_not_reached ();
        }
        var s4 = sc.storage.get ("Yum2");
        if (s4 == null) {
          stdout.printf (@"ERROR: space 'Yum2' not found\n");
          assert_not_reached ();
        }
        if (s4.get_value () != "FAKE3") {
          stdout.printf (@"ERROR: wrong s4 text. Expected 'FAKE3', got: $(s4.get_value ())\n");
          assert_not_reached ();
        }
        var s5 = sc.storage.get ("Yum3");
        if (s5 == null) {
          stdout.printf (@"ERROR: space 'Yum3' not found\n");
          assert_not_reached ();
        }
        if (s5.get_value () != "FAKE5") {
          stdout.printf (@"ERROR: wrong s5 text. Expected 'FAKE5', got: $(s5.get_value ())\n");
          assert_not_reached ();
        }
      } catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
