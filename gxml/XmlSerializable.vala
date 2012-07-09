/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

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

using GXmlDom;

[CCode (gir_namespace = "GXmlDom", gir_version = "0.2")]
namespace GXmlDom {
	public errordomain SerializationError {
		UNKNOWN_TYPE,
		UNKNOWN_PROPERTY,
		UNSUPPORTED_TYPE
	}

	public class Serialization : GLib.Object {
		private static void print_debug (GXmlDom.Document doc, GLib.Object object) {
			stdout.printf ("Object XML\n---\n%s\n", doc.to_string ());

			stdout.printf ("object\n---\n");
			stdout.printf ("get_type (): %s\n", object.get_type ().name ());
			stdout.printf ("get_class ().get_type (): %s\n", object.get_class ().get_type ().name ());

			ParamSpec[] properties;
			properties = object.get_class ().list_properties ();
			stdout.printf ("object has %d properties\n", properties.length);
			foreach (ParamSpec prop_spec in properties) {
				stdout.printf ("---\n");
				stdout.printf ("name: %s\n", prop_spec.name);
				stdout.printf ("value_type: %s\n", prop_spec.value_type.name ());
				stdout.printf ("owner_type: %s\n", prop_spec.owner_type.name ());
				stdout.printf ("get_name (): %s\n", prop_spec.get_name ());
				stdout.printf ("get_blurb (): %s\n", prop_spec.get_blurb ());
				stdout.printf ("get_nick (): %s\n", prop_spec.get_nick ());
			}
		}

		private static GXmlDom.XNode serialize_property (GLib.Object object, ParamSpec prop_spec, GXmlDom.Document doc) throws SerializationError, DomError {
			Type type;
			Value value;
			XNode value_node;

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
				//GLib.warning ("value: %d", value);
				value_node = doc.create_text_node (value.get_string ());
			} else if (type == typeof (GLib.Type)) {
				value_node = doc.create_text_node (type.name ());
				// } else if (type == typeof (GLib.HashTable)) {
				// } else if (type == typeof (Gee.List)) { // TODO: can we do a catch all for Gee.Collection and have <Collection /> ?
				// } else if (type.is_a (typeof (Gee.Collection))) {
			} else if (type.is_a (typeof (GLib.Object))) {
				// TODO: this is going to get complicated
				value = Value (typeof (GLib.Object));
				object.get_property (prop_spec.name, ref value);
				GLib.Object child_object = value.get_object ();
				value_node = Serialization.serialize_object (child_object); // catch serialisation errors?
				// TODO: caller will append_child; can we cross documents like this?  Probably not :D want to be able to steal?, attributes seem to get lost
			} else {
				throw new SerializationError.UNSUPPORTED_TYPE ("Can't currently serialize type '%s' for property '%s' of object '%s'", type.name (), prop_spec.name, object.get_type ().name ());
			}

			return value_node;
		}

