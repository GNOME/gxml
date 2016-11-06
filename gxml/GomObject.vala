/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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
 * A GXml Object Model (GOM) represents a {@link DomElement}. It has attributes
 * and children. All object's properties are handled as attributes if they are
 * basic types like integers, strings, enums and others; {@link SerializableProperty}
 * objects are handled as attributes too. If object's attribute is a {@link GLib.Object}
 * it is handled as node's child, but only if it is a {@link GomElement} object,
 * other wise it is ignored when this object is used as {@link DomNode} in XML
 * documents.
 */
public interface GXml.GomObject : GLib.Object,
                                  DomNode,
                                  DomElement {
  /**
   * Controls if property name to be used when serialize to XML node
   * attribute use property's nick name as declared in {@link GLib.ParamSpec}
   */
  public virtual bool use_nick_name () { return true; }

  /**
   * Returns a list with all properties nick with "::" prefix. Nick name,
   * without "::" will be used on serialization to an attribute's name.
   */
  public virtual List<string> get_properties_list () {
    var l = new List<string> ();
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      if ("::" in spec.get_nick ()) {
        GLib.message ("Name: "+spec.name+ " Nick: "+spec.get_nick ());
        l.append (spec.get_nick ().replace ("::",""));
      }
    }
    return l;
  }
  /**
   * Returns property's name based on given nick. This function is
   * case insensitive.
   */
  public virtual string? find_property_name (string nick) {
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      if ("::" in spec.get_nick ()) {
        string name = spec.get_nick ().replace ("::","");
        if (name.down () == nick.down ()) {
          GLib.message ("Name: "+spec.name+ " Nick: "+spec.get_nick ());
          return spec.name;
        }
      }
    }
    return null;
  }
  /**
   * Returns a list of names for all {@link DomElement}
   * present as object's properties.
   */
  public virtual List<ParamSpec> get_property_element_list () {
    var l = new List<ParamSpec> ();
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      if (spec.value_type.is_a (typeof (GomObject))) {
        GLib.message ("Object Name: "+spec.name+ " Nick: "+spec.get_nick ());
        l.append (spec);
      }
    }
    return l;
  }
  /**
   * Search for properties in objects, it should be
   * an {@link GLib.Object}'s property. If found a
   * property with given name its value is returned
   * as string representation.
   *
   * If property is a {@link SerializableProperty}
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
    GLib.message ("GomObject: attribute: "+name);
    string pname = find_property_name (name);
    if (pname == null) return null;
    GLib.message ("GomObject: found attribute: "+pname);
    var prop = get_class ().find_property (pname);
    if (prop != null) {
      GLib.message ("Found attribute: "+prop.name);
      var v = Value(prop.value_type);
      get_property (prop.name, ref v);
      if (prop.value_type == typeof(SerializableProperty)) {
        SerializableProperty so = (Object) v as SerializableProperty;
        if (so == null) return null;
        return so.get_serializable_property_value ();
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
        return null;
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
   * this object, see {@link set_child}
   */
  public virtual bool set_attribute (string name, string val) {
    GLib.message ("GomObject: searching attribute to set: "+name);
    string pname = find_property_name (name);
    if (pname == null) return false;
    GLib.message ("GomObject: setting attribute: "+name);
    var prop = get_class ().find_property (pname);
    if (prop != null) {
      var v = Value (prop.value_type);
      if (prop.value_type == typeof(SerializableProperty)) {
        get_property (prop.name, ref v);
        SerializableProperty so = (Object) v as SerializableProperty;
        if (so == null) return false;
        so.set_serializable_property_value (val);
        return true;
      }
      if (prop.value_type.is_a (typeof (string))) {
        v.set_string (val);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (int))) {
        v.set_string (val);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (uint))) {
        v.set_string (val);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (double))) {
        v.set_string (val);
        set_property (prop.name, v);
        return true;
      }
      if (prop.value_type.is_a (typeof (bool))) {
        v.set_string (val);
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
   * {@link DomNode.get_elements_by_tag_name} is called, returning
   * first node found. Tag name to use, is the given name parameter.
   *
   * @param name a name of this object's property of type {@link DomElement} or
   * first {@link DomNode} with that name in child nodes.
   *
   */
  public virtual DomElement? get_child (string name) {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type == typeof(DomElement)) {
        var vo = Value(prop.value_type);
        get_property (prop.name, ref vo);
        return (DomElement) ((Object) vo);
      }
    }
    if ((this as DomNode).has_child_nodes ()) {
      var els = (this as DomElement).get_elements_by_tag_name (name);
      if (els.size != 0)
        return els.item (0);
    }
    return null;
  }
  /**
   * Search for a property and set it to null if possible, if value can't
   * be removed, returns without change.
   */
  public virtual bool remove_attribute (string name) {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type.is_a (typeof (SerializableProperty))) {
        (this as SerializableProperty).set_serializable_property_value (null);
        return true;
      }
      if (prop.value_type.is_a (typeof (SerializableCollection))) {
        return true;
      }
      Value v = Value (typeof (Object));
      (this as Object).set_property (name, v);
      return true;
    }
    return false;
  }
}
