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
   * Returns a list with all properties' nick with "::" prefix. Nick name,
   * with "::" prefix will be used on serialization to an attribute's name.
   */
  public virtual List<ParamSpec> get_properties_list () {
    var l = new List<ParamSpec> ();
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
   * Returns property's {@link GLib.ParamSpec} based on given nick. This function is
   * case insensitive.
   */
  public virtual ParamSpec? find_property_name (string pname) {
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      string name = spec.get_nick ();
#if DEBUG
          GLib.message ("Name: "+spec.name+ " Nick: "+spec.get_nick ()+" Type: "+spec.value_type.name());
#endif
      if ("::" in name) {
        name = name.replace ("::","");
        if (name.down () == pname.down ()) {
#if DEBUG
          GLib.message ("Found Property: "+pname);
          GLib.message ("Is GomProperty? : "+(spec.value_type.is_a (typeof(GomProperty)).to_string ()));
#endif
          return spec;
        }
      }
    }
    return null;
  }
  /**
   * Returns a {@link GomObject} or a {@link GomCollection} property's
   * {@link GLib.ParamSpec} based on given name. This method is
   * case insensitive.
   *
   * This method will check if nick's name is equal than given name
   * in order to avoid use canonical names like "your-name" if your
   * property is your_name; so you can se nick to "YourName" to find
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
        if (spec.value_type.is_a (typeof (GomObject))
            || spec.value_type.is_a (typeof (GomCollection))) {
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
  public virtual List<ParamSpec> get_property_element_list () {
    var l = new List<ParamSpec> ();
    foreach (ParamSpec spec in this.get_class ().list_properties ()) {
      if (spec.value_type.is_a (typeof (GomObject))
          || spec.value_type.is_a (typeof (GomCollection))) {
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
    if (prop.value_type.is_a (typeof(GomProperty))) {
#if DEBUG
    GLib.message ("Getting GomProperty attribute: "+prop.name);
#endif
      var so = v.get_object ();
      if (so == null) {
#if DEBUG
        GLib.message ("GomProperty is Null");
#endif
        return null;
      }
#if DEBUG
      if ((so as GomProperty).value != null) {
        message ("GomProperty Value: "+(so as GomProperty).value);
      } else {
        message ("GomProperty Value Is Null");
      }
#endif
      return (so as GomProperty).value;
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
    }
    return null;
  }
  /**
   * Search for properties in objects, it should be
   * an {@link GLib.Object}'s property. If found a
   * property with given name its value is returned
   * as string representation.
   *
   * If property is a {@link GomProperty}
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
#if DEBUG
    GLib.message ("Searching GomObject attribute: "+name);
#endif
    var prop = find_property_name (name);
    if (prop == null) return null;
#if DEBUG
    GLib.message ("Found GomObject attribute: "+prop.name);
#endif
    return get_property_string (prop);
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
#if DEBUG
    GLib.message ("GomObject: searching attribute to set: "+name);
#endif
    var prop = find_property_name (name);
#if DEBUG
    GLib.message ("GomObject: setting attribute: "+name);
#endif
    if (prop != null) {
      var v = Value (prop.value_type);
      if (prop.value_type.is_a (typeof(GomProperty))) {
        get_property (prop.name, ref v);
        GomProperty so = (Object) v as GomProperty;
        if (so == null) {
          var obj = Object.new (prop.value_type);
          v.set_object (obj);
          set_property (prop.name, v);
          so = obj as GomProperty;
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
        v.set_int ((int) iv);
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
    if ((this as DomNode).has_child_nodes ()) {
      var els = (this as DomElement).get_elements_by_tag_name (name);
      if (els.size != 0)
        return els.item (0);
    }
    return null;
  }
  /**
   * From a given property name of type {@link GomElement}, search all
   * child nodes with node's local name equal to property.
   */
  public virtual DomElementList find_elements (string name) {
    var l = new DomElementList ();
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (prop.value_type.is_a (typeof(DomElement))) {
        var o = Object.new (prop.value_type) as DomElement;
        foreach (DomNode n in this.child_nodes) {
          if (!(n is DomElement)) continue;
          if ((n as DomElement).local_name.down () == o.local_name.down ())
            l.add (n as DomElement);
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
      Value v = Value (typeof (Object));
      (this as Object).set_property (name, v);
      return true;
    }
    return false;
  }
  /**
   * Convenient method to set an instance of given property's
   * name and initialize according to have same {@link DomNode.owner_document}
   * and set its {@link DomNode.parent_node} to this appending it as a child.
   * If property is a {@link GomCollection} it is initialize to use
   * this as its {@link GomCollection.element}.
   *
   * Instance is set ot object's property.
   *
   * Property should be a {@link GomElement} or {@link GomCollection}
   *
   * While an object could be created and set to a Object's property, it
   * is not correctly initialized by default. This method helps in the process.
   *
   * If Object's property has been set, this method overwrite it.
   *
   * {{{
   * class NodeA : GomObject {
   *   construct { try { initialize ("NodeA"); } catch { warning ("Can't initialize); }
   * }
   * class NodeB : GomObject {
   *   public NodeA node { get; set; }
   * }
   *
   * var nb = new NodeB ();
   * nb.create_instance_property ("node");
   * assert (nb.node != null);
   * }}}
   *
   * Returns: true if property has been set and initialized, false otherwise.
   */
  public virtual bool set_instance_property (string name) {
    var prop = find_object_property_name (name);
    if (prop == null) return false;
    Value v = Value (prop.value_type);
    Object obj;
    if (prop.value_type.is_a (typeof (GomCollection))) {
      obj = Object.new (prop.value_type, "element", this);
      v.set_object (obj);
      set_property (prop.name, v);
      return true;
    }
    if (prop.value_type.is_a (typeof (GomElement))) {
      obj = Object.new (prop.value_type,"owner-document", this.owner_document);
      try { this.append_child (obj as GomElement); }
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
   * of object. Is useful if you have a {@link GomElement} property, it should be
   * just one child of this type and you want to overwrite it.
   *
   * In this example you have defined an element MyClass to be child of
   * MyParentClass, but it should have just one element, once you set child_elements
   * it calls {@link clean_property_elements} using property's canonicals name.
   *
   * {{{
   *  public class MyClass : GomElement {
   *    public string name { get; set; }
   *  }
   *  public class MyParentClass : GomElement {
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
   * @throws DomError if property is not a {@link GomElement}.
   */
  public virtual
  void clean_property_elements (string name) throws GLib.Error
  {
    var prop = get_class ().find_property (name);
    if (prop != null) {
      if (!prop.value_type.is_a (typeof (GomElement)))
        throw new DomError.TYPE_MISMATCH_ERROR (_("Can't set value. It is not a GXmlGomElement type"));
      var l = find_elements (name);
      if (l.length != 0) {
        foreach (DomElement e in l) {
          e.remove ();
        }
      }
    }
  }
}
