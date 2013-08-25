/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Serializable.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
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
		 * If the implementation has handled deserialization,
		 * return true.  Return false if you want
		 * {@link GXml.Serialization} to try to automatically
		 * deserialize it.  If {@link GXml.Serialization} tries to
		 * handle it, it will want either {@link GXml.Serializable}'s
		 * set_property (or at least {@link GLib.Object.set_property})
		 * to know about the property.
		 *
		 * @param property_name the name of the property as a string
		 * @param spec the {@link GLib.ParamSpec} describing the property.
		 * @param property_node the {@link GXml.Node} encapsulating data to deserialize
		 * @return `true` if the property was handled, `false` if {@link GXml.Serialization} should handle it.
		 */
		/*
		 * @todo: consider not giving property_name, but
		 * letting them get name from spec
		 * @todo: consider returning {@link GLib.Value} as out param
		 */
		public virtual bool deserialize_property (string         property_name,
							  GLib.ParamSpec spec,
							  GXml.Node      property_node) {
			return false; // default deserialize_property gets used
		}

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
		/*
		 * @todo: consider not giving property_name, let them get name from spec?
		 */
		public virtual GXml.Node? serialize_property (string         property_name,
							      GLib.ParamSpec spec,
							      GXml.Document  doc) {
			return null; // default serialize_property gets used
		}

		/* Correspond to: g_object_class_{find_property,list_properties} */

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
		public virtual unowned GLib.ParamSpec? find_property (string property_name) {
			return this.get_class ().find_property (property_name); // default
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
		public virtual unowned GLib.ParamSpec[] list_properties () {
			return this.get_class ().list_properties ();
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
		public virtual void get_property (GLib.ParamSpec spec,
						  ref GLib.Value str_value) {
			((GLib.Object)this).get_property (spec.name, ref str_value);
		}
		/*
		 * Set a property's value.
		 *
		 * @param spec Specifies the property whose value will be set
		 * @param value The value to set the property to.
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
		public virtual void set_property (GLib.ParamSpec spec,
						  GLib.Value     value) {
			((GLib.Object)this).set_property (spec.name, value);
		}
	}
}
