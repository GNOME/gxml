/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;
using Gee;

/**
 * Test cases:
 *   field, property
 *   primitive, complex, collection, object
 *   visibility
 *
 * *. simple field: int, string, double, bool
 * *. simple property: int, string, double
 * *. collection property: glist, ghashtable,
 * *. gee collection property: list, set, hashtable
 * *. complex: simple object, complex object, enum, struct etc.
 *
 * TODO: How do we want to handle the case of A having B and C as properties, and B and C both have D as a property? if we serialize and then deserialize, we'll end up with D1 and D2 separate; we might want to have some memory identifier to tell if we've already deserialised something and then we can just pioint to that.
 *
 */

/*
  Test overriding nothing (rely on defaults)
   Test overriding {de,}serialize_property
   Test overriding list_properties/find_property
   Test overriding {set,get}_property
*/

public class SerializableTomato : GLib.Object, GXml.Serializable
{
	/*  Serializable abstract properties */
	public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; private set; }
	public bool serializable_property_use_nick { get; set; }
	public GXml.Element serialized_xml_node { get; protected set; }
	public string serialized_xml_node_value { get; protected set; }
	public GLib.HashTable<string,GXml.DomNode> unknown_serializable_property { get; private set; }

	public int weight;
	private int age { get; set; }
	public int height { get; set; }
	public string description { get; set; }

	public SerializableTomato (int weight, int age, int height, string description)
	{
		this.weight = weight;
		this.age = age;
		this.height = height;
		this.description = description;
	}

	public string to_string ()
	{
		return "SerializableTomato {weight:%d, age:%d, height:%d, description:%s}".printf (weight, age, height, description);
	}

	public static bool equals (SerializableTomato a, SerializableTomato b)
	{
		bool same = (a.weight == b.weight &&
			     a.age == b.age &&
			     a.height == b.height &&
			     a.description == b.description);

		return same;
	}
}

public class SerializableCapsicum : GLib.Object, GXml.Serializable
{
	/*  Serializable abstract properties */
	public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; private set; }
	public bool serializable_property_use_nick { get; set; }
	public GXml.Element serialized_xml_node { get; protected set; }
	public string serialized_xml_node_value { get; protected set; }
	public GLib.HashTable<string,GXml.DomNode> unknown_serializable_property { get; private set; }

	public int weight;
	private int age { get; set; }
	public int height { get; set; }
	public unowned GLib.List<int> ratings { get; set; }

	public string to_string ()
	{
		string str = "SerializableCapsicum {weight:%d, age:%d, height:%d, ratings:".printf (weight, age, height);
		foreach (int rating in ratings) {
			str += "%d ".printf (rating);
		}
		str += "}";
		return str;
	}

	public SerializableCapsicum (int weight, int age, int height, GLib.List<int> ratings)
	{
		this.weight = weight;
		this.age = age;
		this.height = height;
		this.ratings = ratings;
	}

	/* TODO: do we really need GLib.Value? or should we modify the object directly?
	   Want an example using GBoxed too
	   Perhaps these shouldn't be object methods, perhaps they should be static?
	   Can't have static methods in an interface :(, right? */
	public bool deserialize_property (GLib.ParamSpec spec,
	                                  GXml.DomNode property_node)
	{
		GLib.Value outvalue = GLib.Value (typeof (int));

		switch (spec.name) {
		case "ratings":
			this.ratings = new GLib.List<int> ();
			foreach (GXml.DomNode rating in property_node.child_nodes) {
				int64.try_parse (((GXml.Element)rating).content, out outvalue);
				this.ratings.append ((int)outvalue.get_int64 ());
			}
			return true;
		case "height":
			int64.try_parse (((GXml.Element)property_node).content, out outvalue);
			this.height = (int)outvalue.get_int64 () - 1;
			return true;
		default:
			Test.message ("Wasn't expecting the SerializableCapsicum property '%s'", spec.name);
			assert_not_reached ();
		}

		return false;
	}
	public GXml.DomNode? serialize_property (GLib.ParamSpec spec)
	                                         throws GXml.DomError
	{
		GXml.Document doc = serialized_xml_node.owner_document;
		GXml.Element c_prop;
		GXml.Element rating;

		switch (spec.name) {
		case "ratings":
			GXml.DocumentFragment frag = doc.create_document_fragment ();
			try {
				foreach (int rating_int in ratings) {
					rating = doc.create_element ("rating");
					rating.content = "%d".printf (rating_int);
					frag.append_child (rating);
				}
			} catch (GXml.DomError e) {
				Test.message ("%s", e.message);
				assert_not_reached ();
			}
			return frag;
		case "height":
			return doc.create_text_node ("%d".printf (height + 1));
		default:
			Test.message ("Wasn't expecting the SerializableCapsicum property '%s'", spec.name);
			assert_not_reached ();
		}

		// returning null does a normal serialization
		return null;
	}
}


