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

using Gee;
/**
 * A DOM4 interface to keep references to {@link DomElement} in a {@link element}
 * child nodes. Only {@link GomObject} are supported.
 */
public interface GXml.GomCollection : Object
{
  /**
   * A list of child {@link DomElement} objects of {@link element}
   */
  public abstract GLib.Queue<int> nodes_index { get; }
  /**
   * A {@link GomElement} with all child elements in collection.
   */
  public abstract GomElement element { get; construct set; }
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   *
   * Used when reading to add elements to collection.
   */
  public abstract string items_name { get; }
  /**
   * A {@link GLib.Type} of {@link DomElement} child objects of {@link element},
   * which could be contained in this collection.
   *
   * Type should be an {@link GomObject}.
   */
  public abstract Type items_type { get; construct set; }
  /**
   * Search and add references to all {@link GomObject} nodes as child of
   * {@link element} with same, case insensitive, name of {@link items_name}
   */
  public abstract void search () throws GLib.Error;
  /**
   * Gets a child {@link DomElement} of {@link element} referenced in
   * {@link nodes_index}.
   */
  public virtual DomElement? get_item (int index) throws GLib.Error {
    if (nodes_index.length == 0)
      return null;
    if (index < 0 || index >= nodes_index.length)
      throw new DomError.INDEX_SIZE_ERROR
                  (_("Invalid index for elements in array list"));
    int i = nodes_index.peek_nth (index);
    if (i < 0 || i >= element.child_nodes.size)
      throw new DomError.INDEX_SIZE_ERROR
                  (_("Invalid index reference for child elements in array list"));
    var e = element.child_nodes.get (i);
    if (e != null)
      if (!(e is GomElement))
        throw new DomError.INVALID_NODE_TYPE_ERROR
              (_("Referenced object's type is invalid. Should be a GXmlGomElement"));
    return (DomElement?) e;
  }
  /**
   * Adds a {@link DomElement} node to this collection. Depending on type of
   * collection, this method will take information from node to initialize
   * how to find it.
   */
  public abstract void append (DomElement node) throws GLib.Error;
  /**
   * Number of items referenced in {@link nodes_index}
   */
  public virtual int length { get { return (int) nodes_index.get_length (); } }
  /**
   * Initialize collection to use a given {@link GomElement} derived type.
   * Internally, this method create an instance of given type to initialize
   * {@link items_type} and {@link items_name}.
   *
   * This method can be used at construction time of classes implementing
   * {@link GomCollection} to initialize object type to refer in collection.
   */
  public abstract void initialize (GLib.Type t) throws GLib.Error;
  /**
   * Creates a new instance of {@link items_type}, with same
   * {@link DomNode.owner_document} than {@link element}. New instance
   * is not set as a child of collection's {@link element}; to do so,
   * use {@link append}
   *
   * Returns: a new instance object or null if type is not a {@link GomElement} or no parent has been set
   */
  public virtual GomElement? create_item () {
    if (items_type.is_a (GLib.Type.INVALID)) return null;
    if (!items_type.is_a (typeof (GomElement))) return null;
    if (element == null) return null;
    return Object.new (items_type,
                      "owner_document", element.owner_document) as GomElement;
  }
  /**
   * Validate if given node and index, should be added to collection.
   *
   * Implementations should use this method to perform any action before
   * element is added to collection, like setup internal pointers to given
   * index, in order to get access to referenced node.
   *
   * Return: true if node and index should be added to collection.
   */
  public abstract bool validate_append (int index, DomElement element) throws GLib.Error;
}

/**
 * Base class for collections implemeting {@link GomCollection}, priving basic
 * infrastructure.
 *
 * Collections properties should be initialized with current container element
 * in order to be able to add new references to elements. Use {@link initialize_element}
 * to set parent element and {@link search} to find elements for collection.
 */
