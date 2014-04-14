/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* SerializableGeeTreeModel.vala
 *
 * Copyright (C) 2013, 2014  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */
using GXml;

public class Xom.SerializableTreeMap<K,V> : Gee.TreeMap<K,V>, Xom.Serializable, Xom.SerializableCollection
{
  protected ParamSpec[] properties { get; set; }
  public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
  public string? serialized_xml_node_value { get; protected set; default=null; }
  public GLib.HashTable<string,GXml.Node> unknown_serializable_property { get; protected set; }

  public bool get_enable_unknown_serializable_property () { return false; }
  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual bool property_use_nick () { return false; }

  public virtual string node_name ()
  {
    if (value_type.is_a (typeof (Xom.Serializable)))
      return ((Xom.Serializable) Object.new (value_type)).node_name ();
    else
      return get_type ().name ();
  }

  public virtual GLib.ParamSpec? find_property_spec (string property_name)
  {
    return default_find_property_spec (property_name);
  }

  public virtual void init_properties ()
  {
    default_init_properties ();
  }

  public virtual GLib.ParamSpec[] list_serializable_properties ()
  {
    return default_list_serializable_properties ();
  }

  public virtual void get_property_value (GLib.ParamSpec spec, ref Value val)
  {
    default_get_property_value (spec, ref val);
  }

  public virtual void set_property_value (GLib.ParamSpec spec, GLib.Value val)
  {
    default_set_property_value (spec, val);
  }

  public virtual bool transform_from_string (string str, ref GLib.Value dest)
  {
    return false;
  }

  public virtual bool transform_to_string (GLib.Value val, ref string str)
  {
    return false;
  }

  public virtual GXml.Node? serialize (GXml.Node node)
                              throws GLib.Error
                              requires (node is Element)
  {
    return default_serialize (node);
  }
  public GXml.Node? default_serialize (GXml.Node node)
                              throws GLib.Error
                              requires (node is Element)
  {
    if (value_type.is_a (typeof (Xom.Serializable))) {
      foreach (V v in values) {
       ((Xom.Serializable) v).serialize (node);
      }
    }
    return node;
  }
  public virtual GXml.Node? serialize_property (GXml.Element element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return default_serialize_property (element, prop);
  }
  public GXml.Node? default_serialize_property (GXml.Element element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return element;
  }
  public virtual GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node_name () != null)
  {
    return default_deserialize (node);
  }
  public GXml.Node? default_deserialize (GXml.Node node)
                    throws GLib.Error
  {
    if (!(value_type.is_a (typeof (Xom.Serializable)) &&
        value_type.is_a (typeof (Xom.SerializableMapKey)))) {
      throw new Xom.SerializableError.UNSUPPORTED_TYPE ("%s: Value type '%s' is unsupported", 
                                                    this.get_type ().name (), value_type.name ());
    }
    if (node is GXml.Element) {
      foreach (GXml.Node n in node.child_nodes) {
        if (n is Element) {
#if DEBUG
          stdout.printf (@"Node $(node.node_name) for type '$(get_type ().name ())'\n");
#endif
          var obj = Object.new (value_type);
          if (n.node_name == ((Xom.Serializable) obj).node_name ()) {
            ((Xom.Serializable) obj).deserialize (n);
            @set (((Xom.SerializableMapKey<K>) obj).get_map_key (), obj);
          }
        }
      }
    }
    return node;
  }
  public virtual bool deserialize_property (GXml.Node property_node)
                                            throws GLib.Error
  {
    return default_deserialize_property (property_node);
  }
  public bool default_deserialize_property (GXml.Node property_node)
                                            throws GLib.Error
  {
    return true;
  }
}