public class SerializableBanana : GLib.Object, GXml.Serializable
{
	/*  Serializable abstract properties */
	public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; private set; }
	public bool serializable_property_use_nick { get; set; }
	public GXml.Element serialized_xml_node { get; protected set; }
	public string serialized_xml_node_value { get; protected set; }
	public GLib.HashTable<string,GXml.DomNode> unknown_serializable_property { get; private set; }

	private int private_field;
	public int public_field;
	private int private_property { get; set; }
	public int public_property { get; set; }

	public SerializableBanana (int private_field, int public_field, int private_property, int public_property) {
		this.private_field = private_field;
		this.public_field = public_field;
		this.private_property = private_property;
		this.public_property = public_property;

	}

	public string to_string () {
		return "SerializableBanana {private_field:%d, public_field:%d, private_property:%d, public_property:%d}".printf  (this.private_field, this.public_field, this.private_property, this.public_property);
	}

	public static bool equals (SerializableBanana a, SerializableBanana b) {
		return (a.private_field == b.private_field &&
			a.public_field == b.public_field &&
			a.private_property == b.private_property &&
			a.public_property == b.public_property);
	}

	private ParamSpec[] properties = null;
	public unowned GLib.ParamSpec[] list_properties () {
		// TODO: so, if someone implements list_properties, but they don't create there array until called, that could be inefficient if they don't cache.  If they create it at construction, then serialising and deserialising will lose it?   offer guidance
		if (this.properties == null) {
			properties = new ParamSpec[4];
			int i = 0;
			foreach (string name in new string[] { "private-field", "public-field", "private-property", "public-property" }) {
				properties[i] = new ParamSpecInt (name, name, name, int.MIN, int.MAX, 0, ParamFlags.READABLE); // TODO: offer guidance for these fields, esp. ParamFlags
				i++;
				// TODO: does serialisation use anything other than ParamSpec.name?
			}
		}
		return this.properties;
	}

	private GLib.ParamSpec prop;
	public unowned GLib.ParamSpec? find_property (string property_name) {
		GLib.ParamSpec[] properties = this.list_properties ();
		foreach (ParamSpec prop in properties) {
			if (prop.name == property_name) {
				this.prop = prop;
				return this.prop;
			}
		}
		return null;
	}

	public new void get_property (GLib.ParamSpec spec, ref GLib.Value str_value) {
		Value value = Value (typeof (int));

		switch (spec.name) {
		case "private-field":
			value.set_int (this.private_field);
			break;
		case "public-field":
			value.set_int (this.public_field);
			break;
		case "private-property":
			value.set_int (this.private_property);
			break;
		case "public-property":
			value.set_int (this.public_property);
			break;
		default:
			((GLib.Object)this).get_property (spec.name, ref str_value);
			return;
		}

		value.transform (ref str_value);
		return;
	}

	public new void set_property (GLib.ParamSpec spec, GLib.Value value)
	{
		switch (spec.name) {
		case "private-field":
			this.private_field = value.get_int ();
			break;
		case "public-field":
			this.public_field = value.get_int ();
			break;
		case "private-property":
			this.private_property = value.get_int ();
			break;
		case "public-property":
			this.public_property = value.get_int ();
			break;
		default:
			((GLib.Object)this).set_property (spec.name, value);
			return;
		}
	}
}

