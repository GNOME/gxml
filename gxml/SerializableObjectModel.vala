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
	protected ParamSpec[] properties { get; set; }
	public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
	public bool serializable_property_use_nick { get; set; }
	public string? serialized_xml_node_value { get; protected set; default=null; }
	public GLib.HashTable<string,GXml.Node> unknown_serializable_property { get; protected set; }
	public string serializable_node_name { get; protected set; }

	public SerializableObjectModel ()
	{
		serializable_property_use_nick = false;
		serialized_xml_node_value = null;
		serializable_node_name = get_type().name().down();
	}

	public virtual GLib.ParamSpec? find_property_spec (string property_name)
	{
		return default_find_property_spec (property_name);
	}

	public virtual void init_properties ()
	{
		default_init_properties ();
	}

	public virtual GLib.ParamSpec[] list_serializable_properties ()
	{
		return default_list_serializable_properties ();
	}

	public virtual void get_property_value (GLib.ParamSpec spec, ref Value val)
	{
		default_get_property_value (spec, ref val);
	}

	public virtual void set_property_value (GLib.ParamSpec spec, GLib.Value val)
	{
		default_set_property_value (spec, val);
	}

	public virtual bool transform_from_string (string str, ref GLib.Value dest)
	{
		return false;
	}

	public virtual bool transform_to_string (GLib.Value val, ref string str)
	{
		return false;
	}

	public virtual Node? serialize (Node node) throws GLib.Error
	{
		return default_serialize (node);
	}

	public Node? default_serialize (Node node) throws GLib.Error
	{
		Document doc;
		if (node is Document)
			doc = (Document) node;
		else
			doc = node.owner_document;
		//GLib.message ("Serialing on ..." + node.node_name);
		var element = doc.create_element (serializable_node_name);
		node.append_child (element);
		if (serialized_xml_node_value != null)
			element.content = serialized_xml_node_value;
		//GLib.message ("Node Value is: ?" + element.content);
		foreach (ParamSpec spec in list_serializable_properties ()) {
			//GLib.message ("Property to Serialize: " + spec.name);
			serialize_property (element, spec);
		}
		//GLib.message ("Added a new top node: " + element.node_name);
		return element;
	}

	public virtual GXml.Node? serialize_property (Element element,
	                                      GLib.ParamSpec prop)
	                                      throws GLib.Error
	{
		return default_serialize_property (element, prop);
	}
	public GXml.Node? default_serialize_property (Element element,
	                                      GLib.ParamSpec prop)
	                                      throws GLib.Error
	{
		if (prop.value_type.is_a (typeof (Serializable))) 
		{
			//GLib.message (@"$(prop.name) Is a Serializable");
			var v = Value (typeof (Object));
			get_property (prop.name, ref v);
			var obj = (Serializable) v.get_object ();
			return obj.serialize (element);
		}
		Value oval = Value (prop.value_type);
		get_property (prop.name, ref oval);
		string val = "";
		if (!transform_to_string (oval, ref val)) {
			if (Value.type_transformable (prop.value_type, typeof (string)))
			{
				Value rval = Value (typeof (string));
				oval.transform (ref rval);
				val = rval.dup_string ();
			}
			else {
				Node node = null;
				this.serialize_unknown_property (element, prop, out node);
				return node;
			}
		}
		string attr_name;
		if (serializable_property_use_nick &&
		    prop.get_nick () != null &&
		    prop.get_nick () != "")
			attr_name = prop.get_nick ();
		else
			attr_name = prop.get_name ();
		var attr = element.get_attribute_node (attr_name);
		if (attr == null) {
			//GLib.message (@"New Attr to add... $(attr_name)");
			element.set_attribute (attr_name, val);
		}
		else
			attr.value = val;
		return (Node) attr;
	}

	public virtual Node? deserialize (Node node)
	                                  throws GLib.Error
	{
		return default_deserialize (node);
	}
	public Node? default_deserialize (Node node)
	                                  throws GLib.Error
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
		return_val_if_fail (element.node_name.down () == serializable_node_name.down (), null);
		foreach (Attr attr in element.attributes.get_values ())
		{
			//GLib.message (@"Deseralizing Attribute: $(attr.name)");
			deserialize_property (attr);
		}
		if (element.has_child_nodes ())
		{
			//GLib.message ("Have child Elements ...");
			foreach (Node n in element.child_nodes)
			{
				//GLib.message (@"Deseralizing Element: $(n.node_name)");
				deserialize_property (n);
			}
		}
		if (element.content != null)
				serialized_xml_node_value = element.content;
		return null;
	}

	public virtual bool deserialize_property (GXml.Node property_node)
	                                          throws GLib.Error
	{
		return default_deserialize_property (property_node);
	}
	public bool default_deserialize_property (GXml.Node property_node)
	                                          throws GLib.Error
	{
		bool ret = false;
		var prop = find_property_spec (property_node.node_name);
		if (prop == null) {
			//GLib.message ("Found Unknown property: " + property_node.node_name);
			// FIXME: Event emit
			unknown_serializable_property.set (property_node.node_name, property_node);
			return true;
		}
		//stdout.printf (@"Property name: '$(prop.name)' type: '$(prop.value_type.name ())'\n");
		if (prop.value_type.is_a (typeof (Serializable)))
		{
			//GLib.message (@"$(prop.name): Is Serializable...");
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
			//stdout.printf (@"Not a Serializable object for type: $(prop.value_type.name ())");
			Value val = Value (prop.value_type);
			//stdout.printf (@"No Transformable Node registered method for type: '$(prop.value_type.name ())'");
			if (property_node is GXml.Attr)
			{
				//stdout.printf (@"is an GXml.Attr for type: '$(prop.value_type.name ())'; Value type: '$(val.type ().name ())'");
				if (!transform_from_string (property_node.node_value, ref val)) {
					Value ptmp = Value (typeof (string));
					ptmp.set_string (property_node.node_value);
					if (Value.type_transformable (typeof (string), prop.value_type))
						ret = ptmp.transform (ref val);
					else
						ret = string_to_gvalue (property_node.node_value, ref val);
				}
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
					Value apval = Value (p.value_type);
					((Serializable)a).get_property_value (p, ref apval);
					Value bpval = Value (bp.value_type);;
					((Serializable)b).get_property_value (bp, ref bpval);
					if ( apval != bpval)
						ret = false;
				}
			}
			return ret;
		}
		return false;
	}
}
