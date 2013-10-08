/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Serializable.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 + Copyright (C) 2013  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */


/*
  Version 3: json-glib version

  PLAN:
  * add support for GObject Introspection to allow us to serialise non-property members

  json-glib
  * has functions to convert XML structures into Objects and vice versa
  * can convert simple objects automatically
  * richer objects need to implement interface

  json_serializable_real_serialize -> json_serialize_pspec
  * how do these get used with GInterfaces?  are these default methods like with superclasses?
  * TODO: I don't think vala does multiple inheritance, so do we want GXml.Serializable to be an interface or a superclass?

  json_serializable_default_{de,}serialize_property -> json_serializable_real_{de,}serialize

  json_serializable_{de,}serialize_property -> iface->{de,}serialize_property
    these all get init'd to -> json_serializable_real_{de,}serialize_property
      these all call -> json_{de,}serialize_pspec

  json_serializable_{find,list,get,set}_propert{y,ies} -> iface->{find,list,get,set}_propert{y,ies}
    these all get init'd to -> json_serializable_real_{find,list,get,set}_propert{y,ies}
	  these all call -> g_object_{class,}_{find,list,get,set}_propert{y,ies}
 */

using GXml;

namespace GXml {
	/**
	 * Interface allowing implementors direct control over serialisation of properties and other data
	 *
	 * A class that implements this interface will still be passed
	 * to {@link GXml.Serialization.serialize_object} for
	 * serialization.  That function will check whether the object
	 * implements {@link GXml.Serializable} and will then prefer
	 * overridden methods instead of standard ones.  Most of the
	 * methods for this interface can indicate (via return value)
	 * that, for a given property, the standard serialization
	 * approach should be used instead.  Indeed, not all methods
	 * need to be implemented, but some accompany one another and
	 * should be implemented carefully, corresponding to one
	 * another.  You can also create virtual properties from
	 * non-public property fields to enable their serialization.
	 *
	 * For an example, look in tests/XmlSerializableTest
	 */
	public interface Serializable : GLib.Object {
		/**
		 * Defines the way to set Node name.
		 *
		 * By default is set to object's type's name lowercase.
		 *
		 * This property must be ignored on serialisation.
		 */
		public abstract string serializable_node_name { get; protected set; }

		public abstract bool serializable_property_use_nick { get; set; }
		/**
		 * Store all properties to be ignored on serialization.
		 *
		 * Implementors: By default {@link list_serializable_properties} initialize
		 * this property to store all public properties, except this one.
		 */
		public abstract HashTable<string,GLib.ParamSpec>  ignored_serializable_properties { get; protected set; }
		/**
		 * On deserialization stores any {@link Node} not used on this
		 * object, but exists in current XML file.
		 *
		 * This property must be ignored on serialisation.
		 */
		public abstract HashTable<string,GXml.Node>    unknown_serializable_property { get; protected set; }

		/**
		 * Used by to add content in an {@link GXml.Element}.
		 *
		 * This property must be ignored on serialisation.
		 */
		public abstract string?  serialized_xml_node_value { get; protected set; default = null; }

		/**
		 * Serialize this object.
		 *
		 * @doc an {@link GXml.Document} object to serialise to 
		 */
		public abstract Node? serialize (Node node) throws DomError;

		/**
		 * Handles serializing individual properties.
		 *
		 * Interface method to handle serialization of an
		 * individual property.  The implementing class
		 * receives a description of it, and should create a
		 * {@link GXml.Node} that encapsulates the property.
		 * {@link GXml.Serialization} will embed the {@link GXml.Node} into
		 * a "Property" {@link GXml.Element}, so the {@link GXml.Node}
		 * returned can often be something as simple as
		 * {@link GXml.Text}.
		 *
		 * To let {@link GXml.Serialization} attempt to automatically
		 * serialize the property itself, do not implement
		 * this method.  If the method returns %NULL,
		 * {@link GXml.Serialization} will attempt handle it itsel.
		 *
		 * @param property_name string name of a property to serialize.
		 * @param spec the {@link GLib.ParamSpec} describing the property.
		 * @param doc the {@link GXml.Document} the returned {@link GXml.Node} should belong to
		 * @return a new {@link GXml.Node}, or `null`
		 */
		public abstract GXml.Node? serialize_property (Element element,
		                                                 GLib.ParamSpec prop)
		                                                 throws DomError;

