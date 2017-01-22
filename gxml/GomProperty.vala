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


/**
 * An interface for {@link GomObject}'s properties translated to
 * {@link DomElement} attributes. If object is instantiated it is
 * written, if not is just ingnored.
 */
public interface GXml.GomProperty : Object
{
  /**
   * Attribute's name in the parent {@link DomElement}.
   */
  public abstract string attribute_name { get; construct set; }
  /**
   * Validation rule.
   *
   * Is a regular expression, used to validate if values are valid.
   */
  public abstract string validation_rule { get; construct set; }
  /**
   * Attribute's value in the parent {@link DomElement} using a string.
   *
   * Implementation should take care to validate value before to set or
   * parse from XML document.
   */
  public abstract string value { owned get; set; }
  /**
   * Convenient function to initialize property's name.
   */
  public abstract void initialize (string attribute_name);
  /**
   * Takes a string and check if it can be validated using
   */
  public abstract bool validate_value (string val);
}

/**
 * Base class for properties implementing {@link GomProperty} interface.
 */
public abstract class GXml.GomBaseProperty : Object, GXml.GomProperty {
  protected string _attribute_name;
  protected string _validation_rule = "";
  /**
   * {@inheritDoc}
   */
  public string attribute_name {
    get { return _attribute_name; }
    construct set { _attribute_name = value;}
  }
  /**
   * {@inheritDoc}
   */
  public string validation_rule {
    get { return _validation_rule; }
    construct set { _validation_rule = value; } // TODO: Validate RegEx
  }
  /**
   * {@inheritDoc}
   */
  public abstract string value { owned get; set; }
  /**
   * {@inheritDoc}
   */
  public void initialize (string attribute_name) {
#if DEBUG
  message ("Type: "+this.get_type ().name());
#endif
  _attribute_name =  attribute_name; }
  /**
   * Takes a string and check if it can be validated using
   * {@link validation_rule}.
   */
  public bool validate_value (string val) { return true; } // FIXME: Validate value
}

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using validated string using Regular Expressions.
 */
public class GXml.GomString : GomBaseProperty {
  protected string _value = "";
  public override string value {
    owned get {
      return _value;
    }
    set {
      if (validate_value (value))
        _value = value;
    }
  }
}

/**
 * Convenient class to handle a {@link GomElement}'s attribute
 * using a list of pre-defined and mutable values.
 * Values can be added or removed.
 */
public class GXml.GomArrayString : GomBaseProperty {
  protected string _value = "";
  protected GLib.Array<string> _values = null;
  /**
   * Array of values to  choose from
   * or to be validated from using {@link is_valid_value}
   */
  public GLib.Array<string> values {
    get { return _values; }
    set { _values = value; }
  }
  /**
   * Convenient method to initialize array of values from an array of strings.
   */
  public void initialize_strings (string[] strs) {
    if (strs.length == 0) return;
    if (_values == null) _values = new GLib.Array<string> ();
    _values.append_vals (strs, strs.length);
  }
  /**
   * Returns true if current value in property is included
   * in the array of values.
   */
  public bool is_valid_value () {
    if (_values == null) return true;
    for (int i = 0; i < _values.length; i++) {
      if (_values.index (i) == value) return true;
    }
    return false;
  }
  /**
   * Select one string from array at index:
   */
  public void select (int index) {
    if (_values == null) return;
    if (index < 0 || index > _values.length) return;
    value = _values.index (index);
  }
  /**
   * Check if string is in array
   */
  public bool search (string str) {
    if (_values == null) return true;
    for (int i = 0; i < _values.length; i++) {
      if (_values.index (i) == str) return true;
    }
    return false;
  }
  /**
   * {inheritDoc}
   */
  public override string value {
    owned get {
      return _value;
    }
    set {
      if (validate_value (value))
        _value = value;
    }
  }
}

/**
 * Convenient class to handle a {@link GomElement}'s attribute
 * using a list of pre-defined and unmutable values.
 */
