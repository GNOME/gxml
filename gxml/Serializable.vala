/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* Serializable.vala
 *
 * Copyright (C) 2013-2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;

namespace GXml {
  /**
   * A {@link GXml.Node} Serialization framework. Base interface.
   *
   * Implementors of this interface, could define or override the way you want to 
   * represent your class in a XML file.
   */
  [Version (deprecated = true, deprecated_since = "0.18", replacement = "GXml.GomElement")]
  public interface Serializable : GLib.Object {
   /**
    * Return false if you want to ignore unknown properties and {@link GXml.Node}'s
    * not in your class definition.
    *
    * Take care, disabling this feature you can lost data on serialization, because any unknown
    * property or element will be discarted.
    */
   public abstract bool get_enable_unknown_serializable_property ();
    /**
     * On deserialization stores any {@link GXml.Attribute} not used on this
     * object, but exists in current XML file.
     *
     * Node's name is used as key to find stored {@link GXml.Attribute}, key is
     * case sensitive.
     *
     * XML allows great flexibility, providing different ways to represent the same
     * information. This is a problem when you try to deserialize them.
     *
     * In order to deserialize correctly, you must create your XML, both by
     * serializing a {@link Serializable} object or by hand writing. By using the
     * former, you can add extra information, like attributes, but most of
     * them could be ignored or lost on deserialization/serialization process. To
     * avoid data lost, you can override {@link get_enable_unknown_serializable_property}
     * method in order to return true, your implementation or the ones in GXml, will
     * store all unknown attributes on deserialization and must serialize
     * again back to the XML file. Even you are allowed to get this unknown objects
     * by iterating on {@link unknown_serializable_properties} collection, if you know
     * attribute's name, use it to retrieve it.
     *
     * This property is ignored on serialisation.
     */
    public abstract Gee.Map<string,GXml.Attribute>    unknown_serializable_properties { owned get; }

    
    /**
     * On deserialization stores any {@link GXml.Node} not used on this
     * object, but exists in current XML file.
     *
     * XML allows great flexibility, providing different ways to represent the same
     * information. This is a problem when you try to deserialize them.
     *
     * In order to deserialize correctly, you must create your XML, both by
     * serializing a {@link Serializable} object or by hand writing. By using the
     * former, you can add extra information, like nodes or contents in known nodes,
     * but most of them could be ignored or lost on deserialization/serialization process.
     * To avoid data lost, you can override {@link get_enable_unknown_serializable_property}
     * method in order to return true, your implementation or the ones in GXml, will
     * store all unknown properties and nodes on deserialization and must serialize
     * again back to the XML file. Even you are allowed to get this unknown objects
     * by iterating on {@link Serializable.unknown_serializable_nodes} hash table.
     *
     * This property is ignored on serialisation.
     */
    public abstract Gee.Collection<GXml.Node>    unknown_serializable_nodes { owned get; }

    /**
     * Used to add content in an {@link GXml.Element}.
     *
     * By default no contents is serialized/deseralized. Implementors must implement
     * {@link Serializable.serialize_use_xml_node_value} function returning
     * true in order to use this property.
     *
     * This property is ignored by default. Implementors must implement
     * {@link serialize_use_xml_node_value} to return true and add a
     * set and get function to get/set this value, in order to use your own API.
     *
     * This property is ignored on serialisation.
     */
    public abstract string?  serialized_xml_node_value { owned get; protected set; }

    /**
     * Used to set specific namespace for an {@link GXml.Element}.
     *
     * By default no namspace prefix is added to {@link GXml.Element} on serialized. Implementors
     * must consider override this methodk if this node should have a namespace.
     */
    public abstract bool set_default_namespace (GXml.Node node);
    //public abstract Namespace @namespace { get; set; default = null; }
      /**
      * Used to check {@link GXml.Element}'s contents must be deseralized.
      *
      * By default GXml's implementations doesn't deseriaze/serialize XML node contents.
      * In order to enable it, you must override {@link serialize_use_xml_node_value}
      * method to return true and store XML node's content to {@link serialized_xml_node_value}
      * property.
      *
      * Implementors could set up methods to provide a clean easy to use API to set
      * nodes contents. In most cases, users would like to set a value through a getter
      * or setter or through a property in the class.
      *
     */
    public abstract bool serialize_use_xml_node_value ();
      /**
      * Defines the way to set Node name.
      */
    public abstract string node_name ();
      /**
      * Defines the way to set Node's property name, by using
      * it's nick instead of default name.
      *
      * When serialize a class property, by default it uses its name given  on class
      * declaration, but is less common to see XML node properties with names like
      * "your_property", but more common is to use "YourProperty". In order
      * to use this kind of names, your implementation should use properties' nick
      * name and override {@link property_use_nick} method to return true. This should
      * instruct your code to use this method to use property's nick name. This is
      * the default in GXml default implementations.
      */
    public abstract bool property_use_nick ();
    /**
     * Serialize this object.
     *
     * This method must call serialize_property() recursivally on all properties
     * to serialize.
     *
     * @param node an {@link GXml.Node} object to serialize to.
     */
    public abstract GXml.Node? serialize (GXml.Node node) throws GLib.Error;

