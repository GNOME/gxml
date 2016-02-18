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
public abstract class GXml.SerializableXOM : GXml.TwDocument, GXml.Serializable
{

  construct {
    Init.init ();
    // Clean up unnecesary structs
    if (get_enable_unknown_serializable_property ()) {
      base.attrs.unref ();
      base.children.unref ();
    }
  }

  // SerializableXOM

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

// GXml.Node Implementation

  public override Gee.Map<string,GXml.Node> attrs {
    owned get {
      var m = new AttrMap ();
      if (_node == null) return m;
      var props = list_serializable_properties ();
      foreach (GLib.ParamSpec prop in props) {
        // Should be a SerializableProperty not a Serializable
        if (prop.value_type.is_a (Serializable)
            && !prop.value_type.is_a (SerializableProperty)) continue;
        string attr_name;
        if (property_use_nick () &&
            prop.get_nick () != null &&
            prop.get_nick () != "")
          attr_name = prop.get_nick ();
        else
          attr_name = prop.get_name ();
        if (prop.value_type.is_a (typeof (SerializableProperty))) {
          var v = Value (typeof (Object));
          get_property (prop.name, ref v);
          var obj = v.get_object ();
          if (obj != null) {
              m.set (attr_name,
                  (obj as SerializableProperty).get_serializable_property_value ());
              continue;
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
          m.set (attr_name,
              new TwAttribute (this, attr_name, (string) val));
        }
      }
      return m;
    }
  }

  public Gee.BidirList<GXml.Node> children {
    owned get {
      var m = new ChildrenList ();
      if (_node == null) return m;
      foreach (ParamSpec p in serializable_map_properties ().values) {
        Value v = Value (typeof (Object));
        get_property (p.name, ref v);
        var obj = (Object) v;
        if (obj == null) continue;
        string nname = (obj as Serializable).node_name ();
        if (obj is SerializableCollection) {
          foreach (Serializable sobj in (obj as Traversable<Serializable>)) {
            var e = new TwElement (this, nname);
            (e as Object).set_data<Object> (sobj.ref ());
            m.add (e);
          }
          continue;
        }
        var e = new TwElement (this, nname);
        (e as Object).set_data<Object> (sobj.ref ());
        m.add (e);
      }
      return m;
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
      if (!get_enable_unknown_serializable_property ())
        return new ArrayList<GXml.Node> ();
      return attrs.ref ();
    }
  }
  public Gee.Collection<GXml.Node> unknown_serializable_nodes
  {
    owned get {
      if (!get_enable_unknown_serializable_property ())
        return new ArrayList<GXml.Node> ();
      return children.ref ();
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
    if (node_name () == null) return node;
    GXml.Node element = node;
    GXml.Document doc = node.document;
    if (node is Document) {
      if ((node as Document).root == null) {
        var r = (node as Document).create_element (node_name ());
        node.add (r);
        element = r;
      }
    }
    foreach (GXml.Node a in attrs) {
      element.set_attr (a.name, a.value);
    }
    foreach (GXml.Node c in children) {
      var e = doc.create_element (c.name);
      var obj = (c as Object).get_data<Object> ("serializable");
      if (obj == null) continue;
      if (!(obj is Serializable)) continue;
      (obj as Serializable).serialize (e);
    }
    serialize_property (element);
    return node;
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
    if (node is GXml.Document)
      if ((node as GXml.Document).root == null) return;
      else
        deserialize_property ((node as GXml.Document).root);
    else
      deserialize_property (node);
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
    var prop = find_property_spec (property_node.name.down ());
    if (prop != null) {
      if (property_node is GXml.Attribute)
        serializable.deserialize_property (property_node);
      if (n is GXml.Element) {
        Value v = Value (prop.value_type);
        get_property (prop.value_type, ref v);
        var obj = (Object) v;
        if (obj != null)
          (obj as Serializable).deserialize (property_node);
        else {
          obj = Object.new (prop.value_type);
          (obj as Serializable).deserialize (property_node);
          v.set_object (obj);
          set_property (prop.name, v);
        }
      }
    } else {
      if (get_enable_unknown_serializable_property ()) {
        if (property_node is GXml.Attribute)
          (this as GXml.GNode).attr.add (n);
        else
          (this as GXml.GNode).children.add (n);
      }
      return true;
    }
    return false;
  }

  public class ChildrenList : ArrayList<GXml.Node> {
    private SerializableXOM serializable;
    public ChildrenList (SerializableXOM s)  {
      serializable = s;
      base.add_all ((serializable as GXml.GNode).children);
      base.add_all (serializable.children);
    }
    public new add (GXml.Node n) {
      serializable.deserialize_property (n);
      base.add (n);
    }
  }
  public class AttrMap : HashMap<string,GXml.Node> {
    private SerializableXOM serializable;
    public AttrMap (SerializableXOM s)  {
      serializable = s;
      base.add_all (serializable.children);
      base.add_all ((serializable as GXml.GNode).children);
    }
    public new add (GXml.Node n) {
      serializable.deserialize_property (n);
      base.add (n);
    }
  }
}