		/* TODO: so it seems we can get property information from GObjectClass
		   but that's about it.  Need to definitely use introspection for anything
		   tastier */
		public static GXmlDom.XNode serialize_object (GLib.Object object) throws SerializationError {
			Document doc;
			Element root;
			ParamSpec[] prop_specs;
			Element prop;
			Serializable serializable = null;
			XNode value_prop = null;

			if (object.get_type ().is_a (typeof (Serializable))) {
				serializable = (Serializable)object;
			}

			/* Create an XML Document to return the object
			   in.  TODO: consider just returning an
			   <Object> node; but then we'd probably want
			   a separate document for it to already be a
			   part of as its owner_document. */
			try {
				doc = new Document ();
				root = doc.create_element ("Object");
				doc.append_child (root);
				root.set_attribute ("otype", object.get_type ().name ());

				/* TODO: make sure we don't use an out param for our returned list
				   size in our interface's list_properties (), using
				   [CCode (array_length_type = "guint")] */
				if (serializable != null) {
					prop_specs = serializable.list_properties ();
				} else {
					prop_specs = object.get_class ().list_properties ();
				}

				/* Exam the properties of the object and store
				   them with their name, type and value in XML
				   Elements.  Use GValue to convert them to
				   strings. (Too bad deserialising isn't that
				   easy w.r.t. string conversion.) */
				foreach (ParamSpec prop_spec in prop_specs) {
					prop = doc.create_element ("Property");
					prop.set_attribute ("ptype", prop_spec.value_type.name ());
					prop.set_attribute ("pname", prop_spec.name);

					value_prop = null;
					if (serializable != null) {
						value_prop = serializable.serialize_property (prop_spec.name, prop_spec, doc);
					}
					if (value_prop == null) {
						value_prop = Serialization.serialize_property (object, prop_spec, doc);
					}

					prop.append_child (value_prop);
					root.append_child (prop);
				}
			} catch (GXmlDom.DomError e) {
				GLib.error ("%s", e.message);
				// TODO: handle this better
			}

			/* Debug output */
			bool debug = false;
			if (debug) {
				Serialization.print_debug (doc, object);
			}

			return doc.document_element; // user can get Document through .owner_document
		}

		private static void deserialize_property (ParamSpec spec, Element prop_elem, out Value val) throws SerializationError {
			Type type;

			type = spec.value_type;

			// if (false || ptype != "") {
			// 	// TODO: undisable if we support fields at some point
			// 	type = Type.from_name (ptype);
			// 	if (type == 0) {
			// 		/* This probably shouldn't happen while we're using
			// 		   ParamSpecs but if we support non-property fields
			// 		   later, it might be necessary again :D */
			// 		throw new SerializationError.UNKNOWN_TYPE ("Deserializing object '%s' has property '%s' with unknown type '%s'", otype, pname, ptype);
			// 	}
			// }

			// Get value and save this all as a parameter
			bool transformed = false;
			val = Value (type);
			if (GLib.Value.type_transformable (type, typeof (string))) {
				try {
					string_to_gvalue (prop_elem.content, ref val);
					transformed = true;
				} catch (SerializationError e) {
					throw new SerializationError.UNSUPPORTED_TYPE ("string_to_gvalue should transform it but failed");
				}
			// } else if (type.is_a (typeof (Gee.Collection))) {
			} else if (type.is_a (typeof (GLib.Object))) {
				GXmlDom.XNode prop_elem_child;
				Object property_object;

				try {
					prop_elem_child = prop_elem.first_child;
					property_object = Serialization.deserialize_object (prop_elem_child);
					val.set_object (property_object);
					transformed = true;
				} catch (GXmlDom.SerializationError e) {
					// We don't want this one caught by deserialize_object, or we'd have a cascading error message.  Hmm, not so bad if it does, though.
					e.message += "\nXML [%s]".printf (prop_elem.to_string ());
					throw e;
				}
			}

			if (transformed == false) {
				throw new SerializationError.UNSUPPORTED_TYPE ("Failed to transform property from string to type.");
			}
		}