    /**
     * Serialize a property @prop on a {@link GXml.Element}.
     *
     * This method is called recursivally by {@link serialize} method over all properties
     * to be serialized.
     */
    public abstract GXml.Node? serialize_property (GXml.Node element,
                                                   GLib.ParamSpec prop)
                                                   throws GLib.Error;

    /**
     * Deserialize this object.
     *
     * @param node {@link GXml.Node} used to deserialize from.
     */
    public abstract bool deserialize (GXml.Node node)
                                      throws GLib.Error;
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
     * Implementors:
     * Use Serializable.get_property_value in order to allow derived classes to
     * override the properties to serialize.
     *
     * @param property_node the {@link GXml.Node} encapsulating data to deserialize
     * @return `true` if the property was handled.
     */
    public abstract bool deserialize_property (GXml.Node property_node)
                                              throws GLib.Error;

    /**
     * Signal to serialize unknown properties. Any new node must be added to
     * @param element before return the new @param node added.
     *
     * @param element a {@link GXml.Node} to add attribute or child nodes to
     * @param prop a {@link GLib.ParamSpec} describing attribute to serialize
     * @param node set to the {@link GXml.Node} representing this attribute
     */
    public signal void serialize_unknown_property (GXml.Node element,
                                                   ParamSpec prop,
                                                   out GXml.Node node);

    /**
     * Signal to serialize unknown properties. Any new node must be added to
     * @param element before return the new @node added.
     * 
     * @param element a {@link GXml.Node} to add attribute or child nodes to
     * @param prop a {@link GLib.ParamSpec} describing attribute to serialize
     * @param node set to the {@link GXml.Node} representing this attribute
     */
    public signal void serialize_unknown_property_type (GXml.Node element,
                                                        ParamSpec prop,
                                                        out GXml.Node node);

    /**
     * Signal to deserialize unknown properties.
     *
     * @param node a {@link GXml.Node} to get attribute from
     * @param prop a {@link GLib.ParamSpec} describing attribute to deserialize
     */
    public signal void deserialize_unknown_property (GXml.Node node,
                                                     ParamSpec prop);

    /**
     * Signal to deserialize unknown properties' type.
     *
     * @param node a {@link GXml.Node} to get attribute from
     * @param prop a {@link GLib.ParamSpec} describing attribute to deserialize
     */
    public signal void deserialize_unknown_property_type (GXml.Node node,
                                                          ParamSpec prop);

    /**
     * Handles finding the {@link GLib.ParamSpec} for a given property, it should
     * a serializable property, see {@link list_serializable_properties}.
     *
     * @param property_name the name of a property to obtain a {@link GLib.ParamSpec} for
     * @return a {@link GLib.ParamSpec} describing the named property
     */
    public abstract GLib.ParamSpec? find_property_spec (string property_name);

    /**
     * Default implementation for {@link Serializable.find_property_spec}
     *
     */
    public virtual GLib.ParamSpec? default_find_property_spec (string property_name) {
      var props = list_serializable_properties ();
      foreach (ParamSpec spec in props) {
        if (spec.name.down () == property_name.down ())
          return spec;
        if (property_use_nick ())
          if (spec.get_nick ().down () == property_name.down ())
            return spec;
        if ("-" in spec.name) {
          string[] sp = spec.name.split ("-");
          string n = "";
          foreach (string s in sp) {
            n += @"$(s[0])".up () + @"$(s[1:s.length])";
          }
          if (n.down () == property_name.down ())
            return spec;
        }
      }
      return null;
    }

