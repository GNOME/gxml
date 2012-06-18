/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXmlDom;

// TODO: if I don't subclass GLib.Object, a Vala class's object can't be serialised?
public class Fruit : GLib.Object {
	string colour;
	int weight;
	public string name;
	public int age {
		get { return weight; }
		set { weight = value; }
	}
	public string to_string () {
		return "Fruit: colour[%s] weight[%d] name[%s] age[%d]".printf(this.colour, this.weight, this.name, this.age);
	}
}

class XmlSerializableTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/domnode/xml_serializable", () => {
				Fruit fruit = new Fruit ();
				fruit.name = "fish";
				fruit.age = 3;
				// fruit.colour =  "blue";
				Serializer ser = new Serializer ();
				ser.serialize_object (fruit);
			});
		Test.add_func ("/gxml/domnode/xml_deserializable", () => {
				Document doc = new Document.from_string ("<Object otype=\"Fruit\"><Property pname=\"age\" ptype=\"gint\">3</Property></Object>");
				Serializer ser = new Serializer ();
				Fruit fruit = (Fruit)ser.deserialize_object (doc.document_element);
				stdout.printf ("%s\n", fruit.to_string ());
			});
	}
}