/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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

using Gee;

/**
 * SerializableXOM is an {@link Serializable} implementation using {@link Element}
 * to represent {@link GLib.Object} class objects.
 * 
 * This implementation consider each object as a XML node, represented in GXml 
 * as a {@link GXml.Element} and its properties is represented by {@link GXml.Attribute}.
 * Each property, if it is a {@link Serializable} object, is represented as child
 * {@link Element}.
 * 
 * If a object's value property must be represented as a XML node content, 
 * then it requires to override {@link Serializable.serialize_use_xml_node_value}
 * and set value at {@link Serializable.serialized_xml_node_value}.
 */
public abstract class GXml.SerializableXOM : GXml.Node, GXml.Serializable
{
  protected GXml.Node _node;
  protected GXml.Document doc;
  protected bool _read_from_node;

  construct {
    Init.init ();
    _read_from_node = false;
    _node = null;
    doc = null;
  }

// SerializableXOM
  public GXml.Node node {
    get { return _node; }
    set {
      if (!(value is GXml.Element)) return;
      _node = value;
      doc = _node.document;
    }
  }

  public Gee.Map<string,ParamSpec> serializable_map_properties () {
    var m = new HashMap<string,Serializable> ();
    var props = list_serializable_properties ();
    foreach (GLib.ParamSpec ps in props) {
      if (ps.value_type.is_a (Serializable)) {
        string nname = (Object.new (ps.value_type) as Serializable).node_name ();
        m.set (nname.down (), ps);
      }
    }
    return m;
  }
  public Gee.Map<string,ParamSpec> serializable_map_collection_properties () {
    var m = new HashMap<string,Serializable> ();
    var props = list_serializable_properties ();
    foreach (GLib.ParamSpec ps in props) {
      if (ps.value_type.is_a (Serializable)) {
        string nname = (Object.new  (prop.value_type) as Serializable).node_name ();
        m.set (nname.down (), ps);
      }
    }
    return m;
  }

// GXml.Node Implementation

  public bool set_namespace (string uri, string? prefix) {
    if (node != null)
      node.set_namespace (uri, prefix);
    return true;
  }
  public string to_string () {
    return node.to_string ();
  }
  public Gee.Map<string,GXml.Node> attrs {
    owned get {
      var m = new HashMap<string,Serializable> ();
      if (_node == null) return m;
      var props = list_serializable_properties ();
      foreach (GLib.ParamSpec prop in props) {
        // Should be a SerializableProperty not a Serializable
        if (prop.value_type.is_a (Serializable)
            && !prop.value_type.is_a (SerializableProperty)) continue;

        // Search for an existing property
        string attr_name;
        if (property_use_nick () &&
            prop.get_nick () != null &&
            prop.get_nick () != "")
          attr_name = prop.get_nick ();
        else
          attr_name = prop.get_name ();
        var property_node = _node.attrs.get (attr_name);

        if (property_node != null && _read_from_node) {
          // Property exists and we are getting data from node
          Value val;
          if (prop.value_type.is_a (SerializableProperty)) {
            Value o = Value (typeof (Object));
            var obj = Object.new  (prop.value_type);
            ((SerializableProperty) obj).deserialize_property (property_node, prop, property_use_nick ());
            set_property (prop.name, obj);
          }
          if (prop.value_type == Type.ENUM)
            val = Value (typeof (int));
          else
            val = Value (prop.value_type);
          if (prop.value_type.is_a (Type.ENUM)) {
            EnumValue env;
            try {
              env = Enumeration.parse (prop.value_type, property_node.value);
              val.set_enum (env.value);
            }
            catch (EnumerationError e) {}
          }
          else {
            Value ptmp = Value (typeof (string));
            ptmp.set_string (property_node.value);
            if (Value.type_transformable (typeof (string), prop.value_type))
              ret = ptmp.transform (ref val);
            else
              ret = string_to_gvalue (property_node.value, ref val);
          }
          set_property (prop.name, val);
          m.set (prop.name, property_node);
          continue;
        }
        if (property_node == null && _read_from_node) {
          if (prop.value_type.is_a (SerializableProperty)) {
            // TODO: Check if this works to remove a serializable property
            set_property (prop.name, null);
          }
        }
        if (property_node == null && !_read_from_node) {
          // Writing to a Node
          if (prop.value_type.is_a (typeof (SerializableProperty))) {
            var v = Value (typeof (Object));
            get_property (prop.name, ref v);
            var obj = v.get_object ();
            if (obj != null) {
              return ((SerializableProperty) obj).serialize_property (element, prop, property_use_nick ());
            }
          }
          Value oval = null;
          if (prop.value_type.is_a (Type.ENUM))
            oval = Value (typeof (int));
          else
            oval = Value (prop.value_type);
          get_property (prop.name, ref oval);
          string val = "";
          if (prop.value_type.is_a (Type.ENUM)) {
            try {
              val = Enumeration.get_nick_camelcase (prop.value_type, oval.get_int ());
            } catch (EnumerationError e) { val = null; }
          }
          else {
            if (Value.type_transformable (prop.value_type, typeof (string))) {
              Value rval = Value (typeof (string));
              oval.transform (ref rval);
              val = rval.dup_string ();
            }
          }
          if (val != null) {
            (node as Element).set_attr (attr_name, (string) val);
          }
        }
      }
    }
  }
  public Gee.BidirList<GXml.Node> children {
    owned get {
      var m = new ArrayList ();
      if (_node == null) return m;
      if (_read_from_node) {
        // Getting all children in actual node
        return node.children;
      } else {
        // Updating actual node with all properties
        var props = serializable_map_properties ();
        var cprops = serializable_map_collection_properties ();
        if (node_name () == null) {
          GLib.warning (_("WARNING: Object type '%s' have no Node Name defined").printf (get_type ().name ()));
          return m;
        }
        if (node.name.down () != node_name ().down ()) {
          GLib.warning (_("Actual node's name is '%s' expected '%s'").printf (element.name.down (),node_name ().down ()));
          return m;
        }
        // Removing all previos children
        node.children.clear ();
        // Adding nodes
        foreach (ParamSpec p in serializable_map_properties ().values) {
          Value v = Value (typeof (Object));
          get_property (p.name, ref v);
          var obj = (Object) v;
          if (obj == null) continue;
          string nname = (obj as Serializable).node_name ();
          if (obj is SerializableCollection) {
            (obj as Serializable).serialize (node);
            continue;
          }
          var e = doc.create_element (nname);
          node.children.add (e);
          (obj as Serializable).serialize (e);
        }
      }
      return m;
    }
  }
  public GXml.Document document {
    get {
      if (node == null) {
        doc = new TwDocument ();
        return doc;
      }
      return node.document;
    }
  }
  public string name {
    owned get { return node_name (); }
  }
  public Gee.List<GXml.Namespace> namespaces {
    owned get {
      if (node == null) return new ArrayList<TwNamespace> ();
      return node.namespaces;
    }
  }
  public GXml.NodeType type_node {
    get {
      if (_node == null) return GXml.NodeType.X_UNKNOWN;
      return node.type_node;
    }
  }
  public string value {
    owned get {
      if (_node == null) return "";
      return _node.value;
    }
    set {
      if (_node == null) return;
      _node.value = value;
    }
  }

// Serializable Interface implementation
  public string? serialized_xml_node_value {
    owned get { return (this as GXml.Node).value; }
    protected set { (this as GXml.Node).value = value; }
  }

