/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/**
 *
 *  GXml.Serializable.SerializableTest
 *
 *  Authors:
 *
 *       Richard Schwarting <aquarichy@gmail.com>
 *       Daniel Espinosa <esodan@gmail.com>
 *
 *  Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 *  Copyright (c) 2013-2015 Daniel Espinosa <esodan@gmail.com>
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

public class SerializableTomato : GXml.SerializableJson {
	public int weight;
	private int age { get; set; }
	public int height { get; set; }
	public string description { get; set; }

	public SerializableTomato (int weight, int age, int height, string description) {
		this.weight = weight;
		this.age = age;
		this.height = height;
		this.description = description;
	}

	public string to_string () {
		return "SerializableTomato {weight:%d, age:%d, height:%d, description:%s}".printf (weight, age, height, description);
	}

	public static bool equals (SerializableTomato a, SerializableTomato b) {
		bool same = (a.weight == b.weight &&
			     a.age == b.age &&
			     a.height == b.height &&
			     a.description == b.description);
		return same;
	}
}

public class SerializableCapsicum : GXml.SerializableJson {
	public int weight;
	private int age { get; set; }
	public int height { get; set; }
	public unowned GLib.List<int> ratings { get; set; }

	public string to_string () {
		string str = "SerializableCapsicum {weight:%d, age:%d, height:%d, ratings:".printf (weight, age, height);
		foreach (int rating in ratings) {
			str += "%d ".printf (rating);
		}
		str += "}";
		return str;
	}

	public SerializableCapsicum (int weight, int age, int height, GLib.List<int> ratings) {
		this.weight = weight;
		this.age = age;
		this.height = height;
		this.ratings = ratings;
		((Serializable)this).serialize_unknown_property_type.connect (serialize_unknown_property_type);
		((Serializable)this).deserialize_unknown_property_type.connect (deserialize_unknown_property_type);
	}

	/* TODO: do we really need GLib.Value? or should we modify the object directly?
	   Want an example using GBoxed too
	   Perhaps these shouldn't be object methods, perhaps they should be static?
	   Can't have static methods in an interface :(, right? */
	public void deserialize_unknown_property_type (GXml.xNode element, ParamSpec prop)
	{
		GLib.Value outvalue = GLib.Value (typeof (int));
		switch (prop.name) {
		case "ratings":
			this.ratings = new GLib.List<int> ();
			foreach (GXml.xNode rating in element.child_nodes) {
				int64.try_parse (((GXml.xElement)rating).content, out outvalue);
				this.ratings.append ((int)outvalue.get_int64 ());
			}
			break;
		default:
			Test.message ("Wasn't expecting the SerializableCapsicum property '%s'", prop.name);
			assert_not_reached ();
		}
	}
	private void serialize_unknown_property_type (GXml.Node elem, ParamSpec prop, out GXml.xNode node)
	{
		xElement element = (xElement) elem;
		xDocument doc = element.owner_document;
		switch (prop.name) {
		case "ratings":
			foreach (int rating_int in ratings) {
				xElement n = (xElement) doc.create_element ("rating");
				n.content = "%d".printf (rating_int);
				element.append_child (n);
			}
			break;
		default:
			Test.message ("Wasn't expecting the SerializableCapsicum property '%s'", prop.name);
			assert_not_reached ();
		}
	}
}


public class SerializableBanana : GXml.SerializableJson {
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

	
	// This method overrides the one implemented at Serializable
	public override GLib.ParamSpec[] list_serializable_properties ()
	{
		if (properties == null) {
			properties = new ParamSpec [4];
			int i = 0;
			foreach (string name in new string[] { "private-field", "public-field", "private-property", "public-property" }) {
				// TODO: offer guidance for these fields, esp. ParamFlags
				properties[i] = (ParamSpec) new ParamSpecInt (name, name, name, int.MIN, int.MAX, 0, ParamFlags.READABLE); 
				i++;
			}
		}
		return properties;
	}

	// This method overrides the one implemented at Serializable
	public override void get_property_value (GLib.ParamSpec spec, ref Value val)
	{
		val = Value (typeof (int));
		switch (spec.name) {
		case "private-field":
			val.set_int (this.private_field);
			break;
		case "public-field":
			val.set_int (this.public_field);
			break;
		case "private-property":
			val.set_int (this.private_property);
			break;
		case "public-property":
			val.set_int (this.public_property);
			break;
		default:
			((GLib.Object)this).get_property (spec.name, ref val);
			return;
		}
	}

	// This method overrides the one implemented at Serializable
	public override void set_property_value (GLib.ParamSpec spec, GLib.Value val)
	{
		switch (spec.name) {
		case "private-field":
			this.private_field = val.get_int ();
			break;
		case "public-field":
			this.public_field = val.get_int ();
			break;
		case "private-property":
			this.private_property = val.get_int ();
			break;
		case "public-property":
			this.public_property = val.get_int ();
			break;
		default:
			((GLib.Object)this).set_property (spec.name, val);
			return;
		}
	}
}

class SerializableTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/serializable/interface_defaults", () => {
			try {
				SerializableTomato tomato = new SerializableTomato (0, 0, 12, "cats");
				var doc = new xDocument ();
				tomato.serialize (doc);
				SerializableTomato tomato2 = new SerializableTomato (1,1,4,"dogs");
				tomato2.deserialize (doc);
				assert (tomato.weight != tomato2.weight);
				assert (tomato2.weight == 1);
				assert (tomato.height == tomato2.height);
				assert (tomato.description == tomato2.description);
			} catch (GLib.Error e) {
#if DEBUG
				GLib.message ("ERROR: "+e.message);
#endif
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/serializable/interface_override_serialization_on_list", () => {
				GXml.xDocument doc;
				SerializableCapsicum capsicum;
				SerializableCapsicum capsicum_new;
				string expectation;
				Regex regex;
				GLib.List<int> ratings;

				// Clear cache to avoid collisions with other tests
				Serialization.clear_cache ();

				ratings = new GLib.List<int> ();
				ratings.append (8);
				ratings.append (13);
				ratings.append (21);

				capsicum = new SerializableCapsicum (2, 3, 6, ratings);
				try {
					doc = new xDocument ();
					capsicum.serialize (doc);
				} catch (GLib.Error e) {
					GLib.message ("%s", e.message);
					assert_not_reached ();
				}

				expectation = "<\\?xml version=\"1.0\"\\?>\n<Object otype=\"SerializableCapsicum\" oid=\"0x[0-9a-f]+\"><Property ptype=\"gint\" pname=\"height\">6</Property><Property ptype=\"gpointer\" pname=\"ratings\"><rating>8</rating><rating>13</rating><rating>21</rating></Property></Object>";

				try {
					regex = new Regex (expectation);
					if (! regex.match (doc.to_string ())) {
						Test.message ("Did not serialize as expected.  Got [%s] but expected [%s]", doc.to_string (), expectation);
						assert_not_reached ();
					}

					try {
						capsicum_new = (SerializableCapsicum)Serialization.deserialize_object (typeof (SerializableCapsicum), doc);
					} catch (GLib.Error e) {
						Test.message ("%s", e.message);
						assert_not_reached ();
					}
					if (capsicum_new.height != 6 || ratings.length () != 3 || ratings.nth_data (0) != 8 || ratings.nth_data (2) != 21) {
						Test.message ("Did not deserialize as expected.  Got [%s] but expected height and ratings from [%s], length: %s", capsicum_new.to_string (), capsicum.to_string (), ratings.length ().to_string ());
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
	}
}