		/**
		 * Deserialize this object.
		 *
		 * @node {@link GXml.Node} used to deserialize from.
		 */
		public abstract Node? deserialize (Node node)
		                                  throws SerializableError,
		                                         DomError;
		/**
		 * Handles deserializing individual properties.
		 *
		 * Interface method to handle deserialization of an
		 * individual property.  The implementing class
		 * receives a description of the property and the
		 * {@link GXml.Node} that contains the content.  The
		 * implementing {@link GXml.Serializable} object can extract
		 * the data from the {@link GXml.Node} and store it in its
		 * property itself. Note that the {@link GXml.Node} may be
		 * as simple as a {@link GXml.Text} that stores the data as a
		 * string.
		 *
		 * @param property_name the name of the property as a string
		 * @param spec the {@link GLib.ParamSpec} describing the property.
		 * @param property_node the {@link GXml.Node} encapsulating data to deserialize
		 * @return `true` if the property was handled, `false` if {@link GXml.Serialization} should handle it.
		 */
		public abstract bool deserialize_property (GXml.Node property_node)
		                                          throws SerializableError,
		                                                 DomError;

		/**
		 * Signal to serialize unknown properties.
		 * 
		 * @node a {@link GXml.Node} to add attribute or child nodes to
		 * @prop a {@link GLib.ParamSpec} describing attribute to serialize
		 * @attribute set to the {@link GXml.Attr} representing this attribute
		 */
		public signal void serialize_unknown_property (Node element, ParamSpec prop, out Node node);

		/**
		 * Signal to deserialize array properties.
		 *
		 * @node a {@link GXml.Node} to get attribute from
		 * @prop a {@link GLib.ParamSpec} describing attribute to deserialize
		 */
		public signal void deserialize_unknown_property (Node node, ParamSpec prop);

		/*
		 * Handles finding the {@link GLib.ParamSpec} for a given property.
		 *
		 * @param property_name the name of a property to obtain a {@link GLib.ParamSpec} for
		 * @return a {@link GLib.ParamSpec} describing the named property
		 *
		 * {@link GXml.Serialization} uses {@link
		 * GLib.ObjectClass.find_property} (as well as {@link
		 * GLib.ObjectClass.list_properties}, {@link
		 * GLib.Object.get_property}, and {@link
		 * GLib.Object.set_property}) to manage serialization
		 * of properties.  {@link GXml.Serializable} gives the
		 * implementing class an opportunity to override
		 * {@link GLib.ObjectClass.find_property} to control
		 * what properties exist for {@link GXml.Serialization}'s
		 * purposes.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized, find_property can be defined
		 * to return a {@link GLib.ParamSpec} for non-installed
		 * properties.  Other {@link GXml.Serializable} functions
		 * should be consistent with it.
		 *
		 * An implementing class might wish to maintain such
		 * {@link GLib.ParamSpec} s separately, rather than creating new
		 * ones for each call.
		 */
		public virtual GLib.ParamSpec? find_property_spec (string property_name) {
			init_properties ();
			string pn = property_name.down ();
			if (ignored_serializable_properties.contains (pn)) {
				return null;
			}
			return get_class ().find_property (pn);
		}

