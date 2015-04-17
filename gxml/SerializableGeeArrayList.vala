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
 * A {@link Serializable} objects container.
 * 
 * It is derived  It implements {@link Serializable} and {@link SerializableCollection}
 * interfaces.
 */
public class GXml.SerializableArrayList<G> : Gee.ArrayList<G>, Serializable, SerializableCollection
{
  protected ParamSpec[] properties { get; set; }
  public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
  public string? serialized_xml_node_value { get; protected set; default=null; }
  public string? serialize_set_namespace { get; set; default = null; }

  public GLib.HashTable<string,GXml.xNode> unknown_serializable_property { get; protected set; }

  public bool get_enable_unknown_serializable_property () { return false; }
  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual bool property_use_nick () { return false; }

  public virtual string node_name ()
  {
    return ((Serializable) Object.new (element_type)).node_name ();
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
    if (element_type.is_a (typeof (Serializable))) {
      for (int i =0; i < size; i++) {
       G e = get (i);
       ((GXml.Serializable) e).serialize (node);
      }
    }
    return node;
  }
  public virtual GXml.xNode? serialize_property (GXml.xElement element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return default_serialize_property (element, prop);
  }
  public GXml.xNode? default_serialize_property (GXml.xElement element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return element;
  }
  public virtual GXml.xNode? deserialize (GXml.xNode node)
                                    throws GLib.Error
                                    requires (node_name () != null)
  {
    return default_deserialize (node);
  }
  public GXml.xNode? default_deserialize (GXml.xNode node)
                    throws GLib.Error
  {
    if (!element_type.is_a (typeof (GXml.Serializable))) {
      throw new SerializableError.UNSUPPORTED_TYPE_ERROR ("%s: Value type '%s' is unsupported", 
                                                    this.get_type ().name (), element_type.name ());
    }
    if (node is xElement) {
      foreach (GXml.xNode n in node.child_nodes) {
        if (n is xElement) {
          var obj = (Serializable) Object.new (element_type);
          if (n.node_name == ((Serializable) obj).node_name ()) {
            obj.deserialize (n);
            add (obj);
          }
        }
      }
    }
    return node;
  }
  public virtual bool deserialize_property (GXml.xNode property_node)
                                            throws GLib.Error
  {
    return default_deserialize_property (property_node);
  }
  public bool default_deserialize_property (GXml.xNode property_node)
                                            throws GLib.Error
  {
    return true;
  }
}

