/* -*- Mode: vala; indent-tabs-mode: nil; tab-width: 2 -*- */
/**
 *
 *  SerializablePropertyBoolTest.vala
 *
 *  Authors:
 *
 *       Daniel Espinosa <esodan@gmail.com>
 *
 *
 *  Copyright (c) 2015 Daniel Espinosa
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
class SerializablePropertyBoolTest : GXmlTest {
  public class BoolNode : SerializableObjectModel
  {
    public SerializableBool boolean { get; set; }
    public int  integer { get; set; default = 0; }
    public string name { get; set; }
    public override string node_name () { return "BooleanNode"; }
    public override string to_string () { return get_type ().name (); }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/Bool/basic",
    () => {
      try {
        var bn = new BoolNode ();
        var doc = new GDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.root as Element;
        var b = element.get_attr ("boolean");
        assert (b == null);
        var s = element.get_attr ("name");
        assert (s == null);
        var i = element.get_attr ("integer");
        assert (i.value == "0");
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Bool/changes",
    () => {
      try {
        var bn = new BoolNode ();
        var doc = new GDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.root as Element;
        var b = element.get_attr ("boolean");
        assert (b == null);
        var s = element.get_attr ("name");
        assert (s == null);
        var i = element.get_attr ("integer");
        assert (i.value == "0");
        // Change values
        bn.boolean = new SerializableBool ();
        // set to TRUE
        bn.boolean.set_value (true);
        var doc2 = new GDocument ();
        bn.serialize (doc2);
        Test.message ("XML2:\n"+doc2.to_string ());
        var element2 = doc2.root as Element;
        var b2 = element2.get_attr ("boolean");
        assert (b2 != null);
        assert (b2.value == "true");
        // set to FALSE
        bn.boolean.set_value (false);
        var doc3 = new GDocument ();
        bn.serialize (doc3);
        Test.message ("XML3:\n"+doc3.to_string ());
        var element3 = doc3.root as Element;
        var b3 = element3.get_attr ("boolean");
        assert (b3 != null);
        assert (b3.value == "false");
        // set to NULL/IGNORE
        bn.boolean.set_serializable_property_value (null);
        var doc4= new GDocument ();
        bn.serialize (doc4);
        Test.message ("XML3:\n"+doc4.to_string ());
        var element4 = doc4.root as Element;
        var b4 = element4.get_attr ("boolean");
        assert (b4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Bool/deserialize/basic",
    () => {
      try {
        var doc1 = new GDocument.from_string ("""<?xml version="1.0"?>
                       <BooleanNode boolean="true"/>""");
        var b = new BoolNode ();
        b.deserialize (doc1);
        assert (b.boolean.get_serializable_property_value () == "true");
        assert (b.boolean.get_value () == true);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Bool/deserialize/invalid",
    () => {
      try {
        var doc1 = new GDocument.from_string ("""<?xml version="1.0"?>
                       <BooleanNode boolean="c"/>""");
        var b1 = new BoolNode ();
        b1.deserialize (doc1);
        assert (b1.boolean.get_serializable_property_value () == "c");
        assert (b1.boolean.get_value () == false);
        var doc2 = new GDocument.from_string ("""<?xml version="1.0"?>
                       <BooleanNode boolean="TRUE"/>""");
        var b2 = new BoolNode ();
        b2.deserialize (doc2);
        assert (b2.boolean.get_serializable_property_value () == "TRUE");
        assert (b2.boolean.get_value () == true);
        var doc3 = new GDocument.from_string ("""<?xml version="1.0"?>
                       <BooleanNode boolean="FALSE"/>""");
        var b3 = new BoolNode ();
        b3.deserialize (doc3);
        assert (b3.boolean.get_serializable_property_value () == "FALSE");
        assert (b3.boolean.get_value () == false);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