public abstract class GXml.BaseCollection : Object {
  /**
   * A collection of node's index refered. Don't modify it manually.
   */
  protected GLib.Queue<int> _nodes_index = new GLib.Queue<int> ();
  /**
   * Element used to refer of containier element. You should define it at construction time
   * our set it as a construction property.
   */
  protected GomElement _element;
  /**
   * Local name of {@link DomElement} objects of {@link element}, which could be
   * contained in this collection.
   *
   * Used when reading to add elements to collection. You can set it at construction time,
   * by, for example, instantaiting a object of the type {@link GomCollection.items_type}
   * then use {@link GomElement.local_name}'s value.
   */
  protected string _items_name = "";
  /**
   * Objects' type to be referenced by this collection and to deserialize objects.
   * Derived classes, can initilize this value at constructor or as construct property.
   *
   * Used when reading and at initialization time, to know {@link GomElement.local_name}
   * at runtime.
   */
  protected GLib.Type _items_type = GLib.Type.INVALID;
  /**
   * {@inheritDoc}
   */
  public string items_name { get { return _items_name; } }
  /**
   * {@inheritDoc}
   */
  public Type items_type {
    get { return _items_type; } construct set { _items_type = value; }
  }
  /**
   * {@inheritDoc}
   */
  public GLib.Queue<int> nodes_index { get { return _nodes_index; } }
  /**
   * {@inheritDoc}
   */
  public GomElement element {
    get { return _element; }
    construct set {
      if (value != null)
        _element = value;
    }
  }
  /**
   * {@inheritDoc}
   */
  public void initialize (GLib.Type items_type) throws GLib.Error {
    if (!items_type.is_a (typeof (GomElement))) {
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Invalid attempt to initialize a collection using an unsupported type. Only GXmlGomElement is supported"));
    }
    var o = Object.new (items_type) as GomElement;
    _items_name = o.local_name;
    _items_type = items_type;
  }
  /**
   * Initialize an {@link GomCollection} to use an element as children's parent.
   * Searchs for all nodes, calling {@link GomCollection.search}
   * with {@link GomCollection.items_type}, using its
   * {@link DomElement.local_name} to find it.
   *
   * Implemenation classes, should initialize collection to hold a {@link GomElement}
   * derived type using {@link GomCollection.initialize}.
   */
  public void initialize_element (GomElement e) throws GLib.Error {
    _element = e;
  }

  /**
   * Adds an {@link DomElement} of type {@link GomObject} as a child of
   * {@link element}.
   *
   * Object is always added as a child of {@link element}
   * but just added to collection if {@link validate_append} returns true;
   */
  public void append (DomElement node) throws GLib.Error {
    if (_element == null)
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Parent Element is invalid"));
    if (!(node is GomElement))
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Invalid attempt to set unsupported type. Only GXmlGomElement is supported"));
    if (node.owner_document != _element.owner_document)
      throw new DomError.HIERARCHY_REQUEST_ERROR
                (_("Invalid attempt to set a node with a different parent document"));
    _element.append_child (node);
    if (_element.child_nodes.size == 0)
      throw new DomError.QUOTA_EXCEEDED_ERROR
                (_("Node element not appended as child of parent. No node added to collection"));
    var index = _element.child_nodes.size - 1;
    if (!validate_append (index, node)) return;
    _nodes_index.push_tail (index);
  }
  /**
   * Search for all child nodes in {@link element} of type {@link GomElement}
   * with a {@link GomElement.local_name} equal to {@link GomCollection.items_name},
   * to add it to collection.
   *
   * Implementations could add additional restrictions to add element to collection.
   */
  public void search () throws GLib.Error {
    _nodes_index.clear ();
    if (_element == null)
      throw new DomError.INVALID_NODE_TYPE_ERROR
                (_("Parent Element is invalid"));
    for (int i = 0; i < _element.child_nodes.size; i++) {
      var n = _element.child_nodes.get (i);
      if (n is GomObject) {
        if ((n as DomElement).local_name.down () == items_name.down ()) {
          if (validate_append (i, n as DomElement))
            _nodes_index.push_tail (i);
        }
      }
    }
  }
  /**
   * {@inheritDoc}
   */
  public abstract bool validate_append (int index, DomElement element) throws GLib.Error;
}

