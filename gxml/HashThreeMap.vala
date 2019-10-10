/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * HashThreeMap.vala
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
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;

/**
 * A class implementing {@link Collection} to store references to
 * child {@link DomElement} of {@link Collection.element}, using three attributes in
 * items as primary, secondary tertiary keys or {@link MappeableElementThreeKey.get_map_pkey},
 * {@link MappeableElementThreeKey.get_map_skey}
 * and {@link MappeableElementThreeKey.get_map_tkey}
 * methods if {@link MappeableElementThreeKey} are implemented
 * by items to be added. All keys should be defined in node, otherwise
 * it is not added; but keeps it as a child node of actual
 * {@link Collection.element}.
 *
 * If {@link GXml.Element} to be added is of type {@link Collection.items_type}
 * and implements {@link MappeableElementThreeKey}, you should set
 * {@link attribute_primary_key}, {@link attribute_secondary_key}
 * and  {@link attribute_third_key}
 * to null in order to use returned value of {@link MappeableElementThreeKey.get_map_pkey},
 * {@link MappeableElementThreeKey.get_map_skey}
 * and {@link MappeableElementThreeKey.get_map_tkey}
 * as keys.
 *
 * {{{
 *   public class YourObject : GXml.Element, MappeableElementThreeKey {
 *    [Description (nick="::Name")]
 *    public string name { get; set; }
 *    public string code { get; set; }
 *    public string category { get; set; }
 *    public string get_map_primary_key () { return code; }
 *    public string get_map_secondary_key () { return name; }
 *    public string get_map_third_key () { return category; }
 *   }
 *   public class YourList : HashThreeMap {
 *    construct {
 *      try { initialize_with (typeof (YourObject)); }
 *      catch (GLib.Error e) {
 *        warning ("Initialization error for collection type: %s : %s"
 *             .printf (get_type ().name(), e.message));
 *      }
 *    }
 *   }
 * }}}
 */
public class GXml.HashThreeMap : GXml.BaseCollection, ThreeMap {
  /**
   * A hashtable with all keys as string to node's index referred. Don't modify it manually.
   */
  protected Gee.HashMap<string,Gee.HashMap<string,Gee.HashMap<string,int>>> _hashtable = new Gee.HashMap<string,Gee.HashMap<string,Gee.HashMap<string,int>>> ();
  /**
   * Element's attribute name used to refer of container's element as primary key.
   * You should define it at construction time
   * our set it as a construction property.
   */
  protected string _attribute_primary_key;
  /**
   * Element's attribute name used to refer of container's element as secondary key.
   * You should define it at construction time
   * our set it as a construction property.
   */
  protected string _attribute_secondary_key;
  /**
   * Element's attribute name used to refer of container's element as third key.
   * You should define it at construction time
   * our set it as a construction property.
   */
  protected string _attribute_third_key;
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as primary key.
   */
  public string attribute_primary_key {
    get { return _attribute_primary_key; } construct set { _attribute_primary_key = value; }
  }
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as secondary key.
   */
  public string attribute_secondary_key {
    get { return _attribute_secondary_key; } construct set { _attribute_secondary_key = value; }
  }
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as third key.
   */
  public string attribute_third_key {
    get { return _attribute_third_key; } construct set { _attribute_third_key = value; }
  }
  /**
   * Convenient function to initialize a {@link GXml.HashMap} collection, using
   * given element, items' type and name.
   */
  public void initialize_element_with_keys (GXml.Element element,
                                  GLib.Type items_type,
                                  string attribute_primary_key,
                                  string attribute_secondary_key,
                                  string attribute_third_key) throws GLib.Error
  {
    initialize (items_type);
    initialize_element (element);
    _attribute_primary_key = attribute_primary_key;
    _attribute_secondary_key = attribute_secondary_key;
    _attribute_third_key = attribute_third_key;
  }

