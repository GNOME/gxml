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
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type is SerializableProperty) {
        var ov = Value(prop.value_type);
        get_property (name, ref ov);
        SerializableProperty so = (Object) ov;
        if (so == null) return null;
        return so.get_serializable_property_value ();
      }
    }
    return (this as DomElement).get_attribute ();
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
  public virtual void set_attribute (string name, string val) {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type is SerializableProperty) {
        var ov = get_property (name, ref ov);
        SerializableProperty so = (Object) ov;
        if (so == null) return;
        so.set_serializable_property_value (val);
      }
    }
    return (this as DomElement).set_attribute (name, val);
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
  public virtual DomElement get_child (string name) {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type is DomElement) {
        var vo = Value(prop.value_type);
        get_property (name, ref vo);
        return (DomElement) ((Object) vo);
      }
    }
    if ((this as DomNode).has_child_nodes ()) {
      return (this as DomElement).child_nodes.named_item (name);
    }
  }
}
