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
using Gee;

/**
 * A {@link Serializable} objects container. It uses two keys and value store.
 * 
 * It implements {@link Serializable} and {@link SerializableCollection} interfaces.
 */
public class GXml.SerializableDualKeyMap<P,S,V> : Object, Serializable, SerializableCollection
{
  protected Gee.HashMultiMap<P,HashMap<S,V>> storage;

  public Type value_type
  {
    get {
      init ();
      return typeof (V);
    }
  }
  public Type primary_key_type
  {
    get {
      init ();
      return typeof (P);
    }
  }
  public Type secondary_key_type
  {
    get {
      init ();
      return typeof (S);
    }
  }
  public Gee.Collection<P> primary_keys
  {
    owned get {
      init ();
      return storage.get_keys ();
    }
  }
  public Gee.Collection<S> secondary_keys (P key)
  {
    init ();
    var hs = storage.get (key);
    var s = new HashSet<S> ();
    foreach (HashMap<S,V> hm in hs) {
      s.add_all (hm.keys);
    }
    return s;
  }
  public Gee.Collection<V> values_for_key (P primary_key)
  {
    init ();
    var hs = storage.get (primary_key);
    var s = new HashSet<V> ();
    foreach (HashMap<S,V> hm in hs) {
      s.add_all (hm.values);
    }
    return s;
  }
  public Gee.Collection<V> values ()
  {
    init ();
    var s = new Gee.HashSet<V> ();
    foreach (HashMap<S,V> h in storage.get_values ()) {
      s.add_all (h.values);
    }
    return s;
  }
  public new void @set (P primary_key, S secundary_key, V val)
  {
    init ();
    var h = new HashMap<S,V> ();
    h.@set (secundary_key, val);
    storage.@set (primary_key, h);
  }
  public new V? @get (P primary_key, S secondary_key)
  {
    init ();
    var hs = storage.@get (primary_key);
    foreach (HashMap<S,V> h in hs) {
      if (h.has_key (secondary_key))
        return h.@get (secondary_key);
    }
    return null;
  }
  public int size { get { return storage.size; } }
  private void init ()
  {
    if (storage == null)
      storage = new Gee.HashMultiMap<P,HashMap<S,V>> ();
  }
  // Serializable Interface
  protected ParamSpec[] properties { get; set; }
  public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
  public string? serialized_xml_node_value { get; protected set; default=null; }
  public string? serialize_set_namespace { get; set; default = null; }
  public GLib.HashTable<string,GXml.xNode> unknown_serializable_property { get; protected set; }

  public virtual bool get_enable_unknown_serializable_property () { return false; }
  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual bool property_use_nick () { return false; }

  public virtual string node_name ()
  {
    return ((Serializable) Object.new (value_type)).node_name ();
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
                              requires (node is xElement)
  {
    return default_serialize (node);
  }
  public GXml.Node? default_serialize (GXml.Node node)
                              throws GLib.Error
                              requires (node is xElement)
  {
    foreach (V v in values ()) {
        if (v is Serializable)
          ((GXml.Serializable) v).serialize (node);;
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
  public virtual GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node_name () != null)
  {
    return default_deserialize (node);
  }
  public GXml.Node? default_deserialize (GXml.Node node)
                    throws GLib.Error
                    requires (node is Element)
  {
    if (!(value_type.is_a (typeof (GXml.Serializable)) &&
        value_type.is_a (typeof (SerializableMapDualKey)))) {
      throw new SerializableError.UNSUPPORTED_TYPE_ERROR ("%s: Value type '%s' is unsupported", 
                                                    this.get_type ().name (), value_type.name ());
    }
    foreach (GXml.Node n in node.childs) {
      if (n is Element) {
        var obj = (SerializableMapDualKey<P,S>) Object.new (value_type);
        if (n.name == ((Serializable) obj).node_name ()) {
          ((Serializable) obj).deserialize (n);
          @set (obj.get_map_primary_key (), obj.get_map_secondary_key (), obj);
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