		public static GLib.Object deserialize_object (XNode node) throws SerializationError {
			Element obj_elem;

			string otype;
			Type type;
			Object obj;
			unowned ObjectClass obj_class;
			ParamSpec[] specs;
			bool property_found;
			Serializable serializable = null;

			obj_elem = (Element)node;

			// Get the object's type
			// TODO: wish there was a g_object_class_from_name () method
			otype = obj_elem.get_attribute ("otype");
			type = Type.from_name (otype);
			if (type == 0) {
				throw new SerializationError.UNKNOWN_TYPE ("Deserializing object claims unknown type '%s'", otype);
			}

			// Get the list of properties as ParamSpecs
			obj = Object.newv (type, new Parameter[] {}); // TODO: causes problems with Enums when 0 isn't a valid enum value (e.g. starts from 2 or something)
			obj_class = obj.get_class ();

			if (type.is_a (typeof (Serializable))) {
				serializable = (Serializable)obj;
			}

			if (serializable != null) {
				specs = serializable.list_properties ();
			} else {
				specs = obj_class.list_properties ();
			}

			foreach (XNode child_node in obj_elem.child_nodes) {
				if (child_node.node_name == "Property") {
					Element prop_elem;
					string pname;
					Value val;
					//string ptype;

					prop_elem = (Element)child_node;
					pname = prop_elem.get_attribute ("pname");
					//ptype = prop_elem.get_attribute ("ptype"); // optional

					// Check name and type for property
					ParamSpec? spec = null;
					if (serializable != null) {
						spec = serializable.find_property (pname);
					} else {
						spec = obj_class.find_property (pname);
					}

					if (spec == null) {
						throw new SerializationError.UNKNOWN_PROPERTY ("Deserializing object of type '%s' claimed unknown property named '%s'\nXML [%s]", otype, pname, obj_elem.to_string ());
					}

					try {
						bool serialized = false;

						if (serializable != null) {
							serialized = serializable.deserialize_property (spec.name, /* out val, */ spec, prop_elem); // TODO: consider rearranging these or the ones in Serializer to match
						}
						if (!serialized) {
							Serialization.deserialize_property (spec, prop_elem, out val);
							obj.set_property (pname, val);
							// TODO: should we make a note that for implementing {get,set}_property in the interface, they should specify override (in Vala)?  What about in C?  Need to test which one gets called in which situations (yeah, already read the tutorial)
						}
					} catch (SerializationError.UNSUPPORTED_TYPE e) {
						throw new SerializationError.UNSUPPORTED_TYPE ("Cannot deserialize object '%s's property '%s' with type '%s/%s': %s\nXML [%s]",
											       otype, spec.name, spec.value_type.name (), spec.value_type.to_string (), e.message, obj_elem.to_string ());
					}
				}
			}

			return obj;
		}

		/* TODO:
		 * - can't seem to pass delegates on struct methods to another function :(
		 * - no easy string_to_gvalue method in GValue :(
		 */
		public static bool string_to_gvalue (string str, ref GLib.Value dest) throws SerializationError {
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
				throw new SerializationError.UNSUPPORTED_TYPE ("%s/%s", t.name (), t.to_string ());
			}
		}
	}

	public interface Serializable : GLib.Object {
		/** Return true if your implementation will have handled the given property,
		    and false elsewise (in which case, XmlSerializable will try to deserialize
		    it).  */
		/** OBSOLETENOTE: Return the deserialized value in GLib.Value (even if it's a GLib.Boxed type) because Serializer is going to set the property after calling this, and if you just set it yourself within, it will be overwritten */
		public virtual bool deserialize_property (string property_name, /* out GLib.Value value, */ GLib.ParamSpec spec, GXmlDom.XNode property_node) {
			return false; // default deserialize_property gets used
		}
		// TODO: just added ? to these, do we really want to allow nulls for them?
		// TODO: value and property_name are kind of redundant: eliminate?  property_name from spec.property_name and value from the object itself :)
		/** Serialized properties should have the XML structure <Property pname="PropertyName">...</Property> */
		// TODO: perhaps we should provide that base structure
		public virtual GXmlDom.XNode? serialize_property (string property_name, /*GLib.Value value,*/ GLib.ParamSpec spec, GXmlDom.Document doc) {
			return null; // default serialize_property gets used
		}

		/* Correspond to: g_object_class_{find_property,list_properties} */
		public virtual unowned GLib.ParamSpec? find_property (string property_name) {
			return this.get_class ().find_property (property_name); // default
		}
		public virtual unowned GLib.ParamSpec[] list_properties () {
			return this.get_class ().list_properties ();
		}

		/* Correspond to: g_object_{set,get}_property */
		public abstract void get_property (GLib.ParamSpec spec, ref GLib.Value value);
		public abstract void set_property (GLib.ParamSpec spec, GLib.Value value);
	}
}
