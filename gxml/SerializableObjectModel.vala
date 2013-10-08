/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* ObjectModel.vala
 *
 * Copyright (C) 2013  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

public abstract class GXml.SerializableObjectModel : Object, Serializable
{
	/* Serializable interface properties */
	public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
	public bool serializable_property_use_nick { get; set; }
	public string? serialized_xml_node_value { get; protected set; default=null; }
	public GLib.HashTable<string,GXml.Node> unknown_serializable_property { get; protected set; }
	public string serializable_node_name { get; protected set; }

	public SerializableObjectModel ()
	{
		serializable_property_use_nick = true;
		serialized_xml_node_value = null;
		serializable_node_name = get_type().name().down();
	}

	public Node? serialize (Node node) throws DomError
	{
		Document doc;
		if (node is Document)
			doc = (Document) node;
		else
			doc = node.owner_document;
		GLib.message ("Serialing on ..." + node.node_name);
		var element = doc.create_element (serializable_node_name);
		node.append_child (element);
		if (serialized_xml_node_value != null)
			element.content = serialized_xml_node_value;
		GLib.message ("Node Value is: ?" + element.content);
		foreach (ParamSpec spec in list_serializable_properties ()) {
			GLib.message ("Property to Serialize: " + spec.name);
			serialize_property (element, spec);
		}
		GLib.message ("Added a new top node: " + element.node_name);
		return element;
	}
	
	public GXml.Node? serialize_property (Element element,
	                                                 GLib.ParamSpec prop)
	                                                 throws DomError
	{
		if (prop.value_type.is_a (typeof (Serializable))) 
		{
			GLib.message (@"$(prop.name) Is a Serializable");
			var v = Value (typeof (Object));
			get_property (prop.name, ref v);
			var obj = (Serializable) v.get_object ();
			return obj.serialize (element);
		}
		Node node = null;
		Value oval = Value (prop.value_type);
		get_property (prop.name, ref oval);
		string val = "";
		if (Value.type_transformable (prop.value_type, typeof (string)))
		{
			Value rval = Value (typeof (string));
			oval.transform (ref rval);
			val = rval.dup_string ();
			string attr_name = prop.name.down ();
			var attr = element.get_attribute_node (attr_name);
			if (attr == null) {
				GLib.message (@"New Attr to add... $(attr_name)");
				element.set_attribute (attr_name, val);
			}
			else
				attr.value = val;
			return (Node) attr;
		}
		this.serialize_unknown_property (element, prop, out node);
		return node;
	}
	
	public virtual Node? deserialize (Node node)
	                                  throws SerializableError,
	                                         DomError
	{
		Document doc;
		if (node is Document) {
			doc = (Document) node;
			return_val_if_fail (doc.document_element != null, null);
		}
		else
			doc = node.owner_document;
		Element element;
		if (node is Element)
			element = (Element) node;
		else
			element = (Element) doc.document_element;
		return_val_if_fail (element.node_name.down () == serializable_node_name, null);
		foreach (Attr attr in element.attributes.get_values ())
		{
			GLib.message (@"Deseralizing Attribute: $(attr.name)");
			deserialize_property (attr);
		}
		if (element.has_child_nodes ())
		{
			GLib.message ("Have child Elements ...");
			foreach (Node n in element.child_nodes)
			{
				GLib.message (@"Deseralizing Element: $(n.node_name)");
				deserialize_property (n);
			}
		}
		if (element.content != null)
				serialized_xml_node_value = element.content;
		return null;
	}

	public virtual bool deserialize_property (GXml.Node property_node)
	                                          throws SerializableError,
	                                          DomError
	{
		bool ret = false;
		var prop = find_property_spec (property_node.node_name);
		if (prop == null) {
			GLib.message ("Found Unknown property: " + property_node.node_name);
			// FIXME: Event emit
			unknown_serializable_property.set (property_node.node_name, property_node);
			return true;
		}
		if (prop.value_type.is_a (typeof (Serializable)))
		{
			GLib.message (@"$(prop.name): Is Serializable...");
			Value vobj = Value (typeof(Object));
			get_property (prop.name, ref vobj);
			if (vobj.get_object () == null) {
				var obj = Object.new  (prop.value_type);
				((Serializable) obj).deserialize (property_node);
				set_property (prop.name, obj);
			}
			else
				((Serializable) vobj.get_object ()).deserialize (property_node);
			return true;
		}
		else {
			Value val = Value (prop.value_type);
			if (Value.type_transformable (typeof (Node), prop.value_type))
			{
				Value tmp = Value (typeof (Node));
				tmp.set_object (property_node);
				ret = tmp.transform (ref val);
				set_property (prop.name, val);
				return ret;
			}
			if (property_node is GXml.Attr)
			{
				Value ptmp = Value (typeof (string));
				ptmp.set_string (property_node.node_value);
				if (Value.type_transformable (typeof (string), prop.value_type))
					ret = ptmp.transform (ref val);
				else
					ret = string_to_gvalue (property_node.node_value, ref val);
				set_property (prop.name, val);
				return ret;
			}
		}
		// Attribute can't be deseralized with standard methods. Up to the implementor.
		this.deserialize_unknown_property (property_node, prop);
		return true;
	}
	public abstract string to_string ();

	public static bool equals (SerializableObjectModel a, SerializableObjectModel b)
	{
		if (b.get_type () == a.get_type ()) {
			var alp = ((Serializable)a).list_serializable_properties ();
			bool ret = true;
			foreach (ParamSpec p in alp) {
				var bp = ((Serializable)b).find_property_spec (p.name);
				if (bp != null) {
					var apval = ((Serializable)a).get_property_value (p);
					var bpval = ((Serializable)b).get_property_value (bp);
					if ( apval != bpval)
						ret = false;
				}
			}
			return ret;
		}
		return false;
	}
}