		/**
		 * Used internally to initialize {@link ignored_serializable_properties} property
		 * and default not to be serialized properties. Unless you override any function 
		 * is not required to be called at class implementor's construction time.
		 *
		 */
		public virtual void init_properties ()
		{
			if (ignored_serializable_properties == null) {
				ignored_serializable_properties = new HashTable<string,ParamSpec> (str_hash, str_equal);
				ignored_serializable_properties.set ("ignored-serializable-properties",
				                                     get_class ().find_property("ignored-serializable-properties"));
				ignored_serializable_properties.set ("unknown-serializable-property",
				                                     get_class ().find_property("unknown-serializable-property"));
				ignored_serializable_properties.set ("serialized-xml-node-value",
				                                     get_class ().find_property("serialized-xml-node-value"));
				ignored_serializable_properties.set ("serializable-property-use-nick",
				                                     get_class ().find_property("serializable-property-use-nick"));
				ignored_serializable_properties.set ("serializable-node-name",
				                                     get_class ().find_property("serializable-node-name"));
			}
			if (unknown_serializable_property == null) {
				unknown_serializable_property = new HashTable<string,GXml.Node> (str_hash, str_equal);
			}
		}

		/*
		 * List the known properties for an object's class
		 *
		 * @return an array of {@link GLib.ParamSpec} of
		 * "properties" for the object.
		 *
		 * {@link GXml.Serialization} uses
		 * {@link GLib.ObjectClass.list_properties} (as well as
		 * {@link GLib.ObjectClass.find_property},
		 * {@link GLib.Object.get_property}, and {@link GLib.Object.set_property})
		 * to manage serialization of an object's properties.
		 * {@link GXml.Serializable} gives an implementing class an
		 * opportunity to override
		 * {@link GLib.ObjectClass.list_properties} to control which
		 * properties exist for {@link GXml.Serialization}'s purposes.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized, list_properties can be
		 * defined to return a list of {@link GLib.ParamSpec} s covering
		 * all the "properties" to serialize.  Other
		 * {@link GXml.Serializable} functions should be consistent
		 * with it.
		 *
		 * An implementing class might wish to maintain such
		 * {@link GLib.ParamSpec} s separately, rather than creating new
		 * ones for each call.
		 */
		public virtual GLib.ParamSpec[] list_serializable_properties ()
		{
			init_properties ();
			ParamSpec[] props = {};
			foreach (ParamSpec spec in this.get_class ().list_properties ()) {
				if (!ignored_serializable_properties.contains (spec.name)) {
					props += spec;
				}
			}
			return props;
		}

		/*
		 * Get a string version of the specified property
		 *
		 * @param spec The property we're retrieving as a string.
		 *
		 * {@link GXml.Serialization} uses {@link GLib.Object.get_property} (as
		 * well as {@link GLib.ObjectClass.find_property},
		 * {@link GLib.ObjectClass.list_properties}, and
		 * {@link GLib.Object.set_property}) to manage serialization of
		 * an object's properties.  {@link GXml.Serializable} gives an
		 * implementing class an opportunity to override
		 * {@link GLib.Object.get_property} to control what value is
		 * returned for a given parameter.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized,
		 * {@link GXml.Serializable.get_property} can be used to
		 * handle this case as a virtual property, supported
		 * by the other {@link GXml.Serializable} functions.
		 *
		 * `spec` is usually obtained from list_properties or find_property.
		 *
		 * As indicated by its name, `str_value` is a {@link GLib.Value}
		 * that wants to hold a string type.
		 *
		 * @todo: why not just return a string? :D Who cares
		 * how analogous it is to {@link GLib.Object.get_property}? :D
		 */
		public virtual string get_property_value (GLib.ParamSpec spec) 
		{
			Value val = Value (spec.value_type);
			if (!ignored_serializable_properties.contains (spec.name))
			{
				Value ret = "";
				((GLib.Object)this).get_property (spec.name, ref val);
				if (Value.type_transformable (val.type (), typeof (string)))
				{
					val.transform (ref ret);
					return ret.dup_string ();
				}
			}
			return "";
		}
		/*
		 * Set a property's value.
		 *
		 * @param spec Specifies the property whose value will be set
		 * @param val The value to set the property to.
		 *
		 * {@link GXml.Serialization} uses {@link GLib.Object.set_property} (as
		 * well as {@link GLib.ObjectClass.find_property},
		 * {@link GLib.ObjectClass.list_properties}, and
		 * {@link GLib.Object.get_property}) to manage serialization of
		 * an object's properties.  {@link GXml.Serializable} gives an
		 * implementing class an opportunity to override
		 * {@link GLib.Object.set_property} to control how a property's
		 * value is set.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized,
		 * {@link GXml.Serializable.set_property} can be used to
		 * handle this case as a virtual property, supported
		 * by the other {@link GXml.Serializable} functions.
		 */
		public virtual void set_property_value (GLib.ParamSpec spec, GLib.Value val)
		{
			if (!ignored_serializable_properties.contains (spec.name)) {
				((GLib.Object)this).set_property (spec.name, val);
			}
		}
				/* TODO:
		 * - can't seem to pass delegates on struct methods to another function :(
		 * - no easy string_to_gvalue method in GValue :(
		 */

