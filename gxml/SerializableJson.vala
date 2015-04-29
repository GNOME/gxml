/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* Serialization.vala
 *
 * Copyright (C) 2012-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2013-2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *       Richard Schwarting <aquarichy@gmail.com>
 *       Daniel Espinosa <esodan@gmail.com>
 */

/*
  Version 3: json-glib version

  PLAN:
  * add support for GObject Introspection to allow us to serialise non-property members

  json-glib
  * has functions to convert XML structures into Objects and vice versa
  * can convert simple objects automatically
  * richer objects need to implement interface

  json_serializable_real_serialize -> json_serialize_pspec
  * how do these get used with GInterfaces?  are these default methods like with superclasses?
  * TODO: I don't think vala does multiple inheritance, so do we want GXml.Serializable to be an interface or a superclass?

  json_serializable_default_{de,}serialize_property -> json_serializable_real_{de,}serialize

  json_serializable_{de,}serialize_property -> iface->{de,}serialize_property
    these all get init'd to -> json_serializable_real_{de,}serialize_property
      these all call -> json_{de,}serialize_pspec

  json_serializable_{find,list,get,set}_propert{y,ies} -> iface->{find,list,get,set}_propert{y,ies}
    these all get init'd to -> json_serializable_real_{find,list,get,set}_propert{y,ies}
    these all call -> g_object_{class,}_{find,list,get,set}_propert{y,ies}
 */


/**
 * An implementation of {@link Serializable} using an {@link xElement} called "Object".
 * 
 * {@link xElement} have two properties with object type and object id.
 * 
 * It uses a set children {@link xElement} for each Object property with two {@link Attr},
 * one for its type and one for its name; property's value is set as the property
 * {@link xElement}'s content text.
 */
public class GXml.SerializableJson : GLib.Object, GXml.Serializable
{
  /* Serializable Interface properties */
  protected ParamSpec[] properties { get; set; }
  public HashTable<string,GLib.ParamSpec>  ignored_serializable_properties { get; protected set; }
  public HashTable<string,GXml.xNode>    unknown_serializable_property { get; protected set; }
  public virtual bool get_enable_unknown_serializable_property () { return false; }
  public string?  serialized_xml_node_value { get; protected set; default = null; }
  public string? serialize_set_namespace { get; set; default = null; }

  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual string node_name () { return "Object"; }
  public virtual bool property_use_nick () { return false; }

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
                                            throws GLib.Error
  {
    return false;
  }

  public virtual bool transform_to_string (GLib.Value val, ref string str)
                                            throws GLib.Error
  {
    return false;
  }
  /**
   * If @node is a xDocument serialize just add an <Object> element.
   *
   * If @node is an xElement serialize add to it an <Object> element.
   *
   * Is up to you to add convenient xElement node to a xDocument, in order to be
   * used by serialize and add new <Object> tags per object to serialize.
   */
  public GXml.Node? serialize (GXml.Node node) throws GLib.Error
  {
    xDocument doc;
    xElement root;
    ParamSpec[] props;
    string oid = "%p".printf(this);

    if (node is xDocument)
      doc = (xDocument) node;
    else
      doc = (xDocument) node.document;

    root = (xElement) doc.create_element ("Object");
    doc.append_child (root);
    root.set_attribute ("otype", this.get_type ().name ());
    root.set_attribute ("oid", oid);
    props = list_serializable_properties ();
    foreach (ParamSpec prop_spec in props) {
      serialize_property (root, prop_spec);
    }
    return root;
  }

