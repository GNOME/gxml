/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXmlDom;
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

	public ComplexSimpleProperties (SimpleProperties simple) {
		this.simple = simple;
	}

	public static bool equals (ComplexSimpleProperties a, ComplexSimpleProperties b) {
		return SimpleProperties.equals (a.simple, b.simple);
 	}
}

public class ComplexComplexProperties : GLib.Object {
	public ComplexSimpleProperties complex_simple { get; set; }

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
	public EnumProperty enum_property { get; set; } // if you don't use get;set; it's readonly

	public EnumProperties (EnumProperty enum_property) {
		this.enum_property = enum_property;
	}

	public static bool equals (EnumProperties a, EnumProperties b) {
		return (a.enum_property == b.enum_property);
	}
}

class XmlSerializableTest : GXmlTest {
	// public delegate bool EqualsFunc (GLib.Object object);

	public static GLib.Object test_serialization_deserialization (GLib.Object object, string name, EqualFunc equals) {
		string xml_filename;
		Serializer ser;
		GXmlDom.XNode node;
		GXmlDom.Document doc;
		GLib.Object object_new = null;

		xml_filename = "_serialization_test_" + name + ".xml";

		ser = new Serializer ();

		try {
			node = ser.serialize_object (object);
			// TODO: assert that node is right
			node.owner_document.save_to_path (xml_filename);
			// TODO: assert that saved file is right
			doc = new GXmlDom.Document.from_path (xml_filename);
			// TODO: assert that loaded file is right; do document compare with original
			object_new = ser.deserialize_object (doc.document_element);

			if (! equals (object, object_new)) {
				GLib.Test.fail ();
			}
		} catch (GXmlDom.DomError e) {
			GLib.message ("%s", e.message);
			GLib.Test.fail ();
		} catch (GXmlDom.SerializationError e) {
			GLib.message ("%s", e.message);
			GLib.Test.fail ();
		}

		return object_new;
}

	public static void add_tests () {
		Test.add_func ("/gxml/domnode/xml_serializable", () => {
				Fruit fruit;
				Serializer ser;
				GXmlDom.XNode fruit_xml;

				fruit = new Fruit ();
				fruit.name = "fish";
				fruit.age = 3;
				ser = new Serializer ();
				fruit_xml = ser.serialize_object (fruit);

				// TODO: This test currently should change once we can serialise fields and private properties
				assert ("<Object otype=\"Fruit\"><Property pname=\"age\" ptype=\"gint\">9</Property></Object>" == fruit_xml.to_string ());
			});
		Test.add_func ("/gxml/domnode/xml_serializable_fields", () => {
				Fruit fruit;
				Serializer ser;
				GXmlDom.XNode fruit_xml;

				fruit = new Fruit ();
				fruit.set_all ("blue", 11, "fish", 3);
				ser = new Serializer ();
				fruit_xml = ser.serialize_object (fruit);

				if ("<Object otype=\"Fruit\"><Property pname=\"colour\">blue</Property><Property pname=\"weight\">9</Property><Property pname=\"name\">fish</Property><Property pname=\"age\" ptype=\"gint\">3</Property></Object>" != fruit_xml.to_string ()) { // weight expected to be 3 because age sets it *3
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserializable", () => {
				try {
					Document doc = new Document.from_string ("<Object otype=\"Fruit\"><Property pname=\"age\" ptype=\"gint\">3</Property></Object>"); // Shouldn't need to have type if we have a known property name for a known type
					Serializer ser = new Serializer ();
					Fruit fruit = (Fruit)ser.deserialize_object (doc.document_element);

					if (fruit.age != 3) {
						GLib.Test.fail (); // TODO: check weight? 
					}
				} catch (GXmlDom.SerializationError e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				} catch (GXmlDom.DomError e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/domnode/xml_deserializable_fields", () => {
				try {
					Document doc;
					Serializer ser;
					Fruit fruit;

					doc = new Document.from_string ("<Object otype=\"Fruit\"><Property pname=\"colour\">blue</Property><Property pname=\"weight\">11</Property><Property pname=\"name\">fish</Property><Property pname=\"age\" ptype=\"gint\">3</Property></Object>");
					ser = new Serializer ();
					fruit = (Fruit)ser.deserialize_object (doc.document_element);

					if (! fruit.test ("blue", 11, "fish", 3)) {
						GLib.Test.fail (); // Note that age sets weight normally
					}
				} catch (GXmlDom.SerializationError e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				} catch (GXmlDom.DomError e) {
					GLib.message ("%s", e.message);
					GLib.Test.fail ();
				}
			});
		Test.add_func ("/gxml/serialization/simple_fields", () => {
				SimpleFields obj = new SimpleFields (3, 4.5, "cat", true, 6);
				test_serialization_deserialization (obj, "simple_fields", (GLib.EqualFunc)SimpleFields.equals);
			});
		Test.add_func ("/gxml/serialization/simple_properties", () => {
				SimpleProperties obj = new SimpleProperties (3, 4.2, "catfish", true, 9);
				test_serialization_deserialization (obj, "simple_properties", (GLib.EqualFunc)SimpleProperties.equals);
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
				
				test_serialization_deserialization (obj, "collection_properties", (GLib.EqualFunc)CollectionProperties.equals);
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
				test_serialization_deserialization (obj, "gee_collection_properties", (GLib.EqualFunc)GeeCollectionProperties.equals);
			});
		Test.add_func ("/gxml/serialization/complex_simple_properties", () => {
				SimpleProperties simple_properties;
				ComplexSimpleProperties obj;

				simple_properties = new SimpleProperties (3, 4.2, "catfish", true, 9);
				obj = new ComplexSimpleProperties (simple_properties);

				test_serialization_deserialization (obj, "complex_simple_properties", (GLib.EqualFunc)ComplexSimpleProperties.equals);
			});
		Test.add_func ("/gxml/serialization/complex_complex_properties", () => {
				ComplexComplexProperties obj;
				SimpleProperties simple_properties;
				ComplexSimpleProperties complex_simple_properties;

				simple_properties = new SimpleProperties (3, 4.2, "catfish", true, 9);
				complex_simple_properties = new ComplexSimpleProperties (simple_properties);
				obj = new ComplexComplexProperties (complex_simple_properties);

				test_serialization_deserialization (obj, "complex_complex_properties", (GLib.EqualFunc)ComplexComplexProperties.equals);
			});
		Test.add_func ("/gxml/serialization/enum_properties", () => {
				EnumProperties obj = new EnumProperties (EnumProperty.THREE);
				test_serialization_deserialization (obj, "enum_properties", (GLib.EqualFunc)EnumProperties.equals);
			});
		// TODO: more to do, for structs and stuff and things that do interfaces
		
	}
}