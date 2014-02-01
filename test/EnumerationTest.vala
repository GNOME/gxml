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
                     var doc = new Document ();
                     var options = new Options ();
                     options.options = OptionsEnum.NORMAL_OPERATION;
                     try {
                       options.serialize (doc);
                       if (doc.document_element == null)  {
                         stdout.printf (@"ERROR: No root node found");
                         assert_not_reached ();
                       }
                       if (doc.document_element.node_name != "options") {
                         stdout.printf (@"ERROR: bad root name:\n$(doc)");
                         assert_not_reached ();
                       }
                       Element element = doc.document_element;
                       var op = element.get_attribute_node ("options");
                       if (op == null) {
                         stdout.printf (@"ERROR: attribute options not found:\n$(doc)");
                         assert_not_reached ();
                       }
                       if (op.node_value != "NormalOperation") {
                         stdout.printf (@"ERROR: attribute options value invalid: $(op.node_value)\n$(doc)");
                         assert_not_reached ();
                       }
                       options.options = (OptionsEnum) (-1); // invaliding this property. Avoids serialize it.
                       var doc2 = new Document ();
                       options.serialize (doc2);
                       var opts = doc2.document_element.get_attribute_node ("options");
                       if (opts != null) {
                         stdout.printf (@"ERROR: attribute options must not be present:\n$(doc)");
                         assert_not_reached ();
                       }
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
                       var doc = new Document.from_string ("""<?xml version="1.0"?>
                       <options options="NormalOperation"/>""");
                       options.deserialize (doc);
                       if (options.options != OptionsEnum.NORMAL_OPERATION)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc)");
                         assert_not_reached ();
                       }
                       var doc2 = new Document.from_string ("""<?xml version="1.0"?>
                       <options options="normal-operation"/>""");
                       options.deserialize (doc2);
                       if (options.options != OptionsEnum.NORMAL_OPERATION)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc2)");
                         assert_not_reached ();
                       }
                       var doc3 = new Document.from_string ("""<?xml version="1.0"?>
                       <options options="selectbefore"/>""");
                       options.deserialize (doc3);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc3)");
                         assert_not_reached ();
                       }
                       var doc4 = new Document.from_string ("""<?xml version="1.0"?>
                       <options options="OPTIONS_ENUM_SelectBefore"/>""");
                       options.deserialize (doc4);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc4)");
                         assert_not_reached ();
                       }
                       var doc5 = new Document.from_string ("""<?xml version="1.0"?>
                       <options options="SelectBefore"/>""");
                       options.deserialize (doc5);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc5)");
                         assert_not_reached ();
                       }
                       var doc6 = new Document.from_string ("""<?xml version="1.0"?>
                       <options options="SELECTBEFORE"/>""");
                       options.deserialize (doc6);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc6)");
                         assert_not_reached ();
                       }
                       var doc7 = new Document.from_string ("""<?xml version="1.0"?>
                       <options options="NORMAL_OPERATION"/>""");
                       options.deserialize (doc7);
                       if (options.options != OptionsEnum.SelectBefore)  {
                         stdout.printf (@"ERROR: Bad value to options property: $(options.options)\n$(doc7)");
                         assert_not_reached ();
                       }
                       var op2 = new Options ();
                       var doc8 = new Document.from_string ("""<?xml version="1.0"?>
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
  }
}