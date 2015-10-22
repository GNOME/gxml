/* -*- Mode: vala; indent-tabs-mode: nil; tab-width: 2 -*- */
/**
 *
 *  SerializablePropertyFloatTest.vala
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
class SerializablePropertyFloatTest : GXmlTest {
  public class FloatNode : SerializableObjectModel
  {
    [Description (nick="FloatValue")]
    public SerializableFloat  float_value { get; set; }
    public string name { get; set; }
    public override string node_name () { return "FloatNode"; }
    public override string to_string () { return get_type ().name (); }
    public override bool property_use_nick () { return true; }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/Float/basic",
    () => {
      try {
        var bn = new FloatNode ();
        var doc = new xDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var b = element.get_attribute_node ("FloatValue");
        assert (b == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Float/changes",
    () => {
      try {
        var bn = new FloatNode ();
        var doc = new xDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var b = element.get_attribute_node ("FloatValue");
        assert (b == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
        // Change values
        bn.float_value = new SerializableFloat ();
        // set to 233.014
        bn.float_value.set_value ((float) 233.014);
        var doc2 = new xDocument ();
        bn.serialize (doc2);
        Test.message ("XML2:\n"+doc2.to_string ());
        var element2 = doc2.document_element;
        var b2 = element2.get_attribute_node ("FloatValue");
        assert (b2 != null);
        assert (bn.float_value.get_value () == (float) 233.014);
        Test.message ("Value in xml: "+b2.value);
        Test.message ("Value in double class: "+bn.float_value.get_value ().to_string ());
        Test.message ("Value in xml formated %3.3f".printf (double.parse (b2.value)));
        Test.message ("%3.3f".printf (double.parse (b2.value)));
        assert ("%3.3f".printf (double.parse (b2.value)) == "233.014");
        assert (bn.float_value.format ("%3.3f") == "233.014");
        // set to -1
        bn.float_value.set_value ((float) (-1.013));
        var doc3 = new xDocument ();
        bn.serialize (doc3);
        Test.message ("XML3:\n"+doc3.to_string ());
        var element3 = doc3.document_element;
        var b3 = element3.get_attribute_node ("FloatValue");
        assert (b3 != null);
        assert ("%2.3f".printf (double.parse (b3.value)) == "-1.013");
        // set to NULL/IGNORE
        bn.float_value.set_serializable_property_value (null);
        var doc4= new xDocument ();
        bn.serialize (doc4);
        Test.message ("XML3:\n"+doc4.to_string ());
        var element4 = doc4.document_element;
        var b4 = element4.get_attribute_node ("FloatValue");
        assert (b4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