/**
 * A class impementing {@link GomCollection} to store references to
 * child {@link DomElement} of {@link GomCollection.element}, using an index.
 *
 * {{{
 *   public class YourObject : GomElement {
 *    [Description (nick="::Name")]
 *    public string name { get; set; }
 *   }
 *   public class YourList : GomArrayList {
 *    construct {
 *      try { initialize (typeof (YourObject)); }
 *      catch (GLib.Error e) {
 *        warning ("Initialization error for collection type: %s : %s"
 *             .printf (get_type ().name(), e.message));
 *      }
 *    }
 *   }
 * }}}
 */
public class GXml.GomArrayList : GXml.BaseCollection, GomCollection {
  public override bool validate_append (int index, DomElement element) throws GLib.Error {
#if DEBUG
    GLib.message ("Adding node:"+element.node_name);
#endif
    return true;
  }
}

/**
 * Inteface to be implemented by {@link GomElement} derived classes
 * in order to provide a string to be used in {@link GomHashMap} as key.
 *
 * If {@link GomHashMap} has set its {@link GomHashMap.attribute_key}
 * its value has precedence over this method.
 */
public interface GXml.MappeableElement : Object, DomElement {
  public abstract string get_map_key ();
}

/**
 * A class impementing {@link GomCollection} to store references to
 * child {@link DomElement} of {@link GomCollection.element}, using an attribute in
 * items as key or {@link MappeableElement.get_map_key} method if implemented
 * by items to be added. If key is not defined in node, it is not added; but
 * keeps it as a child node of actual {@link GomCollection.element}.
 *
 * If {@link GomElement} to be added is of type {@link GomCollection.items_type}
 * and implements {@link MappeableElement}, you should set {@link GomHashMap.attribute_key}
 * to null in order to use returned value of {@link MappeableElement.get_map_key}
 * as key.
 *
 * {{{
 *   public class YourObject : GomElement {
 *    [Description (nick="::Name")]
 *    public string name { get; set; }
 *   }
 *   public class YourList : GomHashMap {
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
public class GXml.GomHashMap : GXml.BaseCollection, GXml.GomCollection {
  /**
   * A hashtable with all keys as string to node's index refered. Don't modify it manually.
   */
  protected HashTable<string,int> _hashtable = new HashTable<string,int> (str_hash,str_equal);
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
   * Convenient function to initialize a {@link GomHashMap} collection, using
   * given element, items' type and name.
   */
  public void initialize_element_with_key (GomElement element,
                                  GLib.Type items_type,
                                  string attribute_key) throws GLib.Error
  {
    initialize (items_type);
    initialize_element (element);
    _attribute_key = attribute_key;
  }

  /**
   * Convenient function to initialize a {@link GomHashMap} collection, using
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
    if (!_hashtable.contains (key)) return null;
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
    if (_hashtable.contains (key)) return true;
    return false;
  }
  /**
   * Returns list of keys used in collection.
   */
  public GLib.List<string> get_keys () {
    return _hashtable.get_keys ();
  }
  /**
   * Validates if given element has a {@link GomHashMap.attribute_key} set,
   * if so adds a new key pointing to given index and returns true.
   *
   * Attribute should be a valid {@link DomElement} attribute or
   * a {@link GomObject} property identified using a nick with a '::' prefix.
   *
   * If there are more elements with same key, they are kept as child nodes
   * but the one in collection will be the last one to be found.
   *
   * Return: false if element should not be added to collection.
   */
  public override bool validate_append (int index, DomElement element) throws GLib.Error {
    if (!(element is GomElement)) return false;
#if DEBUG
    message ("Validating HashMap Element..."
            +(element as GomElement).write_string ()
            +" Attrs:"+(element as GomElement).attributes.length.to_string());
#endif
    string key = null;
    if (attribute_key != null) {
      key = (element as DomElement).get_attribute (attribute_key);
      if (key == null)
      key = (element as DomElement).get_attribute (attribute_key.down ());
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
    _hashtable.insert (key, index);
    return true;
  }
}


