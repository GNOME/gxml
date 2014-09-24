/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Serialization.vala
 *
 * Copyright (C) 2012-2013  Richard Schwarting <aquarichy@gmail.com>
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
 */

/* TODO: so it seems we can get property information from GObjectClass
   but that's about it.  Need to definitely use introspection for anything
   tastier */
/* TODO: document memory management for the C side */


namespace GXml {
	private static void print_object_properties (GLib.Object obj) {
		ParamSpec[] properties;
		properties = obj.get_class ().list_properties ();
		stdout.printf ("object has %d properties\n", properties.length);
		foreach (ParamSpec prop_spec in properties) {
			stdout.printf ("---\n");
			stdout.printf ("name            %s\n", prop_spec.name);
			stdout.printf ("  value_type    %s\n", prop_spec.value_type.name ());
			stdout.printf ("  owner_type    %s\n", prop_spec.owner_type.name ());
			stdout.printf ("  get_name ()   %s\n", prop_spec.get_name ());
			stdout.printf ("  get_blurb ()  %s\n", prop_spec.get_blurb ());
			stdout.printf ("  get_nick ()   %s\n", prop_spec.get_nick ());
		}
	}

	/**
	 * Errors from {@link Serialization}.
	 */
	public errordomain SerializationError {
		/**
		 * An unknown {@link GLib.Type} was encountered.
		 */
		UNKNOWN_TYPE,
		/**
		 * A property was described in XML that is not known {@link GLib.Type}.
		 */
		UNKNOWN_PROPERTY,
		/**
		 * Serialization/Deserialization is unsupported for given object type
		 */
		UNSUPPORTED_OBJECT_TYPE,
		/**
		 * Serialization/Deserialization is unsupported for given property type
		 */
		UNSUPPORTED_PROPERTY_TYPE,
		/**
		 * Serialization/Deserialization is unsupported for given {@link GLib.Type}
		 */
		UNSUPPORTED_TYPE,
		/**
		 * Serialization/Deserialization is unsupported for given XML structure
		 */
		UNSUPPORTED_FILE_FORMAT
	}

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
	public class Serialization : GLib.Object {
		private static void print_debug (GXml.Document doc, GLib.Object object) {
			stdout.printf ("Object XML\n---\n%s\n", doc.to_string ());

			stdout.printf ("object\n---\n");
			stdout.printf ("get_type (): %s\n", object.get_type ().name ());
			stdout.printf ("get_class ().get_type (): %s\n", object.get_class ().get_type ().name ());
			GXml.print_object_properties (object);
		}

