/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Serializable.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2013  Daniel Espinosa <esodan@gmail.com>
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

namespace GXml.Jgs {
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
	public interface Serializable : GLib.Object /*, GXml.Serializable*/ {
		/**
		 * Handles serializing potential tasks beyond
		 * serializing individual properties.
		 *
		 * {@link doc} is the {@link GXml.Document} that will
		 * ultimately contain the serialized object.  You can
		 * use it to create the {@link GXml.Node}s you want to
		 * add from here to the serialized object, like
		 * {@link GXml.Element}s, {@link GXml.DocumentFragment}s,
		 * and {@link GXml.Text}s.  Return your completed XML
		 * structure as a {@link GXml.Node} and it will be
		 * added to an <Object> element in the serialized XML.
		 *
		 * Example:
		 *
		 * Say we have a {@link GLib.Object}, Cookie, which
		 * looks like this in Vala,
		 *
		 * {{{
		 * class Cookie {
		 *   string flavour {}
		 *   int mass {}
		 * }
		 * }}}
		 *
		 * The default serialized XML might look like this
		 *
		 * {{{
		 * <Object otype="Cookie" oid="0xC00C1E5">
		 *   <Property ptype="gchar*" pname="flavour">Chocolate chip</Property>
		 *   <Property ptype="int" pname="mass">28</Property>
		 * </Object>
		 * }}}
		 *
		 * If we want additional information not connected to
		 * any of the properties, we could extend the Cookie
		 * class like this:
		 *
		 * {{{
		 * class Cookie : Serializable {
		 *   string flavour {}
		 *   int mass {}
		 *   public override Node? serialize (Node doc)
		 *     throws SerializationError {
		 *     return (doc as Document).create_comment ("<!-- baked on Nov 16 2013 by Wallace Wells -->");
		 *   }
		 * }}}
		 *
		 * This would result in the following serialized XML:
		 *
		 * {{{
		 * <Object otype="Cookie" oid="0xC00C1E5">
		 *   <!-- baked on Nov 16 2013 by Wallace Wells -->
		 *   <Property ptype="gchar*" pname="flavour">Chocolate chip</Property>
		 *   <Property ptype="int" pname="mass">28</Property>
		 * </Object>
		 * }}}
		 *
		 * If you want to completely handle serialization of
		 * your object yourself in {@link Serializable.serialize},
		 * you can prevent automatic serialization of properties
		 * by overriding {@link Serializable.serialize_property}
		 * and simply returning true.
		 *
		 * @param doc The {@link GXml.Document} that contains serialized XML, used to create new {@link GXml.Node}s.  It is represented as a {@link GXml.Node} for interface compatibility with other implementations.
		 *
		 * @return A {@link GXml.Node} representing serialized content from the implementing object
		 */
		public virtual GXml.Node?
		serialize (GXml.Node doc) {
			return null;
		}

		/**
		 * Handles serializing individual properties.
		 *
		 * Interface method to handle serialization of an
		 * individual property.  The implementing class
		 * receives a description of it, and should create a
		 * {@link GXml.Node} that encapsulates the property.
		 * {@link GXml.Jgs.Serialization} will embed the {@link GXml.Node} into
		 * a "Property" {@link GXml.Element}, so the {@link GXml.Node}
		 * returned can often be something as simple as
		 * {@link GXml.Text}.
		 *
		 * To let {@link GXml.Jgs.Serialization} attempt to automatically
		 * serialize the property itself, do not implement
		 * this method.  If the method returns %NULL,
		 * {@link GXml.Jgs.Serialization} will attempt handle it itself.
		 *
		 * @param doc The {@link GXml.Document} as a {@link GXml.Node} that the returned {@link GXml.Node} should belong to.  It is a {@link GXml.Node} for compatibility with other interface implementations.  Use it to create document nodes to represent the property.
		 * @param property_spec The {@link GLib.ParamSpec} describing the property
		 *
		 * @return a new {@link GXml.Node}, or %NULL
		 */
		public virtual GXml.Node?
		serialize_property (GXml.Node doc,
				    GLib.ParamSpec property_spec)
		throws GLib.Error {
			/* TODO: see if esodan changes xom's
			 * serialize_property to Element as per his
			 * e-mail dated "Wed, Apr 2, 2014 at 4:09
			 * PM" */
			return null;
		}

		/**
		 * Handle deserialization of an object beyond its
		 * properties.
		 *
		 * This can cover deserialization tasks outside of
		 * just properties, like initialising variables
		 * normally handled by a contructor.  (Note that when
		 * deserializing, an object's constructor is not
		 * called.)
		 *
		 * @param serialized_node The XML representation of this object
		 */
		public virtual GXml.Node?
		deserialize (GXml.Node serialized_node)
		throws GLib.Error {
			return;
		}

		/* TODO: consider making the visibility of all of
		 * these interface virtual methods to protected or
		 * internal.  In theory, only Serialization should
		 * need to actually see them.
		 */

		/**
		 * Handles deserializing individual properties.
		 *
		 * Interface method to handle deserialization of an
		 * individual property.  The implementing class
		 * receives a description of the property and the
		 * {@link GXml.Node} that contains the content.  The
		 * implementing {@link GXml.Jgs.Serializable} object can extract
		 * the data from the {@link GXml.Node} and store it in its
		 * property itself. Note that the {@link GXml.Node} may be
		 * as simple as a {@link GXml.Text} that stores the data as a
		 * string.
		 *
		 * If the implementation has handled deserialization,
		 * return true.  Return false if you want
		 * {@link GXml.Jgs.Serialization} to try to automatically
		 * deserialize it.  If {@link GXml.Jgs.Serialization} tries to
		 * handle it, it will want either {@link GXml.Serializable}'s
		 * set_property (or at least {@link GLib.Object.set_property})
		 * to know about the property.
		 *
		 * @param property_node the {@link GXml.Node} encapsulating data to deserialize; the node should carry the type, from which you can find the property spec if necessary
		 * @return `true` if the property was handled, `false` if {@link GXml.Jgs.Serialization} should handle it
		 */
		/*
		 * @todo: consider not giving property_name, but
		 * letting them get name from spec
		 * @todo: consider returning {@link GLib.Value} as out param
		 */
		public virtual bool
		deserialize_property (GXml.Node property_node)
		throws GLib.Error {
			return false; // default deserialize_property in jgs.Serialization gets used
		}


