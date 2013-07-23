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
	public GXml.Element serialized_xml_node { get; protected set; }
	public string? serialized_xml_node_value { get; protected set; default=null; }
	public GLib.HashTable<string,GXml.DomNode> unknown_serializable_property { get; protected set; }

	/* No serializable properties */
	[Description (blurb="GXml.DomNode contents")]
	public string @value {
		owned get { return serialized_xml_node_value; } 
		set { serialized_xml_node_value = value; }
	}
	public SerializableObjectModel ()
	{
		serializable_property_use_nick = true;
		var pvalue = find_property_spec ("value");
		ignored_serializable_properties.set ("value", pvalue);
	}
	
	public abstract string to_string ();

	public static bool equals (SerializableObjectModel a, SerializableObjectModel b)
	{
		if (b.get_type () == a.get_type ()) {
			var alp = ((Serializable)a).list_serializable_properties ();
			var blp = ((Serializable)b).list_serializable_properties ();
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