  /**
   * Convenient function to initialize a {@link GXml.HashMap} collection, using
   * given element, items' type and name.
   *
   * Using this method at construction time of derived classes.
   */
  public void initialize_with_keys (GLib.Type items_type,
                                  string attribute_primary_key,
                                  string attribute_secondary_key,
                                  string attribute_third_key) throws GLib.Error
  {
    initialize (items_type);
    _attribute_primary_key = attribute_primary_key;
    _attribute_secondary_key = attribute_secondary_key;
    _attribute_third_key = attribute_third_key;
  }
  /**
   * Returns an {@link DomElement} in the collection using given string keys.
   */
  public new DomElement? get (string primary_key, string secondary_key, string third_key) {
    if (!_hashtable.has_key (primary_key)) return null;
    var ht = _hashtable.get (primary_key);
    if (ht == null) return null;
    if (!ht.has_key (secondary_key)) return null;
    var hte = ht.get (secondary_key);
    if (hte == null) return null;
    if (!hte.has_key (third_key)) return null;
    var i = hte.get (third_key);
    return _element.child_nodes.get (i) as DomElement;
  }
  /**
   * Returns true if @key is used in collection as primary key.
   */
  public bool has_primary_key (string key) {
    if (_hashtable.has_key (key)) return true;
    return false;
  }
  /**
   * Returns true if @key is used in collection as secondary key
   * with @pkey as primary.
   */
  public bool has_secondary_key (string pkey, string key) {
    if (!(_hashtable.has_key (pkey))) return false;
    var ht = _hashtable.get (pkey);
    if (ht == null) return false;
    if (ht.has_key (key)) return true;
    return false;
  }
  /**
   * Returns true if @key is used in collection as third key with secondary key
   * and pkey as primary.
   */
  public bool has_third_key (string pkey, string skey, string key) {
    if (!(_hashtable.has_key (pkey))) return false;
    var ht = _hashtable.get (pkey);
    if (ht == null) return false;
    var hte = ht.get (skey);
    if (hte == null) return false;
    if (hte.has_key (key)) return true;
    return false;
  }
  /**
   * Returns list of primary keys used in collection.
   */
  public GLib.List<string> get_primary_keys () {
    var l = new GLib.List<string> ();
    foreach (string k in _hashtable.keys) {
      l.append (k);
    }
    return l;
  }
  /**
   * Returns list of secondary keys used in collection with pkey as primary key.
   */
  public GLib.List<string> get_secondary_keys (string pkey) {
    var l = new GLib.List<string> ();
    if (!_hashtable.has_key (pkey)) return l;
    var ht = _hashtable.get (pkey);
    if (ht == null) return l;
    foreach (string k in ht.keys) {
      l.append (k);
    }
    return l;
  }
  /**
   * Returns list of third keys used in collection with pkey as primary key
   * and skey as secondary key.
   */
  public GLib.List<string> get_third_keys (string pkey, string skey) {
    var l = new GLib.List<string> ();
    if (!_hashtable.has_key (pkey)) return l;
    var ht = _hashtable.get (pkey);
    if (ht == null) return l;
    var hte = ht.get (skey);
    if (hte == null) return l;
    foreach (string k in hte.keys) {
      l.append (k);
    }
    return l;
  }
  /**
   * Validates if given element has a {@link attribute_primary_key},
   * {@link attribute_secondary_key} and
   * {@link attribute_third_key} set,
   * if so adds a new keys pointing to given index and returns true.
   *
   * Attribute should be a valid {@link DomElement} attribute or
   * a {@link GXml.Object} property identified using a nick with a '::' prefix.
   *
   * If there are more elements with same keys, they are kept as child nodes
   * but the one in collection will be the last one to be found.
   *
   * Return: false if element should not be added to collection.
   */
  public override bool validate_append (int index, DomElement element) throws GLib.Error {
    if (!(element is GXml.Element)) return false;
    string pkey = null;
    string skey = null;
    string tkey = null;
    if (attribute_primary_key != null && attribute_secondary_key != null
        && attribute_third_key != null) {
      pkey = ((DomElement) element).get_attribute (attribute_primary_key);
      skey = ((DomElement) element).get_attribute (attribute_secondary_key);
      tkey = ((DomElement) element).get_attribute (attribute_third_key);
      if (pkey == null || skey == null || tkey == null) {
        pkey = ((DomElement) element).get_attribute (attribute_primary_key.down ());
        skey = ((DomElement) element).get_attribute (attribute_secondary_key.down ());
        tkey = ((DomElement) element).get_attribute (attribute_third_key.down ());
      }
    } else {
      if (items_type.is_a (typeof(MappeableElementThreeKey))) {
        if (!(element is MappeableElementThreeKey)) return false;
        pkey = ((MappeableElementThreeKey) element).get_map_pkey ();
        skey = ((MappeableElementThreeKey) element).get_map_skey ();
        tkey = ((MappeableElementThreeKey) element).get_map_tkey ();
      }
    }
    if (pkey == null || skey == null || tkey == null) return false;
    var ht = _hashtable.get (pkey);
    if (ht == null) ht = new Gee.HashMap<string,Gee.HashMap<string,int>> ();
    var hte = ht.get (skey);
    if (hte == null) hte = new Gee.HashMap<string,int> ();
    if (!_hashtable.has_key (pkey)) _hashtable.set (pkey, ht);
    if (!ht.has_key (skey)) ht.set (skey, hte);
    hte.set (tkey, index);
    return true;
  }
  public override void clear () {
    _hashtable = new Gee.HashMap<string,Gee.HashMap<string,Gee.HashMap<string,int>>> ();
  }

  public DomElement? item (string primary_key, string secondary_key, string third_key) {
    return get (primary_key, secondary_key, third_key);
  }
  public Set<string> primary_keys_set {
    owned get {
      var l = new HashSet<string> ();
      foreach (string k in _hashtable.keys) {
        l.add (k);
      }
      return l;
    }
  }
  public Set<string> secondary_keys_set (string pkey) {
    var l = new HashSet<string> ();
    if (!_hashtable.has_key (pkey)) return l;
    var ht = _hashtable.get (pkey);
    if (ht == null) return l;
    foreach (string k in ht.keys) {
      l.add (k);
    }
    return l;
  }
  public Set<string> third_keys_set (string pkey, string skey) {
    var l = new HashSet<string> ();
    if (!_hashtable.has_key (pkey)) return l;
    var ht = _hashtable.get (pkey);
    if (ht == null) return l;
    var hte = ht.get (skey);
    if (hte == null) return l;
    foreach (string k in hte.keys) {
      l.add (k);
    }
    return l;
  }
}
