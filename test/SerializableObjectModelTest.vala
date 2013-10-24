using GXml;

const string XML_COMPUTER_FILE = 
"""<?xml version="1.0"?>
<computer manufacturer="ThecnicalGroup" model="YH576G" cores="4" ghz="2.8"/>""";

const string SERIALIZED_XML_COMPUTER_FILE = 
"""<?xml version="1.0"?><computer manufacturer="MexicanLaptop, Inc." model="LQ59678" cores="8" ghz="3.5"/>""";


const string XML_MANUAL_FILE =
"""<?xml version="1.0"?>
<manual document="Specification" pages="3">This is an Specification file</manual>""";


const string XML_PACKAGE_FILE =
"""<?xml version="1.0"?>
<PACKAGE source="Mexico/Central" destiny="Japan">
<manual document="Specification" pages="3">This is an Specification file</manual>
<Computer manufacturer="LanCorop" model="Lap39120" cores="16" ghz="3.5"/>
<tag>Printer</tag><tag>Partner</tag><tag>Support</tag>
</PACKAGE>""";

const string XML_PACKAGE_UNKNOWN_FILE =
"""<?xml version="1.0"?>
<PACKAGE source="Mexico/North" destiny="Brazil" Hope="2/4.04">
  <manual document="Sales Card" pages="1">Selling Card Specification</manual>
  <Computer manufacturer="BoxingLAN" model="J24-EX9" cores="32" ghz="1.8"/>
  <Box size="1" volume="33.15" units="cm3" />
</PACKAGE>""";

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
	public string contents {
		get { return serialized_xml_node_value; }
		set { serialized_xml_node_value = value; }
	}
	
	public Manual ()
	{
		document = "MANUAL DOCUMENTATION";
		pages = 3;
		contents = "TEXT INTO THE MANUAL DOCUMENT";
		init_properties ();
		ignored_serializable_properties.set ("contents", get_class ().find_property ("contents"));
	}
	
	public override string to_string ()
	{
		return base.to_string () + @"CONTENTS: { $contents }";
	}
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
				try {
					for (int i = 0; i < tags.length; i++) {
						var str = tags.index (i);
						node = element.owner_document.create_element ("tag");
						((Element) node).content = str;
						element.append_child (node);
					}
				} catch (Error e) {
					GLib.message (e.message);
					assert_not_reached ();
				}
			}
		});
		((Serializable) this).deserialize_unknown_property.connect ( (element, prop) => {
			//GLib.message (@"Deserializing Unknown Property: $(prop.name) | $(prop.get_nick ())");
			if (prop.get_nick () == "tag")
			{
				try {
					if (element.node_name == "tag") {
							tags.append_val (((Element) element).content);
					}
				} catch (Error e) {
					GLib.message (e.message);
					assert_not_reached ();
				}
			}
		});
		//GLib.message ("PACKAGE: Properties.");
//		ParamSpec[] par = this.get_class().list_properties();
//		for (int i = 0; i < par.length; i++ ) {
//			GLib.message (@"Package: Property: $(par[i].name); Type: $(par[i].value_type)");
//		}
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
			catch (Error e) 
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
			} catch (Error e)
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
				var doc = new Document.from_string (XML_MANUAL_FILE);
				manual.deserialize (doc);
				if (manual.document != "Specification") {
					stdout.printf (@"ERROR MANUAL:  document: $(manual.document)\n");
					assert_not_reached ();
				}
				if (manual.pages != 3) {
					stdout.printf (@"ERROR MANUAL:  pages: $(manual.pages)\n");
					assert_not_reached ();
				}
				if (manual.contents != "This is an Specification file") {
					stdout.printf (@"ERROR MANUAL:  value: $(manual.contents)\n");
					assert_not_reached ();
				}
			}
			catch (Error e) {
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
			} catch (Error e) {
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
				if (package.unknown_to_string () != "Unknown Properties: {\n}") {
					stdout.printf (@"ERROR PACKAGE: package unknown properties: $(package.unknown_to_string ())\n");
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
				if (package.manual.contents != "This is an Specification file") {
					stdout.printf (@"ERROR PACKAGE: manual value: $(package.manual.contents)\n");
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
			catch (Error e) {
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
			catch (Error e) {
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
			catch (Error e) {
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
			catch (Error e) {
				GLib.message (@"Error: $(e.message)");
				assert_not_reached ();
			}
		}
		);
	}
	static void serialize_manual_check (Element element, Manual manual)
	{
		try {
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
			if (element.content != manual.contents) {
				stdout.printf (@"ERROR MANUAL: content: $(element.content)\n");
				assert_not_reached ();
			}
		}
		catch (Error e) {
			GLib.message (@"Error: $(e.message)");
			assert_not_reached ();
		}
	}
}
