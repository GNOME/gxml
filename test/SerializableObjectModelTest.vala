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
 *  Copyright (c) 2014 Daniel Espinosa
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
const string XML_COMPUTER_FILE = 
"""<?xml version="1.0"?>
<computer manufacturer="ThecnicalGroup" model="YH576G" cores="4" ghz="2.8"/>""";

const string SERIALIZED_XML_COMPUTER_FILE = 
"""<?xml version="1.0"?><computer manufacturer="MexicanLaptop, Inc." model="LQ59678" cores="8" ghz="3.5"/>""";

const string XML_PACKAGE_FILE =
"""<?xml version="1.0"?>
<PACKAGE source="Mexico/Central" destiny="Japan">
<manual document="Specification" pages="3">This is an Specification file</manual>
<Computer manufacturer="LanCorop" model="Lap39120" cores="16" ghz="3.5"/>
<tag>Printer</tag><tag>Partner</tag><tag>Support</tag>
</PACKAGE>""";

const string XML_PACKAGE_UNKNOWN_NODES_FILE =
"""<?xml version="1.0"?>
<PACKAGE source="Mexico/North" destiny="Brazil" Hope="2/4.04">
<manual document="Sales Card" pages="1">Selling Card Specification</manual>
<Computer manufacturer="BoxingLAN" model="J24-EX9" cores="32" ghz="1.8"/>
<Box size="1" volume="33.15" units="cm3" />
</PACKAGE>""";

const string XML_CPU_FILE =
"""<?xml version="1.0"?>
<cpu ghz="3.85" piles="1,2,3"/>""";
public class ObjectModel : SerializableObjectModel
{
  public override string to_string ()
  {
    var lp = list_serializable_properties ();
    string ret = this.get_type ().name () +"{Properties:\n";
    foreach (ParamSpec p in lp) {
      Value v = Value (p.value_type);
      get_property_value (p, ref v);
      string t;
      try { t = gvalue_to_string (v); } catch { t = "[CANT_TRANSFORM]"; }
      ret += @"[$(p.name)]{" + t + "}\n";
    }
    return ret + "}";
  }
}
public class Computer : ObjectModel
{
  [Description (nick="Manufacturer")]
  public string manufacturer { get; set; }
  public string model { get; set; }
  public int cores { get; set; }
  public float ghz { get; set; }
  public uint quantity { get; set; }

  public Computer ()
  {
    manufacturer = "MexicanLaptop, Inc.";
    model = "LQ59678";
    cores = 8;
    ghz = (float) 3.5;
  }
}

public class Manual : ObjectModel
{
  public string document { get; set; }
  public int pages { get; set; }
  public string get_contents () { return serialized_xml_node_value; }
  public void set_contents (string val) { serialized_xml_node_value = val; }

  public Manual ()
  {
    document = "MANUAL DOCUMENTATION";
    pages = 3;
    set_contents ("TEXT INTO THE MANUAL DOCUMENT");
  }

  public override string to_string ()
  {
    return base.to_string () + @"CONTENTS: { $(get_contents ())}";
  }
  public override bool serialize_use_xml_node_value () { return true; }
}

public class Package : ObjectModel
{
  Array<string> _tags = new Array<string> ();
  public Computer computer { get; set; }
  public Manual manual { get; set; }
  public string source { get; set; }
  public string destiny { get; set; }
  [Description (nick="tag", blurb="tags in package")]
  public Array<string> tags { get {return _tags;} }

  public override bool property_use_nick () { return true; }
  public override bool get_enable_unknown_serializable_property () { return true; }

  public Package ()
  {
    computer = new Computer ();
    manual = new Manual ();
    source = "Mexico";
    destiny = "World";
    ((Serializable) this).serialize_unknown_property.connect ( (element, prop, out node) => {
      //GLib.message (@"Serializing Unknown Property: $(prop.name) | $(prop.get_nick ())");
      if (prop.name == "tags")
      {
        for (int i = 0; i < tags.length; i++) {
          var str = tags.index (i);
          node = element.owner_document.create_element ("tag");
          ((Element) node).content = str;
          element.append_child (node);
        }
      }
    });
    ((Serializable) this).deserialize_unknown_property.connect ( (element, prop) => {
      //GLib.message (@"Deserializing Unknown Property: $(prop.name) | $(prop.get_nick ())");
      if (element.node_name == "tag") {
        tags.append_val (((Element) element).content);
      }
    });
  }

