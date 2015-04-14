/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
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

/**
 * Object Model is an {@link Serializable} implementation using {@link Element}
 * to represent {@link GLib.Object} class objects.
 * 
 * This implementation consider each object as a XML node, represented in GXml 
 * as a {@link GXml.Element} and its properties is represented by {@link GXml.Attr}.
 * Each property, if it is a {@link Serializable} object, is represented as child
 * {@link Element}.
 * 
 * If a object's value property must be represented as a XML node content, 
 * then it requires to override {@link Serializable.serialize_use_xml_node_value}
 * and set value at {@link Serializable.serialized_xml_node_value}.
 */
public abstract class GXml.SerializableObjectModel : Object, Serializable
{
  /* Serializable interface properties */
  protected ParamSpec[] properties { get; set; }
  public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
  public string? serialized_xml_node_value { get; protected set; default=null; }
  public string? serialize_set_namespace { get; set; default = null; }
  public virtual bool get_enable_unknown_serializable_property () { return false; }
  public GLib.HashTable<string,GXml.xNode> unknown_serializable_property { get; protected set; }

  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual bool property_use_nick () { return false; }

  public virtual string node_name ()
  {
    return default_node_name ();
  }
  public string default_node_name ()
  {
    return get_type().name().down();
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
                                            throws GLib.Error
  {
    return false;
  }

  public virtual bool transform_to_string (GLib.Value val, ref string str)
                                          throws GLib.Error
  {
    return false;
  }

  public virtual GXml.xNode? serialize (GXml.xNode node)
                       throws GLib.Error
                       requires (node_name () != null)
                       requires (node is xDocument || node is Element)
  {
    return default_serialize (node);
  }

  public GXml.xNode? default_serialize (GXml.xNode node) throws GLib.Error
  {
#if DEBUG
    stdout.printf (@"$(get_type ().name ()): Serializing on node: $(node.node_name)\n");
#endif
    xDocument doc;
    if (node is xDocument)
      doc = (xDocument) node;
    else
      doc = node.owner_document;
    var element = doc.create_element (node_name ());
    node.append_child (element);
    if (serialize_set_namespace != null) {
      string[] str = serialize_set_namespace.split ("|", 2);
      doc.document_element.add_namespace_attr (str[1], str[0]);
      element.set_namespace (str[1], str[0]);
    }
    foreach (ParamSpec spec in list_serializable_properties ()) {
      serialize_property (element, spec);
    }
    if (get_enable_unknown_serializable_property ()) {
        foreach (xNode n in unknown_serializable_property.get_values ()) {
          if (n is Element) {
            var e = (xNode) doc.create_element (n.node_name);
            n.copy (ref e, true);
            element.append_child (e);
          }
          if (n is Attr) {
            element.set_attribute (n.node_name, n.node_value);
            var a = (xNode) element.get_attribute_node (n.node_name);
            n.copy (ref a);
          }
          if (n is Text) {
            var tnode = doc.create_text_node (n.node_value);
            element.append_child (tnode);
          }
        }
    }
    // Setting element content
    if (serialize_use_xml_node_value ()) {
      // Set un empty string if no value is set for node contents
      string t = "";
      if (serialized_xml_node_value != null)
        t = serialized_xml_node_value;
      var tn = doc.create_text_node (t);
#if DEBUG
      stdout.printf (@"SETTING CONTENT FOR: $(get_type ().name ()): $(element.node_name): content '$t'\n");
#endif
      element.append_child (tn);
    }
    return element;
  }

  public virtual GXml.xNode? serialize_property (GXml.Element element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    return default_serialize_property (element, prop);
  }
  public GXml.xNode? default_serialize_property (GXml.Element element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    if (prop.value_type.is_a (typeof (Serializable))) 
    {
      var v = Value (typeof (Object));
      get_property (prop.name, ref v);
      var obj = (Serializable) v.get_object ();
      if (obj != null)
        return obj.serialize (element);
    }
    Value oval;
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
    else
    {
      if (!transform_to_string (oval, ref val)) {
        if (Value.type_transformable (prop.value_type, typeof (string)))
        {
          Value rval = Value (typeof (string));
          oval.transform (ref rval);
          val = rval.dup_string ();
        }
        else {
          xNode node = null;
          this.serialize_unknown_property (element, prop, out node);
          return node;
        }
      }
    }
    string attr_name;
    if (property_use_nick () &&
        prop.get_nick () != null &&
        prop.get_nick () != "")
      attr_name = prop.get_nick ();
    else
      attr_name = prop.get_name ();
    var attr = element.get_attribute_node (attr_name);
    if (attr == null) {
      if (val != null)
        element.set_attribute (attr_name, val);
    }
    else
      attr.value = val;
    return (xNode) attr;
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
    xDocument doc;
    if (node is xDocument) {
      doc = (xDocument) node;
      return_val_if_fail (doc.document_element != null, null);
    }
    else
      doc = node.owner_document;
    Element element;
    if (node is Element)
      element = (Element) node;
    else
      element = (Element) doc.document_element;
    return_val_if_fail (element != null, null);
    if (node_name () == null) {
      message (@"WARNING: Object type '$(get_type ().name ())' have no Node Name defined");
      return null;
    }
#if DEBUG
    if (element.node_name.down () != node_name ().down ()) {
      GLib.warning (@"Actual node's name is '$(element.node_name.down ())' expected '$(node_name ().down ())'");
    }
    stdout.printf (@"Deserialize Node: $(element.node_name)\n");
    stdout.printf (@"Node is: $(element)\n\n");
    stdout.printf (@"Attributes in Node: $(element.node_name)\n");
#endif
    foreach (Attr attr in element.attributes.get_values ())
    {
      deserialize_property (attr);
    }
#if DEBUG
    stdout.printf (@"Elements Nodes in Node: $(element.node_name)\n");
#endif
    if (element.has_child_nodes ())
    {
      if (get_type ().is_a (typeof (SerializableContainer)))
      {
//        stdout.printf (@"This is a Container: found a: $(get_type ().name ())\n");
        ((SerializableContainer) this).init_containers ();
      }
      var cnodes = new Gee.HashMap<string,ParamSpec> ();
      foreach (ParamSpec spec in list_serializable_properties ())
      {
        if (spec.value_type.is_a (typeof (Serializable)))
        {
            if (spec.value_type.is_a (typeof (SerializableCollection)))
            {
              Value vo = Value (spec.value_type);
              get_property (spec.name, ref vo);
              var objv = vo.get_object ();
              if (objv != null) {
                ((Serializable) objv).deserialize (element);
                cnodes.@set (((Serializable) objv).node_name (), spec);
//                stdout.printf (@"Added Key for container node as: $(((Serializable) objv).node_name ())\n");
              }
            }
        }
      }
      foreach (xNode n in element.child_nodes)
      {
        if (n is Text) {
          if (serialize_use_xml_node_value ()) {
            serialized_xml_node_value = n.node_value;
#if DEBUG
            stdout.printf (@"$(get_type ().name ()): NODE '$(element.node_name)' CONTENT '$(n.node_value)'\n");
#endif
          } else {
            if (get_enable_unknown_serializable_property ()) {
              if (n.node_value._chomp () == n.node_value && n.node_value != "")
                unknown_serializable_property.set (n.node_name, n);
            }
          }
        }
        if (n is Element  && !cnodes.has_key (n.node_name)) {
#if DEBUG
            stdout.printf (@"$(get_type ().name ()): DESERIALIZING ELEMENT '$(n.node_name)'\n");
#endif
          deserialize_property (n);
        }
      }
    }
    return null;
  }

  public virtual bool deserialize_property (GXml.xNode property_node)
                                            throws GLib.Error
  {
    return default_deserialize_property (property_node);
  }
  public bool default_deserialize_property (GXml.xNode property_node)
                                            throws GLib.Error
  {
#if DEBUG
    stdout.printf (@"Deserialize Property Node: $(property_node.node_name)\n");
#endif
    bool ret = false;
    var prop = find_property_spec (property_node.node_name);
    if (prop == null) {
      // FIXME: Event emit
      if (get_enable_unknown_serializable_property ()) {
//        stdout.printf (@"Adding node $(property_node.node_name) to $(get_type ().name ())\n");
        unknown_serializable_property.set (property_node.node_name, property_node);
      }
      return true;
    }
    if (prop.value_type.is_a (typeof (Serializable)))
    {
      Value vobj = Value (typeof(Object));
      get_property (prop.name, ref vobj);
      if (vobj.get_object () == null) {
        var obj = Object.new  (prop.value_type);
        ((Serializable) obj).deserialize (property_node);
        set_property (prop.name, obj);
      }
      else
        ((Serializable) vobj.get_object ()).deserialize (property_node);
      return true;
    }
    else {
      Value val;
      if (prop.value_type == Type.ENUM)
        val = Value (typeof (int));
      else
        val = Value (prop.value_type);
      if (property_node is GXml.Attr)
      {
        if (prop.value_type.is_a (Type.ENUM)) {
          EnumValue env;
          try {
            env = Enumeration.parse (prop.value_type, property_node.node_value);
            val.set_enum (env.value);
          }
          catch (EnumerationError e) {}
        }
        else {
          if (!transform_from_string (property_node.node_value, ref val)) {
            Value ptmp = Value (typeof (string));
            ptmp.set_string (property_node.node_value);
            if (Value.type_transformable (typeof (string), prop.value_type))
              ret = ptmp.transform (ref val);
            else
              ret = string_to_gvalue (property_node.node_value, ref val);
          }
        }
        set_property (prop.name, val);
        return ret;
      }
    }
    // Attribute can't be deseralized with standard methods. Up to the implementor.
    this.deserialize_unknown_property (property_node, prop);
    return true;
  }
  public abstract string to_string ();

  public static bool equals (SerializableObjectModel a, SerializableObjectModel b)
  {
    if (b.get_type () == a.get_type ()) {
      var alp = ((Serializable)a).list_serializable_properties ();
      bool ret = true;
      foreach (ParamSpec p in alp) {
        var bp = ((Serializable)b).find_property_spec (p.name);
        if (bp != null) {
          Value apval = Value (p.value_type);
          ((Serializable)a).get_property_value (p, ref apval);
          Value bpval = Value (bp.value_type);;
          ((Serializable)b).get_property_value (bp, ref bpval);
          if ( apval != bpval)
            ret = false;
        }
      }
      return ret;
    }
    return false;
  }
}
