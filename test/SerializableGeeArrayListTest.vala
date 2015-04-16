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
        var doc = new xDocument ();
        var root = doc.create_element ("root");
        doc.childs.add (root);
        c.serialize ((xNode) root);
        assert (root.childs.size == 2);
        bool found1 = false;
        bool found2 = false;
        foreach (GXml.Node n in root.childs) {
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
        var doc = new xDocument.from_string ("""<?xml version="1.0"?>
  <root><aelement name="Big"/><aelement name="Small"/></root>""");
        var c = new SerializableArrayList<AElement> ();
        c.deserialize (doc.document_element);
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
        var idoc = new xDocument.from_string ("""<?xml version="1.0"?>
    <root>
      <aelement name="Big"/>
      <aelement name="Small"/>
      <aelement name="Wall">FAKE1</aelement>
    </root>""");
        var iroot = idoc.document_element;
        var ic = new SerializableArrayList<AElement> ();
        ic.deserialize (iroot);
        var doc = new xDocument.from_string ("""<?xml version="1.0"?><root />""");
        var root = doc.document_element;
        ic.serialize (root);
        var c = new SerializableArrayList<AElement> ();
        c.deserialize (root);
        if (c.size != 3) {
          stdout.printf (@"ERROR: incorrect counted. Expected 3, got $(c.size)");
          assert_not_reached ();
        }
        int i = 0;
        foreach (AElement e in c)
          i++;
        if (i != 3) {
          stdout.printf (@"ERROR: incorrect counted. Expected 3, got $i");
          assert_not_reached ();
        }
        string[] s = {"Big","Small","Wall"};
        for (int j = 0; j < c.size; j++) {
          var e = c.get (j);
          if (s[j] != e.name) {
            stdout.printf (@"ERROR: incorrect name. Expected $(s[j]), got: $(c.get (j))");
            assert_not_reached ();
          }
          if (e.name == "Wall") {
            if (e.serialized_xml_node_value != null) {
              stdout.printf (@"ERROR: incorrect node '$(e.name)' content. Expected '', got: '$(e.serialized_xml_node_value)'");
              assert_not_reached ();
            }
          }
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
