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
      get_property (p.name, ref v);
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
          try { node = (Element) element.document.create_element ("tag"); }
          catch (GLib.Error e) {
	          GLib.message ("Error: "+e.message);
	          assert_not_reached ();
          }
          ((Element) node).content = str;
          element.children_nodes.add (node);
        }
      }
    });
    ((Serializable) this).deserialize_unknown_property.connect ( (element, prop) => {
      //GLib.message (@"Deserializing Unknown Property: $(prop.name) | $(prop.get_nick ())");
      if (element.name == "tag") {
        tags.append_val (((GElement) element).content);
      }
    });
  }

  public string unknown_to_string ()
  {
    string t = "";
    foreach (GXml.Attribute node in unknown_serializable_properties.values)
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
/*
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
  */
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

  public override GLib.ParamSpec[] list_serializable_properties ()
  {
    ParamSpec[] props = {};
    var l = new HashTable<string,ParamSpec> (str_hash, str_equal);
    l.set ("invalid",
           get_class ().find_property("invalid"));
    foreach (ParamSpec spec in default_list_serializable_properties ()) {
      if (!l.contains (spec.name)) {
        props += spec;
      }
    }
    return props;
  }
  public override GXml.Node? serialize (GXml.Node node) throws GLib.Error
  {
    var n = default_serialize (node);
    n.set_namespace ("http://www.gnome.org/gxml/0.4", "om");
    return (GXml.Node)n;
  }
  public override bool deserialize (GXml.Node node) throws GLib.Error
  {
#if DEBUG
    GLib.message (@"CONFIGURATOR: Deserializing... $(node.to_string ())");
#endif
    GXml.Node n;
    if (node is Document)
      n = (GXml.Node) (((GXml.Document) node).root);
    else
      n = node;
#if DEBUG
    GLib.message ("Checking namespaces... in GXml.Node");
#endif
    foreach (GXml.Namespace ns in n.namespaces) {
#if DEBUG
      GLib.message (@"Namespace = $(ns.prefix):$(ns.uri)");
#endif
      if (ns.prefix == "om" && ns.uri == "http://www.gnome.org/gxml/0.4")
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

public class NameSpace : SerializableObjectModel
{
  public override bool set_default_namespace (GXml.Node node)
  {
    Test.message ("Setting default namespace");
    node.set_namespace ("http://www.gnome.org/GXml", "gxml");
    return true;
  }
  public override string to_string ()
  {
    return "";
  }
}

class SerializableObjectModelTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/object_model/serialize/simple_object",
                   () => {
                     try {
                       var computer = new Computer ();
                       var doc = new GDocument ();
                       computer.serialize (doc);
                       if (doc.root.name.down () != "computer") {
                         stdout.printf ("ERROR XML_COMPUTER: computer\n");
                         assert_not_reached ();
                       }
                       var m = (doc.root as Element).get_attr ("manufacturer");
                       if (m == null) assert_not_reached ();
                       if (m.value != "MexicanLaptop, Inc.") {
                         stdout.printf ("ERROR XML_COMPUTER: manufacturer\n");
                         assert_not_reached ();
                       }
                       var mod = (doc.root as Element).get_attr ("model");
                       if (mod == null) assert_not_reached ();
                       if (mod.value != "LQ59678") {
                         stdout.printf ("ERROR XML_COMPUTER: model\n");
                         assert_not_reached ();
                       }
                       var c = (doc.root as Element).get_attr ("cores");
                       if (c == null) assert_not_reached ();
                       if (c.value != "8") {
                         stdout.printf ("ERROR XML_COMPUTER: cores val\n");
                         assert_not_reached ();
                       }
                       var g = (doc.root as Element).get_attr ("ghz");
                       if (g == null) assert_not_reached ();
                       if (double.parse (g.value) != (double) 3.5) {
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
                       var doc = new GDocument.from_string (XML_COMPUTER_FILE);
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
                       var doc = new GDocument.from_string ("""<?xml version="1.0"?>
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
                         stdout.printf (@"ERROR MANUAL:  Bad GElement content value. Expected 'This is an Specification file', got: $(manual.get_contents ())\n");
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
                     var doc = new GDocument ();
                     var manual = new Manual ();
                     try {
                       manual.serialize (doc);
                       assert (doc.root != null);
                       assert (doc.root.name == "manual");
                       var element = doc.root as GElement;
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
                       var doc = new GDocument.from_string (XML_PACKAGE_FILE);
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
                     var doc = new GDocument ();
                     var package = new Package ();
                     try {
                       package.serialize (doc);
                       if (doc.root.name != "package") {
                         stdout.printf (@"ERROR MANUAL:  GElement: $(doc.root.name)\n");
                         assert_not_reached ();
                       }
                       var element = doc.root as Element;
                       var source = element.get_attr ("source");
                       if (source == null ) assert_not_reached ();
                       if (source.value != "Mexico") {
                         stdout.printf (@"ERROR PACKAGE: source: $(source.value)\n");
                         assert_not_reached ();
                       }
                       var destiny = element.get_attr ("destiny");
                       if (destiny == null ) assert_not_reached ();
                       if (destiny.value != "World") {
                         stdout.printf (@"ERROR PACKAGE: source: $(destiny.value)\n");
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
     try {
       var doc = new GDocument.from_string (XML_PACKAGE_FILE);
       var package = new Package ();
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
    });
    Test.add_func ("/gxml/serializable/object_model/serialize_array_property",
                   () => {
                     var doc = new GDocument ();
                     var package = new Package ();
                     package.tags.append_val ("Computer");
                     package.tags.append_val ("Customer");
                     package.tags.append_val ("Sale");
                     try {
                       package.serialize (doc);
                       //stdout.printf (@"$(doc)");
                       if (doc.root.name != "package")
                         assert_not_reached ();
                       var element = doc.root as Element;
                       bool com = false;
                       bool cus = false;
                       bool sal = false;
                       foreach (GXml.Node n in element.children_nodes) {
                         //stdout.printf (@"Found GElement: $(n.name)");
                         if (n.name == "tag") {
                           //stdout.printf (@"Found: $(n.name)");
                           if (((GElement) n).content == "Computer")
                             com = true;
                           if (((GElement) n).content == "Customer")
                             cus = true;
                           if (((GElement) n).content == "Sale")
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
                     var doc = new GDocument ();
                     var monitor = new Monitor ();
                     try {
                       monitor.resolution = "1204x720";
                       monitor.ac_power = 120;
                       monitor.dc_power = 125;
                       monitor.serialize (doc);
                       //stdout.printf (@"DOC: [$(doc)]");
                       if (doc.root == null) {
                         stdout.printf ("ERROR MONITOR: No root GElement");
                         assert_not_reached ();
                       }
                       var element = doc.root as Element;
                       if (element.name != "monitor") {
                         stdout.printf (@"ERROR MONITOR: root GElement $(element.name)");
                         assert_not_reached ();
                       }
                       var ac = element.get_attr ("AcPower");
                       if (ac == null) {
                         stdout.printf (@"ERROR MONITOR: attribute AcPower not found");
                         assert_not_reached ();
                       }
                       if (ac.value != "120") {
                         stdout.printf (@"ERROR MONITOR: AcPower value $(ac.value)");
                         assert_not_reached ();
                       }
                       var dc = element.get_attr ("DcPower");
                       if (dc == null) {
                         stdout.printf (@"ERROR MONITOR: attribute DcPower not found");
                         assert_not_reached ();
                       }
                       if (dc.value != "125") {
                         stdout.printf (@"ERROR MONITOR: AcPower value $(dc.value)");
                         assert_not_reached ();
                       }
                       var r = element.get_attr ("resolution");
                       if (r == null) {
                         stdout.printf (@"ERROR MONITOR: attribute resolution not found");
                         assert_not_reached ();
                       }
                       if (r.value != "1204x720") {
                         stdout.printf (@"ERROR MONITOR: resolution value $(r.value)");
                         assert_not_reached ();
                       }
                     }
                     catch (GLib.Error e) {
                       stdout.printf (@"Error: $(e.message)");
                       assert_not_reached ();
                     }
                   }
                   );
    /*Test.add_func ("/gxml/serializable/object_model/override_transform_to_string",
                   () => {
                     var cpu = new Cpu ();
                     cpu.ghz = (float) 3.85;
                     cpu.piles.add (1);
                     cpu.piles.add (2);
                     cpu.piles.add (3);
                     var doc = new GDocument ();
                     try {
                       cpu.serialize (doc);
                       //stdout.printf (@"$doc");
                       if (doc.root == null) {
                         stdout.printf (@"ERROR CPU: no root element");
                         assert_not_reached ();
                       }
                       if (doc.root.name != "cpu") {
                         stdout.printf (@"ERROR CPU: root element $(doc.root.name)");
                         assert_not_reached ();
                       }
                       var ghz = (doc.root as Element).get_attr ("ghz");
                       if (ghz == null) {
                         stdout.printf (@"ERROR CPU: no attribute ghz");
                         assert_not_reached ();
                       }
                       if (ghz.value != "3.85") {
                         stdout.printf (@"ERROR CPU: ghz '$(ghz.value)'");
                         assert_not_reached ();
                       }
                       var p = (doc.root as Element).get_attr ("piles");
                       if (p == null) {
                         stdout.printf (@"ERROR CPU: no attribute piles");
                         assert_not_reached ();
                       }
                       if (p.value != "1,2,3") {
                         stdout.printf (@"ERROR CPU: piles '$(p.value)'");
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
                     var doc = new GDocument.from_string (XML_CPU_FILE);
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
                   });*/
    Test.add_func ("/gxml/serializable/object_model/override_serialize",
                   () => {
                     var doc = new GDocument ();
                     var configuration = new Configuration ();
                     configuration.device = "Controller";
                     try {
                       configuration.serialize (doc);
                       //stdout.printf (@"DOC: $doc");
                       if (doc.root == null) {
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
    Test.add_func ("/gxml/serializable/object_model/override_deserialize",
    () => {
     try {
       var doc = new GDocument.from_string ("""<?xml version="1.0"?>
       <Configuration xmlns:om="http://www.gnome.org/gxml/0.4" device="Sampler"/>""");
       var configuration = new Configuration ();
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
         foreach (GXml.Namespace n in doc.root.namespaces) {
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
    Test.add_func ("/gxml/serializable/object_model/custome_node_name",
    () => {
      try {
       var doc = new GDocument.from_string ("""<?xml version="1.0"?><NodeName />""");
       var nodename = new NodeName ();
       nodename.deserialize (doc);
      }
      catch (GLib.Error e) {
       stdout.printf (@"Error: $(e.message)");
       assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/object_model/no_serialize_null_property",
    () => {
     try {
       var doc = new GDocument();
       var unknown_property = new UnknownAttribute (); // name is set to null
       unknown_property.serialize (doc);
       //stdout.printf (@"DOCUMENT: $doc"); assert_not_reached ();
       var name = (doc.root as GElement).get_attr ("name");
       if (name != null) {
         stdout.printf (@"ERROR: NULL ATTRIBUTE SERIALIZATION: name found $(name.name)");
         assert_not_reached ();
       }
       var array = (doc.root as Element).get_attr ("array");
       if (array != null) {
         stdout.printf (@"ERROR: NULL ATTRIBUTE SERIALIZATION: array found $(array.name)");
         assert_not_reached ();
       }
       if (doc.root.children_nodes.size > 0) {
         stdout.printf (@"ERROR: NULL ATTRIBUTE SERIALIZATION: Nodes found $(doc.root.children_nodes.size > 0)");
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
     try {
      var doc = new GDocument.from_string ("""<?xml version="1.0"?>
      <UnknownAttribute ignore="true" ignore2="test"><UnknownNode toignore = "true" />TEXT</UnknownAttribute>""");
      assert (doc.root != null);
      assert (doc.root.name == "UnknownAttribute");
#if DEBUG
       GLib.message ("Document to use:\n"+doc.root.children_nodes.size.to_string ());
       foreach (GXml.Node n in doc.root.children_nodes) {
          GLib.message ("Node in root: "+ n.name+ " Contents: "+n.value);
       }
       GLib.message ("Document root children:\n"+doc.to_string ());
#endif
       assert (doc.root.children_nodes.size == 2);
       var unknown_property = new UnknownAttribute ();
       unknown_property.deserialize (doc);
#if DEBUG
      GLib.message ("Checking unknown attributes...");
       foreach (GXml.Attribute a in unknown_property.unknown_serializable_properties.values) {
         GLib.message (@"Unknown Attribute: $(a.name) = $(a.value)");
       }
      GLib.message ("Checking unknown nodes...");
       foreach (GXml.Node un in unknown_property.unknown_serializable_nodes) {
         GLib.message (@"Unknown Node: $(un.name) = $(un.to_string ())");
       }
#endif
       var ukp = unknown_property.unknown_serializable_properties;
       assert (ukp.size == 2);
       var ignore = ukp.get ("ignore");
       assert (ignore != null);
       var ignore2 = ukp.get ("ignore2");
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
    Test.add_func ("/gxml/serializable/object_model/deserialize_unknown_property",
    () => {
     try {
       var doc = new GDocument.from_string ("""<?xml version="1.0"?>
       <UnknownAttribute ignore="true" ignore2="test">
        <UnknownNode direction = "fordward">
         <UnknownChild t = "test">
          <UnknownChildTwo t = "test">SECOND FAKE TEXT</UnknownChildTwo>
         </UnknownChild>
       </UnknownNode>FAKE TEXT</UnknownAttribute>""");
       assert (doc.root.name == "UnknownAttribute");
       assert (doc.root.children_nodes.size == 3);
       assert (doc.root.children_nodes[1].name == "UnknownNode");
       assert (doc.root.children_nodes[2].value == "FAKE TEXT");
       assert (doc.root.children_nodes[1].children_nodes.size == 3);
       assert (doc.root.children_nodes[1].children_nodes[1].name == "UnknownChild");
       assert (doc.root.children_nodes[1].children_nodes[1].children_nodes.size == 3);
       assert (doc.root.children_nodes[1].children_nodes[1].children_nodes[1].name == "UnknownChildTwo");
       assert (doc.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes.size == 1);
       assert (doc.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes[0] is GXml.Text);
       assert (doc.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes[0].value == "SECOND FAKE TEXT");
       var unknown_property = new UnknownAttribute ();
       unknown_property.deserialize (doc);
       var doc2 = new GDocument ();
       unknown_property.serialize (doc2);
#if DEBUG
       GLib.message ("Unknown nodes:");
       foreach (GXml.Node n in unknown_property.unknown_serializable_nodes) {
        GLib.message (@"Unknown node: '$(n.name)'");
       }
       GLib.message ("Prepare to Serialize...");
       GLib.message ("After Serialize...");
       GLib.message ("Serialized back document: \n"+doc2.libxml_to_string ());
#endif
       assert (doc2.root != null);
       assert (doc.root.name == "UnknownAttribute");
       assert (doc2.root.children_nodes.size == 3);
       assert (doc2.root.children_nodes[1].name == "UnknownNode");
       assert (doc2.root.children_nodes[1].children_nodes.size == 3);
       assert (doc2.root.children_nodes[2].value == "FAKE TEXT");
       assert (doc2.root.children_nodes[1].children_nodes[1].name == "UnknownChild");
       assert (doc2.root.children_nodes[1].children_nodes[1].children_nodes[1].name == "UnknownChildTwo");
       assert (doc2.root.children_nodes[1].children_nodes[1].children_nodes.size == 3);
       assert (doc2.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes.size == 1);
       assert (doc2.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes[0] is GXml.Text);
       assert (doc2.root.children_nodes[1].children_nodes[1].children_nodes[1].children_nodes[0].value == "SECOND FAKE TEXT");
     }
     catch (GLib.Error e) {
       stdout.printf (@"Error: $(e.message)");
       assert_not_reached ();
     }
    });
    Test.add_func ("/gxml/serializable/object_model/serialize_unknown_property",
                   () => {
                     try {
                       var doc = new GDocument.from_string ("""<?xml version="1.0"?>
<UnknownAttribute ignore="true" ignore2="test"><UnknownNode toignore = "true" />TEXT</UnknownAttribute>""");
                        var unknown_property = new UnknownAttribute ();
                       unknown_property.deserialize (doc);
                       var ndoc = new GDocument ();
                       unknown_property.serialize (ndoc);
                       if (ndoc.root.children_nodes.size != 2) {
                         stdout.printf (@"ERROR: Root incorrect child node number: found '$(doc.root.children_nodes.size)\n");
                         foreach (GXml.Node rn in ndoc.root.children_nodes) {
                           string nv = "__NULL__";
                           if (rn.value != null)
                             nv = rn.value;
                           stdout.printf (@"Node: $(rn.name) / Value: '$(nv)'\n");
                         }
                         stdout.printf (@"$(ndoc)\n");
                         assert_not_reached ();
                       }
                       foreach (GXml.Node n in ndoc.root.children_nodes) {
                         if (n is Text) {
                           if (n.value != "TEXT") {
                             stdout.printf (@"ERROR: Unknown Text GElement not set: found '$(n.value)\n");
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
                       var doc = new GDocument.from_string (
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
    
    Test.add_func ("/gxml/serializable/object_model/set_namespace", () => {
      try {
        var ns = new NameSpace ();
        var doc = new GDocument ();
        ns.serialize (doc);
        Test.message ("DOC ROOT: "+doc.to_string ());
        assert (doc.root.to_string () == "<namespace xmlns:gxml=\"http://www.gnome.org/GXml\"/>");
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
  Test.add_func ("/gxml/serializable/object_model/find-unknown_property", () => {
      try {
        var p = new Package ();
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
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
  static void serialize_manual_check (GElement element, Manual manual) {
    var document = element.get_attr ("document");
    assert (document != null);
    assert (document.value == manual.document);
    var pages = element.get_attr ("pages");
    assert (pages != null);
    assert (int.parse (pages.value) == manual.pages);
    bool found = false;
    foreach (GXml.Node n in element.children_nodes) {
      if (n is GXml.Text)
        if (n.value == manual.get_contents ()) found = true;
    }
    assert (found);
  }
}

