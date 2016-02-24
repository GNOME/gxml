/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* SerializableGeeTreeModel.vala
 *
 * Copyright (C) 2013-2015  Daniel Espinosa <esodan@gmail.com>
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
/**
 * Serializable Framework. A {@link Serializable} objects container based on {@link Gee.TreeMap}.
 * 
 * It uses a key and value store implementing {@link Gee.TreeMap} interface.
 * It implements {@link Serializable} and {@link SerializableCollection} interfaces.
 */
public class GXml.SerializableTreeMap<K,V> : Gee.TreeMap<K,V>, Serializable, SerializableCollection
{
  GXml.Node _node;

  // SerializableCollection interface
  public virtual bool deserialized () { return true; }
  public virtual bool is_prepared () { return (_node is GXml.Node); }
  public virtual bool deserialize_node (GXml.Node node) { return deserialize_property (node); }
  public virtual bool deserialize_children (GXml.Node node) { return deserialize (node); }

	construct { Init.init (); }

  public Gee.Map<string,GXml.Attribute> unknown_serializable_properties
  {
    owned get {
      return new Gee.HashMap<string,GXml.Attribute> ();
    }
  }
  public Gee.Collection<GXml.Node> unknown_serializable_nodes
  {
    owned get {
      return new Gee.ArrayList<GXml.Node> ();
    }
  }
  protected ParamSpec[] properties { get; set; }
  public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
  public string? serialized_xml_node_value { owned get; protected set; default=null; }
  public virtual bool set_default_namespace (GXml.Node node) { return true; }

  public bool get_enable_unknown_serializable_property () { return false; }
  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual bool property_use_nick () { return false; }

  public virtual string node_name ()
  {
    if (value_type.is_a (typeof (Serializable)))
      return ((Serializable) Object.new (value_type)).node_name ();
    else
      return get_type ().name ();
  }

  public virtual GLib.ParamSpec? find_property_spec (string property_name)
  {
    return default_find_property_spec (property_name);
  }

  public virtual GLib.ParamSpec[] list_serializable_properties ()
  {
    return default_list_serializable_properties ();
  }

  public virtual GXml.Node? serialize (GXml.Node node)
                              throws GLib.Error
                              requires (node is GXml.Element)
  {
    return default_serialize (node);
  }
  public GXml.Node? default_serialize (GXml.Node node)
                              throws GLib.Error
                              requires (node is GXml.Element)
  {
    if (value_type.is_a (typeof (Serializable))) {
      foreach (V v in values) {
       ((GXml.Serializable) v).serialize (node);
      }
    }
    return node;
  }
  public virtual GXml.Node? serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return default_serialize_property (element, prop);
  }
  public GXml.Node? default_serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return element;
  }
  public virtual bool deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node_name () != null)
  {
    return default_deserialize (node);
  }
  public bool default_deserialize (GXml.Node node)
                    throws GLib.Error
  {
    if (!(value_type.is_a (typeof (GXml.Serializable)) &&
        value_type.is_a (typeof (SerializableMapKey)))) {
      throw new SerializableError.UNSUPPORTED_TYPE_ERROR (_("%s: Value type '%s' is unsupported"), 
                                                    this.get_type ().name (), value_type.name ());
    }
    if (node is Element) {
      foreach (GXml.Node n in node.childs) {
        if (n is Element) {
#if DEBUG
          stdout.printf (@"Node $(node.name) for type '$(get_type ().name ())'\n");
#endif
          var obj = Object.new (value_type);
          if (n.name.down () == ((Serializable) obj).node_name ().down ()) {
            ((Serializable) obj).deserialize (n);
            @set (((SerializableMapKey<K>) obj).get_map_key (), obj);
          }
        }
      }
    }
    return true;
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
