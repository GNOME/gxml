/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/*
  Version 3:
  This time base it off of json-glib

  PLAN:
  * 

  So, json-glib's serialisation has a bunch of functions and code.

  * TODO: do we want to return Documents or XNodes?  XNodes
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
	public class Serializer : GLib.Object {
		/* TODO: so it seems we can get property information from GObjectClass
		   but that's about it.  Need to definitely use introspection for anything
		   tastier */
		/* TODO: determine if I want to return an <Object/>
		 * root node or the Document containing it */
		public GXmlDom.XNode serialize_object (GLib.Object object) {
			Document doc = new Document ();
			Element root = doc.create_element ("Object");
			doc.append_child (root); // TODO: is that how we set a root element?
			root.set_attribute ("otype", object.get_type ().name ());

			/* TODO: make sure we don't use an out param for our returned list
			   size in our interface's list_properties (), using
			   [CCode (array_length_type = "guint")] */
			ParamSpec[] prop_specs = object.get_class ().list_properties ();

			foreach (ParamSpec prop_spec in prop_specs) {
				Element prop = doc.create_element ("Property");
				prop.set_attribute ("ptype", prop_spec.value_type.name ());
				prop.set_attribute ("pname", prop_spec.name);

				Value value = new Value (typeof (string));
				object.get_property (prop_spec.name, ref value);
				prop.content = value.get_string ();
				root.append_child (prop);
				
				// // } else if (t.is_object ()) {
				// } else {
				// 	GLib.warning ("Cannot serialise property of type '%s' yet.", prop_spec.value_type.name ());
				// }				
			}



			stdout.printf ("Object XML\n---\n%s\n", doc.to_string ());

			bool debug = false;
			if (debug) {
				stdout.printf ("object\n---\n");
				stdout.printf ("get_type (): %s\n", object.get_type ().name ());
				stdout.printf ("get_class ().get_type (): %s\n", object.get_class ().get_type ().name ());
				
				ParamSpec[] properties = object.get_class ().list_properties ();
				stdout.printf ("object has %d properties\n", properties.length);
				foreach (ParamSpec prop in properties) {
					stdout.printf ("---\n");
					stdout.printf ("name: %s\n", prop.name);
					stdout.printf ("value_type: %s\n", prop.value_type.name ());
					stdout.printf ("owner_type: %s\n", prop.owner_type.name ());
					stdout.printf ("get_name (): %s\n", prop.get_name ());
					stdout.printf ("get_blurb (): %s\n", prop.get_blurb ());
					stdout.printf ("get_nick (): %s\n", prop.get_nick ());
				}
				// get properties
				// serialise each property
			}

			return doc;
		}

		public GLib.Object deserialize_object (XNode node) {
			Element obj_elem = (Element)node;

			NodeList properties = obj_elem.get_elements_by_tag_name ("Property");
			Parameter[] parameters;
			string[] names;

			parameters = new Parameter[properties.length];
			names = new string[properties.length]; // because Parameter.name is unowned

			for (int i = 0; i < properties.length; i++) {
				Element prop_elem = (Element)properties.nth (i);
				Value val = Value (Type.from_name (prop_elem.get_attribute ("ptype")));

				string_to_gvalue (prop_elem.content, ref val);
				names[i] = prop_elem.get_attribute ("pname");
				parameters[i] = { names[i], val };
			}

			Object obj = Object.newv (Type.from_name (obj_elem.get_attribute ("otype")),
						  parameters);

			return obj;
		}

		public GLib.Object deserialize_object_old (XNode node) {
			Element obj_elem = (Element)node;

			Type type = Type.from_name (obj_elem.get_attribute ("otype"));
			
			Object obj = Object.newv (type, {});

			Parameter[] parameters;

			ParamSpec[] param_specs = obj.get_class ().list_properties ();

			parameters = new Parameter[param_specs.length];

			for (int i = 0; i < param_specs.length; i++) {
				for (int j = 0; j < obj_elem.child_nodes.length; j++) {
					XNode prop_node = obj_elem.child_nodes.nth (i);
					if (prop_node.node_type == NodeType.ELEMENT) {
						Element prop_elem = (Element)obj_elem.child_nodes.nth (i);
						if (param_specs[i].get_name () == prop_elem.get_attribute ("pname")) {
							Value prop_str_value = new Value (typeof (string));
							prop_str_value.set_string (prop_elem.content);
							GLib.message ("prop_str_value: [%s], prop_elem.content: [%s]",
								      prop_str_value.get_string (), prop_elem.content);


							Value prop_value = new Value (Type.from_name (prop_elem.get_attribute ("ptype")));

							
							//param_specs[i].value_convert (prop_str_value, prop_value, false);
							//prop_str_value.transform (ref prop_value);
							string_to_gvalue (prop_elem.content, ref prop_value);

							GLib.message ("prop_str_value: %s",
								      prop_str_value.strdup_contents ());
							GLib.message ("  prop_value: %s",
								      prop_value.strdup_contents ());


							Parameter param = { param_specs[i].get_name (), prop_value };
							parameters[i] = param;
							break;
						}
					}
				}
			}

			for (int i = 0; i < parameters.length; i++) {
				stdout.printf ("param[%d]: name[%s]\n", i, parameters[i].name);
			}
			
			obj = Object.newv (type, parameters);

			return obj;
		}

		/* TODO: how do you do delegates for struct methods? */
		public static bool string_to_gvalue (string str, ref GLib.Value dest) {
			Type t = dest.type ();
			GLib.Value dest2 = Value (t);
			bool ret = false;
			
			if (t == typeof (int64)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_int64 (val);
				}
			} else if (t == typeof (bool)) {
				bool val;
				if (ret = bool.try_parse (str, out val)) {
					dest2.set_boolean (val);
				} 
			} else if (t == typeof (double)) {
				double val;
				if (ret = double.try_parse (str, out val)) {
					dest2.set_double (val);
				}
			} else if (t == typeof (string)) {
				dest2.set_string (str);
				ret = true;
			} else if (t == typeof (int)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_int ((int)val);
				}
			} else if (t == typeof (float)) {
				double val;
				if (ret = double.try_parse (str, out val)) {
					dest2.set_float ((float)val);
				}
			} else if (t == Type.BOXED) {
				// ret = parser<BOXED> (str, (ParseMethod)BOXED.parse, (pv) => { dest2.set_BOXED (pv); } );
			} else if (t == typeof (uint)) {
				uint64 val;
				if (ret = uint64.try_parse (str, out val)) {
					dest2.set_uint ((uint)val);
				}
			} else if (t == typeof (long)) {
				int64 val;
				if (ret = int64.try_parse (str, out val)) {
					dest2.set_long ((long)val);
				}
			} else if (t == typeof (ulong)) {
				uint64 val;
				if (ret = uint64.try_parse (str, out val)) {
					dest2.set_ulong ((ulong)val);
				}
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
			} else if (t.is_enum ()) {
			} else if (t.is_flags ()) {
			} else if (t.is_object ()) {
				// } else if (t == typeof (none)) {
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

/**
 * SECTION:gxml-serializable
 * @short-description: Serialize and deserialize GObjects
 *
 * TODO: elaborate
 */
	public interface SerializableInterface : GLib.Object {
		public abstract void deserialize_property (string property_name, out GLib.Value value, GLib.ParamSpec spec, GXmlDom.XNode property_node);
		public abstract GXmlDom.XNode serialize_property (string property_name, GLib.Value value, GLib.ParamSpec spec);

		// g_object_class_{find_property,list_properties}
		public abstract GLib.ParamSpec find_property (string property_name); // TODO: won't these names conflict with GLib.Object ones? :|
		public abstract GLib.ParamSpec[] list_properties (out int num_specs); // TODO: probably unowned

		// g_object_{set,get}_property
		public abstract void get_property (GLib.ParamSpec spec, GLib.Value value); // TODO: const?
		public abstract void set_property (GLib.ParamSpec spec, GLib.Value value); // TODO: const?
	}

	public class Serializable : SerializableInterface, GLib.Object {
		void deserialize_property (string property_name, out GLib.Value value, GLib.ParamSpec spec, GXmlDom.XNode property_node) {
			// TODO: mimic json_deserialize_pspec
			// TODO: consider returning GLib.Value instead of using an out param?

			// convert from XML to a GLib.Value
			return;
		}
		GXmlDom.XNode serialize_property (string property_name, GLib.Value value, GLib.ParamSpec spec) {
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
		GLib.ParamSpec find_property (string property_name) {
			// TODO: call object find property
			return null;
		}
		GLib.ParamSpec[] list_properties (out int num_specs) {
			// TODO: call object list properties
			return null;

		}
		// g_object_{set,get}_property
		void get_property (GLib.ParamSpec spec, GLib.Value value) {
			// TODO: call object get property
		}
		void set_property (GLib.ParamSpec spec, GLib.Value value) {
			// TODO: call object set property
		}
	}
}