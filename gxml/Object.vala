/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016-2019  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

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
 * A GXml Object Model represents a {@link DomElement}. It has attributes
 * and children. All object's properties are handled as attributes if they are
 * basic types like integers, strings, enums and others; {@link Property}
 * objects are handled as attributes too. If object's attribute is a {@link GLib.Object}
 * it is handled as node's child, but only if it is a {@link GXml.Element} object,
 * other wise it is ignored when this object is used as {@link DomNode} in XML
 * documents.
 */
public interface GXml.Object : GLib.Object,
                                  DomNode,
                                  DomElement {
  /**
   * Returns a list with all properties' nick with "::" prefix. Nick name,
   * with "::" prefix will be used on serialization to an attribute's name.
   */
  public virtual GLib.List<ParamSpec> get_properties_list () {
    var l = new GLib.List<ParamSpec> ();
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      if ("::" in spec.get_nick ()) {
#if DEBUG
        GLib.message ("Name: "+spec.name+ " Nick: "+spec.get_nick ());
#endif
        l.append (spec);
      }
    }
    return l;
  }
  /**
   * Returns property's {@link GLib.ParamSpec} based on given nick, without '::'
   * This function is case insensitive.
   *
   * By default any property to be serialized, should set its nick with a prefix
   * '::', while this method requires to avoid '::' for property's name to find.
   * '::' will not be present on serialization output, so you can use any convention
   * for your attribute's name, like using camel case.
   */
  public virtual ParamSpec? find_property_name (string nick) {
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      string name = spec.get_nick ();
      if ("::" in name) {
        name = name.replace ("::","");
        if (name.down () == nick.down ()) {
          return spec;
        }
      }
    }
    return null;
  }
  /**
   * Returns a {@link GXml.Object} or a {@link Collection} property's
   * {@link GLib.ParamSpec} based on given name. This method is
   * case insensitive.
   *
   * This method will check if nick's name is equal than given name
   * in order to avoid use canonical names like "your-name" if your
   * property is your_name; so you can use nick to "YourName" to find
   * and instantiate it.
   */
  public virtual ParamSpec? find_object_property_name (string pname) {
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      string name = pname.down ();
      if ("::" in name) name = name.replace ("::","");
      string nick = spec.get_nick ().down ();
      if ("::" in nick) nick = nick.replace ("::","");
      string sname = spec.name.down ();
      if (sname == name || nick == name) {
        if (spec.value_type.is_a (typeof (GXml.Object))
            || spec.value_type.is_a (typeof (Collection))) {
#if DEBUG
          GLib.message ("Found Property: "+pname);
#endif
          return spec;
        }
      }
    }
    return null;
  }
  /**
   * Returns a list of names for all {@link DomElement}
   * present as object's properties.
   */
  public virtual GLib.List<ParamSpec> get_property_element_list () {
    var l = new GLib.List<ParamSpec> ();
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      if ((spec.value_type.is_a (typeof (GXml.Object))
          || spec.value_type.is_a (typeof (Collection)))
          && spec.value_type.is_instantiatable ()) {
#if DEBUG
        GLib.message ("Object Name: "+spec.name+ " Nick: "+spec.get_nick ());
#endif
        l.append (spec);
      }
    }
    return l;
  }
  /**
   * Returns an string representation of an Object's property.
   */
  public virtual string? get_property_string (ParamSpec prop) {
    var v = Value(prop.value_type);
    get_property (prop.name, ref v);
    if (prop.value_type.is_a (typeof(GXml.Property))) {
#if DEBUG
    GLib.message ("Getting GXml.Property attribute: "+prop.name);
#endif
      var so = v.get_object ();
      if (so == null) {
#if DEBUG
        GLib.message ("GXml.Property is Null");
#endif
        return null;
      }
#if DEBUG
      if (((GXml.Property) so).value != null) {
        message ("GXml.Property Value: "+((GXml.Property) so).value);
      } else {
        message ("GXml.Property Value Is Null");
      }
#endif
      return ((GXml.Property) so).value;
    }
    if (prop.value_type.is_a (typeof (string))) {
      return (string) v;
    }
    if (prop.value_type.is_a (typeof (int))) {
      return ((int) v).to_string ();
    }
    if (prop.value_type.is_a (typeof (uint))) {
      return ((uint) v).to_string ();
    }
    if (prop.value_type.is_a (typeof (float))) {
      return ((float) v).to_string ();
    }
    if (prop.value_type.is_a (typeof (double))) {
      return ((double) v).to_string ();
    }
    if (prop.value_type.is_a (typeof (bool))) {
      return ((bool) v).to_string ();
    }
    if (prop.value_type.is_a (Type.ENUM)) {
      var n = v.get_enum ();
      try {
        return Enumeration.get_string (prop.value_type, n, true, true);
      } catch {
        GLib.warning (_("Enumeration is out of range"));
      }
    }
    return null;
  }
  /**
   * Search for properties in objects, it should be
   * an {@link GLib.Object}'s property. If found a
   * property with given name its value is returned
   * as string representation.
   *
   * If property is a {@link GXml.Property}
   * returned value is a string representation according
   * with object implementation.
   *
   * If given property name is not found, then {@link DomElement.get_attribute}
   * is called.
   *
   * By default all {@link GLib.Object} are children of
   * this object, see {@link get_child}
   */
  public virtual string? get_attribute (string name) {
    var prop = find_property_name (name);
    if (prop == null) return null;
    return get_property_string (prop);
  }
  /**
   * Search for a property of type {@link GXml.Property}
   * and returns it as object
   */
  public virtual GXml.Property? find_property (string name) {
    var prop = find_property_name (name);
    if (prop != null) {
      var v = Value (prop.value_type);
      if (prop.value_type.is_a (typeof(GXml.Property))
          && prop.value_type.is_instantiatable ()) {
        get_property (prop.name, ref v);
        GXml.Property so = (Object) v as GXml.Property;
        if (so == null) {
          var obj = GLib.Object.new (prop.value_type);
          v.set_object (obj);
          set_property (prop.name, v);
          so = obj as GXml.Property;
        }
        return so;
      }
    }
    return null;
  }
  /**
   * Search for a {@link GLib.Object} property with
   * given name, if found, given string representation
   * is used as value to property, using any required
   * transformation from string.
   *
   * By default all {@link GLib.Object} are children of
   * this object.
   */
  public virtual bool set_attribute (string name, string val) {
    var prop = find_property_name (name);
    if (prop != null) {
      var v = Value (prop.value_type);
      if (prop.value_type.is_a (typeof(GXml.Property))
          && prop.value_type.is_instantiatable ()) {
        get_property (prop.name, ref v);
        GXml.Property so = (Object) v as GXml.Property;
        if (so == null) {
          var obj = GLib.Object.new (prop.value_type);
          v.set_object (obj);
          set_property (prop.name, v);
          so = obj as GXml.Property;
        }
        so.value = val;
        return true;
      }
      if (prop.value_type.is_a (typeof (string))) {
        v.set_string (val);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (int))) {
        int iv = (int) double.parse (val);
        v.set_int (iv);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (uint))) {
        uint iv = (uint) double.parse (val);
        v.set_uint ((int) iv);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (float))) {
        double dv = double.parse (val);
        v.set_float ((float) dv);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (double))) {
        double dv = double.parse (val);
        v.set_double (dv);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (bool))) {
        bool bv = bool.parse (val);
        v.set_boolean (bv);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (Type.ENUM)) {
        try {
          var n = (int) Enumeration.parse (prop.value_type, val).value;
          v.set_enum (n);
        } catch {
          GLib.warning (_("Enumeration can't be parsed from string"));
          return false;
        }
        return true;
      }
    }
    return false;
  }
  /**
   * Search a {@link GLib.Object} property with given name
   * and returns it, if it is a {@link DomElement}. If not found,
   * {@link DomElement.get_elements_by_tag_name} is called, returning
   * first node found. Tag name to use, is the given name parameter.
   *
   * @param name a name of this object's property of type {@link DomElement} or
   * first {@link DomNode} with that name in child nodes.
   *
   */
  public virtual DomElement? get_child (string name) {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type.is_a (typeof(DomElement))) {
        var vo = Value(prop.value_type);
        get_property (prop.name, ref vo);
        return (DomElement) ((Object) vo);
      }
    }
    if (((DomNode) this).has_child_nodes ()) {
      var els = ((DomElement) this).get_elements_by_tag_name (name);
      if (els.size != 0)
        return els.item (0);
    }
    return null;
  }
  /**
   * From a given property name of type {@link GXml.Element}, search all
   * child nodes with node's local name equal to property.
   */
  public virtual DomElementList find_elements (string name) {
    var l = new DomElementList ();
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type.is_a (typeof(DomElement))) {
        var o = GLib.Object.new (prop.value_type) as DomElement;
        foreach (DomNode n in this.child_nodes) {
          if (!(n is DomElement)) continue;
          if (((DomElement) n).local_name.down () == o.local_name.down ())
            l.add ((DomElement) n);
        }
      }
    }
    return l;
  }
  /**
   * Search for a property and set it to null if possible returning true,
   * if value can't be removed or located, returns false without change.
   */
  public virtual bool remove_attribute (string name) {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type.is_a (typeof (Object))) {
        Value v = Value (typeof (Object));
        ((Object) this).set_property (name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (string))) {
        Value v = Value (typeof (string));
        v.set_string (null);
        set_property (prop.name, v);
        return true;
      }
    }
    return false;
  }
  /**
   * Convenient method to set an instance of given property's
   * name and initialize according to have same {@link DomNode.owner_document}
   * and set its {@link DomNode.parent_node} to this appending it as a child.
   * If property is a {@link Collection} it is initialize to use
   * this as its {@link Collection.element}.
   *
   * Instance is set to object's property.
   *
   * Property should be a {@link GXml.Element} or {@link Collection}
   *
   * While an object could be created and set to a Object's property, it
   * is not correctly initialized by default. This method helps in the process.
   *
   * If Object's property has been set, this method overwrite it.
   *
   * {{{
   * class NodeA : GXml.Object {
   *   construct { try { initialize ("NodeA"); } catch { warning ("Can't initialize); }
   * }
   * class NodeB : GXml.Object {
   *   public NodeA node { get; set; }
   * }
   *
   * var nb = new NodeB ();
   * nb.create_instance_property ("node");
   * assert (nb.node != null);
   * }}}
   *
   * Property's name can be canonical or its nick name, see {@link find_object_property_name}
   *
   * Returns: true if property has been set and initialized, false otherwise.
   */
  public virtual bool set_instance_property (string name) {
    var prop = find_object_property_name (name);
    if (prop == null) return false;
    Value v = Value (prop.value_type);
    GLib.Object obj;
    if (prop.value_type.is_a (typeof (Collection))) {
      obj = GLib.Object.new (prop.value_type, "element", this);
      v.set_object (obj);
      set_property (prop.name, v);
      return true;
    }
    if (prop.value_type.is_a (typeof (GXml.Element))) {
      obj = GLib.Object.new (prop.value_type,"owner-document", this.owner_document);
      try { this.append_child (obj as GXml.Element); }
      catch (GLib.Error e) {
        warning (_("Error while attempting to instantiate property object: %s").printf (e.message));
        return false;
      }
      v.set_object (obj);
      set_property (prop.name, v);
      return true;
    }
    return false;
  }
  /**
   * Utility method to remove all instances of a property being child elements
   * of object. Is useful if you have a {@link GXml.Element} property, it should be
   * just one child of this type and you want to overwrite it.
   *
   * In this example you have defined an element MyClass to be child of
   * MyParentClass, but it should have just one element, once you set child_elements
   * it calls {@link clean_property_elements} using property's canonicals name.
   *
   * {{{
   *  public class MyClass : GXml.Element {
   *    public string name { get; set; }
   *  }
   *  public class MyParentClass : GXml.Element {
   *    private Myclass _child_elements = null;
   *    public MyClass child_elements {
   *      get { return _child_elements; }
   *      set {
   *        try {
   *          clean_property_elements ("child-elements");
   *          _child_elements = value;
   *          append_child (_child_elements);
   *        } catch (GLib.Error e) {
   *          warning (e.message);
   *        }
   *      }
   *    }
   *  }
   * }}}
   *
   * @param name property name to search value type, use canonical names.
   *
   * @throws DomError if property is not a {@link GXml.Element}.
   */
  public virtual
  void clean_property_elements (string name) throws GLib.Error
  {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (!prop.value_type.is_a (typeof (GXml.Element)))
        throw new DomError.TYPE_MISMATCH_ERROR (_("Can't set value. It is not a GXmlGXml.Element type"));
      var l = find_elements (name);
      if (l.length != 0) {
        foreach (DomElement e in l) {
          e.remove ();
        }
      }
    }
  }
}
