/* -*- Mode: vala; indent-tabs-mode: nil; tab-width: 2 -*- */
/**
 *
 *  SerializablePropertyIntTest.vala
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
class SerializablePropertyIntTest : GXmlTest {
  public class IntNode : SerializableObjectModel
  {
    [Description (nick="IntegerValue")]
    public SerializableInt  integer { get; set; default = new SerializableInt ("IntegerValue"); }
    public string name { get; set; }
    public override string node_name () { return "IntNode"; }
    public override string to_string () { return get_type ().name (); }
    public override bool property_use_nick () { return true; }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/Int/basic",
    () => {
      try {
        var bn = new IntNode ();
        var doc = new xDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var b = element.get_attribute_node ("IntegerValue");
        assert (b == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/Int/changes",
    () => {
      try {
        var bn = new IntNode ();
        var doc = new xDocument ();
        bn.serialize (doc);
        Test.message ("XML:\n"+doc.to_string ());
        var element = doc.document_element;
        var b = element.get_attribute_node ("IntegerValue");
        assert (b == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
        // Change values
        // set to 233
        bn.integer.set_value (233);
        var doc2 = new xDocument ();
        bn.serialize (doc2);
        Test.message ("XML2:\n"+doc2.to_string ());
        var element2 = doc2.document_element;
        var b2 = element2.get_attribute_node ("IntegerValue");
        assert (b2 != null);
        assert (b2.value == "233");
        // set to -1
        bn.integer.set_value (-1);
        var doc3 = new xDocument ();
        bn.serialize (doc3);
        Test.message ("XML3:\n"+doc3.to_string ());
        var element3 = doc3.document_element;
        var b3 = element3.get_attribute_node ("IntegerValue");
        assert (b3 != null);
        assert (b3.value == "-1");
        // set to NULL/IGNORE
        bn.integer.set_serializable_property_value (null);
        var doc4= new xDocument ();
        bn.serialize (doc4);
        Test.message ("XML3:\n"+doc4.to_string ());
        var element4 = doc4.document_element;
        var b4 = element4.get_attribute_node ("IntegerValue");
        assert (b4 == null);
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
