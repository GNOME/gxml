/* -*- Mode: vala; indent-tabs-mode: nil; tab-width: 2 -*- */
/**
 *
 *  GXml.Serializable.BasicTypeTest
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
        var doc = new xDocument ();
        bn.serialize (doc);
        var element = doc.document_element;
        var b = element.get_attribute_node ("boolean");
        assert (b == null);
        var s = element.get_attribute_node ("name");
        assert (s == null);
        var i = element.get_attribute_node ("integer");
        assert (i.value == "0");
      } catch (GLib.Error e) {
        Test.message (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