  public virtual GXml.Node? serialize_property (GXml.Node node, 
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
                                        requires (node is xElement)
  {
    xElement element = (xElement) node;
    Type type;
    Value val;
    GXml.xNode value_node = null;
    xElement prop_node;

    type = prop.value_type;

    if (type.is_a (typeof (Serializable))) {
      val = Value (type);
      this.get_property_value (prop, ref val);
      return (xNode)((Serializable) val.get_object ()).serialize (element);
    }

    var doc = element.owner_document;
    prop_node = (xElement) doc.create_element ("Property");
    prop_node.set_attribute ("ptype", prop.value_type.name ());
    prop_node.set_attribute ("pname", prop.name);
    element.append_child (prop_node);

    if (type.is_enum ())
    {
      val = Value (typeof (int));
      this.get_property_value (prop, ref val);
      value_node = doc.create_text_node ("%d".printf (val.get_int ()));
      prop_node.append_child (value_node);
      return prop_node;
    } 
    else if (Value.type_transformable (type, typeof (string))) 
    { // e.g. int, double, string, bool
//    GLib.message ("DEBUG: Transforming property  name '%s' of object '%s', using GLib defaults", prop.name, this.get_type ().name ());
      val = Value (type);
      Value t = Value (typeof (string));
      this.get_property_value (prop, ref val);
      val.transform (ref t);
      string str = t.get_string ();
      if (str == null) str = "";
      value_node = doc.create_text_node (str);
      prop_node.append_child (value_node);
      return prop_node;
    }
    else if (type == typeof (GLib.Type)) {
      value_node = doc.create_text_node (type.name ());
      prop_node.append_child (value_node);
      return prop_node;
    }
    else if (type.is_a (typeof (GLib.Object))
               && ! type.is_a (typeof (Gee.Collection)))
    {
      GLib.Object child_object;

      // TODO: this is going to get complicated
      val = Value (typeof (GLib.Object));
      this.get_property_value (prop, ref val);
      child_object = val.get_object ();
      xDocument value_doc = Serialization.serialize_object (child_object);
      value_node = (xNode) doc.create_element ("fake");
      value_doc.document_element.copy (ref value_node, true);
      //value_node = doc.copy_node (value_doc.document_element);
      prop_node.append_child (value_node);
      return prop_node;
    }
    //GLib.message ("DEBUG: serialing unknown property type '%s' of object '%s'", prop.name, this.get_type ().name ());
    serialize_unknown_property_type (prop_node, prop, out value_node);
    return prop_node;
  }

  public GXml.Node? deserialize (GXml.Node n) throws GLib.Error
  {
    xNode node = (xNode) n;
    xElement obj_elem;
    ParamSpec[] specs;

    if (node is xDocument) {
      obj_elem = node.owner_document.document_element;
    }
    else {
      obj_elem = (xElement) node;
    }

    specs = this.list_serializable_properties ();

    foreach (GXml.xNode child_node in obj_elem.child_nodes) {
      deserialize_property (child_node);
    }
    return obj_elem;
  }

  public virtual bool deserialize_property (GXml.Node nproperty)
    throws GLib.Error
    requires (nproperty is xNode)
  {
    xNode property_node = (xNode) nproperty;
    //GLib.message ("At SerializableJson.deserialize_property");
    if (property_node.node_name == "Property")
    {
      xElement prop_elem;
      string pname;
      string ptype;
      Type type;
      Value val;
      ParamSpec spec;
      //string ptype;

      prop_elem = (xElement)property_node;
      pname = prop_elem.get_attribute ("pname");
      ptype = prop_elem.get_attribute ("ptype");
      type = Type.from_name (ptype);
      // Check name and type for property
      spec = this.find_property_spec (pname);

      if (spec == null) {
        GLib.message ("Deserializing object of type '%s' claimed unknown property named '%s'\nXML [%s]", ptype, pname, property_node.stringify ());
        unknown_serializable_property.set (property_node.node_name, property_node);
      }
      else {
        if (spec.value_type.is_a (typeof(Serializable)))
        {
          Value vobj = Value (spec.value_type);
          this.get_property (pname, ref vobj);
          ((Serializable) vobj).deserialize (property_node);
        }
        else {
          val = Value (type);
          if (transform_from_string (prop_elem.content, ref val)) {
            this.set_property_value (spec, val);
            return true;
          }
          else if (GLib.Value.type_transformable (type, typeof (string))) {
            Serializable.string_to_gvalue (prop_elem.content, ref val);
            this.set_property_value (spec, val);
            //GLib.message (@"Setting value to property $(spec.name)");
          }
          else if (type.is_a (typeof (GLib.Object))) 
          {
            GXml.xNode prop_elem_child;
            Object property_object;

            prop_elem_child = prop_elem.first_child;

            property_object = Serialization.deserialize_object_from_node (prop_elem_child);
            val.set_object (property_object);
            return true;
          }
          else {
            deserialize_unknown_property_type (prop_elem, spec);
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }
}
