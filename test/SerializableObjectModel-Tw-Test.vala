/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/**
 *
 *  GXml.EnumerationTest.vala
 *
 *  Authors:
 *
 *       Daniel Espinosa <esodan@gmail.com>
 *
 *
 *  Copyright (c) 2014-2015 Daniel Espinosa
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
class SerializableObjectModelTwTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/tw/serializable/object_model/serialize/simple_object",
                   () => {
                     try {
                       var computer = new Computer ();
                       var doc = new TwDocument ();
                       computer.serialize (doc);
                       assert (doc.root.name.down () == "computer") ;
                       var m = doc.root.attrs.get ("manufacturer");
                       assert (m != null);
                       var mod = doc.root.attrs.get ("model");
                       assert (mod != null);
                       var c = doc.root.attrs.get ("cores");
                       assert (c != null);
                       var g = doc.root.attrs.get ("ghz");
                       assert (g != null);
                     }
                     catch (GLib.Error e) 
                     {
                       GLib.message (e.message);
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_simple_object",
                   () => {
                     var computer = new Computer ();
                     try {
                       var doc = new xDocument.from_string (XML_COMPUTER_FILE);
                       computer.deserialize (doc);
                       if (computer.manufacturer != "ThecnicalGroup") {
                         stdout.printf (@"ERROR XML_COMPUTER: manufacturer val: $(computer.manufacturer)\n");
                         assert_not_reached ();
                       }
                       if (computer.model !="YH576G") {
                         stdout.printf (@"ERROR XML_COMPUTER: model val: $(computer.model)\n");
                         assert_not_reached ();
                       }
                       if (computer.cores != 4) {
                         stdout.printf (@"ERROR XML_COMPUTER: cores val: $(computer.cores)\n");
                         assert_not_reached ();
                       }
                       if (computer.ghz != (float) 2.8) {
                         stdout.printf (@"ERROR XML_COMPUTER: ghz val: $(computer.ghz)\n");
                         assert_not_reached ();
                       }
                     } catch (GLib.Error e)
                     {
                       GLib.message (@"GHz : $(computer.to_string ()) ERROR: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_object_contents",
                   () => {
                     var manual = new Manual ();
                     try {
                       var doc = new xDocument.from_string ("""<?xml version="1.0"?>
                       <manual document="Specification" pages="3">This is an Specification file</manual>""");
                       manual.deserialize (doc);
                       if (manual.document != "Specification") {
                         stdout.printf (@"ERROR MANUAL:  Bad document value. Expected 'Specification', got: $(manual.document)\n");
                         assert_not_reached ();
                       }
                       if (manual.pages != 3) {
                         stdout.printf (@"ERROR MANUAL:  Bad pages value. Expected '3', got: $(manual.pages)\n");
                         assert_not_reached ();
                       }
                       if (manual.get_contents () != "This is an Specification file") {
                         stdout.printf (@"ERROR MANUAL:  Bad xElement content value. Expected 'This is an Specification file', got: $(manual.get_contents ())\n");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       GLib.message (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_object_contents",
                   () => {
                     var doc = new xDocument ();
                     var manual = new Manual ();
                     try {
                       manual.serialize (doc);
                       if (doc.document_element.node_name != "manual") {
                         stdout.printf (@"ERROR MANUAL:  xElement: $(doc.document_element.node_name)\n");
                         assert_not_reached ();
                       }
                       xElement element = doc.document_element;
                       serialize_manual_check (element, manual);
                     } catch (GLib.Error e) {
                       stdout.printf (@"$(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_serializable_properties",
                   () => {
                     var package = new Package ();
                     try {
                       var doc = new xDocument.from_string (XML_PACKAGE_FILE);
                       package.deserialize (doc);
                       if (package.source != "Mexico/Central") {
                         stdout.printf (@"ERROR PACKAGE: source: $(package.source)\n");
                         assert_not_reached ();
                       }
                       if (package.destiny != "Japan") {
                         stdout.printf (@"ERROR PACKAGE: destiny: $(package.destiny)\n");
                         assert_not_reached ();
                       }
                       /*if (package.unknown_to_string () != "Unknown Properties: {\n}") {
                         stdout.printf (@"ERROR PACKAGE: package unknown properties: $(package.unknown_to_string ())\n");
    assert_not_reached ();
                     }*/
                       if (package.manual.document != "Specification") {
                         stdout.printf (@"ERROR PACKAGE: manual document: $(package.manual.document)\n");
                         assert_not_reached ();
                       }
                       if (package.manual.pages != 3) {
                         stdout.printf (@"ERROR PACKAGE: manual pages: $(package.manual.pages)\n");
                         assert_not_reached ();
                       }
                       if (package.manual.get_contents () != "This is an Specification file") {
                         stdout.printf (@"ERROR PACKAGE: manual value: $(package.manual.get_contents ())\n");
                         assert_not_reached ();
                       }
                       if (package.computer.manufacturer != "LanCorop") {
                         stdout.printf (@"ERROR PACKAGE: computer manufacturer: $(package.computer.manufacturer)\n");
                         assert_not_reached ();
                       }
                       if (package.computer.model != "Lap39120") {
                         stdout.printf (@"ERROR PACKAGE: computer model: $(package.computer.model)\n");
                         assert_not_reached ();
                       }
                       if (package.computer.cores != 16) {
                         stdout.printf (@"ERROR PACKAGE: computer cores: $(package.computer.cores)\n");
                         assert_not_reached ();
                       }
                       if (package.computer.ghz != (float) 3.5) {
                         stdout.printf (@"ERROR PACKAGE: computer ghz $(package.computer.ghz)\n");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       GLib.message (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_serializable_properties",
                   () => {
                     var doc = new xDocument ();
                     var package = new Package ();
                     try {
                       package.serialize (doc);
                       if (doc.document_element.node_name != "package") {
                         stdout.printf (@"ERROR MANUAL:  xElement: $(doc.document_element.node_name)\n");
                         assert_not_reached ();
                       }
                       xElement element = doc.document_element;
                       var source = element.get_attribute_node ("source");
                       if (source == null ) assert_not_reached ();
                       if (source.node_value != "Mexico") {
                         stdout.printf (@"ERROR PACKAGE: source: $(source.node_value)\n");
                         assert_not_reached ();
                       }
                       var destiny = element.get_attribute_node ("destiny");
                       if (destiny == null ) assert_not_reached ();
                       if (destiny.node_value != "World") {
                         stdout.printf (@"ERROR PACKAGE: source: $(destiny.node_value)\n");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       GLib.message (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_array_property",
                   () => {
                     var doc = new xDocument.from_string (XML_PACKAGE_FILE);
                     var package = new Package ();
                     try {
                       package.deserialize (doc);
                       if (package.tags.length != 3) {
                         stdout.printf (@"ERROR PACKAGE: tags length: $(package.tags.length)");
                         assert_not_reached ();
                       }
                       if (package.tags.index (0) != "Printer") {
                         stdout.printf (@"ERROR PACKAGE: tags index 0: $(package.tags.index (0))");
                         assert_not_reached ();
                       }
                       if (package.tags.index (1) != "Partner") {
                         stdout.printf (@"ERROR PACKAGE: tags index 1: $(package.tags.index (1))");
                         assert_not_reached ();
                       }
                       if (package.tags.index (2) != "Support") {
                         stdout.printf (@"ERROR PACKAGE: tags index 0: $(package.tags.index (2))");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       GLib.message (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_array_property",
                   () => {
                     var doc = new xDocument ();
                     var package = new Package ();
                     package.tags.append_val ("Computer");
                     package.tags.append_val ("Customer");
                     package.tags.append_val ("Sale");
                     try {
                       package.serialize (doc);
                       //stdout.printf (@"$(doc)");
                       if (doc.document_element.node_name != "package")
                         assert_not_reached ();
                       xElement element = doc.document_element;
                       bool com = false;
                       bool cus = false;
                       bool sal = false;
                       foreach (GXml.xNode n in element.child_nodes) {
                         //stdout.printf (@"Found xElement: $(n.node_name)");
                         if (n.node_name == "tag") {
                           //stdout.printf (@"Found: $(n.node_name)");
                           if (((xElement) n).content == "Computer")
                             com = true;
                           if (((xElement) n).content == "Customer")
                             cus = true;
                           if (((xElement) n).content == "Sale")
                             sal = true;
                         }
                       }
                       if (!com) {
                         stdout.printf (@"ERROR PACKAGE tag Computer not found!");
                         assert_not_reached ();
                       }
                       if (!cus) {
                         stdout.printf (@"ERROR PACKAGE tag Customer not found!");
                         assert_not_reached ();
                       }
                       if (!sal) {
                         stdout.printf (@"ERROR PACKAGE tag Sale not found!");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       GLib.message (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_property_nick",
                   () => {
                     var doc = new xDocument ();
                     var monitor = new Monitor ();
                     try {
                       monitor.resolution = "1204x720";
                       monitor.ac_power = 120;
                       monitor.dc_power = 125;
                       monitor.serialize (doc);
                       //stdout.printf (@"DOC: [$(doc)]");
                       if (doc.document_element == null) {
                         stdout.printf ("ERROR MONITOR: No root xElement");
                         assert_not_reached ();
                       }
                       xElement element = doc.document_element;
                       if (element.node_name != "monitor") {
                         stdout.printf (@"ERROR MONITOR: root xElement $(element.node_name)");
                         assert_not_reached ();
                       }
                       var ac = element.get_attribute_node ("AcPower");
                       if (ac == null) {
                         stdout.printf (@"ERROR MONITOR: attribute AcPower not found");
                         assert_not_reached ();
                       }
                       if (ac.node_value != "120") {
                         stdout.printf (@"ERROR MONITOR: AcPower value $(ac.node_value)");
                         assert_not_reached ();
                       }
                       var dc = element.get_attribute_node ("DcPower");
                       if (dc == null) {
                         stdout.printf (@"ERROR MONITOR: attribute DcPower not found");
                         assert_not_reached ();
                       }
                       if (dc.node_value != "125") {
                         stdout.printf (@"ERROR MONITOR: AcPower value $(dc.node_value)");
                         assert_not_reached ();
                       }
                       var r = element.get_attribute_node ("resolution");
                       if (r == null) {
                         stdout.printf (@"ERROR MONITOR: attribute resolution not found");
                         assert_not_reached ();
                       }
                       if (r.node_value != "1204x720") {
                         stdout.printf (@"ERROR MONITOR: resolution value $(r.node_value)");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/tw/serializable/object_model/override_transform_to_string",
                   () => {
                     var cpu = new Cpu ();
                     cpu.ghz = (float) 3.85;
                     cpu.piles.add (1);
                     cpu.piles.add (2);
                     cpu.piles.add (3);
                     var doc = new xDocument ();
                     try {
                       cpu.serialize (doc);
                       //stdout.printf (@"$doc");
                       if (doc.document_element == null) {
                         stdout.printf (@"ERROR CPU: no root element");
                         assert_not_reached ();
                       }
                       if (doc.document_element.node_name != "cpu") {
                         stdout.printf (@"ERROR CPU: root element $(doc.document_element.node_name)");
                         assert_not_reached ();
                       }
                       var ghz = doc.document_element.get_attribute_node ("ghz");
                       if (ghz == null) {
                         stdout.printf (@"ERROR CPU: no attribute ghz");
                         assert_not_reached ();
                       }
                       if (ghz.node_value != "3.85") {
                         stdout.printf (@"ERROR CPU: ghz '$(ghz.node_value)'");
                         assert_not_reached ();
                       }
                       var p = doc.document_element.get_attribute_node ("piles");
                       if (p == null) {
                         stdout.printf (@"ERROR CPU: no attribute piles");
                         assert_not_reached ();
                       }
                       if (p.node_value != "1,2,3") {
                         stdout.printf (@"ERROR CPU: piles '$(p.node_value)'");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/override_transform_from_string",
                   () => {
                     var cpu = new Cpu ();
                     var doc = new xDocument.from_string (XML_CPU_FILE);
                     try {
                       cpu.deserialize (doc);
                       //stdout.printf (@"$doc");
                       if (cpu.ghz != (float) 3.85) {
                         stdout.printf (@"ERROR CPU: ghz '$(cpu.ghz)'");
                         assert_not_reached ();
                       }
                       if (cpu.piles.size != 3) {
                         stdout.printf (@"ERROR CPU: piles size '$(cpu.piles.size)'");
                         assert_not_reached ();
                       }
                       if (!cpu.piles.contains (1)) {
                         stdout.printf (@"ERROR CPU: piles contains 1 '$(cpu.piles_to_string ())'");
                         assert_not_reached ();
                       }
                       if (!cpu.piles.contains (2)) {
                         stdout.printf (@"ERROR CPU: piles contains 2 '$(cpu.piles_to_string ())'");
                         assert_not_reached ();
                       }
                       if (!cpu.piles.contains (3)) {
                         stdout.printf (@"ERROR CPU: piles contains 3 '$(cpu.piles_to_string ())'");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/override_serialize",
                   () => {
                     var doc = new xDocument ();
                     var configuration = new Configuration ();
                     configuration.device = "Controller";
                     try {
                       configuration.serialize (doc);
                       //stdout.printf (@"DOC: $doc");
                       if (doc.document_element == null) {
#if DEBUG
                         GLib.message ("DOC: No root element");
#endif
                         assert_not_reached ();
                       }
                       GXml.Element element = (GXml.Element) doc.root;
                       if (element.name != "Configuration") {
#if DEBUG
                         GLib.message (@"CONFIGURATION: Bad node name: $(element.name)");
#endif
                         assert_not_reached ();
                       }
                       bool found = false;
                       foreach (GXml.Namespace n in element.namespaces)
                       {
                         if (n.prefix == "om" && n.uri == "http://www.gnome.org/gxml/0.4")
                           found = true;
                       }
                       if (!found) {
#if DEBUG
                         stdout.printf (@"CONFIGURATION: No namespace found: size: $(element.namespaces.size)");
                         foreach (GXml.Namespace n in element.namespaces) {
                           stdout.printf (@"CONFIGURATION: Defined Namespace: $(n.prefix):$(n.uri)");
                         }
#endif
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/override_deserialize",
                   () => {
                     var doc = new xDocument.from_string ("""<?xml version="1.0"?>
                     <Configuration xmlns:om="http://www.gnome.org/gxml/0.4" device="Sampler"/>""");
                     var configuration = new Configuration ();
                     try {
#if DEBUG
                       GLib.message ("Deserializing doc...");
#endif
                       configuration.deserialize (doc);
#if DEBUG
                       GLib.message ("Verifing Configuration...");
#endif
                       if (configuration.invalid == true) {
#if DEBUG
                         stdout.printf ("CONFIGURATION: deserialize is INVALID\n");
                         foreach (GXml.Namespace n in doc.document_element.namespace_definitions) {
                           stdout.printf (@"CONFIGURATION: namespace: $(n.uri)\n");
                         }
#endif
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/custome_node_name",
                   () => {
                     var doc = new xDocument.from_string ("""<?xml version="1.0"?><NodeName />""");
                     var nodename = new NodeName ();
                     try {
                       nodename.deserialize (doc);
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/no_serialize_null_property",
                   () => {
                     var doc = new xDocument();
                     var unknown_property = new UnknownAttribute (); // name is set to null
                     try {
                       unknown_property.serialize (doc);
                       //stdout.printf (@"DOCUMENT: $doc"); assert_not_reached ();
                       var name = doc.document_element.get_attribute_node ("name");
                       if (name != null) {
                         stdout.printf (@"ERROR: NULL ATTRIBUTE SERIALIZATION: name found $(name.node_name)");
                         assert_not_reached ();
                       }
                       var array = doc.document_element.get_attribute_node ("array");
                       if (array != null) {
                         stdout.printf (@"ERROR: NULL ATTRIBUTE SERIALIZATION: array found $(array.node_name)");
                         assert_not_reached ();
                       }
                       if (doc.document_element.has_child_nodes ()) {
                         stdout.printf (@"ERROR: NULL ATTRIBUTE SERIALIZATION: Nodes found $(doc.document_element.has_child_nodes ())");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/unknown_property",
                   () => {
                     var doc = new xDocument.from_string ("""<?xml version="1.0"?>
                     <UnknownAttribute ignore="true" ignore2="test">
                     <UnknownNode toignore = "true" />TEXT
                     </UnknownAttribute>""");
                     var unknown_property = new UnknownAttribute ();
                     try {
                       unknown_property.deserialize (doc);
#if DEBUG
                       foreach (GXml.Attribute a in unknown_property.unknown_serializable_properties.values) {
                         GLib.message (@"Unknown Attribute: $(a.name) = $(a.value)");
                       }
                       foreach (GXml.Node un in unknown_property.unknown_serializable_nodes) {
                         GLib.message (@"Unknown Node: $(un.name) = $(un.to_string ())");
                       }
#endif
                       assert (unknown_property.unknown_serializable_properties.size == 2);
                       if (unknown_property.unknown_serializable_properties.size != 2) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: size $(unknown_property.unknown_serializable_properties.size.to_string ())\n");
                         foreach (GXml.Node un in unknown_property.unknown_serializable_properties.values) {
                           string sv = "__NULL__";
                           if (un.value != null)
                             sv = un.value;
                           stdout.printf (@"Saved unknown property: $(un.name) / '$(sv)'\n");
                         }
                         assert_not_reached ();
                       }
                       var ignore = unknown_property.unknown_serializable_properties.get ("ignore");
                       assert (ignore != null);
                       var ignore2 = unknown_property.unknown_serializable_properties.get ("ignore2");
                       assert (ignore2 != null);
#if DEBUG
                       GLib.message (@"Unknown nodes = $(unknown_property.unknown_serializable_nodes.size)");
#endif
                       assert (unknown_property.unknown_serializable_nodes.size == 2);
                       bool foundn = false;
                       bool foundt = false;
                       GXml.Node unkn;
                       foreach (GXml.Node n in unknown_property.unknown_serializable_nodes) {
                         if (n.name == "UnknownNode") {
                           foundn = true;
                           assert (n.attrs.get ("toignore") != null);
                           assert (n.attrs.get ("toignore").value == "true");
                         }
                         if (n is Text) {
                           foundt = true;
                           assert (n.value == "TEXT");
                         }
                       }
                       assert (foundn);
                       assert (foundt);
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_unknown_property",
                   () => {
                     var doc = new xDocument.from_string ("""<?xml version="1.0"?>
                     <UnknownAttribute ignore="true" ignore2="test">
                      <UnknownNode direction = "fordward">
                       <UnknownChild t = "test">
                        <UnknownChildTwo t = "test">SECOND FAKE TEXT</UnknownChildTwo>
                       </UnknownChild>
                     </UnknownNode>FAKE TEXT</UnknownAttribute>""");
                     var unknown_property = new UnknownAttribute ();
                     try {
                       unknown_property.deserialize (doc);
                       var doc2 = (GXml.Document) new xDocument ();
#if DEBUG
                       GLib.message ("Prepare to Serialize...");
#endif
                       unknown_property.serialize (doc2);
                       GLib.message ("After Serialize...");
#if DEBUG
                       GLib.message ("Serialized back document: \n"+doc2.to_string ());
#endif
                       if (doc2.root == null) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No Root xElement");
                         assert_not_reached ();
                       }
                       GXml.Element element = (GXml.Element) doc2.root;
                       if (element.name.down () != "unknownattribute") {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Root xElement Bad name $(element.name.down ())");
                         assert_not_reached ();
                       }
                       var ignore = element.attrs.get ("ignore");
                       if (ignore == null) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No attribute ignore");
                         assert_not_reached ();
                       }
                       if (ignore.value != "true") {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Attribute ignore bad value $(ignore.value)");
                         assert_not_reached ();
                       }
                       var ignore2 = element.attrs.get ("ignore2");
                       if (ignore2 == null) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No attribute ignore");
                         assert_not_reached ();
                       }
                       if (ignore2.value != "test") {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Attribute ignore2 bad value $(ignore2.value)");
                         assert_not_reached ();
                       }
                       if (element.childs.size == 0) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No child nodes");
                         assert_not_reached ();
                       }
                       assert (element.childs.size == 2);
                       var unkn = element.childs.get (0);
                       assert (unkn != null);
                       assert (unkn.name == "UnknownNode");
                       int countechilds = 0;
                       GXml.Node child = unkn;
                       foreach (GXml.Node n in unkn.childs) {
                         if (n is GXml.Element) countechilds++;
                         if (n.name == "UnknownChild") child = n;
                       }
                       assert (countechilds == 1);
                       var cunkn = child;
                       assert (cunkn != null);
                       assert (cunkn.name == "UnknownChild");
                       assert (cunkn.attrs.size == 1);
                       var ca = cunkn.attrs.get ("t");
                       assert (ca != null);
                       assert (ca.value == "test");
                       countechilds = 0;
                       foreach (GXml.Node cn in cunkn.childs) {
                         if (cn is GXml.Element) countechilds++;
                         if (cn.name == "UnknownChildTwo") child = cn;
                       }
                       assert (countechilds == 1);
                       var scunkn = child;
                       assert (scunkn != null);
                       assert (scunkn.name == "UnknownChildTwo");
                       var sca = scunkn.attrs.get ("t");
                       assert (sca != null);
                       assert (sca.value == "test");
                       bool found = false;
#if DEBUG
                       GLib.message (@"Second unknown child. Childs nodes = $(scunkn.childs.size)");
#endif
                       foreach (GXml.Node tn in scunkn.childs) {
                         assert (tn is GXml.Text);
#if DEBUG
                       GLib.message (@"Second unknown Text child = $(tn.value)");
#endif
                         if (tn.value == "SECOND FAKE TEXT") found = true;
                       }
                       assert (found);
                       var tscunkn = cunkn.childs.get (0);
                       assert (tscunkn is GXml.Text);
                       assert (element.content == "FAKE TEXT");
                       found = false;
                       foreach (GXml.Node n in element.childs) {
                         if (n.name == "UnknownNode") {
                           found = true;
                           var direction = ((Element) n).attrs.get ("direction");
                           if (direction == null)  {
                             stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: UnknownNode No attribute direction");
                             assert_not_reached ();
                           }
                           if (direction.value != "fordward") {
                             stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: UnknownNode attribute direction bad value $(direction.value)");
                             assert_not_reached ();
                           }
                         }
                       }
                       if (!found) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: UnknownNode No not found");
                         assert_not_reached ();
                       }
                       // TODO: serialized_xml_node_value have more text than expected, may be a bug in xDocument.to_string ()
                       if (unknown_property.serialized_xml_node_value == "FAKE TEXT") {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Bad UnknownAttribute node's content text $(unknown_property.serialized_xml_node_value)");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_unknown_property",
                   () => {
                     try {
                       var doc = new xDocument.from_string ("""<?xml version="1.0"?>
                     <UnknownAttribute ignore="true" ignore2="test">
                     <UnknownNode toignore = "true" />TEXT
                     </UnknownAttribute>""");
                        var unknown_property = new UnknownAttribute ();
                       unknown_property.deserialize (doc);
                       var ndoc = new xDocument ();
                       unknown_property.serialize (ndoc);
                       if (ndoc.document_element.child_nodes.size != 2) {
                         stdout.printf (@"ERROR: Root incorrect child node number: found '$(doc.document_element.childs.size)\n");
                         foreach (GXml.xNode rn in ndoc.document_element.child_nodes) {
                           string nv = "__NULL__";
                           if (rn.node_value != null)
                             nv = rn.node_value;
                           stdout.printf (@"Node: $(rn.node_name) / Value: '$(nv)'\n");
                         }
                         stdout.printf (@"$(ndoc)\n");
                         assert_not_reached ();
                       }
                       foreach (GXml.xNode n in ndoc.document_element.child_nodes) {
                         if (n is Text) {
                           if (n.node_value != "TEXT") {
                             stdout.printf (@"ERROR: Unknown Text xElement not set: found '$(n.node_value)\n");
                             assert_not_reached ();
                           }
                         }
                       }
                     } catch (GLib.Error e) {
                       stdout.printf (@"ERROR: $(e.message)\n");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_incorrect_uint",
                   () => {
                     try {
                       var doc = new xDocument.from_string (
                            """<?xml version="1.0"?>
                            <PACKAGE source="Mexico/North" destiny="Brazil" Hope="2/4.04">
                            <manual document="Sales Card" pages="1">Selling Card Specification</manual>
                            <Computer manufacturer="BoxingLAN" model="J24-EX9" cores="32.5" ghz="1.8" quantity="0.2" />
                            <Box size="1" volume="33.15" units="cm3" />
                            </PACKAGE>""");
                       Test.message (@"XML:\n$(doc)");
                       var pkg = new Package ();
                       pkg.deserialize (doc);
                     }
                     catch (GLib.Error e) {
                       Test.message ("Error thrown for invalid string to guint");
                       assert_not_reached ();
                     }
                   });
    
    Test.add_func ("/gxml/tw/serializable/object_model/set_namespace", () => {
      try {
        var ns = new NameSpace ();
        var doc = new xDocument ();
        ns.serialize (doc);
        assert (doc.document_element.to_string () == "<gxml:namespace xmlns:gxml=\"http://www.gnome.org/GXml\"/>");
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
  Test.add_func ("/gxml/tw/serializable/object_model/find-unknown_property", () => {
      try {
        var p = new Package ();
        var doc = new xDocument.from_string ("""<?xml version="1.0"?>
<PACKAGE source="Mexico/North" destiny="Brazil" Unknown="2/4.04">
<manual document="Sales Card" pages="1">Selling Card Specification</manual>
<Computer manufacturer="BoxingLAN" model="J24-EX9" cores="32" ghz="1.8"/>
<Box size="1" volume="33.15" units="cm3" />
UNKNOWN CONTENT
</PACKAGE>""");
        p.deserialize (doc);
        assert (p.unknown_serializable_properties != null);
        var ukattr = p.unknown_serializable_properties.get ("Unknown");
        assert (ukattr != null);
        assert (ukattr.name == "Unknown");
        assert (ukattr.value == "2/4.04");
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
  }
  static void serialize_manual_check (xElement element, Manual manual)
  {
    var document = element.get_attribute_node ("document");
    if (document == null) assert_not_reached ();
    if (document.node_value != manual.document) {
      stdout.printf (@"ERROR MANUAL:  document: $(document.node_value)\n");
      assert_not_reached ();
    }
    var pages = element.get_attribute_node ("pages");
    if (pages == null) assert_not_reached ();
    if (int.parse (pages.node_value) != manual.pages) {
      stdout.printf (@"ERROR MANUAL: pages: $(pages.node_value)\n");
      assert_not_reached ();
    }
    if (element.content != manual.get_contents ()) {
      stdout.printf (@"ERROR MANUAL: content: Expected $(manual.get_contents ()): got: $(element.content)\n");
      assert_not_reached ();
    }
  }
}