    /**
     * List the known properties for an object's class to be de/seriablizable.
     *
     * @return an array of {@link GLib.ParamSpec} of "properties" for the object.
     */
    public abstract GLib.ParamSpec[] list_serializable_properties ();
    /**
     * Default implementation for {@link Serializable.list_serializable_properties}
     *
     */
    public virtual GLib.ParamSpec[] default_list_serializable_properties ()
    {
      ParamSpec[] props = {};
      var l = new HashTable<string,ParamSpec> (str_hash, str_equal);
      l.set ("ignored-serializable-properties",
                                           get_class ().find_property("ignored-serializable-properties"));
      l.set ("unknown-serializable-properties",
                                           get_class ().find_property("unknown-serializable-properties"));
      l.set ("unknown-serializable-nodes",
                                           get_class ().find_property("unknown-serializable-nodes"));
      l.set ("serialized-xml-node-value",
                                           get_class ().find_property("serialized-xml-node-value"));
      foreach (ParamSpec spec in this.get_class ().list_properties ()) {
        if (!l.contains (spec.name)) {
          props += spec;
        }
      }
      return props;
    }

     /**
      * Transforms a string into another type hosted by {@link GLib.Value}.
      *
      * A utility function that handles converting a string
      * representation of a value into the type specified by the
      * supplied #GValue dest.  A #GXmlSerializableError will be
      * set if the string cannot be parsed into the desired type.
      *
      * {@link Serializable} interface support a number of data types to convert
      * from its string representation. These are supported types:
      *
      * a. integers: int8, int64, uint, long, ulong, char, uchar
      * a. boolean
      * a. floats: float, double
      * a. enumerations
      *
      * @param str the string to transform into the given #GValue object
      * @param dest the #GValue out parameter that will contain the parsed value from the string
      * @return `true` if parsing succeeded, otherwise `false`
      */
    public static bool string_to_gvalue (string str, ref GLib.Value dest)
                                         throws SerializableError
    {
      Type t = dest.type ();
      GLib.Value dest2 = Value (t);
      bool ret = false;

      if (t == typeof (int64)
        || t == typeof (uint64)) {
        int64 val;
        val = (int64) double.parse (str);
        dest2.set_int64 (val);
        ret = true;
      } else if (t == typeof (int)) {
        int val;
        val = (int) double.parse (str);
        dest2.set_int (val);
        ret = true;
      } else if (t == typeof (long)) {
        long val;
        val = (long) double.parse (str);
        dest2.set_long (val);
        ret = true;
      } else if (t == typeof (uint)) {
        uint val;
        val = (uint) double.parse (str);
        dest2.set_uint (val);
        ret = true;
      } else if (t == typeof (ulong)) {
        ulong val;
        val = (ulong) double.parse (str);
        dest2.set_ulong (val);
        ret = true;
      } else if (t == typeof (bool)) {
        bool val;
        if (ret = bool.try_parse (str.down (), out val)) {
          dest2.set_boolean (val);
        }
      } else if (t == typeof (float)) {
        float val;
        val = (float) double.parse (str);
        dest2.set_float (val);
        ret = true;
      } else if (t == typeof (double)) {
        double val;
        val = (double) double.parse (str);
        dest2.set_double (val);
        ret = true;
      } else if (t == typeof (string)) {
        dest2.set_string (str);
        ret = true;
      } else if (t == typeof (uchar)) {
        uchar val;
        val = (uchar) double.parse (str);
        dest2.set_uchar (val);
        ret = true;
      } else if (t == Type.BOXED) {
        // TODO: Boxed type transformation
      } else if (t.is_enum ()) {
        int val;
        val = (int) double.parse (str);
        dest2.set_enum (val);
        ret = true;
      } else if (t.is_flags ()) {
      } else if (t.is_object ()) {
      } else {
      }

      if (ret == true) {
        dest = dest2;
        return true;
      } else {
        throw new SerializableError.UNSUPPORTED_TYPE_ERROR (_("Transformation Error on \'%s\' or Unsupported type: \'%s\'"),
                                                      str, t.name ());
      }
    }
    /**
     * Transforms a {@link GLib.Value} to its string representation.
     *
     * By default use {@link GLib.Value} standard transformations.
     *
     */
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
        throw new SerializableError.UNSUPPORTED_TYPE_ERROR (_("Can't transform \'%s\' to string"), val.type ().name ());
      }
    }
  }

  /**
   * Errors from {@link Serializable}.
   */
  public errordomain SerializableError {
    /**
     * An object with a known {@link GLib.Type} that we do not support was encountered.
     */
    UNSUPPORTED_TYPE_ERROR,
    STR_TO_VALUE_ERROR,
  }
}
