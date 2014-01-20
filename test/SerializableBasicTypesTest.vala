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
 *  Copyright (c) 2013-2014 Daniel Espinosa
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
class SerializableBasicTypeTest : GXmlTest {
  public class BasicType : SerializableObjectModel
  {
    public bool boolean { get; set; }
    public override string node_name () { return "basictype"; }
    public override string to_string () { return get_type ().name (); }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/basic_types/boolean",
    () => {
      try {
        var bt = new BasicType ();
        bt.boolean = true;
        var doc = new Document ();
        bt.serialize (doc);
        var element = doc.document_element;
        var b = element.get_attribute_node ("boolean");
        if (b == null) {
          stdout.printf (@"ERROR: No boolean exists\n");
          assert_not_reached ();
        }
        if (b.node_value.down () != "true") {
          stdout.printf (@"ERROR: Wrong boolean value. Expected true got: $(b.node_value.down ()) : $(b.node_value)\n");
          assert_not_reached ();
        }
        //stdout.printf (@"\n$doc\n");
      } catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/basic_types/boolean",
    () => {
      try {
        var bt = new BasicType ();
        bt.boolean = true;
        var doc = new Document.from_string ("""<?xml version="1.0"?>
<basictype boolean="true"/>""");
        bt.deserialize (doc);
        if (bt.boolean != true) {
          stdout.printf (@"ERROR: Wrong boolean value. Expected true got: $(bt.boolean)\n$doc\n");
          assert_not_reached ();
        }
        //stdout.printf (@"\n$doc\n");
      } catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
