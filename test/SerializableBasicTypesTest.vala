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
class SerializableBasicTypeTest : GXmlTest {
  public class BasicType : SerializableObjectModel
  {
    public bool boolean { get; set; }
    public int  integer { get; set; default = 0; }
    public float  floatval { get; set; default = (float) 0.0; }
    public double  doubleval { get; set; default = 0.0; }
    public override string node_name () { return "basictype"; }
    public override string to_string () { return get_type ().name (); }
  }
  public static void add_tests () {
    Test.add_func ("/gxml/serializable/basic_types/boolean/serialize",
    () => {
      try {
        var bt = new BasicType ();
        bt.boolean = true;
        var doc = new GDocument ();
        bt.serialize (doc);
        var element = doc.root as Element;
        var b = element.get_attr ("boolean");
        if (b == null) {
          stdout.printf (@"ERROR: No boolean exists\n");
          assert_not_reached ();
        }
        if (b.value.down () != "true") {
          stdout.printf (@"ERROR: Wrong boolean value. Expected true got: $(b.value.down ()) : $(b.value)\n");
          assert_not_reached ();
        }
        //stdout.printf (@"\n$doc\n");
      } catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/basic_types/boolean/deserialize",
    () => {
      try {
        var bt = new BasicType ();
        bt.boolean = true;
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
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
    Test.add_func ("/gxml/serializable/basic_types/integer",
    () => {
      try {
        var bt = new BasicType ();
        bt.boolean = true;
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype integer="156"/>""");
        bt.deserialize (doc);
        assert (bt.integer == 156);
        var doc1 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype integer="a156"/>""");
        bt.deserialize (doc1);
        assert (bt.integer == 0);
        var doc2 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype integer="156b"/>""");
        bt.deserialize (doc2);
        assert (bt.integer == 156);
        var doc3 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype integer="156.0"/>""");
        bt.deserialize (doc3);
        assert (bt.integer == 156);
        var doc4 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype integer="0.156"/>""");
        bt.deserialize (doc4);
        assert (bt.integer == 0);
        var doc5 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype integer="a156.156"/>""");
        bt.deserialize (doc5);
        assert (bt.integer == 0);
        var doc6 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype integer="156.156b"/>""");
        bt.deserialize (doc6);
        assert (bt.integer == 156);
      } catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/basic_types/float",
    () => {
      try {
        var bt = new BasicType ();
        bt.boolean = true;
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype floatval="156"/>""");
        bt.deserialize (doc);
        assert (bt.floatval == 156.0);
        var doc1 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype floatval="a156"/>""");
        bt.deserialize (doc1);
        assert (bt.floatval == 0.0);
        var doc2 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype floatval="156b"/>""");
        bt.deserialize (doc2);
        assert (bt.floatval == 156.0);
        var doc3 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype floatval="156.0"/>""");
        bt.deserialize (doc3);
        assert (bt.floatval == 156.0);
        var doc4 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype floatval="0.156"/>""");
        bt.deserialize (doc4);
        assert (bt.floatval == (float) 0.156);
        var doc5 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype floatval="a156.156"/>""");
        bt.deserialize (doc5);
        assert (bt.floatval == 0.0);
        var doc6 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype floatval="156.156b"/>""");
        bt.deserialize (doc6);
        assert (bt.floatval == (float) 156.156);
        var doc7 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype boolean="true"/>""");
        bt.floatval = (float) 0.0;
        bt.deserialize (doc7);
        assert (bt.floatval == 0.0);
      } catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/basic_types/double",
    () => {
      try {
        var bt = new BasicType ();
        bt.boolean = true;
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype doubleval="156"/>""");
        bt.deserialize (doc);
        assert (bt.doubleval == 156.0);
        var doc1 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype doubleval="a156"/>""");
        bt.deserialize (doc1);
        assert (bt.doubleval == 0.0);
        var doc2 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype doubleval="156b"/>""");
        bt.deserialize (doc2);
        assert (bt.doubleval == 156.0);
        var doc3 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype doubleval="156.0"/>""");
        bt.deserialize (doc3);
        assert (bt.doubleval == 156.0);
        var doc4 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype doubleval="0.156"/>""");
        bt.deserialize (doc4);
        assert (bt.doubleval == 0.156);
        var doc5 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype doubleval="a156.156"/>""");
        bt.deserialize (doc5);
        assert (bt.doubleval == 0.0);
        var doc6 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype doubleval="156.156b"/>""");
        bt.deserialize (doc6);
        assert (bt.doubleval == 156.156);
        var doc7 = new GDocument.from_string ("""<?xml version="1.0"?>
<basictype boolean="true"/>""");
        bt.doubleval = 0.0;
        bt.deserialize (doc7);
        assert (bt.doubleval == 0.0);
      } catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
