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
 * Serializable Framework. A {@link Serializable} objects container based on {@link Gee.ArrayList}.
 * 
 * It is derived  It implements {@link Serializable} and {@link SerializableCollection}
 * interfaces.
 */
public class GXml.SerializableArrayList<G> : Gee.ArrayList<G>, Serializable, SerializableCollection
{
  Gee.HashMap<string,GXml.Attribute> _unknown_serializable_property = new Gee.HashMap<string,GXml.Attribute> ();
  Gee.ArrayList<GXml.Node> _unknown_serializable_nodes = new Gee.ArrayList<GXml.Node> ();
  
	construct { Init.init (); }

  public Gee.Map<string,GXml.Attribute> unknown_serializable_properties
  {
    owned get {
      return (Gee.Map<string,GXml.Attribute>) _unknown_serializable_property.ref ();
    }
  }
  public Gee.Collection<GXml.Node> unknown_serializable_nodes
  {
    owned get {
      return (Gee.Collection<GXml.Node>) _unknown_serializable_nodes.ref ();
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
    return ((Serializable) Object.new (element_type)).node_name ();
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
    if (element_type.is_a (typeof (Serializable))) {
      for (int i =0; i < size; i++) {
       G e = get (i);
       ((GXml.Serializable) e).serialize (node);
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
  public virtual GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node_name () != null)
  {
    return default_deserialize (node);
  }
  public GXml.Node? default_deserialize (GXml.Node node)
                    throws GLib.Error
  {
    if (!element_type.is_a (typeof (GXml.Serializable))) {
      throw new SerializableError.UNSUPPORTED_TYPE_ERROR (_("%s: Value type '%s' is unsupported"), 
                                                    this.get_type ().name (), element_type.name ());
    }
    if (node is Element) {
#if DEBUG
            GLib.message (@"Deserializing ArrayList on Element: $(node.name)");
#endif
      foreach (GXml.Node n in node.childs) {
        deserialize_property (n);
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
    if (!element_type.is_a (typeof (GXml.Serializable))) {
      throw new SerializableError.UNSUPPORTED_TYPE_ERROR (_("%s: Value type '%s' is unsupported"), 
                                                    this.get_type ().name (), element_type.name ());
    }
    if (property_node is Element) {
      var obj = Object.new (element_type) as Serializable;
      if (property_node.name.down () == obj.node_name ().down ()) {
        obj.deserialize (property_node);
        add (obj);
      }
    }
    return true;
  }
}

