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
		UNKNOWN_PROPERTY
	}

	public class Serializer : GLib.Object {
		/* TODO: so it seems we can get property information from GObjectClass
		   but that's about it.  Need to definitely use introspection for anything
		   tastier */
		public GXmlDom.XNode serialize_object (GLib.Object object) {
			Document doc;
			Element root;
			ParamSpec[] prop_specs;
			Element prop;
			Value value;

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
					
					value = Value (typeof (string));
					object.get_property (prop_spec.name, ref value);
					prop.content = value.get_string ();
					root.append_child (prop);
				}
			} catch (GXmlDom.DomError e) {
				GLib.error ("%s", e.message);
				// TODO: handle this better
			}

			/* Debug output */
			bool debug = false;
			if (debug) {
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

			return doc.document_element; // user can get Document through .owner_document
		}

		public GLib.Object deserialize_object (XNode node) throws SerializationError {
			Element obj_elem;
			NodeList properties;

			string otype;
			Type type;
			Object obj;
			unowned ObjectClass obj_class;
			ParamSpec[] specs;
			bool property_found;

			obj_elem = (Element)node;

			// Get the object's type
			// TODO: wish there was a g_object_class_from_name () method
			otype = obj_elem.get_attribute ("otype");
			type = Type.from_name (otype);
			if (type == 0) {
				throw new SerializationError.UNKNOWN_TYPE ("Deserializing object claims unknown type '%s'", otype);
			}

			// Get the list of properties as ParamSpecs
			obj = Object.newv (type, new Parameter[] {});
			obj_class = obj.get_class ();
			specs = obj_class.list_properties ();

			// Get ready to collect properties as parameters
			properties = obj_elem.get_elements_by_tag_name ("Property");
			parameters = new Parameter[properties.length];
			names = new string[properties.length]; // because Parameter.name is unowned

			for (int i = 0; i < properties.length; i++) {
				Element prop_elem;
				string pname;
				string ptype;
				Value val;

				prop_elem = (Element)properties.nth (i);
				pname = prop_elem.get_attribute ("pname");
				ptype = prop_elem.get_attribute ("ptype"); // optional

				// Check name and type for property
				property_found = false;
				foreach (ParamSpec spec in specs) {
					if (spec.name == pname) {
						// only doing this if ptype omitted
						// want ptype shown in XML for readability?
						type = spec.value_type;
						property_found = true;
					}
				}
				if (!property_found) {
					throw new SerializationError.UNKNOWN_PROPERTY ("Deserializing object of type '%s' claimed unknown property named '%s'", otype, pname);
				}

				if (false || ptype != "") {
					// TODO: undisable if we support fields at some point
					type = Type.from_name (ptype);
					if (type == 0) {
						/* This probably shouldn't happen while we're using
						   ParamSpecs but if we support non-property fields
						   later, it might be necessary again :D */
						throw new SerializationError.UNKNOWN_TYPE ("Deserializing object '%s' has property '%s' with unknown type '%s'", otype, pname, ptype);
					}
				}

				// Get value and save this all as a parameter
				val = Value (type);
				string_to_gvalue (prop_elem.content, ref val);

				obj.set_property (pname, val);
			}

			return obj;
		}

		/* TODO:
		 * - can't seem to pass delegates on struct methods to another function :(
		 * - no easy string_to_gvalue method in GValue :(
		 */
		public static bool string_to_gvalue (string str, ref GLib.Value dest) {
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
			} else if (t.is_flags ()) {
			} else if (t.is_object ()) {
			} else {
			}

			if (ret == true) {
				dest = dest2;
				return true;
			} else {
				GLib.warning ("Cannot convert from string to type '%s' yet.", t.to_string ());
				return false;
			}
		}
	}

	public interface SerializableInterface : GLib.Object {
		public abstract void deserialize_property (string property_name, out GLib.Value value, GLib.ParamSpec spec, GXmlDom.XNode property_node);
		// TODO: just added ? to these, do we really want to allow nulls for them?
		public abstract GXmlDom.XNode? serialize_property (string property_name, GLib.Value value, GLib.ParamSpec spec);

		/* Correspond to: g_object_class_{find_property,list_properties} */
		public abstract GLib.ParamSpec? find_property (string property_name);
		public abstract GLib.ParamSpec[]? list_properties (out int num_specs); // TODO: probably unowned

		/* Correspond to: g_object_{set,get}_property */
		public abstract void get_property (GLib.ParamSpec spec, GLib.Value value); // TODO: const?
		public abstract void set_property (GLib.ParamSpec spec, GLib.Value value); // TODO: const?
	}
	
	// TODO: what is this below? 
	/**
	 * SECTION:gxml-serializable
	 * @short-description: Serialize and deserialize GObjects
	 *
	 * TODO: elaborate
	 */
	public class Serializable : SerializableInterface, GLib.Object {
		void deserialize_property (string property_name, out GLib.Value value, GLib.ParamSpec spec, GXmlDom.XNode property_node) {
			// TODO: mimic json_deserialize_pspec
			// TODO: consider returning GLib.Value instead of using an out param?

			// convert from XML to a GLib.Value
			return;
		}
		GXmlDom.XNode? serialize_property (string property_name, GLib.Value value, GLib.ParamSpec spec) {
			// TODO: mimic json_serialize_pspec

			// convert from GLib.Value to XML
			Type t = value.type ();

			if (t == typeof (int64)) {
				// do this
			} else if (t == typeof (bool)) {
			} else if (t == typeof (double)) {
			} else if (t == typeof (string)) {
			} else if (t == typeof (int)) {
			} else if (t == typeof (float)) {
			} else if (t == Type.BOXED) {
			} else if (t == typeof (uint)) {
			} else if (t == typeof (long)) {
			} else if (t == typeof (ulong)) {
			} else if (t == typeof (char)) {
			} else if (t == typeof (uchar)) {
			} else if (t.is_enum ()) {
			} else if (t.is_flags ()) {
			} else if (t.is_object ()) {
			//} else if (t == typeof (none)) {
			} else {
				
			}

						
			// switch (value.type ().name ()) {
			// case "int64":
			// case "boolean":
			// case "double":
			// case "string":
			// case "int":
			// case "float":
			// case "boxed":
			// case "uint":
			// case "long":
			// case "ulong":
			// case "char":
			// case "uchar":
			// case "enum":
			// case "flags":
			// case "object":
			// case "none":
			// default: /* unsupported */
				
			// }

			return null;
		}

		// g_object_class_{find_property,list_properties}
		GLib.ParamSpec? find_property (string property_name) {
			// TODO: call object find property
			return null;
		}
		GLib.ParamSpec[]? list_properties (out int num_specs) {
			// TODO: call object list properties
			return null;

		}
		// g_object_{set,get}_property
		new void get_property (GLib.ParamSpec spec, GLib.Value value) {
			// TODO: call object get property
		}
		new void set_property (GLib.ParamSpec spec, GLib.Value value) {
			// TODO: call object set property
		}
	}
}