  public string unknown_to_string ()
  {
    string t = "";
    foreach (GXml.Node node in unknown_serializable_property.get_values ())
    {
      t+= node.to_string () ;
    }
    return @"Unknown Properties: {$t}";
  }
}

public class Monitor : ObjectModel
{
  public string resolution { get; set; }
  [Description (nick="AcPower")]
  public int ac_power { get; set; }
  [Description (nick="DcPower")]
  public int dc_power { get; set; }

  public override bool property_use_nick () { return true; }
}


public class Cpu : ObjectModel
{
  public float ghz { get; set; default = (float) 0.0; }
  public Gee.ArrayList<int> piles { get; set; }

  public Cpu ()
  {
    piles = new Gee.ArrayList<int> ();
  }

  public override bool transform_to_string (GLib.Value val, ref string str)
  {
    if (val.type ().is_a (typeof (float))) {
      str = "%.2f".printf (val.get_float ());
      return true;
    }
    if (val.type ().is_a (typeof (Gee.ArrayList))) {
      str = piles_to_string ();
      return true;
    }
    return false;
  }
  public override bool transform_from_string (string str, ref GLib.Value val)
  {
    //stdout.printf (@"Transforming from string type $(val.type ().name ())\n");
    if (val.type ().is_a (typeof (Gee.ArrayList))) {
      //stdout.printf ("Is ArraySize: from string\n");
      var a = new Gee.ArrayList<int> ();
      foreach (string s in str.split (",")) {
        a.add (int.parse (s));
      }
      val.set_object (a);
      return true;
    }
    return false;
  }
  public string piles_to_string ()
  {
    string str = "";
    int i = 0;
    while (i < piles.size) {
      str += @"$(piles.get (i))";
      if ( i + 1 < piles.size)
        str += ",";
      i++;
    }
    return str;
  }
}

class NodeName : ObjectModel
{
  public bool invalid { get; set; default = true; }
  public override string node_name () { return "NodeName"; }
}

class Configuration : ObjectModel
{
  public bool invalid { get; set; default = true; }
  public string device { get; set; }
  public override string node_name () { return "Configuration"; }
  public override bool property_use_nick () { return true; }

  public Configuration ()
  {
    init_properties (); // initializing properties to be ignored by default
    ignored_serializable_properties.set ("invalid",
                                         get_class ().find_property("invalid"));
  }
  public override GXml.Node? serialize (GXml.Node node) throws GLib.Error
  {
    var n = default_serialize (node);
    n.add_namespace_attr ("http://www.gnome.org/gxml/0.4", "om");
    return n;
  }
  public override GXml.Node? deserialize (GXml.Node node) throws GLib.Error
  {
    //stdout.printf (@"CONFIGURATOR: Namespaces Check");
    GXml.Node n;
    if (node is Document)
      n = (GXml.Node) (((GXml.Document) node).document_element);
    else
      n = node;

    foreach (GXml.Node ns in n.namespace_definitions) {
      //stdout.printf (@"Namespace = $(ns.node_value)");
      if (ns.node_name == "om" && ns.node_value == "http://www.gnome.org/gxml/0.4")
        invalid = false;
    }
    return default_deserialize (node);
  }
}

class FakeSerializable : ObjectModel
{
  public string none { get; set; }
}
class UnknownAttribute : ObjectModel
{
  public string name { get; set; }
  public Gee.ArrayList<int> array { get; set; }
  public FakeSerializable fake { get; set; }
  public override bool get_enable_unknown_serializable_property () { return true; }
}

class SerializableObjectModelTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/object_model/serialize/simple_object",
                   () => {
                     try {
                       var computer = new Computer ();
                       var doc = new Document ();
                       computer.serialize (doc);
                       if (doc.document_element.tag_name.down () != "computer") {
                         stdout.printf ("ERROR XML_COMPUTER: computer\n");
                         assert_not_reached ();
                       }
                       var m = doc.document_element.get_attribute_node ("manufacturer");
                       if (m == null) assert_not_reached ();
                       if (m.node_value != "MexicanLaptop, Inc.") {
                         stdout.printf ("ERROR XML_COMPUTER: manufacturer\n");
                         assert_not_reached ();
                       }
                       var mod = doc.document_element.get_attribute_node ("model");
                       if (mod == null) assert_not_reached ();
                       if (mod.node_value != "LQ59678") {
                         stdout.printf ("ERROR XML_COMPUTER: model\n");
                         assert_not_reached ();
                       }
                       var c = doc.document_element.get_attribute_node ("cores");
                       if (c == null) assert_not_reached ();
                       if (c.node_value != "8") {
                         stdout.printf ("ERROR XML_COMPUTER: cores val\n");
                         assert_not_reached ();
                       }
                       var g = doc.document_element.get_attribute_node ("ghz");
                       if (g == null) assert_not_reached ();
                       if (double.parse (g.node_value) != (double) 3.5) {
                         stdout.printf ("ERROR XML_COMPUTER: ghz val\n");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) 
                     {
                       GLib.message (e.message);
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/serializable/object_model/deserialize_simple_object",
                   () => {
                     var computer = new Computer ();
                     try {
                       var doc = new Document.from_string (XML_COMPUTER_FILE);
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
    Test.add_func ("/gxml/serializable/object_model/deserialize_object_contents",
                   () => {
                     var manual = new Manual ();
                     try {
                       var doc = new Document.from_string ("""<?xml version="1.0"?>
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
                         stdout.printf (@"ERROR MANUAL:  Bad Element content value. Expected 'This is an Specification file', got: $(manual.get_contents ())\n");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       GLib.message (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/serializable/object_model/serialize_object_contents",
                   () => {
                     var doc = new Document ();
                     var manual = new Manual ();
                     try {
                       manual.serialize (doc);
                       if (doc.document_element.node_name != "manual") {
                         stdout.printf (@"ERROR MANUAL:  Element: $(doc.document_element.node_name)\n");
                         assert_not_reached ();
                       }
                       Element element = doc.document_element;
                       serialize_manual_check (element, manual);
                     } catch (GLib.Error e) {
                       stdout.printf (@"$(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    Test.add_func ("/gxml/serializable/object_model/deserialize_serializable_properties",
                   () => {
                     var package = new Package ();
                     try {
                       var doc = new Document.from_string (XML_PACKAGE_FILE);
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
    Test.add_func ("/gxml/serializable/object_model/serialize_serializable_properties",
                   () => {
                     var doc = new Document ();
                     var package = new Package ();
                     try {
                       package.serialize (doc);
                       if (doc.document_element.node_name != "package") {
                         stdout.printf (@"ERROR MANUAL:  Element: $(doc.document_element.node_name)\n");
                         assert_not_reached ();
                       }
                       Element element = doc.document_element;
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
    Test.add_func ("/gxml/serializable/object_model/deserialize_array_property",
                   () => {
                     var doc = new Document.from_string (XML_PACKAGE_FILE);
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
    Test.add_func ("/gxml/serializable/object_model/serialize_array_property",
                   () => {
                     var doc = new Document ();
                     var package = new Package ();
                     package.tags.append_val ("Computer");
                     package.tags.append_val ("Customer");
                     package.tags.append_val ("Sale");
                     try {
                       package.serialize (doc);
                       //stdout.printf (@"$(doc)");
                       if (doc.document_element.node_name != "package")
                         assert_not_reached ();
                       Element element = doc.document_element;
                       bool com = false;
                       bool cus = false;
                       bool sal = false;
                       foreach (GXml.Node n in element.child_nodes) {
                         //stdout.printf (@"Found Element: $(n.node_name)");
                         if (n.node_name == "tag") {
                           //stdout.printf (@"Found: $(n.node_name)");
                           if (((Element) n).content == "Computer")
                             com = true;
                           if (((Element) n).content == "Customer")
                             cus = true;
                           if (((Element) n).content == "Sale")
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
    Test.add_func ("/gxml/serializable/object_model/serialize_property_nick",
                   () => {
                     var doc = new Document ();
                     var monitor = new Monitor ();
                     try {
                       monitor.resolution = "1204x720";
                       monitor.ac_power = 120;
                       monitor.dc_power = 125;
                       monitor.serialize (doc);
                       //stdout.printf (@"DOC: [$(doc)]");
                       if (doc.document_element == null) {
                         stdout.printf ("ERROR MONITOR: No root Element");
                         assert_not_reached ();
                       }
                       Element element = doc.document_element;
                       if (element.node_name != "monitor") {
                         stdout.printf (@"ERROR MONITOR: root Element $(element.node_name)");
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
    Test.add_func ("/gxml/serializable/object_model/override_transform_to_string",
                   () => {
                     var cpu = new Cpu ();
                     cpu.ghz = (float) 3.85;
                     cpu.piles.add (1);
                     cpu.piles.add (2);
                     cpu.piles.add (3);
                     var doc = new Document ();
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
    Test.add_func ("/gxml/serializable/object_model/override_transform_from_string",
                   () => {
                     var cpu = new Cpu ();
                     var doc = new Document.from_string (XML_CPU_FILE);
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
    Test.add_func ("/gxml/serializable/object_model/override_serialize",
                   () => {
                     var doc = new Document ();
                     var configuration = new Configuration ();
                     configuration.device = "Controller";
                     try {
                       configuration.serialize (doc);
                       //stdout.printf (@"DOC: $doc");
                       if (doc.document_element == null) {
                         stdout.printf ("DOC: No root element");
                         assert_not_reached ();
                       }
                       Element element = doc.document_element;
                       if (element.node_name != "Configuration") {
                         stdout.printf (@"CONFIGURATION: Bad node name: $(element.node_name)");
                         assert_not_reached ();
                       }
                       bool found = false;
                       foreach (GXml.Node n in element.namespace_definitions)
                       {
                         if (n.node_name == "om" && n.node_value == "http://www.gnome.org/gxml/0.4")
                           found = true;
                       }
                       if (!found) {
                         stdout.printf (@"CONFIGURATION: No namespace found:");
                         foreach (GXml.Node n in element.namespace_definitions) {
                           stdout.printf (@"CONFIGURATION: Defined Namespace: $(n.node_name):$(n.node_value)");
                         }
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/object_model/override_deserialize",
                   () => {
                     var doc = new Document.from_string ("""<?xml version="1.0"?>
                     <Configuration xmlns:om="http://www.gnome.org/gxml/0.4" device="Sampler"/>""");
                     var configuration = new Configuration ();
                     try {
                       //stdout.printf (@"$doc");
                       configuration.deserialize (doc);
                       if (configuration.invalid == true) {
                         stdout.printf ("CONFIGURATION: deserialize is INVALID\n");
                         foreach (GXml.Node n in doc.document_element.namespace_definitions) {
                           stdout.printf (@"CONFIGURATION: namespace: $(n.node_value)\n");
                         }
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/object_model/custome_node_name",
                   () => {
                     var doc = new Document.from_string ("""<?xml version="1.0"?><NodeName />""");
                     var nodename = new NodeName ();
                     try {
                       nodename.deserialize (doc);
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/object_model/no_serialize_null_property",
                   () => {
                     var doc = new Document();
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
    Test.add_func ("/gxml/serializable/object_model/unknown_property",
                   () => {
                     var doc = new Document.from_string ("""<?xml version="1.0"?>
                     <UnknownAttribute ignore="true" ignore2="test">
                     <UnknownNode toignore = "true" />TEXT
                     </UnknownAttribute>""");
                     var unknown_property = new UnknownAttribute ();
                     try {
                       unknown_property.deserialize (doc);
                       if (unknown_property.unknown_serializable_property.size () != 4) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: size $(unknown_property.unknown_serializable_property.size ().to_string ())\n");
                         foreach (GXml.Node un in unknown_property.unknown_serializable_property.get_values ()) {
                           string sv = "__NULL__";
                           if (un.node_value != null)
                             sv = un.node_value;
                           stdout.printf (@"Saved unknown property: $(un.node_name) / '$(sv)'\n");
                         }
                         assert_not_reached ();
                       }
                       if (!unknown_property.unknown_serializable_property.contains ("ignore")) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: ignore not found");
                         assert_not_reached ();
                       }
                       var ignore = unknown_property.unknown_serializable_property.get ("ignore");
                       if (!(ignore is Attr)) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: ignore is not an GXml.Attr");
                         assert_not_reached ();
                       }
                       if (!unknown_property.unknown_serializable_property.contains ("ignore2")) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: ignore not found");
                         assert_not_reached ();
                       }
                       var ignore2 = unknown_property.unknown_serializable_property.get ("ignore2");
                       if (!(ignore2 is Attr)) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: ignore2 is not an GXml.Attr");
                         assert_not_reached ();
                       }
                       if (!unknown_property.unknown_serializable_property.contains ("UnknownNode")) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: node UnknownNode not found");
                         assert_not_reached ();
                       }var unknown_node = unknown_property.unknown_serializable_property.get ("UnknownNode");
                       if (!(unknown_node is Element)) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: unknown node is not an GXml.Element");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/object_model/deserialize_unknown_property",
                   () => {
                     var doc = new Document.from_string ("""<?xml version="1.0"?>
                     <UnknownAttribute ignore="true" ignore2="test">
                     <UnknownNode direction = "fordward">
                     <UnknownChild t = "test">
                     <UnknownChildTwo t = "test">
                     SECOND FAKE TEXT
                     </UnknownChildTwo>
                     </UnknownChild>
                     </UnknownNode>
                     FAKE TEXT
                     </UnknownAttribute>""");
                     var unknown_property = new UnknownAttribute ();
                     try {
                       unknown_property.deserialize (doc);
                       var doc2 = new Document ();
                       unknown_property.serialize (doc2);
                       if (doc2.document_element == null) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No Root Element");
                         assert_not_reached ();
                       }
                       Element element = doc2.document_element;
                       if (element.node_name.down () != "unknownattribute") {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Root Element Bad name $(element.node_name.down ())");
                         assert_not_reached ();
                       }
                       var ignore = element.get_attribute_node ("ignore");
                       if (ignore == null) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No attribute ignore");
                         assert_not_reached ();
                       }
                       if (ignore.node_value != "true") {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Attribute ignore bad value $(ignore.node_value)");
                         assert_not_reached ();
                       }
                       var ignore2 = element.get_attribute_node ("ignore2");
                       if (ignore2 == null) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No attribute ignore");
                         assert_not_reached ();
                       }
                       if (ignore2.node_value != "test") {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Attribute ignore2 bad value $(ignore2.node_value)");
                         assert_not_reached ();
                       }
                       if (!element.has_child_nodes ()) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: No child nodes");
                         assert_not_reached ();
                       }
                       if (element.child_nodes.length != 2) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: Too many child nodes. Expected 2, got $(element.child_nodes.length)\n");
                         assert_not_reached ();
                       }
                       bool found = false;
                       foreach (GXml.Node n in element.child_nodes) {
                         if (n.node_name == "UnknownNode") {
                           found = true;
                           var direction = ((Element) n).get_attribute_node ("direction");
                           if (direction == null)  {
                             stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: UnknownNode No attribute direction");
                             assert_not_reached ();
                           }
                           if (direction.node_value != "fordward") {
                             stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: UnknownNode attribute direction bad value $(direction.node_value)");
                             assert_not_reached ();
                           }
                         }
                       }
                       if (!found) {
                         stdout.printf (@"ERROR: UNKNOWN_ATTRIBUTE: SERIALIZATION: UnknownNode No not found");
                         assert_not_reached ();
                       }
                       // TODO: serialized_xml_node_value have more text than expected, may be a bug in Document.to_string ()
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
    Test.add_func ("/gxml/serializable/object_model/serialize_unknown_property",
                   () => {
                     try {
                       var doc = new Document.from_string ("""<?xml version="1.0"?>
                     <UnknownAttribute ignore="true" ignore2="test">
                     <UnknownNode toignore = "true" />TEXT
                     </UnknownAttribute>""");
                        var unknown_property = new UnknownAttribute ();
                       unknown_property.deserialize (doc);
                       var ndoc = new Document ();
                       unknown_property.serialize (ndoc);
                       if (ndoc.document_element.child_nodes.size != 2) {
                         stdout.printf (@"ERROR: Root incorrect child node number: found '$(doc.document_element.child_nodes.size)\n");
                         foreach (GXml.Node rn in ndoc.document_element.child_nodes) {
                           string nv = "__NULL__";
                           if (rn.node_value != null)
                             nv = rn.node_value;
                           stdout.printf (@"Node: $(rn.node_name) / Value: '$(nv)'\n");
                         }
                         stdout.printf (@"$(ndoc)\n");
                         assert_not_reached ();
                       }
                       foreach (GXml.Node n in ndoc.document_element.child_nodes) {
                         if (n is Text) {
                           if (n.node_value != "TEXT") {
                             stdout.printf (@"ERROR: Unknown Text Element not set: found '$(n.node_value)\n");
                             assert_not_reached ();
                           }
                         }
                       }
                     } catch (GLib.Error e) {
                       stdout.printf (@"ERROR: $(e.message)\n");
                       assert_not_reached ();
                     }
                   });
    Test.add_func ("/gxml/serializable/object_model/deserialize_incorrect_uint",
                   () => {
                     try {
                       var doc = new Document.from_string (
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
                     catch (GXml.SerializableError e) { Test.message ("Error thrown for invalid string to guint"); }
                   });
  }
  static void serialize_manual_check (Element element, Manual manual)
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