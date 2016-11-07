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
 * {@link DomElement} attributes.
 */
public interface GXml.GomProperty : Object
{
  /**
   * Attribute's name in the parent {@link DomElement}.
   */
  public abstract string attribute_name { get; construct set; }
  /**
   * Attribute's value in the parent {@link DomElement}.
   */
  public abstract string value { owned get; set; }
}

public class GXml.GomDouble : Object, GomProperty {
  protected double _value = 0.0;
  protected string _attribute_name;
  public string attribute_name {
    get { return _attribute_name; }
    construct set { _attribute_name = value;}
  }
  public string value {
    owned get {
      string s = "%."+decimals.to_string ()+"f";
      return s.printf (_value);
    }
    set {
      _value = double.parse (value);
    }
  }
  public uint decimals { get; set; default = 4; }
  public double get_double () { return _value; }
  public void set_double (double value) { _value = value; }
}

public class GXml.GomFloat : GomDouble {
  public float get_float () { return (float) _value; }
  public void set_float (float value) { _value = value; }
}


public class GXml.GomInt : Object, GomProperty {
  protected int _value = 0;
  protected string _attribute_name;
  public string attribute_name {
    get { return _attribute_name; }
    construct set { _attribute_name = value;}
  }
  public string value {
    owned get {
      return _value.to_string ();
    }
    set {
      _value = (int) double.parse (value);
    }
  }
  public int get_integer () { return _value; }
  public void set_integer (int value) { _value = value; }
}

public class GXml.GomBoolean : Object, GomProperty {
  protected bool _value = false;
  protected string _attribute_name;
  public string attribute_name {
    get { return _attribute_name; }
    construct set { _attribute_name = value;}
  }
  public string value {
    owned get {
      return _value.to_string ();
    }
    set {
      _value = bool.parse (value);
    }
  }
  public bool get_boolean () { return _value; }
  public void set_boolean (bool value) { _value = value; }
}

public class GXml.GomEnum : Object, GomProperty {
  protected int _value = 0;
  protected string _attribute_name;
  protected Type _enum_type;
  public string attribute_name {
    get { return _attribute_name; }
    construct set { _attribute_name = value;}
  }
  public string value {
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
  public Type enum_type {
    get { return _enum_type; }
    construct set { _enum_type = value; }
  }
  public int get_enum () { return (int) _value; }
  public void set_enum (int value) { _value = value; }
}
