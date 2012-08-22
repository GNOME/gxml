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

// TODO: if I don't subclass GLib.Object, a Vala class's object can't be serialised?
public class Fruit : GLib.Object {
	string colour;
	int weight;
	public string name;
	public int age {
		get { return weight; }
		set { weight = 3 * value; }
	}
	public string to_string () {
		return "Fruit: colour[%s] weight[%d] name[%s] age[%d]".printf(this.colour, this.weight, this.name, this.age);
	}

	public void set_all (string colour, int weight, string name, int age) {
		this.colour = colour;
		this.weight = weight; // weight will never matter as age will always overwrite
		this.name = name;
		this.age = age;
	}
	public bool test (string colour, int weight, string name, int age) {
		return (this.colour == colour &&
			this.weight == weight &&
			this.name == name &&
			this.age == age);
	}
}

public class SimpleFields : GLib.Object {
	public int public_int;
	public double public_double;
	public string public_string;
	public bool public_bool;
	private int private_int;

	// TODO: want something like reflection to automate this :D
	public string to_string () {
		return "SimpleFields: public_int[%d] public_double[%f] public_string[%s] public_bool[%s] private_int[%d]".printf (public_int, public_double, public_string, public_bool.to_string (), private_int);
	}

	public SimpleFields (int public_int, double public_double,
			     string public_string, bool public_bool, int private_int) {
		this.public_int = public_int;
		this.public_double = public_double;
		this.public_string = public_string;
		this.public_bool = public_bool;
		this.private_int = private_int;
	}

	public static bool equals (SimpleFields a, SimpleFields b) {
		return (a.public_double == b.public_double &&
			a.public_string == b.public_string &&
			a.public_bool == b.public_bool &&
			a.private_int == b.private_int);
	}
}

public class SimpleProperties : GLib.Object {
	public int public_int { get; set; }
	public double public_double { get; set; }
	public string public_string { get; set; }
	public bool public_bool { get; set; }
	private int private_int { get; set; }

	public string to_string () {
		return "SimpleFields: public_int[%d] public_double[%f] public_string[%s] public_bool[%s] private_int[%d]".printf (public_int, public_double, public_string, public_bool.to_string (), private_int);
	}

	public SimpleProperties (int public_int, double public_double, string public_string, bool public_bool, int private_int) {
		this.public_int = public_int;
		this.public_double = public_double;
		this.public_string = public_string;
		this.public_bool = public_bool;
		this.private_int = private_int;
	}

	public static bool equals (SimpleProperties a, SimpleProperties b) {
		return (a.public_int == b.public_int &&
			a.public_double == b.public_double &&
			a.public_string == b.public_string &&
			a.public_bool == b.public_bool &&
			a.private_int == b.private_int);
	}
}

public class CollectionProperties : GLib.Object {
	public unowned GLib.List list { get; set; } // Need to test these with C code too
	public GLib.HashTable table { get; set; }

	public string to_string () {
		return "CollectionProperties: list[length:%u] table[size:%u]".printf (list.length (), table.size ());
		// TODO: consider stringifying elements
	}

	public CollectionProperties (GLib.List list, GLib.HashTable table) {
		this.list = list;
		this.table = table;
	}

	public static bool equals (CollectionProperties a, CollectionProperties b) {
		return false; // TODO: need to figure out how i want to compare these
	}
}

public class GeeCollectionProperties : GLib.Object {
	public Gee.List list { get; set; }
	public Gee.HashSet hash_set { get; set; }
	public Gee.Set geeset { get; set; }
	public Gee.HashMap map { get; set; }
	public Gee.Collection collection { get; set; }

	public string to_string () {
		return "GeeCollectionProperties: list[size:%d] hash_st[size:%d] geeset[size:%d] map[size:%d] collection[size:%d]".printf (list.size, hash_set.size, geeset.size, map.size, collection.size);
		// TODO: consider stringifying elements
	}

	public GeeCollectionProperties (Gee.List list, Gee.HashSet hash_set, Gee.Set geeset, Gee.HashMap map, Gee.Collection collection) {
		this.list = list;
		this.hash_set = hash_set;
		this.geeset = geeset;
		this.map = map;
		this.collection = collection;
	}

	public static bool equals (GeeCollectionProperties a, GeeCollectionProperties b) {
		return false; // TODO: how do I want to compare these
	}
}

public class ComplexSimpleProperties : GLib.Object {
	public SimpleProperties simple { get; set; }

	public string to_string () {
		return "ComplexSimpleProperties: simple[%s]".printf (simple.to_string ());
	}