  public virtual bool get_enable_unknown_serializable_property () { return true; }

  public Gee.Map<string,GXml.Attribute> unknown_serializable_properties
  {
    owned get {
      var ps = new HashMap<string,GXml.Attribute> ();
      if (node == null) return ps;
      foreach (GXml.Node a in node.attrs) {
        if (attrs.has_key (a.name))
          ps.set (a.name, (Attribute) a);
      }
      return ps;
    }
  }
  public Gee.Collection<GXml.Node> unknown_serializable_nodes
  {
    owned get {
      var ns = new ArrayList<GXml.Node> ();
      var props = serializable_map_properties;
      var scollections = serializable_map_collection_properties ();
      if (serialize_use_xml_node_value) {
        foreach (GXml.Node n in node.children) {
          if (n is GXml.Element) {
            if (!props.has_key (n.name)) {
              if (!scollections.has_key (n.name))
                ns.add (ns);
            }
          }
        }
      }
      return ns;
    }
  }

  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual bool property_use_nick () { return false; }

  public virtual bool set_default_namespace (GXml.Node node) { return true; }
  public virtual string node_name () { return get_type().name().down(); }

  public virtual GLib.ParamSpec? find_property_spec (string property_name) {
    return default_find_property_spec (property_name);
  }

  public virtual GLib.ParamSpec[] list_serializable_properties ()
  {
    var props = default_list_serializable_properties ();
    props.set ("value",
               get_class ().find_property("value"));
    props.set ("name",
               get_class ().find_property("name"));
    props.set ("type-node",
               get_class ().find_property("type-node"));
    props.set ("namespaces",
               get_class ().find_property("namespaces"));
    props.set ("children",
               get_class ().find_property("children"));
    props.set ("document",
               get_class ().find_property("document"));
    props.set ("attrs",
               get_class ().find_property("attrs"));
    props.set ("content",
               get_class ().find_property("content"));
    props.set ("tag-name",
               get_class ().find_property("tag-name"));
    return props;
  }

  public virtual GXml.Node? serialize (GXml.Node node)
                       throws GLib.Error
                       requires (node_name () != null)
                       requires (node is GXml.Document || node is GXml.Element)
  {
    return default_serialize (node);
  }

  public GXml.Node? default_serialize (GXml.Node node) throws GLib.Error
  {
    
    return element;
  }

  public virtual GXml.Node? serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
    requires (element is GXml.Element)
  {
    return default_serialize_property ((GXml.Element) element, prop);
  }
  public GXml.Node? default_serialize_property (GXml.Element element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return attr;
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
  public abstract string to_string ();
}