		/**
		 * Transforms a string into another type hosted by {@link GLib.Value}.
		 *
		 * A utility function that handles converting a string
		 * representation of a value into the type specified by the
		 * supplied #GValue dest.  A #GXmlSerializableError will be
		 * set if the string cannot be parsed into the desired type.
		 *
		 * @param str the string to transform into the given #GValue object
		 * @param dest the #GValue out parameter that will contain the parsed value from the string
		 * @return `true` if parsing succeeded, otherwise `false`
		 */
		/*
		 * @todo: what do functions written in Vala return in C when
		 * they throw an exception?  NULL/0/FALSE?
		 */
		public static bool string_to_gvalue (string str, ref GLib.Value dest)
		                                     throws SerializableError
		{
			Type t = dest.type ();
			GLib.Value dest2 = Value (t);
			bool ret = false;

			if (t == typeof (int64)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_int64 (val);
				}
			} else if (t == typeof (int)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_int ((int)val);
				}
			} else if (t == typeof (long)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_long ((long)val);
				}
			} else if (t == typeof (uint)) {
				uint64 val;
				if (ret = uint64.try_parse (str, out val)) {
					dest2.set_uint ((uint)val);
				}
			} else if (t == typeof (ulong)) {
				uint64 val;
				if (ret = uint64.try_parse (str, out val)) {
					dest2.set_ulong ((ulong)val);
				}
			} else if ((int)t == 20) { // gboolean
				bool val = (str == "TRUE");
				dest2.set_boolean (val); // TODO: huh, investigate why the type is gboolean and not bool coming out but is going in
				ret = true;
			} else if (t == typeof (bool)) {
				bool val;
				if (ret = bool.try_parse (str, out val)) {
					dest2.set_boolean (val);
				}
			} else if (t == typeof (float)) {
				double val;
				if (ret = double.try_parse (str, out val)) {
					dest2.set_float ((float)val);
				}
			} else if (t == typeof (double)) {
				double val;
				if (ret = double.try_parse (str, out val)) {
					dest2.set_double (val);
				}
			} else if (t == typeof (string)) {
				dest2.set_string (str);
				ret = true;
			} else if (t == typeof (char)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_char ((char)val);
				}
			} else if (t == typeof (uchar)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_uchar ((uchar)val);
				}
			} else if (t == Type.BOXED) {
			} else if (t.is_enum ()) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_enum ((int)val);
				}
			} else if (t.is_flags ()) {
			} else if (t.is_object ()) {
			} else {
			}

			if (ret == true) {
				dest = dest2;
				return true;
			} else {
				throw new SerializableError.UNSUPPORTED_TYPE ("%s/%s", t.name (), t.to_string ());
			}
		}

		public static string gvalue_to_string (GLib.Value val)
		                                     throws SerializableError
		{
			Value ret = "";
			if (Value.type_transformable (val.type (), typeof (string)))
			{
				val.transform (ref ret);
				return ret.dup_string ();
			}
			else
			{
				throw new SerializableError.UNSUPPORTED_TYPE ("Can't transform '%s' to string", val.type ().name ());
			}
		}
	}

	/**
	 * Errors from {@link Serialization}.
	 */
	public errordomain SerializableError {
		/**
		 * An object with a known {@link GLib.Type} that we do not support was encountered.
		 */
		UNSUPPORTED_TYPE
	}
}
