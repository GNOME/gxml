/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 3; tab-width: 3 -*- */
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
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */
namespace GXml {
  /**
   * Interface allowing implementors direct control over serialisation of properties and other data
   */
  public interface Serializable : GLib.Object {
     /**
      * Convenient property to store serializable properties
      */
     protected abstract ParamSpec[] properties { get; set; }
    /**
     * Store all properties to be ignored on serialization.
     *
     * Use property's cannonical name as key and its {@link GLib.ParamSpec}. To
     * get the last one use {@link GLib.get_class} and use, again, property's
     * cannonical name to find it.
     *
     * Long named properties like this 'ignored_serializable_properties' are stored
     * by GObject using its cannonical name, then you must use it as key, in this
     * case use 'ignored-serializable-properties'.
     *
     * This property is ignored on serialisation.
     *
     * Implementors: By default {@link list_serializable_properties} initialize
     * this property to store all public properties, except this one. Make shure t
     * call {@link init_properties()} before add new propeties.
     */
    public abstract HashTable<string,GLib.ParamSpec>  ignored_serializable_properties { get; protected set; }
     /**
      * Return {@link false} if you want ignore unknown properties and {@link GXml.Node}'s
      * not in your class definition.
      *
      * Take care, disabling this feature you can lost data on serialization, because any unknown
      * property or element will be ignored.
      */
     public abstract bool get_enable_unknown_serializable_property ();
    /**
     * On deserialization stores any {@link GXml.Node} not used on this
     * object, but exists in current XML file.
     *
     * Node's name is used as key to find stored {@link GXml.Node}.
     *
     * This property is ignored on serialisation.
     */
    public abstract HashTable<string,GXml.Node>    unknown_serializable_property { get; protected set; }

    /**
     * Used to add content in an {@link GXml.Element}.
     *
     * By default no contents is serialized/deseralized. Implementors must implement
     * {@link Serializable.serialize_use_xml_node_value} function returning
     * {@link true} in order to use this property.
     *
     * This property is ignored by default. Implementors must implement
     * {@link serialize_use_xml_node_value ()} to return {@link true}.
     *
     * This property is ignored on serialisation.
     */
    public abstract string?  serialized_xml_node_value { get; protected set; default = null; }
    /**
     * Used to check {@link GXml.Element}'s contents must be deseralized.
     *
     * By default no contents is serialized/deseralized. Implementors must implement
     * this function returning {@link true} in order to use {@link serialized_xml_node_value}
     * property's value in serialization to set {@link Element}'s contents.
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
     */
    public abstract bool property_use_nick ();
    /**
     * Serialize this object.
     *
     * @doc an {@link GXml.Document} object to serialise to 
     */
    public abstract Node? serialize (Node node) throws GLib.Error;

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
     * Implementors:
     * Use Serializable.get_property_value in order to allow derived classes to
     * override the properties to serialize.
     *
     * @param property_name string name of a property to serialize.
     * @param spec the {@link GLib.ParamSpec} describing the property.
     * @param doc the {@link GXml.Document} the returned {@link GXml.Node} should belong to
     * @return a new {@link GXml.Node}, or %NULL
     */
    public abstract GXml.Node? serialize_property (Element element,
                                                   GLib.ParamSpec prop)
                                                   throws GLib.Error;

    /**
     * Deserialize this object.
     *
     * @node {@link GXml.Node} used to deserialize from.
     */
    public abstract Node? deserialize (Node node)
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
     * @param property_name the name of the property as a string
     * @param spec the {@link GLib.ParamSpec} describing the property.
     * @param property_node the {@link GXml.Node} encapsulating data to deserialize
     * @return `true` if the property was handled, `false` if {@link GXml.Serialization} should handle it.
     */
    public abstract bool deserialize_property (GXml.Node property_node)
                                              throws GLib.Error;

    /**
     * Signal to serialize unknown properties. Any new node must be added to
     * @element before return the new @node added.
     * 
     * @element a {@link GXml.Node} to add attribute or child nodes to
     * @prop a {@link GLib.ParamSpec} describing attribute to serialize
     * @node set to the {@link GXml.Node} representing this attribute
     */
    public signal void serialize_unknown_property (Node element, ParamSpec prop, out Node node);

    /**
     * Signal to serialize unknown properties. Any new node must be added to
     * @element before return the new @node added.
     * 
     * @element a {@link GXml.Node} to add attribute or child nodes to
     * @prop a {@link GLib.ParamSpec} describing attribute to serialize
     * @node set to the {@link GXml.Node} representing this attribute
     */
    public signal void serialize_unknown_property_type (Node element, ParamSpec prop, out Node node);

    /**
     * Signal to deserialize unknown properties.
     *
     * @node a {@link GXml.Node} to get attribute from
     * @prop a {@link GLib.ParamSpec} describing attribute to deserialize
     */
    public signal void deserialize_unknown_property (Node node, ParamSpec prop);

