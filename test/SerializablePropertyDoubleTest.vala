/* -*- Mode: vala; indent-tabs-mode: nil; tab-width: 2 -*- */
/**
 *
 *  SerializablePropertyDoubleTest.vala
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
class SerializablePropertyDoubleTest : GXmlTest {
  public class DoubleNode : SerializableObjectModel
  {
    [Description (nick="DoubleValue")]
    public SerializableDouble  double_value { get; set; }
    public string name { get; set; }
    public override string node_name () { return "DoubleNode"; }
    public override string to_string () { return get_type ().name (); }
    public override bool property_use_nick () { return true; }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/Double/basic",
    () => {
      try {
        var bn = new DoubleNode ();
        var doc = new xDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var b = element.get_attribute_node ("DoubleValue");
        assert (b == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Double/changes",
    () => {
      try {
        var bn = new DoubleNode ();
        var doc = new xDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var b = element.get_attribute_node ("DoubleValue");
        assert (b == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
        // Change values
        // set to 233.014
        bn.double_value = new SerializableDouble ();
        bn.double_value.set_value (233.014);
        var doc2 = new xDocument ();
        bn.serialize (doc2);
        Test.message ("XML2:\n"+doc2.to_string ());
        var element2 = doc2.document_element;
        var b2 = element2.get_attribute_node ("DoubleValue");
        assert (b2 != null);
        assert (bn.double_value.get_value () == 233.014);
        Test.message ("Value in xml: "+b2.value);
        Test.message ("Value in double class: "+bn.double_value.get_value ().to_string ());
        Test.message ("Value in xml formated %3.3f".printf (double.parse (b2.value)));
        Test.message ("%3.3f".printf (double.parse (b2.value)));
        assert ("%3.3f".printf (double.parse (b2.value)) == "233.014");
        assert (bn.double_value.format ("%3.3f") == "233.014");
        // set to -1
        bn.double_value.set_value (-1.013);
        var doc3 = new xDocument ();
        bn.serialize (doc3);
        Test.message ("XML3:\n"+doc3.to_string ());
        var element3 = doc3.document_element;
        var b3 = element3.get_attribute_node ("DoubleValue");
        assert (b3 != null);
        assert ("%2.3f".printf (double.parse (b3.value)) == "-1.013");
        // set to NULL/IGNORE
        bn.double_value.set_serializable_property_value (null);
        var doc4= new xDocument ();
        bn.serialize (doc4);
        Test.message ("XML3:\n"+doc4.to_string ());
        var element4 = doc4.document_element;
        var b4 = element4.get_attribute_node ("DoubleValue");
        assert (b4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Double/deserialize",
    () => {
      try {
        var doc1 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <DoubleNode DoubleValue="3.1416"/>""");
        var d = new DoubleNode ();
        d.deserialize (doc1);
        Test.message ("Actual value: "+d.double_value.get_serializable_property_value ());
        assert (d.double_value.get_serializable_property_value () == "3.1416");
        Test.message ("Actual value parse: "+"%2.4f".printf (double.parse (d.double_value.get_serializable_property_value ())));
        assert ("%2.4f".printf (double.parse (d.double_value.get_serializable_property_value ())) == "3.1416");
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Double/deserialize/bad-value",
    () => {
      try {
        var doc1 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <DoubleNode DoubleValue="a"/>""");
        var d = new DoubleNode ();
        d.deserialize (doc1);
        Test.message ("Actual value: "+d.double_value.get_serializable_property_value ());
        assert (d.double_value.get_serializable_property_value () == "a");
        Test.message ("Actual value parse: "+"%2.4f".printf (double.parse (d.double_value.get_serializable_property_value ())));
        assert ("%2.4f".printf (double.parse (d.double_value.get_serializable_property_value ())) == "0.0000");
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
