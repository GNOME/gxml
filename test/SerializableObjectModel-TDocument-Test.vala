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
class SerializableObjectModelTDocumentTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/tw/serializable/object_model/serialize/simple_object",
     () => {
       try {
         var computer = new Computer ();
         var doc = new TDocument ();
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
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_object_contents",
      () => {
       var doc = new TDocument ();
       var manual = new Manual ();
       assert (manual.document == "MANUAL DOCUMENTATION");
       assert (manual.pages == 3);
       assert (manual.get_contents () == "TEXT INTO THE MANUAL DOCUMENT");
       try {
         manual.serialize (doc);
         Element element = (Element) doc.root;
       } catch (GLib.Error e) {
         stdout.printf (@"$(e.message)");
         assert_not_reached ();
       }
      });
      
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_serializable_properties",
     () => {
       var doc = new TDocument ();
       var package = new Package ();
       try {
         package.serialize (doc);
         if (doc.root.name != "package") {
           stdout.printf (@"ERROR MANUAL:  GElement: $(doc.root.name)\n");
           assert_not_reached ();
         }
         Element element = (Element) doc.root;
         var source = element.attrs.get ("source");
         if (source == null ) assert_not_reached ();
         if (source.value != "Mexico") {
           stdout.printf (@"ERROR PACKAGE: source: $(source.value)\n");
           assert_not_reached ();
         }
         var destiny = element.attrs.get ("destiny");
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
     });
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_array_property",
     () => {
       var doc = new TDocument ();
       var package = new Package ();
       package.tags.append_val ("Computer");
       package.tags.append_val ("Customer");
       package.tags.append_val ("Sale");
       try {
         package.serialize (doc);
         //stdout.printf (@"$(doc)");
         if (doc.root.name != "package")
           assert_not_reached ();
         Element element = (Element) doc.root;
         bool com = false;
         bool cus = false;
         bool sal = false;
         foreach (GXml.Node n in element.children_nodes) {
           //stdout.printf (@"Found GElement: $(n.name)");
           if (n.name == "tag") {
             //stdout.printf (@"Found: $(n.name)");
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
     });
    Test.add_func ("/gxml/tw/serializable/object_model/serialize_property_nick",
     () => {
       var doc = new TDocument ();
       var monitor = new Monitor ();
       try {
         monitor.resolution = "1204x720";
         monitor.ac_power = 120;
         monitor.dc_power = 125;
         monitor.serialize (doc);
         //stdout.printf (@"DOC: [$(doc)]");
         if (doc.root == null) {
           stdout.printf ("ERROR MONITOR: No root Element");
           assert_not_reached ();
         }
         Element element = (Element) doc.root;
         if (element.name != "monitor") {
           stdout.printf (@"ERROR MONITOR: root GElement $(element.name)");
           assert_not_reached ();
         }
         var ac = element.attrs.get ("AcPower");
         if (ac == null) {
           stdout.printf (@"ERROR MONITOR: attribute AcPower not found");
           assert_not_reached ();
         }
         if (ac.value != "120") {
           stdout.printf (@"ERROR MONITOR: AcPower value $(ac.value)");
           assert_not_reached ();
         }
         var dc = element.attrs.get ("DcPower");
         if (dc == null) {
           stdout.printf (@"ERROR MONITOR: attribute DcPower not found");
           assert_not_reached ();
         }
         if (dc.value != "125") {
           stdout.printf (@"ERROR MONITOR: AcPower value $(dc.value)");
           assert_not_reached ();
         }
         var r = element.attrs.get ("resolution");
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
     });
/*    Test.add_func ("/gxml/tw/serializable/object_model/override_transform_to_string",
     () => {
       var cpu = new Cpu ();
       cpu.ghz = (float) 3.85;
       cpu.piles.add (1);
       cpu.piles.add (2);
       cpu.piles.add (3);
       var doc = new TDocument ();
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
         var ghz = doc.root.attrs.get ("ghz");
         if (ghz == null) {
           stdout.printf (@"ERROR CPU: no attribute ghz");
           assert_not_reached ();
         }
         if (ghz.value != "3.85") {
           stdout.printf (@"ERROR CPU: ghz '$(ghz.value)'");
           assert_not_reached ();
         }
         var p = doc.root.attrs.get ("piles");
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
     });*/
    Test.add_func ("/gxml/tw/serializable/object_model/override_serialize",
     () => {
       var doc = new TDocument ();
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
    Test.add_func ("/gxml/tw/serializable/object_model/set_namespace", () => {
      try {
        var ns = new NameSpace ();
        var doc = new TDocument ();
        ns.serialize (doc);
        string str = doc.to_string ();
#if DEBUG
        GLib.message (@"$doc");
#endif
        assert ("<namespace xmlns:gxml=\"http://www.gnome.org/GXml\"/>" in str);
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
        var doc = new TDocument ();
        var r = (Element) doc.create_element ("PACKAGE");
        doc.children_nodes.add (r);
        r.set_attr ("source", "Mexico/North");
        r.set_attr ("destiny", "Brazil");
        r.set_attr ("Unknown", "2/4.04");
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
    Test.add_func ("/gxml/tw/serializable/object_model/find-unknown_node", () => {
      try {
        var p = new Package ();
        var doc = new TDocument ();
        var r = (Element) doc.create_element ("PACKAGE");
        doc.children_nodes.add (r);
        r.set_attr ("source", "Mexico/North");
        r.set_attr ("destiny", "Brazil");
        var c = (Element) doc.create_element ("Unknown");
        r.children_nodes.add (c);
        c.set_attr ("prop","value");
        p.deserialize (doc);
        assert (p.unknown_serializable_nodes != null);
        bool found = false;
        GXml.Node un = c;
        foreach (GXml.Node n in p.unknown_serializable_nodes) {
          if (n.name == "Unknown") {
            found = true;
            un = n;
          }
        }
        assert (found);
        var ukattr = un.attrs.get ("prop");
        assert (ukattr != null);
        assert (ukattr.name == "prop");
        assert (ukattr.value == "value");
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });/*
    // TODO: Add deserialize to TDocument
    Test.add_func ("/gxml/tw/serializable/object_model/override_transform_from_string",
     () => {
       var cpu = new Cpu ();
       var doc = new TDocument.from_string (XML_CPU_FILE);
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
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_serializable_properties",
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
     });
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_simple_object",
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
    });
  Test.add_func ("/gxml/tw/serializable/object_model/deserialize_object_contents",
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

    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_array_property",
     () => {
       var doc = new GDocument.from_string (XML_PACKAGE_FILE);
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
     });
Test.add_func ("/gxml/tw/serializable/object_model/override_deserialize",
     () => {
       var doc = new GDocument.from_string ("""<?xml version="1.0"?>
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
           foreach (GXml.Namespace n in doc.root.namespace_definitions) {
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
       var doc = new GDocument.from_string ("""<?xml version="1.0"?><NodeName />""");
       var nodename = new NodeName ();
       try {
         nodename.deserialize (doc);
       }
       catch (GLib.Error e) {
         stdout.printf (@"Error: $(e.message)");
         assert_not_reached ();
       }
     });
    Test.add_func ("/gxml/tw/serializable/object_model/deserialize_incorrect_uint",
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
     });*/
  }
  static void serialize_manual_check (Element element, Manual manual)
  {
    var document = element.attrs.get ("document");
    assert (document != null);
    assert (document.value == manual.document);
    var pages = element.attrs.get ("pages");
    assert (pages != null);
    assert (int.parse (pages.value) == manual.pages);
    assert (element.content == manual.get_contents ());
  }
}
