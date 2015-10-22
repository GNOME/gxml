/* -*- Mode: vala; indent-tabs-mode: nil; tab-width: 2 -*- */
/**
 *
 *  SerializablePropertyEnumTest.vala
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
class SerializablePropertyEnumTest : GXmlTest {
  public class Enum : SerializableEnum
  {
    construct {
      _enumtype = typeof (Enum.Values);
    }
    public Enum.Values get_value () throws GLib.Error { return (Enum.Values) to_integer (); }
    public void set_value (Enum.Values val) throws GLib.Error { parse_integer ((int) val); }
    public string get_string () throws GLib.Error { return get_serializable_property_value (); }
    public void set_string (string? str) throws GLib.Error { set_serializable_property_value (str); }
    public enum Values {
      SER_ONE,
      SER_TWO,
      SER_THREE,
      AP,
      SER_EXTENSION
    }
  }
  public class EnumerationValues : SerializableObjectModel
  {
    public Enum values { get; set; }
    [Description(nick="OptionalValues", blurb="Optional values")]
    public Enum optional_values { get; set; }
    public int  integer { get; set; default = 0; }
    public string name { get; set; }
    public override string node_name () { return "Enum"; }
    public override string to_string () { return get_type ().name (); }
    public override bool property_use_nick () { return true; }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/Enum/basic",
    () => {
      try {
        var e = new EnumerationValues ();
        var doc = new xDocument ();
        e.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var ee1 = element.get_attribute_node ("values");
        assert (ee1 == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
        var i = element.get_attribute_node ("integer");
        assert (i.value == "0");
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Enum/changes",
    () => {
      try {
        var e = new EnumerationValues ();
        var doc1 = new xDocument ();
        e.serialize (doc1);
        Test.message ("XML1:\n"+doc1.to_string ());
        var element1 = doc1.document_element;
        var ee1 = element1.get_attribute_node ("values");
        assert (ee1 == null);
        var s1 = element1.get_attribute_node ("name");
        assert (s1 == null);
        var i1 = element1.get_attribute_node ("integer");
        assert (i1.value == "0");
        // Getting value
        Enum.Values v = Enum.Values.SER_ONE;
        e.values = new Enum ();
        try { v = e.values.get_value (); }
        catch (GLib.Error e) {
          Test.message ("Error cough correctly: "+e.message);
        }
        e.values.set_value (Enum.Values.SER_THREE);
        assert (e.values.get_value () == Enum.Values.SER_THREE);
        Test.message ("Actual value= "+e.values.to_string ());
        assert (e.values.to_string () == "SerThree");
        var d2 = new xDocument ();
        e.serialize (d2);
        Test.message ("XML2:\n"+d2.to_string ());
        var element2 = d2.document_element;
        var ee2 = element2.get_attribute_node ("values");
        assert (ee2 != null);
        assert (ee2.value == "SerThree");
        e.values.set_value (Enum.Values.SER_TWO);
        assert (e.values.get_value () == Enum.Values.SER_TWO);
        Test.message ("Actual value= "+e.values.to_string ());
        assert (e.values.to_string () == "SerTwo");
        var d3 = new xDocument ();
        e.serialize (d3);
        Test.message ("XML3:\n"+d3.to_string ());
        var element3 = d3.document_element;
        var ee3 = element3.get_attribute_node ("values");
        assert (ee3 != null);
        assert (ee3.value == "SerTwo");
        // ignore
        e.values.set_string (null);
        var d4 = new xDocument ();
        e.serialize (d4);
        Test.message ("XML4:\n"+d4.to_string ());
        var element4 = d4.document_element;
        var ee4 = element4.get_attribute_node ("values");
        assert (ee4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Enum/string",
    () => {
      try {
        var e = new EnumerationValues ();
        e.values = new Enum ();
        e.values.set_string ("SERONE");
        assert (e.values.get_value () == Enum.Values.SER_ONE);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Enum/property_name",
    () => {
      try {
        var e = new EnumerationValues ();
        e.values = new Enum ();
        e.values.set_value (Enum.Values.AP);
        var d1 = new xDocument ();
        e.serialize (d1);
        Test.message ("XML1: "+d1.to_string ());
        var d2 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <Enum optionalvalues="SerExtension"/>""");
        e.deserialize (d2);
        assert (e.optional_values.get_value () == Enum.Values.SER_EXTENSION);
        var d3 = new xDocument ();
        e.serialize (d3);
        Test.message ("XML2: "+d3.to_string ());
        var d4 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <Enum OPTIONALVALUES="SERTHREE"/>""");
        e.deserialize (d4);
        assert (e.optional_values.get_value () == Enum.Values.SER_THREE);
        var d5 = new xDocument ();
        e.serialize (d5);
        Test.message ("XML3: "+d5.to_string ());
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