class ObjectModel : SerializableObjectModel
{
	public override string to_string ()
	{
		var lp = list_serializable_properties ();
		string ret = this.get_type ().name () +"{Properties:\n";
		foreach (ParamSpec p in lp) {
			ret += @"[$(p.name)]{" + get_property_value (p) + "}\n";
		}
		return ret + "}";
	}
}

class Computer : ObjectModel
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

class Manual : ObjectModel
{
	public string document { get; set; }
	public int pages { get; set; }

	public Manual ()
	{
		document = "MANUAL DOCUMENTATION";
		pages = 3;
		value = "TEXT INTO THE MANUAL DOCUMENT";
	}
}

class Package : ObjectModel
{
	public Computer computer { get; set; }
	public Manual manual { get; set; }
	public string source { get; set; }
	public string destiny { get; set; }

	public Package ()
	{
		computer = new Computer ();
		manual = new Manual ();
		source = "Mexico";
		destiny = "World";
	}
}

class SerializableTest : GXmlTest
{
	public static void add_tests () {
		Test.add_func ("/gxml/serializable/interface_defaults", () => {
				SerializableTomato tomato = new SerializableTomato (0, 0, 12, "cats");

				SerializationTest.test_serialization_deserialization (tomato, "interface_defaults", (GLib.EqualFunc)SerializableTomato.equals, (SerializationTest.StringifyFunc)SerializableTomato.to_string);
			});
		Test.add_func ("/gxml/serializable/interface_override_serialization_on_list", () => {
				GXml.DomNode node;
				SerializableCapsicum capsicum;
				SerializableCapsicum capsicum_new;
				string expectation;
				Regex regex;
				GLib.List<int> ratings;

				// Clear cache to avoid collisions with other tests
				Serialization.clear_caches ();

				ratings = new GLib.List<int> ();
				ratings.append (8);
				ratings.append (13);
				ratings.append (21);

				capsicum = new SerializableCapsicum (2, 3, 5, ratings);
				try {
					node = Serialization.serialize_object (capsicum);
				} catch (GXml.SerializationError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}

				expectation = "<Object otype=\"SerializableCapsicum\" oid=\"0x[0-9a-f]+\"><Property pname=\"height\" ptype=\"gint\">6</Property><Property pname=\"ratings\" ptype=\"gpointer\"><rating>8</rating><rating>13</rating><rating>21</rating></Property></Object>";

				try {
					regex = new Regex (expectation);
					if (! regex.match (node.to_string ())) {
						Test.message ("Did not serialize as expected.  Got [%s] but expected [%s]", node.to_string (), expectation);
						assert_not_reached ();
					}

					try {
						capsicum_new = (SerializableCapsicum)Serialization.deserialize_object (node);
					} catch (GXml.SerializationError e) {
						Test.message ("%s", e.message);
						assert_not_reached ();
					}
					if (capsicum_new.height != 5 || ratings.length () != 3 || ratings.nth_data (0) != 8 || ratings.nth_data (2) != 21) {
						Test.message ("Did not deserialize as expected.  Got [%s] but expected height and ratings from [%s]", capsicum_new.to_string (), capsicum.to_string ());
						assert_not_reached ();
					}
				} catch (RegexError e) {
					Test.message ("Regular expression [%s] for test failed: %s",
						      expectation, e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/serializable/interface_override_properties_view", () => {
				SerializableBanana banana = new SerializableBanana (17, 19, 23, 29);

				SerializationTest.test_serialization_deserialization (banana, "interface_override_properties", (GLib.EqualFunc)SerializableBanana.equals, (SerializationTest.StringifyFunc)SerializableBanana.to_string);
			});
		Test.add_func ("/gxml/serializable/xml_object_model/derived_class", () => {
			var computer = new Computer ();
			SerializationTest.test_serialization_deserialization (computer, "derived_class", (GLib.EqualFunc)SerializableObjectModel.equals, (SerializationTest.StringifyFunc)ObjectModel.to_string);
			});
	}
}