	public ComplexSimpleProperties (SimpleProperties simple) {
		this.simple = simple;
	}

	public static bool equals (ComplexSimpleProperties a, ComplexSimpleProperties b) {
		return SimpleProperties.equals (a.simple, b.simple);
 	}
}

public class ComplexDuplicateProperties : GLib.Object {
	public SimpleProperties a { get; set; }
	public SimpleProperties b { get; set; }

	public string to_string () {
		return "ComplexDuplicateProperties: a[%s] b[%s]".printf (a.to_string (), b.to_string ());
	}

	public ComplexDuplicateProperties (SimpleProperties simple) {
		this.a = simple;
		this.b = simple;
	}

	public static bool equals (ComplexDuplicateProperties cdp_a, ComplexDuplicateProperties cdp_b) {
		return (SimpleProperties.equals (cdp_a.a, cdp_b.a) &&
			SimpleProperties.equals (cdp_a.b, cdp_b.b));
 	}
}

public class ComplexComplexProperties : GLib.Object {
	public ComplexSimpleProperties complex_simple { get; set; }

	public string to_string () {
		return "ComplexComplexProperties: complex_simple[%s]".printf (complex_simple.to_string ());
	}

	public ComplexComplexProperties (ComplexSimpleProperties complex_simple) {
		this.complex_simple = complex_simple;
	}

	public static bool equals (ComplexComplexProperties a, ComplexComplexProperties b) {
		return ComplexSimpleProperties.equals (a.complex_simple, b.complex_simple);
	}
}

public enum EnumProperty {
	ONE = 11,
	TWO,
	THREE;
}

public class EnumProperties : GLib.Object {
	public EnumProperty enum_property { get; set; default = EnumProperty.ONE; } // if you don't use get;set; it's readonly

	public string to_string () {
		return "%d".printf (enum_property);
	}

	public EnumProperties (EnumProperty enum_property) {
		this.enum_property = enum_property;
	}

	public static bool equals (EnumProperties a, EnumProperties b) {
		return (a.enum_property == b.enum_property);
	}
}

class SerializationTest : GXmlTest {
	public delegate string StringifyFunc (GLib.Object object);

	public static GLib.Object test_serialization_deserialization (GLib.Object object, string name, EqualFunc equals, StringifyFunc stringify) {
		string xml_filename;
		GXml.DomNode node;
		GXml.Document doc;
		GLib.Object object_new = null;

		xml_filename = "_serialization_test_" + name + ".xml";

		try {
			node = Serialization.serialize_object (object);

			// TODO: assert that node is right
			node.owner_document.save_to_path (xml_filename);
			// TODO: assert that saved file is right
			doc = new GXml.Document.from_path (xml_filename);
			// TODO: assert that loaded file is right; do document compare with original
			object_new = Serialization.deserialize_object (doc.document_element);

			if (! equals (object, object_new)) {
				GLib.warning ("Expected [%s] but got [%s]",
					      stringify (object), stringify (object_new));
				GLib.Test.fail ();
			}
		} catch (GLib.Error e) {
			GLib.message ("%s", e.message);
			GLib.Test.fail ();
		}

		return object_new;
	}

