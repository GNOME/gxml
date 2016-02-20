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

using Gee;

/**
 * Object Model is an {@link Serializable} implementation using {@link Element}
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
public abstract class GXml.SerializableObjectModel : Object, Serializable
{
	construct { Init.init (); }
  // holds all unknown nodes
  protected GXml.TwDocument _doc = null;
  /* Serializable interface properties */
  protected ParamSpec[] properties { get; set; }
  public GLib.HashTable<string,GLib.ParamSpec> ignored_serializable_properties { get; protected set; }
  public string? serialized_xml_node_value { owned get; protected set; default=null; }
  public virtual bool get_enable_unknown_serializable_property () { return false; }
  /**
   * All unknown nodes, will be stored in a per-object {@link GXml.Document}
   * in its {@link GXml.Element} root. Then, all unknown properties will be
   * stored as properties in document's root and all unknown childs {@link GXml.Node}
   * as root's childs.
   */
  public Gee.Map<string,GXml.Attribute> unknown_serializable_properties
  {
    owned get {
#if DEBUG
      GLib.message ("Getting unknown_serializable_nodes");
      if (_doc != null)
        if (_doc.root != null)
          GLib.message ("Doc is not NULL and Root Attributes is NULL:"+(_doc.root.attrs == null).to_string ());
        else
          GLib.message ("Doc is not NULL but Root IS NULL");
#endif
      if (_doc == null) init_unknown_doc ();
      return _doc.root.attrs as Gee.Map<string,GXml.Attribute>;
    }
  }
  public Gee.Collection<GXml.Node> unknown_serializable_nodes
  {
    owned get {
#if DEBUG
      GLib.message ("Getting unknown_serializable_nodes");
      if (_doc != null)
        if (_doc.root != null)
          GLib.message ("Doc is not NULL and Root Children is NULL:"+(_doc.root.children == null).to_string ());
        else
          GLib.message ("Doc is not NULL but Root IS NULL");
#endif
      if (_doc == null) init_unknown_doc ();
      return _doc.root.children;
    }
  }

  private void init_unknown_doc ()
  {
    _doc = new TwDocument ();
    try {
      var r = _doc.create_element ("root");
     _doc.children.add (r);
    }
    catch { assert_not_reached (); }
  }

  public virtual bool serialize_use_xml_node_value () { return false; }
  public virtual bool property_use_nick () { return false; }

  public virtual bool set_default_namespace (GXml.Node node) { return true; }
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

  public virtual GLib.ParamSpec[] list_serializable_properties ()
  {
    return default_list_serializable_properties ();
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
    assert (node.name != null);
#if DEBUG
    GLib.message (@"$(get_type ().name ()): Serializing on node: $(node.name) : type: @$(node.get_type ().name ())\n");
#endif
    Document doc;
    if (node is GXml.Document)
      doc = (GXml.Document) node;
    else
      doc = node.document;
    var element = (Element) doc.create_element (node_name ());
    node.children.add (element);
    set_default_namespace (element);
    foreach (ParamSpec spec in list_serializable_properties ()) {
      serialize_property (element, spec);
    }
    if (get_enable_unknown_serializable_property ()) {
        // Serializing unknown Attributes
        foreach (GXml.Attribute attr in unknown_serializable_properties.values) {
          element.set_attr (attr.name, attr.value); // TODO: Namespace
        }
        // Serializing unknown Nodes
        foreach (GXml.Node n in unknown_serializable_nodes) {
#if DEBUG
            GLib.message (@"Serializing Unknown NODE: $(n.name) to $(element.name)");
#endif
          if (n is GXml.Element) {
#if DEBUG
            GLib.message (@"Serializing Unknown Element NODE: $(n.name) to $(element.name)");
#endif
            var e = doc.create_element (n.name);
            GXml.Node.copy (node.document, e, n, true);
#if DEBUG
            GLib.message (@"Serialized Unknown Element NODE AS: $(e.to_string ())");
#endif
            element.children.add (e);
          }
          if (n is Text) {
            if (n.value == null) GLib.warning (_("Text node with NULL or none text"));
            if (n.value == "") continue;
            var t = doc.create_text (n.value);
            element.children.add (t);
#if DEBUG
            GLib.message (@"Serializing Unknown Text Node: '$(n.value)' to '$(element.name)' : Size $(element.children.size.to_string ())");
            GLib.message (@"Added Text: $(element.children.get (element.children.size - 1))");
#endif
          }
        }
    }
    // Setting element content
    if (serialize_use_xml_node_value ()) {
      // Set un empty string if no value is set for node contents
      string t = "";
#if DEBUG
      stdout.printf (@"SET CONTENT FOR: $(get_type ().name ()): $(element.name)\n");
#endif
      if (serialized_xml_node_value != null)
        t = serialized_xml_node_value;
      element.content  = t;
#if DEBUG
      stdout.printf (@"SET CONTENT FOR: $(get_type ().name ()): $(element.name): content '$t'\n");
#endif
    }
    return element;
  }

  public virtual GXml.Node? serialize_property (GXml.Node element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    if (element is GXml.Element)
      return default_serialize_property ((GXml.Element) element, prop);
    return null;
  }
  public GXml.Node? default_serialize_property (GXml.Element element,
                                        GLib.ParamSpec prop)
                                        throws GLib.Error
  {
    if (prop.value_type.is_a (typeof (Serializable)) || prop.value_type.is_a (typeof (SerializableProperty))) 
    {
      var v = Value (typeof (Object));
      get_property (prop.name, ref v);
      var obj = v.get_object ();
      if (obj != null) {
        if (obj is SerializableProperty)
          return ((SerializableProperty) obj).serialize_property (element, prop, property_use_nick ());
        if (obj is Serializable)
          return ((Serializable) obj).serialize (element);
      }
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
      if (Value.type_transformable (prop.value_type, typeof (string)))
      {
        Value rval = Value (typeof (string));
        oval.transform (ref rval);
        val = rval.dup_string ();
      }
      else {
        Node node = null;
        this.serialize_unknown_property (element, prop, out node);
        return node;
      }
    }
    string attr_name;
    if (property_use_nick () &&
        prop.get_nick () != null &&
        prop.get_nick () != "")
      attr_name = prop.get_nick ();
    else
      attr_name = prop.get_name ();
    var attr = element.get_attr (attr_name);
    if (attr == null) {
      if (val != null) {
#if DEBUG
        GLib.message (@"Setting attribute: '$(attr_name)' : val: '$(val)' to node: '$(element.name)'");
#endif
        element.set_attr (attr_name, val);
      }
    }
    else
      attr.value = val;
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
    Document doc;
    if (node is Document) {
      doc = (Document) node;
      return_val_if_fail (doc.root != null, null);
    }
    else
      doc = node.document;
    Element element;
    if (node is Element)
      element = (Element) node;
    else
      element = (Element) doc.root;
    return_val_if_fail (element != null, null);
    if (node_name () == null) {
      GLib.warning (_("WARNING: Object type '%s' have no Node Name defined").printf (get_type ().name ()));
      return null;
    }
    if (element.name.down () != node_name ().down ()) {
      GLib.warning (_("Actual node's name is '%s' expected '%s'").printf (element.name.down (),node_name ().down ()));
    }
#if DEBUG
    stdout.printf (@"Deserialize Node: $(element.name)\n");
    stdout.printf (@"Node is: $(element)\n\n");
    stdout.printf (@"Attributes in Node: $(element.name)\n");
#endif
    foreach (GXml.Node attr in element.attrs.values)
    {
      deserialize_property (attr);
    }
    if (element.children.size > 0)
    {
      if (get_type ().is_a (typeof (SerializableContainer)))
      {
#if DEBUG
        stdout.printf (@"This is a Container: found a: $(get_type ().name ())\n");
#endif
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
#if DEBUG
    stdout.printf (@"Elements Nodes in Node: $(element.name)\n");
#endif
      foreach (Node n in element.children)
      {
        if (n is Text) {
          if (serialize_use_xml_node_value ()) {
            serialized_xml_node_value = n.value;
#if DEBUG
            GLib.message (@"$(get_type ().name ()): NODE '$(element.name)' CONTENT '$(n.value)'\n");
#endif
          } else {
            if (get_enable_unknown_serializable_property ()) {
              GLib.message (@"Adding unknown Text node with value: $(n.value)");
              if (n.value._chomp () == n.value && n.value != "") {
                var t = _doc.create_text (n.value);
                _doc.root.children.add (t);
              }
            }
          }
        }
        if (n is GXml.Element  && !cnodes.has_key (n.name)) {
#if DEBUG
            stdout.printf (@"$(get_type ().name ()): DESERIALIZING ELEMENT '$(n.name)'\n");
#endif
          deserialize_property (n);
        }
      }
    }
    return null;
  }

  public virtual bool deserialize_property (GXml.Node property_node)
                                            throws GLib.Error
  {
    return default_deserialize_property (property_node);
  }
  public bool default_deserialize_property (GXml.Node property_node)
                                            throws GLib.Error
  {
#if DEBUG
    stdout.printf (@"Deserialize Property Node: $(property_node.name)\n");
#endif
    bool ret = false;
    var prop = find_property_spec (property_node.name);
    if (prop == null) {
      // FIXME: Event emit
      if (get_enable_unknown_serializable_property ()) {
        if (_doc == null) init_unknown_doc ();
        if (property_node is GXml.Attribute) {
#if DEBUG
          GLib.message (@"Adding unknown attribute $(property_node.name) to $(get_type ().name ()) Size=$(unknown_serializable_properties.size.to_string ())\n");
#endif
          ((GXml.Element)_doc.root).set_attr (property_node.name, property_node.value);
        }
        else {
          var e = _doc.create_element (property_node.name);
          _doc.root.children.add (e);
          GXml.Node.copy (_doc, e, property_node, true);
#if DEBUG
          GLib.message (@"Adding unknown node $(property_node.name) to $(get_type ().name ()): Size=$(unknown_serializable_nodes.size.to_string ())");
#endif
        }
      }
#if DEBUG
          GLib.message (@"Finishing deserialize unknown node/property $(property_node.name) to $(get_type ().name ())");
#endif
      return true;
    }
#if DEBUG
          GLib.message (@"Checking if $(property_node.name) of type $(prop.value_type.name ()) is Serializable");
#endif
    if (prop.value_type.is_a (typeof (Serializable)) || prop.value_type.is_a (typeof (SerializableProperty)))
    {
#if DEBUG
      GLib.message (@"'$(property_node.name)'- $(prop.value_type.name ()) - Is Serializable: deserializing");
#endif
      Value vobj = Value (typeof(Object));
      get_property (prop.name, ref vobj);
      GLib.Object object = null;
      object = vobj.get_object ();
      if (object == null) {
        if (prop.value_type.is_a (typeof (SerializableProperty))) {
          var obj = Object.new  (prop.value_type);
          ((SerializableProperty) obj).deserialize_property (property_node, prop, property_use_nick ());
          set_property (prop.name, obj);
        }
        else if (prop.value_type.is_a (typeof (Serializable))) {
          var obj = Object.new  (prop.value_type);
          ((Serializable) obj).deserialize (property_node);
          set_property (prop.name, obj);
        }
      }
      else {
        if (object is SerializableProperty)
          ((SerializableProperty) object).deserialize_property (property_node, prop, property_use_nick ());
        else
          ((Serializable) object).deserialize (property_node);
      }
      return true;
    }
    else {
      Value val;
      if (prop.value_type == Type.ENUM)
        val = Value (typeof (int));
      else
        val = Value (prop.value_type);
      if (property_node is GXml.Attribute)
      {
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
        return ret;
      }
    }
    // Attribute can't be deseralized with standard methods. Up to the implementor.
    this.deserialize_unknown_property (property_node, prop);
    return true;
  }
  public abstract string to_string ();
}
