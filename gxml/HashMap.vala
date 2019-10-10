/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * GXml.HashMap.vala
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
 * child {@link DomElement} of {@link Collection.element}, using an attribute in
 * items as key or {@link MappeableElement.get_map_key} method if implemented
 * by items to be added. If key is not defined in node, it is not added; but
 * keeps it as a child node of actual {@link Collection.element}.
 *
 * If {@link GXml.Element} to be added is of type {@link Collection.items_type}
 * and implements {@link MappeableElement}, you should set {@link GXml.HashMap.attribute_key}
 * to null in order to use returned value of {@link MappeableElement.get_map_key}
 * as key.
 *
 * {{{
 *   public class YourObject : GXml.Element {
 *    [Description (nick="::Name")]
 *    public string name { get; set; }
 *   }
 *   public class YourList : GXml.HashMap {
 *    construct {
 *      try { initialize_with_key (typeof (YourObject),"Name"); }
 *      catch (GLib.Error e) {
 *        warning ("Initialization error for collection type: %s : %s"
 *             .printf (get_type ().name(), e.message));
 *      }
 *    }
 *   }
 * }}}
 */
public class GXml.HashMap : GXml.BaseCollection, GXml.Map {
  /**
   * A hashtable with all keys as string to node's index referred. Don't modify it manually.
   */
  protected Gee.HashMap<string,int> _hashtable = new Gee.HashMap<string,int> ();
  /**
   * Element's attribute name used to refer of container's element.
   * You should define it at construction time
   * our set it as a construction property.
   */
  protected string _attribute_key;
  /**
   * An attribute's name in items to be added and used to retrieve elements
   * as key.
   */
  public string attribute_key {
    get { return _attribute_key; } construct set { _attribute_key = value; }
  }
  /**
   * Convenient function to initialize a {@link GXml.HashMap} collection, using
   * given element, items' type and name.
   */
  public void initialize_element_with_key (GXml.Element element,
                                  GLib.Type items_type,
                                  string attribute_key) throws GLib.Error
  {
    initialize (items_type);
    initialize_element (element);
    _attribute_key = attribute_key;
  }

  /**
   * Convenient function to initialize a {@link GXml.HashMap} collection, using
   * given element, items' type and name.
   *
   * Using this method at construction time of derived classes.
   */
  public void initialize_with_key (GLib.Type items_type,
                                  string attribute_key) throws GLib.Error
  {
    initialize (items_type);
    _attribute_key = attribute_key;
  }
  /**
   * Returns an {@link DomElement} in the collection using a string key.
   */
  public new DomElement? get (string key) {
    if (!_hashtable.has_key (key)) return null;
    var i = _hashtable.get (key);
#if DEBUG
    GLib.message ("Key:"+key+" item:"+i.to_string ());
#endif
    return _element.child_nodes.get (i) as DomElement;
  }
  /**
   * Returns true if @key is used in collection.
   */
  public bool has_key (string key) {
    if (_hashtable.has_key (key)) return true;
    return false;
  }
  /**
   * Returns list of keys used in collection.
   */
  public GLib.List<string> get_keys () {
    var l = new GLib.List<string> ();
    foreach (string k in _hashtable.keys) { l.append (k); }
    return l;
  }
  /**
   * Validates if given element has a {@link GXml.HashMap.attribute_key} set,
   * if so adds a new key pointing to given index and returns true.
   *
   * Attribute should be a valid {@link DomElement} attribute or
   * a {@link GXml.Object} property identified using a nick with a '::' prefix.
   *
   * If there are more elements with same key, they are kept as child nodes
   * but the one in collection will be the last one to be found.
   *
   * Return: false if element should not be added to collection.
   */
  public override bool validate_append (int index, DomElement element) throws GLib.Error {
    if (!(element is GXml.Element)) return false;
#if DEBUG
    message ("Validating HashMap Element..."
            +(element as GXml.Element).write_string ()
            +" Attrs:"+(element as GXml.Element).attributes.length.to_string());
#endif
    string key = null;
    if (attribute_key != null) {
      key = ((DomElement) element).get_attribute (attribute_key);
      if (key == null)
      key = ((DomElement) element).get_attribute (attribute_key.down ());
    } else {
      if (items_type.is_a (typeof(MappeableElement))) {
        if (!(element is MappeableElement)) return false;
        key = ((MappeableElement) element).get_map_key ();
      }
    }
    if (key == null) return false;
#if DEBUG
    message ("Attribute key value: "+key);
#endif
    _hashtable.set (key, index);
    return true;
  }
  public override void clear () {
    _hashtable = new Gee.HashMap<string,int> ();
  }
  public DomElement? item (string key) { return get (key); }
  public Gee.Set<string> keys_set {
    owned get {
      var l = new HashSet<string> ();
      foreach (string k in _hashtable.keys) { l.add (k); }
      return l;
    }
  }
}