	public static void add_tests () {
		Test.add_func ("/gxml/domnode/xml_serialize", () => {
				Fruit fruit;
				GXml.DomNode fruit_xml;
				string expectation;
				Regex regex;

				/* TODO: This test should change once we can serialise fields
				   and private properties */
				expectation = "<Object otype=\"Fruit\" oid=\"0x[0-9a-f]+\"><Property pname=\"age\" ptype=\"gint\">9</Property></Object>";

				fruit = new Fruit ();
				fruit.name = "fish";
				fruit.age = 3;

				try {
					fruit_xml = Serialization.serialize_object (fruit);

					regex = new Regex (expectation);
					if (! regex.match (fruit_xml.to_string ())) {
						GLib.warning ("Expected [%s] but found [%s]",
							      expectation, fruit_xml.to_string ());
						GLib.Test.fail ();
					}
				} catch (RegexError e) {
					GLib.warning ("Regular expression [%s] for test failed: %s",
						      expectation, e.message);
					GLib.Test.fail ();
				} catch (GXml.SerializationError e) {
					GLib.warning ("%s", e.message);
					GLib.Test.fail ();
				}

			});
		Test.add_func ("/gxml/domnode/xml_serialize_fields", () => {
				/* NOTE: We expect this one to fail right now */

				Fruit fruit;
				GXml.DomNode fruit_xml;
				string expectation;
				Regex regex;

				expectation = "<Object otype=\"Fruit\" oid=\"0x[0-9a-f]+\"><Property pname=\"colour\">blue</Property><Property pname=\"weight\">9</Property><Property pname=\"name\">fish</Property><Property pname=\"age\" ptype=\"gint\">3</Property></Object>";
				 // weight expected to be 9 because age sets it *3

				fruit = new Fruit ();
				fruit.set_all ("blue", 11, "fish", 3);

				try {
					fruit_xml = Serialization.serialize_object (fruit);

					regex = new Regex (expectation);
					if (! regex.match (fruit_xml.to_string ())) {
						GLib.warning ("Expected [%s] but found [%s]",
							      expectation, fruit_xml.to_string ());
						GLib.Test.fail ();
					}
				} catch (RegexError e) {
					GLib.warning ("Regular expression [%s] for test failed: %s",
						      expectation, e.message);
					GLib.Test.fail ();
				} catch (GXml.SerializationError e) {
					GLib.warning ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserialize", () => {
				Document doc;
				Fruit fruit;

				try {
					doc = new Document.from_string ("<Object otype='Fruit'><Property pname='age' ptype='gint'>3</Property></Object>");
					fruit = (Fruit)Serialization.deserialize_object (doc.document_element);

					// we expect 9 because Fruit triples it in the setter
					if (fruit.age != 9) {
						GLib.warning ("Expected fruit.age [%d] but found [%d]", 9, fruit.age);
						GLib.Test.fail (); // TODO: check weight?
					}
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserialize_no_type", () => {
				Document doc;
				Fruit fruit;

				/* Right now we can infer the type from a property's name, but fields we might need to specify */
				try {
					doc = new Document.from_string ("<Object otype='Fruit'><Property pname='age'>3</Property></Object>");
					fruit = (Fruit)Serialization.deserialize_object (doc.document_element);
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserialize_bad_property_name", () => {
				Document doc;

				try {
					doc = new Document.from_string ("<Object otype='Fruit'><Property name='badname'>3</Property></Object>");
					Serialization.deserialize_object (doc.document_element);
					GLib.Test.fail ();
				} catch (GXml.SerializationError.UNKNOWN_PROPERTY e) {
					// Pass
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserialize_bad_object_type", () => {
				Document doc;

				try {
					doc = new Document.from_string ("<Object otype='BadType'></Object>");
					Serialization.deserialize_object (doc.document_element);
					GLib.Test.fail ();
				} catch (GXml.SerializationError.UNKNOWN_TYPE e) {
					// Pass
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserialize_bad_property_type", () => {
				Document doc;
				Fruit fruit;

				try {
					doc = new Document.from_string ("<Object otype='Fruit'><Property pname='age' ptype='badtype'>blue</Property></Object>");
					fruit = (Fruit)Serialization.deserialize_object (doc.document_element);
					GLib.Test.fail ();
				} catch (GXml.SerializationError.UNSUPPORTED_TYPE e) {
					// Pass
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserializable_fields", () => {
				/* TODO: expecting this one to fail right now,
				         because we probably still don't support fields,
					 just properties. */
				Document doc;
				Fruit fruit;

				try {
					doc = new Document.from_string ("<Object otype='Fruit'><Property pname='colour' ptype='gchararray'>blue</Property><Property pname='weight' ptype='gint'>11</Property><Property pname='name' ptype='gchararray'>fish</Property><Property pname='age' ptype='gint'>3</Property></Object>");
					fruit = (Fruit)Serialization.deserialize_object (doc.document_element);

					if (! fruit.test ("blue", 11, "fish", 3)) {
						GLib.warning ("Expected [\"%s\", %d, \"%s\", %d] but found [%s]", "blue", 11, "fish", 3, fruit.to_string ());
						GLib.Test.fail (); // Note that age sets weight normally
					}
				} catch (GXml.SerializationError e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				} catch (GXml.DomError e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/serialization/simple_fields", () => {
				SimpleFields obj = new SimpleFields (3, 4.5, "cat", true, 6);
				test_serialization_deserialization (obj, "simple_fields", (GLib.EqualFunc)SimpleFields.equals, (StringifyFunc)SimpleFields.to_string);
			});
		Test.add_func ("/gxml/serialization/simple_properties_private", () => {
				SimpleProperties obj = new SimpleProperties (3, 4.2, "catfish", true, 9);  // 5th arg is private
				test_serialization_deserialization (obj, "simple_properties", (GLib.EqualFunc)SimpleProperties.equals, (StringifyFunc)SimpleProperties.to_string);
			});
		Test.add_func ("/gxml/serialization/simple_properties", () => {
				SimpleProperties obj = new SimpleProperties (3, 4.2, "catfish", true, 0); // set private arg just to 0
				test_serialization_deserialization (obj, "simple_properties", (GLib.EqualFunc)SimpleProperties.equals, (StringifyFunc)SimpleProperties.to_string);
			});
		Test.add_func ("/gxml/serialization/collection_properties", () => {
				// TODO: want a test with more complex data than strings

				CollectionProperties obj;
				GLib.List<string> list;
				GLib.HashTable<string,string> table;

				list = new GLib.List<string> ();
				list.append ("a");
				list.append ("b");
				list.append ("c");

				table = new GLib.HashTable<string,string> (GLib.str_hash, GLib.str_equal);
				table.set ("aa", "AA");
				table.set ("bb", "BB");
				table.set ("cc", "CC");

				obj = new CollectionProperties (list, table);

				test_serialization_deserialization (obj, "collection_properties", (GLib.EqualFunc)CollectionProperties.equals, (StringifyFunc)CollectionProperties.to_string);
			});
		Test.add_func ("/gxml/serialization/gee_collection_properties", () => {
				GeeCollectionProperties obj;

				Gee.List<string> list = new Gee.ArrayList<string> ();
				Gee.HashSet<string> hashset = new Gee.HashSet<string> ();
				Gee.Set<string> tset = new Gee.TreeSet<string> ();
				Gee.HashMap<string,string> map = new Gee.HashMap<string,string> ();
				Gee.Collection<string> col = new Gee.LinkedList<string> ();

				foreach (string str in new string[] { "a", "b", "c" }) {
					list.add (str);
					hashset.add (str);
					tset.add (str);
					map.set (str + str, str + str + str);
					col.add (str);
				}

				obj = new GeeCollectionProperties (list, hashset, tset, map, col);
				test_serialization_deserialization (obj, "gee_collection_properties", (GLib.EqualFunc)GeeCollectionProperties.equals, (StringifyFunc)GeeCollectionProperties.to_string);
			});
		Test.add_func ("/gxml/serialization/complex_simple_properties", () => {
				SimpleProperties simple_properties;
				ComplexSimpleProperties obj;

				simple_properties = new SimpleProperties (3, 4.2, "catfish", true, 0);
				obj = new ComplexSimpleProperties (simple_properties);

				test_serialization_deserialization (obj, "complex_simple_properties", (GLib.EqualFunc)ComplexSimpleProperties.equals, (StringifyFunc)ComplexSimpleProperties.to_string);
			});
		Test.add_func ("/gxml/serialization/complex_duplicate_properties", () => {
				/* This tests the case where the same object is referenced multiple
				   times during serialisation; we want to deserialise it to just
				   one object, rather than creating a new object for each reference. */

				SimpleProperties simple_properties;
				ComplexDuplicateProperties obj;
				ComplexDuplicateProperties restored;
				GXml.DomNode xml;

				simple_properties = new SimpleProperties (3, 4.2, "catfish", true, 0);
				obj = new ComplexDuplicateProperties (simple_properties);

				xml = Serialization.serialize_object (obj);

				restored = (ComplexDuplicateProperties)Serialization.deserialize_object (xml);

				if (restored.a != restored.b) {
					GLib.message ("Properties a (%p) and b (%p) should reference the same object but do not", restored.a, restored.b);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/serialization/complex_complex_properties", () => {
				ComplexComplexProperties obj;
				SimpleProperties simple_properties;
				ComplexSimpleProperties complex_simple_properties;

				simple_properties = new SimpleProperties (3, 4.2, "catfish", true, 0);
				complex_simple_properties = new ComplexSimpleProperties (simple_properties);
				obj = new ComplexComplexProperties (complex_simple_properties);

				test_serialization_deserialization (obj, "complex_complex_properties", (GLib.EqualFunc)ComplexComplexProperties.equals, (StringifyFunc)ComplexComplexProperties.to_string);
			});
		Test.add_func ("/gxml/serialization/enum_properties", () => {
				EnumProperties obj = new EnumProperties (EnumProperty.THREE);
				test_serialization_deserialization (obj, "enum_properties", (GLib.EqualFunc)EnumProperties.equals, (StringifyFunc)EnumProperties.to_string);
			});
		// TODO: more to do, for structs and stuff and things that do interfaces
	}
}