		/*
		 * This coordinates the automatic serialization of individual
		 * properties.  As of 0.2, it supports enums, anything that
		 * {@link GLib.Value} can transform into a string, and
		 * operates recursively.
		 */
		private static GXml.Node serialize_property (GLib.Object object,
		                                             ParamSpec prop_spec,
		                                             GXml.Document doc)
						                                         throws GLib.Error
		{
			Type type;
			Value value;
			GXml.Node value_node;
			Serializable serializable = null;

			if (object.get_type ().is_a (typeof (Serializable))) {
				serializable = (Serializable)object;
			}

			type = prop_spec.value_type;

			if (prop_spec.value_type.is_enum ()) {
				/* We're going to handle this simply by saving it
				   as an int.  If we save a string representation,
				   we can't easily convert it back to the number
				   in a generic fashion unless we can use GEnumClass,
				   but I can't figure out how to get that right now,
				   except from a GParamSpecEnum, but I don't know
				   how to get that, at least in Vala (e.g. is it
				   supposed to be as simple in C as casting the
				   GParamSpec for an enum to GParamSpecEnum (assuming
				   it truly is the latter, but is returned as the
				   former by list_properties) */
				value = Value (typeof (int));
				object.get_property (prop_spec.name, ref value);
				value_node = doc.create_text_node ("%d".printf (value.get_int ()));
				/* TODO: in the future, perhaps figure out GEnumClass
				         and save it as the human readable enum value :D */
			} else if (Value.type_transformable (prop_spec.value_type, typeof (string))) { // e.g. int, double, string, bool
				value = Value (typeof (string));
				object.get_property (prop_spec.name, ref value);
				value_node = doc.create_text_node (value.get_string ());
			} else if (type == typeof (GLib.Type)) {
				value_node = doc.create_text_node (type.name ());
/*
			} else if (type.is_a (typeof (Gee.Collection))) {
			    // We need to be able to figure out
				// * what generics it has, and
				// * any parametres for delegates it might have used.
				GXml.print_object_properties (object);
				value_node = null;
			} else if (type == typeof (GLib.HashTable)) {

			} else if (type == typeof (Gee.List)) {
				// TODO: can we do a catch all for Gee.Collection and have <Collection /> ?
			} else if (type.is_a (typeof (Gee.TreeSet))) {
				object.get_property (prop_spec, ref value);
				doc.create_element ("Collection");
				foreach (Object member in
			} else if {
				g-dup-func gpointer
			    GParamPointer
			    $43 = {g_type_instance = {g_class = 0x67ad30}, name = 0x7ffff7b7d685 "g-dup-func", flags = 234, value_type = 68, owner_type = 14758512, _nick = 0x7ffff7b7d67c "dup func", _blurb =
				0x7ffff7b7d67c "dup func", qdata = 0x0, ref_count = 4, param_id = 2}
*/
			} else if (type.is_a (typeof (GLib.Object))
			           && ! type.is_a (typeof (Gee.Collection)))
			  {
					GLib.Object child_object;

					// TODO: this is going to get complicated
					value = Value (typeof (GLib.Object));
					object.get_property (prop_spec.name, ref value);
					/* This can fail; consider case of Gee.TreeSet that isn't special cased above, gets error
						 (/home/richard/mine/development/gnome/gdom/gxml/test/.libs/gxml_test:10996):
						 GLib-GObject-CRITICAL **: Read-only property 'read-only-view' on class 'GeeReadOnlyBidirSortedSet' has type
						 'GeeSortedSet' which is not equal to or more restrictive than the type 'GeeBidirSortedSet' of the property
						 on the interface 'GeeBidirSortedSet' */
					child_object = value.get_object ();
					Document value_doc = Serialization.serialize_object (child_object); // catch serialisation errors?
					// TODO: Make copy_node public to allow others to use it
					value_node = doc.copy_node (value_doc.document_element);
			} else if (type.name () == "gpointer") {
				GLib.warning ("DEBUG: skipping gpointer with name '%s' of object '%s'", prop_spec.name, object.get_type ().name ());
				value_node = doc.create_text_node (prop_spec.name);
			} else {
				throw new SerializationError.UNSUPPORTED_PROPERTY_TYPE ("Can't currently serialize type '%s' for property '%s' of object '%s'", type.name (), prop_spec.name, object.get_type ().name ());
			}

			return value_node;
		}