/**
 * Inteface to be implemented by {@link GomElement} derived classes
 * in order to provide a strings to be used in {@link GomHashPairedMap} as keys.
 */
public interface GXml.MappeableElementPairKey : Object, DomElement {
  public abstract string get_map_primary_key ();
  public abstract string get_map_secondary_key ();
}

/**
 * A class impementing {@link GomCollection} to store references to
 * child {@link DomElement} of {@link GomCollection.element}, using two attributes in
 * items as primary and secondary keys or {@link MappeableElementPairKey.get_map_primary_key}
 * and {@link MappeableElementPairKey.get_map_secondary_key} methods if
 * {@link MappeableElementPairKey} are implemented
 * by items to be added. If one or both keys are not defined in node,
 * it is not added; but keeps it as a child node of actual
 * {@link GomCollection.element}.
 *
 * If {@link GomElement} to be added is of type {@link GomCollection.items_type}
 * and implements {@link MappeableElementPairKey}, you should set
 * {@link attribute_primary_key} and {@link attribute_secondary_key}
 * to null in order to use returned value of {@link MappeableElementPairKey.get_map_primary_key}
 * and {@link MappeableElementPairKey.get_map_secondary_key}
 * as keys.
 *
 * {{{
 *   public class YourObject : GomElement, MappeableElementPairKey {
 *    [Description (nick="::Name")]
 *    public string name { get; set; }
 *    public string code { get; set; }
 *    public string get_map_primary_key () { return code; }
 *    public string get_map_secondary_key () { return name; }
 *   }
 *   public class YourList : GomHashPairedMap {
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
public class GXml.GomHashPairedMap : GXml.BaseCollection, GXml.GomCollection {
  /**
   * A hashtable with all keys as string to node's index refered. Don't modify it manually.
   */
  protected Gee.HashMap<string,HashMap<string,int>> _hashtable = new HashMap<string,HashMap<string,int>> ();
  /**
   * Element's attribute name used to refer of container's element as primery key.
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
   * Convenient function to initialize a {@link GomHashMap} collection, using
   * given element, items' type and name.
   */
  public void initialize_element_with_keys (GomElement element,
                                  GLib.Type items_type,
                                  string attribute_primary_key,
                                  string attribute_secondary_key) throws GLib.Error
  {
    initialize (items_type);
    initialize_element (element);
    _attribute_primary_key = attribute_primary_key;
    _attribute_secondary_key = attribute_secondary_key;
  }

  /**
   * Convenient function to initialize a {@link GomHashMap} collection, using
   * given element, items' type and name.
   *
   * Using this method at construction time of derived classes.
   */
  public void initialize_with_keys (GLib.Type items_type,
                                  string attribute_primary_key,
                                  string attribute_secondary_key) throws GLib.Error
  {
    initialize (items_type);
    _attribute_primary_key = attribute_primary_key;
    _attribute_secondary_key = attribute_secondary_key;
  }
  /**
   * Returns an {@link DomElement} in the collection using given string keys.
   */
  public new DomElement? get (string primary_key, string secondary_key) {
    if (!_hashtable.contains (primary_key)) return null;
    var ht = _hashtable.get (primary_key);
    if (ht == null) return null;
    if (!ht.contains (secondary_key)) return null;
    var i = ht.get (secondary_key);
    return _element.child_nodes.get (i) as DomElement;
  }
  /**
   * Returns true if @key is used in collection as primery key.
   */
  public bool has_primary_key (string key) {
    if (_hashtable.contains (key)) return true;
    return false;
  }
  /**
   * Returns true if @key is used in collection as secondary key
   * with @pkey as primary.
   */
  public bool has_secondary_key (string pkey, string key) {
    if (!(_hashtable.contains (pkey))) return false;
    var ht = _hashtable.get (pkey);
    if (ht == null) return false;
    if (ht.contains (key)) return true;
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
   * Returns list of secondary keys used in collection with @pkey as primary key.
   */
  public GLib.List<string> get_secondary_keys (string pkey) {
    var l = new GLib.List<string> ();
    var ht = _hashtable.get (pkey);
    if (ht == null) return l;
    foreach (string k in ht.keys) {
      l.append (k);
    }
    return l;
  }
  /**
   * Validates if given element has a {@link attribute_primary_key}
   * and {@link attribute_secondary_key} set,
   * if so adds a new keys pointing to given index and returns true.
   *
   * Attribute should be a valid {@link DomElement} attribute or
   * a {@link GomObject} property identified using a nick with a '::' prefix.
   *
   * If there are more elements with same keys, they are kept as child nodes
   * but the one in collection will be the last one to be found.
   *
   * Return: false if element should not be added to collection.
   */
  public override bool validate_append (int index, DomElement element) throws GLib.Error {
    if (!(element is GomElement)) return false;
#if DEBUG
    message ("Validating HashMap Element..."
            +(element as GomElement).write_string ()
            +" Attrs:"+(element as GomElement).attributes.length.to_string());
#endif
    string pkey = null;
    string skey = null;
    if (attribute_primary_key != null && attribute_secondary_key != null) {
      pkey = (element as DomElement).get_attribute (attribute_primary_key);
      skey = (element as DomElement).get_attribute (attribute_secondary_key);
      if (pkey == null || skey == null) {
        pkey = (element as DomElement).get_attribute (attribute_primary_key.down ());
        skey = (element as DomElement).get_attribute (attribute_secondary_key.down ());
      }
    } else {
      if (items_type.is_a (typeof(MappeableElementPairKey))) {
        if (!(element is MappeableElementPairKey)) return false;
        pkey = ((MappeableElementPairKey) element).get_map_primary_key ();
        skey = ((MappeableElementPairKey) element).get_map_secondary_key ();
      }
    }
    if (pkey == null || skey == null)
      throw new DomError.NOT_FOUND_ERROR (_("No primary key and/or secondary key was found"));
    var ht = _hashtable.get (pkey);
    if (ht == null) {
      ht = new HashMap<string,int> ();
      _hashtable.set (pkey, ht);
    }
    ht.set (skey, index);
    return true;
  }
}


