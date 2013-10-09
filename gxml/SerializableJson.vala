/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Serialization.vala
 *
 * Copyright (C) 2012-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2013  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *       Richard Schwarting <aquarichy@gmail.com>
 *       Daniel Espinosa <esodan@gmail.com>
 */

/**
 * Serializes and deserializes {@link GLib.Object}s to and from
 * {@link GXml.Node}.
 *
 * Serialization can automatically serialize a variety of public
 * properties.  {@link GLib.Object}s can also implement the
 * {@link GXml.Serializable} to partially or completely manage
 * serialization themselves, including non-public properties or
 * data types not automatically supported by {@link GXml.Serialization}.
 */
public class GXml.SerializableJason : GLib.Object, Serializable
{
	/* Serializable Interface properties */
	public string serializable_node_name { get; protected set; }
	public bool serializable_property_use_nick { get; set; }
	public HashTable<string,GLib.ParamSpec>  ignored_serializable_properties { get; protected set; }
	public HashTable<string,GXml.Node>    unknown_serializable_property { get; protected set; }

	public string?  serialized_xml_node_value { get; protected set; default = null; }

  /**
   * If @node is a Document serialize just add an <Object> element.
   *
   * If @node is an Element serialize add to it an <Object> element.
   *
   * Is up to you to add convenient Element node to a Document, in order to be
   * used by serialize and add new <Object> tags per object to serialize.
   */
	public Node? serialize (Node node)
	{
		Document doc;
		Element root;
		ParamSpec[] prop_specs;
		Element prop;
		Node value_prop = null;
		string oid = "%p".printf(this);

		if (node is Document)
			doc = (Document) node;
		else
			doc = node.owner_document;

		root = doc.create_element ("Object");
		doc.append_child (root);
		root.set_attribute ("otype", object.get_type ().name ());
		root.set_attribute ("oid", oid);

		prop_specs = serializable.list_properties ();

		foreach (ParamSpec prop_spec in prop_specs) {
			prop = doc.create_element ("Property");
			prop.set_attribute ("ptype", prop_spec.value_type.name ());
			prop.set_attribute ("pname", prop_spec.name);
			value_prop = serialize_property (prop, prop_spe);
			prop.append_child (value_prop);
			root.append_child (prop);
		}
		return root;
	}

	public GXml.Node? serialize_property (Element element,
	                                               GLib.ParamSpec prop)
	{
		Type type;
		Value value;
		Node value_node = null;
		
		type = prop.value_type;

		if (type.is_a (typeof (Serializable)))
			return (Serializable).serialize ();

		var doc = element.owner_document;

		if (type.is_enum ())
		{
			value = Value (typeof (int));
			this.get_property (prop_spec.name, ref value);
			value_node = doc.create_text_node ("%d".printf (value.get_int ()));
		} 
		else if (Value.type_transformable (type, typeof (string))) 
		{ // e.g. int, double, string, bool
			value = Value (typeof (string));
			this.get_property (prop_spec.name, ref value);
			value_node = doc.create_text_node (value.get_string ());
		}
		else if (type == typeof (GLib.Type)) {
			value_node = doc.create_text_node (type.name ());
		}
		else if (type.is_a (typeof (GLib.Object))
		           && ! type.is_a (typeof (Gee.Collection)))
		{
			GLib.Object child_object;

			// TODO: this is going to get complicated
			value = Value (typeof (GLib.Object));
			this.get_property (prop.name, ref value);
			child_object = value.get_object ();
			Document value_doc = Serialization.serialize_object (child_object);

			value_node = doc.copy_node (value_doc.document_element);
		}
		else if (type.name () == "gpointer") {
			GLib.warning ("DEBUG: skipping gpointer with name '%s' of object '%s'", prop_spec.name, object.get_type ().name ());
			value_node = doc.create_text_node (prop.name);
		} else {
			throw new SerializationError.UNSUPPORTED_TYPE ("Can't currently serialize type '%s' for property '%s' of object '%s'", type.name (), prop.name, object.get_type ().name ());
		}

		return value_node;
	}

	public Node? deserialize (Node node) throws SerializableError
	{
		bool ret = true;
		Element obj_elem;
		string otype;
		string oid;
		Type type;
		ParamSpec[] specs;

		if (node is Document) {
			obj_elem = node.owner_document.document_element;
		}
		else {
			obj_elem = (Element) node;
		}

		specs = this.list_serializable_properties ();

		foreach (Node child_node in obj_elem.child_nodes) {
			deserialize_property (child_node);
		}
		return obj_elem;
	}

	public bool deserialize_property (GXml.Node property_node) throws SerializableError
	{
		if (properly_node.node_name == "Property")
		{
			Element prop_elem;
			string pname;
			Value val;
			//string ptype;

			prop_elem = (Element)child_node;
			pname = prop_elem.get_attribute ("pname");
			//ptype = prop_elem.get_attribute ("ptype"); // optional

			// Check name and type for property
			spec = this.find_property_spec (pname);

			if (spec == null) {
				GLib.message ("Deserializing object of type '%s' claimed unknown property named '%s'\nXML [%s]", otype, pname, obj_elem.to_string ());
				unknown_serializable_property.set (property_node.node_name, property_node);
				continue;
			}
			else {
				if (spec.value_type ().is_a (typeof(Serializable)))
				{
					Value vobj;
					this.get_property (pname, out vobj);
					((Serializable) vobj).deserialize (child_node);
				}
				else {
					val = Value (type);
					if (GLib.Value.type_transformable (type, typeof (string))) {
						Serializable.string_to_gvalue (prop_elem.content, ref val);
						this.set_property_value (pname, val);
					}
					else if (type.is_a (typeof (GLib.Object))) 
					{
						GXml.Node prop_elem_child;
						Object property_object;

						prop_elem_child = prop_elem.first_child;

						property_object = Serialization.deserialize_object_from_node (prop_elem_child);
						val.set_object (property_object);
					}
					else {
						deserialize_unknown_property_type.set (prop_elem, spec);
						ret = false;
					}
				}
			}
		}
	}
}
