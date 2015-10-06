/* -*- Mode: vala; indent-tabs-mode: nil; tab-width: 2 -*- */
/**
 *
 *  SerializablePropertyValueListTest.vala
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
class SerializablePropertyValueListTest : GXmlTest {
  public class ValueList : SerializableObjectModel
  {
    public SerializableValueList values { get; set; default = new SerializableValueList ("values"); }
    public int  integer { get; set; default = 0; }
    public string name { get; set; }
    public override string node_name () { return "ValueList"; }
    public override string to_string () { return get_type ().name (); }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/ValueList/basic",
    () => {
      try {
        var vl = new ValueList ();
        var doc = new xDocument ();
        vl.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var evl1 = element.get_attribute_node ("boolean");
        assert (evl1 == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
        var i = element.get_attribute_node ("integer");
        assert (i.value == "0");
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/ValueList/changes",
    () => {
      try {
        var vl = new ValueList ();
        var doc1 = new xDocument ();
        vl.serialize (doc1);
        Test.message ("XML1:\n"+doc1.to_string ());
        var element1 = doc1.document_element;
        var evl1 = element1.get_attribute_node ("values");
        assert (evl1 == null);
        var s1 = element1.get_attribute_node ("name");
        assert (s1 == null);
        var i1 = element1.get_attribute_node ("integer");
        assert (i1.value == "0");
        // Adding values
        var v = vl.values.get_value_at (0);
        assert (v == null);
        vl.values.add_values ({"Temp1","Temp2"});
        v = vl.values.get_value_at (0);
        assert (v == "Temp1");
        v = vl.values.get_value_at (1);
        assert (v == "Temp2");
        var doc2 = new xDocument ();
        vl.serialize (doc2);
        Test.message ("XML2:\n"+doc2.to_string ());
        var element2 = doc2.document_element;
        var evl2 = element2.get_attribute_node ("values");
        assert (evl2 == null);
        // Select a value
        vl.values.select_value_at (1);
        v = vl.values.get_serializable_property_value ();
        assert (v == "Temp2");
        var doc3 = new xDocument ();
        vl.serialize (doc3);
        Test.message ("XML3:\n"+doc3.to_string ());
        var element3 = doc3.document_element;
        var evl3 = element3.get_attribute_node ("values");
        assert (evl3 != null);
        assert (evl3.value == "Temp2");
        // Set value to null/ignore
        vl.values.set_serializable_property_value (null);
        var doc4 = new xDocument ();
        vl.serialize (doc4);
        Test.message ("XML4:\n"+doc4.to_string ());
        var element4 = doc4.document_element;
        var evl4 = element4.get_attribute_node ("values");
        assert (evl4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