public class GXml.GomFixedArrayString : GomBaseProperty {
  protected string _value = "";
  protected string[] _values = null;
  public unowned string[] get_values () {
    return _values;
  }
  /**
   * Convenient method to initialize array of values from an array of strings.
   * Values are taken and should not be freed after call initialization.
   */
  public void initialize_strings (owned string[] strs) {
    if (strs.length == 0) return;
    _values = strs;
  }
  /**
   * Returns true if current value in attribute is included
   * in the array of values.
   */
  public bool is_valid_value () {
    if (_values == null) return true;
    foreach (string s in _values) {
      if (s == value) return true;
    }
    return false;
  }
  /**
   * Select one string from array at index:
   */
  public void select (int index) {
    if (index < 0 || index > _values.length) return;
    value = _values[index];
  }
  /**
   * Check if string is in array
   */
  public bool search (string str) {
    if (_values == null) return true;
    for (int i = 0; i < _values.length; i++) {
      if (_values[i] == str) return true;
    }
    return false;
  }
  /**
   * {inheritDoc}
   */
  public override string value {
    owned get {
      return _value;
    }
    set {
      if (validate_value (value))
        _value = value;
    }
  }
}

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using double pressition floats as sources of values.
 *
 * Property is represented as a string.
 */
public class GXml.GomDouble : GomBaseProperty {
  protected double _value = 0.0;
  public override string value {
    owned get {
      string s = "%."+decimals.to_string ()+"f";
      return s.printf (_value);
    }
    set {
      _value = double.parse (value);
    }
  }
  /**
   * Set number of decimals to write out as {@link GomElement}'s property.
   * Default is 4.
   */
  public uint decimals { get; set; default = 4; }
  /**
   * Retrive current value.
   */
  public double get_double () { return _value; }
  /**
   * Sets current value.
   */
  public void set_double (double value) { _value = value; }
}

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using floats as sources of values.
 *
 * Property is represented as a string.
 */
public class GXml.GomFloat : GomDouble {
  /**
   * Retrive current value.
   */
  public float get_float () { return (float) _value; }
  /**
   * Sets current value.
   */
  public void set_float (float value) { _value = value; }
}


/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using a integers as sources of values.
 *
 * Property is represented as a string.
 */
public class GXml.GomInt : GomBaseProperty {
  protected int _value = 0;
  public override string value {
    owned get {
      return _value.to_string ();
    }
    set {
      _value = (int) double.parse (value);
    }
  }
  /**
   * Retrive current value.
   */
  public int get_integer () { return _value; }
  /**
   * Sets current value.
   */
  public void set_integer (int value) { _value = value; }
}

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using a boolean ('true' and 'false') as sources of values.
 *
 * Property is represented as a string, using 'true' or 'false'.
 */
public class GXml.GomBoolean : GomBaseProperty {
  protected bool _value = false;
  public override string value {
    owned get {
      return _value.to_string ();
    }
    set {
      _value = bool.parse (value);
    }
  }
  /**
   * Retrive current value.
   */
  public bool get_boolean () { return _value; }
  /**
   * Sets current value.
   */
  public void set_boolean (bool value) { _value = value; }
}

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using a {@link GLib.Type.ENUM} as a source of values.
 *
 * Enumeration is represented as a string, using its name, independent of
 * value possition in enumeration.
 */
public class GXml.GomEnum : GomBaseProperty {
  protected int _value = 0;
  protected Type _enum_type;
  public override string value {
    owned get {
      string s = "";
      try {
        s = Enumeration.get_string (enum_type, _value, true, true);
      } catch {
        GLib.warning (_("Error when transform enum to attribute's value"));
      }
      return s;
    }
    set {
      try {
        _value = (int) Enumeration.parse (enum_type, value).value;
      } catch {
        GLib.warning (_("Error when transform from attribute string value to enum"));
      }
    }
  }
  /**
   * Enum type used by property.
   */
  public Type enum_type {
    get { return _enum_type; }
    construct set { _enum_type = value; }
  }
  /**
   * Convenient method to initialize internal enum type.
   */
  public void initialize_enum (string attribute_name, GLib.Type enum_type) {
    initialize (attribute_name);
    _enum_type = enum_type;
  }
  /**
   * Retrive current value.
   */
  public int get_enum () { return (int) _value; }
  /**
   * Sets current value.
   */
  public void set_enum (int value) { _value = value; }
}
