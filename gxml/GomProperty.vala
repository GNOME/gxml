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
   * Attribute's value in the parent {@link DomElement} using a string.
   *
   * Implementation should take care to validate value before to set or
   * parse from XML document.
   */
  public abstract string? value { owned get; set; }
  /**
   * Takes a string and check if it is a valid value for property
   */
  public abstract bool validate_value (string val);
}

/**
 * Base class for properties implementing {@link GomProperty} interface.
 */
public abstract class GXml.GomBaseProperty : Object, GXml.GomProperty {
  /**
   * {@inheritDoc}
   */
  public abstract string? value { owned get; set; }
  /**
   * Takes a string and check if it can be validated using
   * {@link validation_rule}.
   */
  public virtual bool validate_value (string val) { return true; }
}

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using validated string using Regular Expressions.
 */
public class GXml.GomString : GomBaseProperty {
  protected string _value = "";
  public override string? value {
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
public class GXml.GomArrayString : GomBaseProperty {
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
    if (_values == null) return false;
    for (int i = 0; i < _values.length; i++) {
      if (_values[i] == str) return true;
    }
    return false;
  }
  /**
   * {inheritDoc}
   */
  public override string? value {
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
 * using a list of pre-defined and unmutable values, taken from
 * an {@link XsdSimpleType} definition
 */
public class GXml.GomXsdArrayString : GomArrayString {
  protected GLib.File _source = null;
  protected string _simple_type = null;
  /**
   * Name of {@link XsdSympleType} to use as source. If {@link source} is set
   * calls {@link initialize_xsd}.
   */
  public string simple_type {
    get { return _simple_type; }
    set { _simple_type = value; }
  }
  /**
   * A {@link GLib.File} source to read from, simple type definitions in
   * an XSD file type. Once it is set, search required {@link simple_type}
   * definition name and call {@link initalize_xsd}
   */
  public GLib.File source {
    get { return _source; }
    set {
      if (!value.query_exists ()) return;
      _source = value;
    }
  }
  /**
   * Load list of strings from a {@link GLib.File}, parsing using an
   * {@link GomXsdSchema} object and searching for {@link XsdSimpleType}
   * definition with name {@link source_type}.
   */
  public void load () throws GLib.Error {
#if DEBUG
          message ("Initializing enumerations: ");
#endif
    if (_source == null) return;
    if (!_source.query_exists ()) return;
    if (_simple_type == null) return;
    var xsd = new GomXsdSchema ();
    xsd.read_from_file (_source);
    if (xsd.simple_type_definitions == null) return;
    if (xsd.simple_type_definitions.length == 0) return;
#if DEBUG
    message ("Searching SimpleType: "+_simple_type);
    message ("SimpleType definitions: "+xsd.simple_type_definitions.length.to_string ());
#endif
    for (int i = 0; i < xsd.simple_type_definitions.length; i++) {
      var st = xsd.simple_type_definitions.get_item (i) as GomXsdSimpleType;
#if DEBUG
          message ("Item SimpleType %i is Null %s: ".printf (i, (st == null).to_string ()));
#endif
      if (st == null) continue;
#if DEBUG
          message ("Item SimpleType %i name is Null %s: ".printf (i, (st.name == null).to_string ()));
#endif
      if (st.name == null) continue;
#if DEBUG
          message ("Checking SimpleType: "+st.name);
#endif
      if (_simple_type.down () == st.name.down ()) {
        if (st.restriction == null) continue;
        if (st.restriction.enumerations == null) continue;
        if (st.restriction.enumerations.length == 0) continue;
        string[] vals = {};
        for (int j = 0; j < st.restriction.enumerations.length; j++) {
          var en = st.restriction.enumerations.get_item (j) as GomXsdTypeRestrictionEnumeration;
          if (en == null) continue;
          if (en.value == null) continue;
#if DEBUG
          message ("Enumeration to add: "+en.value);
#endif
          vals += en.value;
        }
        initialize_strings (vals);
      }
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
  public override string? value {
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
  public override string? value {
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
  public override string? value {
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
  public override string? value {
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
  public void initialize_enum (GLib.Type enum_type) {
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

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using a {@link GLib.Date} as sources of values.
 *
 * Property is represented as a string using a %Y-%m-%d format
 */
public class GXml.GomDate : GomBaseProperty {
  protected Date _value = Date ();
  public override string? value {
    owned get {
      if (!_value.valid ()) return null;
      char[] fr = new char[100];
      _value.strftime (fr, "%Y-%m-%d");
      return (string) fr;
    }
    set {
      _value = Date ();
      _value.set_parse (value);
      if (!_value.valid ())
        warning (_("Invalid Date for property: "+value));
    }
  }
  /**
   * Retrives current value.
   */
  public Date get_date () { return _value; }
  /**
   * Sets current value.
   */
  public void set_date (Date date) { _value = date; }
}

/**
 * Convenient class to handle {@link GomElement}'s attributes
 * using a {@link GLib.DateTime} as sources of values.
 *
 * Timestamp is considered in local time.
 *
 * Property is represented as a string using a {@link GomDateTime.format}
 * and {@link GLib.DateTime.format} method. If {@link GomDateTime.format}
 * is not set '%FT%T' format is used by default.
 */
public class GXml.GomDateTime : GomBaseProperty {
  protected DateTime _value = null;
  public string format { get; set; }
  public override string? value {
    owned get {
      if (_value == null) return null;
      string s = format;
      if (s == null)
        s = "%FT%T";
      return _value.format (s);
    }
    set {
      var tv = TimeVal ();
      if (tv.from_iso8601 (value)) {
        _value = new DateTime.from_timeval_local (tv);
      } else
        warning (_("Invalid timestamp for property: "+value));
    }
  }
  /**
   * Retrives current value.
   */
  public DateTime get_datetime () { return _value; }
  /**
   * Sets current value.
   */
  public void set_datetime (DateTime dt) { _value = dt; }
}
