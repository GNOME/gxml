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

using GXml;

[CCode (gir_namespace = "GXml", gir_version = "0.2")]
namespace GXml {
	public interface Serializable : GLib.Object {
		/** Return true if your implementation will have handled the given property,
		    and false elsewise (in which case, XmlSerializable will try to deserialize
		    it).  */
		/** OBSOLETENOTE: Return the deserialized value in GLib.Value (even if it's a GLib.Boxed type) because Serializer is going to set the property after calling this, and if you just set it yourself within, it will be overwritten */
		public virtual bool deserialize_property (string property_name, /* out GLib.Value value,*/ GLib.ParamSpec spec, GXml.DomNode property_node) {
			return false; // default deserialize_property gets used
		}
		// TODO: just added ? to these, do we really want to allow nulls for them?
		// TODO: value and property_name are kind of redundant: eliminate?  property_name from spec.property_name and value from the object itself :)
		/** Serialized properties should have the XML structure <Property pname="PropertyName">...</Property> */
		// TODO: perhaps we should provide that base structure
		public virtual GXml.DomNode? serialize_property (string property_name, /*GLib.Value value, */ GLib.ParamSpec spec, GXml.Document doc) {
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
