namespace GXml {
	public interface Serializable : GLib.Object {
		public abstract Node? serialize (Node node) throws GLib.Error;
		public abstract GXml.Node? serialize_property (Element element,
													   GLib.ParamSpec prop)	throws GLib.Error;
		public abstract Node? deserialize (Node node) throws GLib.Error;
		public abstract bool deserialize_property (GXml.Node property_node) throws GLib.Error;
		public abstract GLib.ParamSpec? find_property_spec (string property_name);
		public abstract GLib.ParamSpec[] list_serializable_properties ();
		public abstract void get_property_value (GLib.ParamSpec spec, ref Value val);
		public abstract void set_property_value (GLib.ParamSpec spec, GLib.Value val);
	}

	public errordomain SerializableError {
		UNSUPPORTED_TYPE
	}
}