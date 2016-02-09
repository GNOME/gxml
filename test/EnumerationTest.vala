/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/**
 *
 *  GXml.EnumerationTest
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
using Gee;

public enum OptionsEnum
{
  [Description (nick="SelectionOption")]
  SelectBefore,
  HoldOn,
  LeaveHeare,
  NORMAL_OPERATION
}

class Options : ObjectModel
{
  public string test { get; set; }
  public OptionsEnum options { get; set; }
  public Values vals { get; set; }
  public enum Values {
    AP,
    KP_VALUE,
    EXTERNAL_VALUE_VISION
  }
}
class SerializableEnumerationTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/enumeration",
                   () => {
                     var e = new Options ();
                     try {
                       e.test = "t1";
                       e.options = OptionsEnum.SelectBefore;
                       string s = Enumeration.get_string (typeof (OptionsEnum), e.options);
                       if (s != "OPTIONS_ENUM_SelectBefore") {
                         stdout.printf (@"ERROR: Bad Enum stringification: $(s)");
                         assert_not_reached ();
                       }
                       s = Enumeration.get_nick (typeof (OptionsEnum), e.options);
                       if (s != "selectbefore") {
                         stdout.printf (@"ERROR: Bad Enum nick name: $(s)");
                         assert_not_reached ();
                       }
                       s = Enumeration.get_nick (typeof (OptionsEnum),OptionsEnum.NORMAL_OPERATION);
                       if (s != "normal-operation") {
                         stdout.printf (@"ERROR: Bad Enum nick name: $(s)");
                         assert_not_reached ();
                       }
                       s = Enumeration.get_nick_camelcase (typeof (OptionsEnum),OptionsEnum.NORMAL_OPERATION);
                       if (s != "NormalOperation") {
                         stdout.printf (@"ERROR: Bad Enum nick name: $(s)");
                         assert_not_reached ();
                       }
                       try {
                         Enumeration.parse (typeof (OptionsEnum), "selectbefore");
                       }
                       catch (GLib.Error e) {
                         stdout.printf (@"ERROR PARSING selectbefore: $(e.message)");
                         assert_not_reached ();
                       }
                       try {
                         Enumeration.parse (typeof (OptionsEnum), "normal-operation");
                       }
                       catch (GLib.Error e) {
                         stdout.printf (@"ERROR PARSING normal-operation: $(e.message)");
                         assert_not_reached ();
                       }
                       try {
                         Enumeration.parse (typeof (OptionsEnum), "NormalOperation");
                       }
                       catch (GLib.Error e) {
                         stdout.printf (@"ERROR PARSING NormalOperation: $(e.message)");
                         assert_not_reached ();
                       }
                       var env = Enumeration.parse (typeof (OptionsEnum), "NormalOperation");
                       Value v = Value (typeof (int));
                       v.set_int (env.value);
                       e.options = (OptionsEnum) v.get_int ();
                       if (e.options != OptionsEnum.NORMAL_OPERATION) {
                         stdout.printf (@"ERROR: setting NormalOperation: $(e.options)");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/enumeration-serialize",
                   () => {
                     var doc = new xDocument ();
                     var options = new Options ();
                     options.options = OptionsEnum.NORMAL_OPERATION;
                     try {
                       Test.message ("Before serialize...");
                       options.serialize (doc);
                       Test.message ("doc: "+doc.to_string ()+" Root?"+(doc.root != null).to_string ());
                       assert (doc.root != null);
                       assert (doc.root.name == "options");
                       Element element = (Element) doc.root;
                       var op = element.get_attr ("options");
                       assert (op != null);
                       assert (op.value == "NormalOperation");
                       options.options = (OptionsEnum) (-1); // invaliding this property. Avoids serialize it.
                       var doc2 = new GDocument ();
                       assert (doc.root != null);
                       options.serialize (doc2);
                       var opts = (doc2.root as Element).get_attr ("options");
                       assert (opts == null);
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/enumeration-deserialize",
                   () => {
                     var options = new Options ();
                     try {
                       var doc = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="NormalOperation"/>""");
                       options.deserialize (doc);
                       if (options.options != OptionsEnum.NORMAL_OPERATION)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc)");
                         assert_not_reached ();
                       }
                       var doc2 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="normal-operation"/>""");
                       options.deserialize (doc2);
                       if (options.options != OptionsEnum.NORMAL_OPERATION)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc2)");
                         assert_not_reached ();
                       }
                       var doc3 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="selectbefore"/>""");
                       options.deserialize (doc3);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc3)");
                         assert_not_reached ();
                       }
                       var doc4 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="OPTIONS_ENUM_SelectBefore"/>""");
                       options.deserialize (doc4);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc4)");
                         assert_not_reached ();
                       }
                       var doc5 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="SelectBefore"/>""");
                       options.deserialize (doc5);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc5)");
                         assert_not_reached ();
                       }
                       var doc6 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="SELECTBEFORE"/>""");
                       options.deserialize (doc6);
                       assert (options.options == OptionsEnum.SelectBefore);
                       var doc7 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="NORMAL_OPERATION"/>""");
                       options.deserialize (doc7);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc7)");
                         assert_not_reached ();
                       }
                       var op2 = new Options ();
                       var doc8 = new xDocument.from_string ("""<?xml version="1.0"?>
                       <options options="INVALID"/>""");
                       op2.deserialize (doc8);
                       if (op2.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(op2.options)\n$(doc8)");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/enumeration/parse", () => {
      try {
        var v1 = Enumeration.parse (typeof (Options.Values), "AP");
        assert (v1.value == (int) Options.Values.AP);
        var v2 = Enumeration.parse (typeof (Options.Values), "Ap");
        assert (v2.value == (int) Options.Values.AP);
        var v3 = Enumeration.parse (typeof (Options.Values), "ap");
        assert (v3.value == (int) Options.Values.AP);
        var v4 = Enumeration.parse (typeof (Options.Values), "KPVALUE");
        assert (v4.value == (int) Options.Values.KP_VALUE);
        var v5 = Enumeration.parse (typeof (Options.Values), "KpValue");
        assert (v5.value == (int) Options.Values.KP_VALUE);
        var v6 = Enumeration.parse (typeof (Options.Values), "kpvalue");
        assert (v6.value == (int) Options.Values.KP_VALUE);
        var v7 = Enumeration.parse (typeof (Options.Values), "EXTERNALVALUEVISION");
        assert (v7.value == (int) Options.Values.EXTERNAL_VALUE_VISION);
        var v8 = Enumeration.parse (typeof (Options.Values), "ExternalValueVision");
        assert (v8.value == (int) Options.Values.EXTERNAL_VALUE_VISION);
        var v9 = Enumeration.parse (typeof (Options.Values), "externalvaluevision");
        assert (v9.value == (int) Options.Values.EXTERNAL_VALUE_VISION);
      } catch (GLib.Error e) {
        Test.message ("Parse error: "+e.message);
      }
    });
    Test.add_func ("/gxml/serializable/enumeration/to_string_array", () => {
      try {
        string[] options = Enumeration.to_string_array (typeof (Options.Values));
        assert (options != null);
        assert (options.length == 3);
        assert (options[0] == "Ap");
        assert (options[1] == "KpValue");
        assert (options[2] == "ExternalValueVision");
      } catch (GLib.Error e) {
        Test.message ("Parse error: "+e.message);
      }
    });
  }
}