		/**
		 * Serializes a {@link GLib.Object} into a {@link GXml.Document}.
		 *
		 * This takes a {@link GLib.Object} and serializes it
		 * into a {@link GXml.Document} which can be saved to
		 * disk or transferred over a network.  It handles
		 * serialization of primitive properties and some more
		 * complex ones like enums, other {@link GLib.Object}s
		 * recursively, and some collections.
		 *
		 * The serialization process can be customised for an object
		 * by having the object implement the {@link GXml.Serializable}
		 * interface, which allows direct control over the
		 * conversation of individual properties into {@link GXml.Node}s
		 * and the object's list of properties as used by
		 * {@link GXml.Serialization}.
		 *
		 * A {@link GXml.SerializationError} may be thrown if there is
		 * a problem serializing a property (e.g. the type is unknown,
		 * unsupported, or the property isn't known to the object).
		 *
		 * @param object A {@link GLib.Object} to serialize
		 * @return a {@link GXml.Document} representing the serialized `object`
		 */
		public static GXml.Document serialize_object (GLib.Object object) throws GLib.Error
		{
			Document doc;
			Element root;
			ParamSpec[] prop_specs;
			Element prop;
			GXml.Node value_prop = null;
			string oid;

			Serialization.init_caches ();
			/* Create an XML Document to return the object
			in.  TODO: consider just returning an
			<Object> node; but then we'd probably want
			a separate document for it to already be a
			part of as its owner_document. */
			doc = new Document ();
			if (object is Serializable) {
				((Serializable) object).serialize (doc);
				return doc;
			}
			// If the object has been serialized before, let's not do it again!
			oid = "%p".printf (object);
			// first, check if its been serialised already, and if so, just return an ObjectRef element for it.
			if (oid != "" && Serialization.serialize_cache.contains (oid)) {
				// GLib.message ("cache hit on oid %s", oid);
				root = doc.create_element ("ObjectRef");
				doc.append_child (root);
				root.set_attribute ("otype", object.get_type ().name ());
				root.set_attribute ("oid", oid);
				return doc;
			}

			if (object is Serializable) {
				((Serializable) object).serialize (doc);
				Serialization.serialize_cache.set (oid, doc.document_element);
				return doc;
			}
			// For now and on assume is not a Serializable object
			root = doc.create_element ("Object");
			doc.append_child (root);
			root.set_attribute ("otype", object.get_type ().name ());
			root.set_attribute ("oid", oid);
			// Cache this before we start exploring properties in case there's a cycle
			Serialization.serialize_cache.set (oid, root);

			/* TODO: make sure we don't use an out param for our returned list
			   size in our interface's list_properties (), using
			   [CCode (array_length_type = "guint")] */
			prop_specs = object.get_class ().list_properties ();

			/* Exam the properties of the object and store
			   them with their name, type and value in XML
			   Elements.  Use GValue to convert them to
			   strings. (Too bad deserialising isn't that
			   easy w.r.t. string conversion.) */
			foreach (ParamSpec prop_spec in prop_specs) {
				prop = doc.create_element ("Property");
				prop.set_attribute ("ptype", prop_spec.value_type.name ());
				prop.set_attribute ("pname", prop_spec.name);
				value_prop = Serialization.serialize_property (object, prop_spec, doc);
				prop.append_child (value_prop);
				root.append_child (prop);
			}

			/* Debug output */
			bool debug = false;
			if (debug) {
				Serialization.print_debug (doc, object);
			}

			return doc;
		}

		/*
		 * This handles deserializing properties individually.
		 * Because {@link GLib.Value} doesn't handle transforming
		 * strings back to other types, we use our own function to do
		 * that.
		 */
		private static void deserialize_property (ParamSpec spec, Element prop_elem,
		                                          out Value val)
		                                          throws GLib.Error
		{
			Type type;
			type = spec.value_type;
			// Get value and save this all as a parameter
			val = Value (type);
			if (GLib.Value.type_transformable (type, typeof (string))) {
					Serializable.string_to_gvalue (prop_elem.content, ref val);
			} else if (type.is_a (typeof (GLib.Object))) {
				GXml.Node prop_elem_child;
				Object property_object;
				prop_elem_child = prop_elem.first_child;
				property_object = Serialization.deserialize_object_from_node (prop_elem_child);
				val.set_object (property_object);
			}
		}

		/**
		 * FIXME: DON'T USE CACHE. SERIALIZE OVER NEW OBJECTS OR OVERWRITE PROPERTIES.
		 *       When serialize a set of objects, you can add Node Elements <Object>
		 *       as many as objects you have serialized to the XML Document. On
		 *       deserialization, you must create a new GObject, on the fly, for each
		 *       <Object> tag found in the file.
		 *
		 * This table is used while deserializing objects to avoid
		 * creating duplicate objects when we encounter multiple
		 * references to a single serialized object.
		 *
		 * TODO: one problem, if you deserialize two XML structures,
		 * some differing objects might have the same OID :( Need to
		 * find make it more unique than just the memory address.  SEE ABOVE!!!!*/
		private static HashTable<string,Object> deserialize_cache = null;
		private static HashTable<string,GXml.Node> serialize_cache = null;
		// public so that tests can call it
		public static void clear_cache () { // TODO: rename to clear_caches, just changed back temporarily to avoid API break for 0.3.2
			if (Serialization.deserialize_cache != null)
				Serialization.deserialize_cache.remove_all ();
			if (Serialization.serialize_cache != null)
				Serialization.serialize_cache.remove_all ();
		}

