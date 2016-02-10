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
  public class Values : SerializableValueList
  {
    construct {
      _vals = {"Val1","Val2"};
    }
    public void select (Enum v)
    {
      select_value_at ((int) v);
    }
    public string get_string () { return get_serializable_property_value (); }
    public void set_string (string str) { set_serializable_property_value (str); }
    public enum Enum
    {
      VAL1, VAL2
    }
  }
  public class ValueList : SerializableObjectModel
  {
    public SerializableValueList values { get; set; }
    public Values vals { get; set; }
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
        var doc = new GDocument ();
        vl.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.root as Element;
        var evl1 = element.get_attr ("values");
        assert (evl1 == null);
        var evl2 = element.get_attr ("vals");
        assert (evl2 == null);
        var s = element.get_attr ("name");
        assert (s == null);
        var i = element.get_attr ("integer");
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
        var doc1 = new GDocument ();
        vl.serialize (doc1);
        Test.message ("XML1:\n"+doc1.to_string ());
        var element1 = doc1.root as Element;
        var evl1 = element1.get_attr ("values");
        assert (evl1 == null);
        var s1 = element1.get_attr ("name");
        assert (s1 == null);
        var i1 = element1.get_attr ("integer");
        assert (i1.value == "0");
        // Adding values
        vl.values = new SerializableValueList ();
        var v = vl.values.get_value_at (0);
        assert (v == null);
        vl.values.add_values ({"Temp1","Temp2"});
        v = vl.values.get_value_at (0);
        assert (v == "Temp1");
        v = vl.values.get_value_at (1);
        assert (v == "Temp2");
        var doc2 = new GDocument ();
        vl.serialize (doc2);
        Test.message ("XML2:\n"+doc2.to_string ());
        var element2 = doc2.root as Element;
        var evl2 = element2.get_attr ("values");
        assert (evl2 == null);
        // Select a value
        vl.values.select_value_at (1);
        v = vl.values.get_serializable_property_value ();
        assert (v == "Temp2");
        var doc3 = new GDocument ();
        vl.serialize (doc3);
        Test.message ("XML3:\n"+doc3.to_string ());
        var element3 = doc3.root as Element;
        var evl3 = element3.get_attr ("values");
        assert (evl3 != null);
        assert (evl3.value == "Temp2");
        // Set value to null/ignore
        vl.values.set_serializable_property_value (null);
        var doc4 = new GDocument ();
        vl.serialize (doc4);
        Test.message ("XML4:\n"+doc4.to_string ());
        var element4 = doc4.root as Element;
        var evl4 = element4.get_attr ("values");
        assert (evl4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/ValueList/deserialize",
    () => {
      try {
        var doc1 = new GDocument.from_string ("""<?xml version="1.0"?>
                       <options values="Temp1"/>""");
        var vl = new ValueList ();
        vl.deserialize (doc1);
        assert (vl.values.get_serializable_property_value () == "Temp1");
        assert (vl.values.get_values_array () == null);
        assert (vl.values.is_value () == false);
        vl.values.add_values ({"Temp1"});
        assert (vl.values.get_values_array () != null);
        assert (vl.values.get_values_array ().length == 1);
        assert (vl.values.is_value () == true);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/ValueList/no-name",
    () => {
      try {
        var vl = new ValueList ();
        vl.values = new SerializableValueList ();
        var doc1 = new GDocument ();
        vl.serialize (doc1);
        Test.message ("XML1:\n"+doc1.to_string ());
        var element1 = doc1.root as Element;
        var evl1 = element1.get_attr ("values");
        assert (evl1 == null);
        var s1 = element1.get_attr ("name");
        assert (s1 == null);
        var i1 = element1.get_attr ("integer");
        assert (i1.value == "0");
        // Adding values
        var v = vl.values.get_value_at (0);
        assert (v == null);
        vl.values.add_values ({"Temp1","Temp2"});
        v = vl.values.get_value_at (0);
        assert (v == "Temp1");
        v = vl.values.get_value_at (1);
        assert (v == "Temp2");
        var doc2 = new GDocument ();
        vl.serialize (doc2);
        Test.message ("XML2:\n"+doc2.to_string ());
        var element2 = doc2.root as Element;
        var evl2 = element2.get_attr ("values");
        assert (evl2 == null);
        // Select a value
        vl.values.select_value_at (1);
        v = vl.values.get_serializable_property_value ();
        assert (v == "Temp2");
        var doc3 = new GDocument ();
        vl.serialize (doc3);
        Test.message ("XML3:\n"+doc3.to_string ());
        var element3 = doc3.root as Element;
        var evl3 = element3.get_attr ("values");
        assert (evl3 != null);
        assert (evl3.value == "Temp2");
        // Set value to null/ignore
        vl.values.set_serializable_property_value (null);
        var doc4 = new GDocument ();
        vl.serialize (doc4);
        Test.message ("XML4:\n"+doc4.to_string ());
        var element4 = doc4.root as Element;
        var evl4 = element4.get_attr ("values");
        assert (evl4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/ValueList/fixed/basic",
    () => {
      var v = new ValueList ();
      v.vals = new Values ();
      assert (v.vals != null);
      assert (v.vals.get_value_at (0) == "Val1");
      assert (v.vals.get_value_at (1) == "Val2");
      assert (v.vals.get_serializable_property_value () == null);
      v.vals.select_value_at (0);
      assert (v.vals.get_serializable_property_value () == "Val1");
      v.vals.select_value_at (1);
      assert (v.vals.get_serializable_property_value () == "Val2");
      v.vals.select_value_at (Values.Enum.VAL1);
      assert (v.vals.get_serializable_property_value () == "Val1");
      v.vals.select_value_at (Values.Enum.VAL2);
      assert (v.vals.get_serializable_property_value () == "Val2");
      v.vals.select (Values.Enum.VAL1);
      assert (v.vals.get_string () == "Val1");
      assert (v.vals.get_string () == "Val1");
      assert (v.vals.is_value ());
      v.vals.set_string ("K1");
      assert (v.vals.get_string () == "K1");
      assert (!v.vals.is_value ());
    });
    Test.add_func ("/gxml/serializable/ValueList/fixed/serialize",
    () => {
      try {
        var vl = new ValueList ();
        vl.vals = new Values ();
        vl.vals.select_value_at (Values.Enum.VAL1);
        var doc = new GDocument ();
        vl.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.root as Element;
        var s = element.get_attr ("name");
        assert (s == null);
        var i = element.attrs.get ("integer");
        assert (i.value == "0");
        var evl1 = element.attrs.get ("vals");
        assert (evl1 != null);
        assert (evl1.value != null);
        assert (evl1.value == "Val1");
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