/**
 * Inteface to beimplemented by {@link GomElement} derived classes
 * in order to provide a string to be used in {@link GomHashThreeMap} as key.
 *
 * If {@link GomHashMap} has set its {@link GomHashMap.attribute_key}
 * its value has precedence over this method.
 */
public interface GXml.MappeableElementThreeKey : Object, DomElement {
  /**
   * Returns primary key of collection.
   */
  public abstract string get_map_pkey ();
  /**
   * Returns secundary key of collection.
   */
  public abstract string get_map_skey ();
  /**
   * Returns third key of collection.
   */
  public abstract string get_map_tkey ();
}

/**
 * A class impementing {@link GomCollection} to store references to
 * child {@link DomElement} of {@link GomCollection.element}, using three attributes in
 * items as primary, secondary tertiary keys or {@link MappeableElementThreeKey.get_map_pkey},
 * {@link MappeableElementThreeKey.get_map_skey}
 * and {@link MappeableElementThreeKey.get_map_tkey}
 * methods if {@link MappeableElementThreeKey} are implemented
 * by items to be added. All keys should be defined in node, otherwise
 * it is not added; but keeps it as a child node of actual
 * {@link GomCollection.element}.
 *
 * If {@link GomElement} to be added is of type {@link GomCollection.items_type}
 * and implements {@link MappeableElementThreeKey}, you should set
 * {@link attribute_primary_key}, {@link attribute_secondary_key}
 * and  {@link attribute_third_key}
 * to null in order to use returned value of {@link MappeableElementThreeKey.get_map_pkey},
 * {@link MappeableElementThreeKey.get_map_skey}
 * and {@link MappeableElementThreeKey.get_map_tkey}
 * as keys.
 *
 * {{{
 *   public class YourObject : GomElement, MappeableElementThirdKey {
 *    [Description (nick="::Name")]
 *    public string name { get; set; }
 *    public string code { get; set; }
 *    public string category { get; set; }
 *    public string get_map_primary_key () { return code; }
 *    public string get_map_secondary_key () { return name; }
 *    public string get_map_third_key () { return category; }
 *   }
 *   public class YourList : GomHashPairedMap {
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
public class GXml.GomHashThreeMap : GXml.BaseCollection, GXml.GomCollection {
  /**
   * A hashtable with all keys as string to node's index refered. Don't modify it manually.
   */
  protected HashMap<string,HashMap<string,HashMap<string,int>>> _hashtable = new HashMap<string,HashMap<string,HashMap<string,int>>> ();
  /**
   * Element's attribute name used to refer of container's element as primery key.
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
   * Convenient function to initialize a {@link GomHashMap} collection, using
   * given element, items' type and name.
   */
  public void initialize_element_with_keys (GomElement element,
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
   * Convenient function to initialize a {@link GomHashMap} collection, using
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
    if (!_hashtable.contains (primary_key)) return null;
    var ht = _hashtable.get (primary_key);
    if (ht == null) return null;
    if (!ht.contains (secondary_key)) return null;
    var hte = ht.get (secondary_key);
    if (hte == null) return null;
    if (!hte.contains (third_key)) return null;
    var i = hte.get (secondary_key);
    return _element.child_nodes.get (i) as DomElement;
  }
  /**
   * Returns true if @key is used in collection as primery key.
   */
  public bool has_primary_key (string key) {
    if (_hashtable.contains (key)) return true;
    return false;
  }
  /**
   * Returns true if @key is used in collection as secondary key
   * with @pkey as primary.
   */
  public bool has_secondary_key (string pkey, string key) {
    if (!(_hashtable.contains (pkey))) return false;
    var ht = _hashtable.get (pkey);
    if (ht == null) return false;
    if (ht.contains (key)) return true;
    return false;
  }
  /**
   * Returns true if @key is used in collection as third key with secondary key
   * and pkey as primary.
   */
  public bool has_third_key (string pkey, string skey, string key) {
    if (!(_hashtable.contains (pkey))) return false;
    var ht = _hashtable.get (pkey);
    if (ht == null) return false;
    var hte = ht.get (skey);
    if (hte == null) return false;
    if (hte.contains (key)) return true;
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
    if (!_hashtable.contains (pkey)) return l;
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
    if (!_hashtable.contains (pkey)) return l;
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
   * a {@link GomObject} property identified using a nick with a '::' prefix.
   *
   * If there are more elements with same keys, they are kept as child nodes
   * but the one in collection will be the last one to be found.
   *
   * Return: false if element should not be added to collection.
   */
  public override bool validate_append (int index, DomElement element) throws GLib.Error {
    if (!(element is GomElement)) return false;
    string pkey = null;
    string skey = null;
    string tkey = null;
    if (attribute_primary_key != null && attribute_secondary_key != null
        && attribute_third_key != null) {
      pkey = (element as DomElement).get_attribute (attribute_primary_key);
      skey = (element as DomElement).get_attribute (attribute_secondary_key);
      tkey = (element as DomElement).get_attribute (attribute_third_key);
      if (pkey == null || skey == null || tkey == null) {
        pkey = (element as DomElement).get_attribute (attribute_primary_key.down ());
        skey = (element as DomElement).get_attribute (attribute_secondary_key.down ());
        tkey = (element as DomElement).get_attribute (attribute_third_key.down ());
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
    if (ht == null) ht = new HashMap<string,HashMap<string,int>> ();
    var hte = ht.get (skey);
    if (hte == null) hte = new HashMap<string,int> ();
    if (!_hashtable.contains (pkey)) _hashtable.set (pkey, ht);
    if (!ht.contains (skey)) ht.set (skey, hte);
    hte.set (tkey, index);
    return true;
  }
}