		private static void init_caches () {
			if (Serialization.deserialize_cache == null) {
				Serialization.deserialize_cache = new HashTable<string,Object> (str_hash, str_equal);
			}
			if (Serialization.serialize_cache == null) {
				Serialization.serialize_cache = new HashTable<string,GXml.Node> (str_hash, str_equal);
			}
		}

		/**
		 * Deserialize a {@link GXml.Document} back into a {@link GLib.Object}.
		 * 
		 * This deserializes a {@link GXml.Document} back into a
		 * {@link GLib.Object}.  The {@link GXml.Document}
		 * must represent a {@link GLib.Object} as serialized
		 * by {@link GXml.Serialization}.  The types of the
		 * objects that are being deserialized must be known
		 * to the system deserializing them or a
		 * {@link GXml.SerializationError} will result.
		 * 
		 * @param type object type to deserialize
		 * @param doc a {@link GXml.Document} to deseralize from
		 * @return the deserialized {@link GLib.Object}
		 */
		public static GLib.Object deserialize_object (Type type, GXml.Document doc) throws GLib.Error
		{
			if (type.is_a (typeof (Serializable))) {
				Object object = Object.new (type);
				((Serializable) object).deserialize (doc);
				return object;
			}
			return deserialize_object_from_node (doc.document_element);
		}

		/**
		 * This function must assume deserialize over non-Serializable objects
		 * because Serializable have its own method serialize/deserialize
		 */
		internal static GLib.Object? deserialize_object_from_node (GXml.Node obj_node) 
		                                                          throws GLib.Error
		{
			Element obj_elem;
			string otype;
			string oid;
			Type type;
			Object obj;
			unowned ObjectClass obj_class;
			ParamSpec[] specs;

			obj_elem = (Element)obj_node;

			// FIXME: Remove cache.
			// If the object has been deserialised before, get it from cache
			oid = obj_elem.get_attribute ("oid");
			Serialization.init_caches ();
			if (oid != "" && Serialization.deserialize_cache.contains (oid)) {
				return Serialization.deserialize_cache.get (oid);
			}

			// Get the object's type
			// TODO: wish there was a g_object_class_from_name () method
			otype = obj_elem.get_attribute ("otype");
			type = Type.from_name (otype);
			if (type == 0) {
				throw new SerializationError.UNKNOWN_TYPE ("Deserializing unknown GType '%s' objects is unsupported", otype);
			}
			
			if (type.is_a (typeof (Serializable))) {
				obj = Object.new (type);
				((Serializable) obj).deserialize (obj_node);
				return obj;
			}

			// Get the list of properties as ParamSpecs
			obj = Object.newv (type, new Parameter[] {}); // TODO: causes problems with Enums when 0 isn't a valid enum value (e.g. starts from 2 or something)
			obj_class = obj.get_class ();

			// Set it as the last possible action, so that invalid objects won't end up getting stored // Changed our mind, for deserializing ObjectRefs
			Serialization.deserialize_cache.set (oid, obj);
			specs = obj_class.list_properties ();

			foreach (GXml.Node child_node in obj_elem.child_nodes) {
				if (child_node.node_name == "Property") {
					Element prop_elem;
					string pname;
					Value val;

					prop_elem = (Element)child_node;
					pname = prop_elem.get_attribute ("pname");
					// Check name and type for property
					ParamSpec? spec = null;
					spec = obj_class.find_property (pname);

					if (spec == null) {
						throw new SerializationError.UNKNOWN_PROPERTY ("Unknown property '%s' found, for object type '%s'-->XML: [%s]", pname, otype, obj_elem.to_string ());
						return null;
					}
					Serialization.deserialize_property (spec, prop_elem, out val);
					obj.set_property (pname, val);
				}
			}
			return obj;
		}
	}
}