		/* Correspond to: g_object_class_{find_property,list_properties} */

		/*
		 * Handles finding the {@link GLib.ParamSpec} for a given property.
		 *
		 * {@link GXml.Jgs.Serialization} uses {@link
		 * GLib.ObjectClass.find_property} (as well as {@link
		 * GLib.ObjectClass.list_properties}, {@link
		 * GLib.Object.get_property}, and {@link
		 * GLib.Object.set_property}) to manage serialization
		 * of properties.  {@link GXml.Jgs.Serializable} gives the
		 * implementing class an opportunity to provide their own
		 * logic for 
		 * {@link GLib.ObjectClass.find_property} to control
		 * what properties exist for {@link GXml.Jgs.Serialization}'s
		 * purposes.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized, find_property_sn can be defined
		 * to return a {@link GLib.ParamSpec} for non-installed
		 * properties.  Other {@link GXml.Jgs.Serializable} functions
		 * should be consistent with it.
		 *
		 * An implementing class might wish to maintain such
		 * {@link GLib.ParamSpec} s separately, rather than creating new
		 * ones for each call.
		 *
		 * @param property_name the name of a property to obtain a {@link GLib.ParamSpec} for
		 * @return a {@link GLib.ParamSpec} describing the named property
		 */
		public virtual unowned GLib.ParamSpec? find_property_sn (string property_name) {
			return this.get_class ().find_property (property_name); // default
		}

		/*
		 * List the known properties for an object's class
		 *
		 * {@link GXml.Jgs.Serialization} uses
		 * {@link GLib.ObjectClass.list_properties} (as well as
		 * {@link GLib.ObjectClass.find_property},
		 * {@link GLib.Object.get_property}, and {@link GLib.Object.set_property})
		 * to manage serialization of an object's properties.
		 * {@link GXml.Serializable} gives an implementing class an
		 * opportunity to implement their own version of the logic of
		 * {@link GLib.ObjectClass.list_properties} to control which
		 * properties exist for {@link GXml.Jgs.Serialization}'s purposes.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized, list_properties_sn can be
		 * defined to return a list of {@link GLib.ParamSpec} s covering
		 * all the "properties" to serialize.  Other
		 * {@link GXml.Jgs.Serializable} functions should be consistent
		 * with it.
		 *
		 * An implementing class might wish to maintain such
		 * {@link GLib.ParamSpec} s separately, rather than creating new
		 * ones for each call.
		 *
		 * @return an array of {@link GLib.ParamSpec} of
		 * "properties" for the object.
		 */
		public virtual unowned GLib.ParamSpec[] list_properties_sn () {
			return this.get_class ().list_properties ();
		}

		/*
		 * Get a string version of the specified property
		 *
		 * {@link GXml.Jgs.Serialization} uses {@link GLib.Object.get_property} (as
		 * well as {@link GLib.ObjectClass.find_property},
		 * {@link GLib.ObjectClass.list_properties}, and
		 * {@link GLib.Object.set_property}) to manage serialization of
		 * an object's properties.  {@link GXml.Jgs.Serializable} gives an
		 * implementing class an opportunity to override
		 * {@link GLib.Object.get_property} to control what value is
		 * returned for a given parameter.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized,
		 * {@link GXml.Jgs.Serializable.get_property} can be used to
		 * handle this case as a virtual property, supported
		 * by the other {@link GXml.Jgs.Serializable} functions.
		 *
		 * `spec` is usually obtained from list_properties or
		 * find_property (or the corresponding link_properties_sn or
		 * find_property_sn).
		 *
		 * As indicated by its name, `str_value` is a {@link GLib.Value}
		 * that wants to hold a string type.
		 *
		 * @param spec The property we're retrieving as a string
		 *
		 * @todo: why not just return a string? :D Who cares
		 * how analogous it is to {@link GLib.Object.get_property}? :D
		 */
		public virtual void get_property_sn (GLib.ParamSpec spec, ref GLib.Value str_value) {
			((GLib.Object)this).get_property (spec.name, ref str_value);
		}
		/*
		 * Set a property's value.
		 *
		 * {@link GXml.Jgs.Serialization} uses {@link GLib.Object.set_property} (as
		 * well as {@link GLib.ObjectClass.find_property},
		 * {@link GLib.ObjectClass.list_properties}, and
		 * {@link GLib.Object.get_property}) to manage serialization of
		 * an object's properties.  {@link GXml.Jgs.Serializable} gives an
		 * implementing class an opportunity to override
		 * {@link GLib.Object.set_property} to control how a property's
		 * value is set.
		 *
		 * For instance, if an object has private data fields
		 * that are not installed public properties, but that
		 * should be serialized,
		 * {@link GXml.Jgs.Serializable.set_property} can be used to
		 * handle this case as a virtual property, supported
		 * by the other {@link GXml.Jgs.Serializable} functions.
		 *
		 * @param spec Specifies the property whose value will be set
		 * @param value The value to set the property to
		 */
		public virtual void set_property_sn (GLib.ParamSpec spec, GLib.Value value) {
			((GLib.Object)this).set_property (spec.name, value);
		}
	}
}