    /**
     * Signal to deserialize unknown properties' type.
     *
     * @node a {@link GXml.Node} to get attribute from
     * @prop a {@link GLib.ParamSpec} describing attribute to deserialize
     */
    public signal void deserialize_unknown_property_type (Node node, ParamSpec prop);

    /**
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
    public abstract GLib.ParamSpec? find_property_spec (string property_name);

    /**
     * Default implementation for find_property_spec ().
     *
     */
    public virtual GLib.ParamSpec? default_find_property_spec (string property_name) {
      init_properties ();
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
     * Used internally to initialize {@link ignored_serializable_properties} property
     * and default not to be serialized properties. Unless you override any function 
     * is not required to be called at class implementor's construction time.
     *
     */
    public abstract void init_properties ();

    /**
     * Default implementation for init_properties ().
     *
     */
    public virtual void default_init_properties ()
    {
      if (ignored_serializable_properties == null) {
        ignored_serializable_properties = new HashTable<string,ParamSpec> (str_hash, str_equal);
        ignored_serializable_properties.set ("ignored-serializable-properties",
                                             get_class ().find_property("ignored-serializable-properties"));
        ignored_serializable_properties.set ("unknown-serializable-property",
                                             get_class ().find_property("unknown-serializable-property"));
        ignored_serializable_properties.set ("serialized-xml-node-value",
                                             get_class ().find_property("serialized-xml-node-value"));
      }
      if (unknown_serializable_property == null) {
        unknown_serializable_property = new HashTable<string,GXml.Node> (str_hash, str_equal);
      }
    }

    /**
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
    public abstract GLib.ParamSpec[] list_serializable_properties ();
    /**
     * Default implementation for list_serializable_properties ().
     *
     */
    public virtual GLib.ParamSpec[] default_list_serializable_properties ()
    {
      init_properties ();
      if (properties == null) {
        ParamSpec[] props = {};
        foreach (ParamSpec spec in this.get_class ().list_properties ()) {
          if (!ignored_serializable_properties.contains (spec.name)) {
            props += spec;
          }
        }
        properties = props;
      }
      return properties;
    }

    /**
     * Get a string version of the specified property
     *
     * @param spec The property we're retrieving as a string
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
     */
    public abstract void get_property_value (GLib.ParamSpec spec, ref Value val);
    /**
     * Default implementation for get_property_value ().
     *
     */
    public virtual void default_get_property_value (GLib.ParamSpec spec, ref Value val) 
    {
      if (!ignored_serializable_properties.contains (spec.name))
        ((GLib.Object)this).get_property (spec.name, ref val);
    }
    /**
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
    public abstract void set_property_value (GLib.ParamSpec spec, GLib.Value val);
    /**
     * Default implementation for set_property_value ().
     *
     */
    public virtual void default_set_property_value (GLib.ParamSpec spec, GLib.Value val)
    {
      if (!ignored_serializable_properties.contains (spec.name)) {
        ((GLib.Object)this).set_property (spec.name, val);
      }
    }

    /**
     * Method to provide custome transformations from strings to
     * a {@link GLib.Value}. Could be used on {@link serialize} or simple 
     * transformations from string.
     *
     * Some specialized classes, like derived from {@link Serializable} class
     * implementator, can provide custome transformations.
     *
     * Returns: {@link true} if transformation was handled, {@link false} otherwise.
     *
     * Implementors:
     * To be overrided by derived classes of implementators to provide custome
     * transformations. Declare it as virtual if you want derived classes of 
     * implementators to provide custome transformations.
     * Call this method before use standard Serializable or implementator ones.
     *
     * @node a {@link GXml.Node} to get attribute from
     * @prop a {@link GLib.ParamSpec} describing attribute to deserialize
     */
    public abstract bool transform_from_string (string str, ref GLib.Value dest);

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
      } else if (t == typeof (bool)) {
        bool val;
        if (ret = bool.try_parse (str.down (), out val)) {
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

    /**
     * Method to provide custome transformations from
     * a {@link GLib.Value} to strings. Could be used on {@link deserialize} or simple 
     * transformations to strings.
     *
     * Some specialized classes, like derived from {@link Serializable} class
     * implementator, can provide custome transformations.
     *
     * Returns: {@link true} if transformation was handled, {@link false} otherwise.
     *
     * Implementors:
     * To be overrided by derived classes of implementators to provide custome
     * transformations. Declare it as virtual if you want derived classes of 
     * implementators to provide custome transformations.
     * Call this method before use standard Serializable or implementator ones.
     *
     * @node a {@link GXml.Node} to get attribute from
     * @prop a {@link GLib.ParamSpec} describing attribute to deserialize
     */
    public abstract bool transform_to_string (GLib.Value val, ref string str);
    /**
     * Transforms a {@link GLib.Value} to its string representation.
     *
     * By default use GObject standard transformations.
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
