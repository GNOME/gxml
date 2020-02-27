/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* Parser.vala
 *
 * Copyright (C) 2016-2019  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
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
 * Parser Error codes for {@link DomNode} parsing objects
 */
public errordomain GXml.ParserError {
  INVALID_DATA_ERROR,
  INVALID_FILE_ERROR,
  INVALID_STREAM_ERROR
}

/**
 * XML parser engine for {@link DomDocument} implementations.
 */
public interface GXml.Parser : GLib.Object {
  /**
   * Controls if, when writing to a file, a backup should
   * be created.
   */
  public abstract bool backup { get; set; }
  /**
   * Controls if, when writing, indentation should be used.
   */
  public abstract bool indent { get; set; }
  /**
   * Controls if, when writing, indentation should be used.
   */
  public abstract Cancellable? cancellable { get; set; }
  /**
   * A {@link GXml.DomDocument} to read to or write from
   */
  public abstract DomNode node { get; }
  /**
   * A collection of child types of found {@link GXml.CollectionParent}
   * objects, used to instantiate the correct class based on the
   * node's name.
   *
   * The map use the {@link GLib.Type} of the object implementing
   * {@link GXml.CollectionParent} as the key, to get a {@link GLib.HashTable}
   * holding a set of instantiable child classes, with the key as the
   * lowercase of the node's local name to get the {@link GLib.Type}
   * of the instantiable class to create and add to the collection.
   */
  public abstract GLib.HashTable<GLib.Type,GLib.HashTable<string,GLib.Type>> types { get; }
  /**
   * Writes a {@link GXml.DomDocument} to a {@link GLib.File}
   */
  public virtual void write_file (GLib.File file) throws GLib.Error {
    var ostream = file.replace (null, backup,
                            GLib.FileCreateFlags.NONE, cancellable);
    write_stream (ostream);
  }
  /**
   * Writes a {@link GXml.DomDocument} to a {@link GLib.File}
   */
  public virtual async void write_file_async (GLib.File file) throws GLib.Error {
    var ostream = yield file.replace_async (null, backup,
                            GLib.FileCreateFlags.NONE, 0, cancellable);
    yield write_stream_async (ostream);
  }
  /**
   * Writes a {@link node} to a string
   */
  public abstract string write_string () throws GLib.Error;
  /**
   * Writes asynchronically {@link node} to a string
   */
  public abstract async string write_string_async () throws GLib.Error;
  /**
   * Writes a {@link GXml.DomDocument} to a {@link GLib.OutputStream}
   */
  public abstract void write_stream (OutputStream stream) throws GLib.Error;
  /**
   * Writes asynchronically a {@link node} to a {@link GLib.OutputStream}
   */
  public abstract async void write_stream_async (OutputStream stream) throws GLib.Error;
  /**
   * Reads a {@link node} from a {@link GLib.File}
   */
  public virtual void read_file (GLib.File file)
                                throws GLib.Error {
    if (!file.query_exists ())
      throw new GXml.ParserError.INVALID_FILE_ERROR (_("File doesn't exist"));
    read_stream (file.read ());
  }
  /**
   * Reads a {@link GXml.DomDocument} from a {@link GLib.File}
   */
  public async virtual void read_file_async (GLib.File file) throws GLib.Error {
    if (!file.query_exists ())
      throw new GXml.ParserError.INVALID_FILE_ERROR (_("File doesn't exist"));
    Idle.add (read_file_async.callback);
    yield;
    yield read_stream_async (file.read ());
  }

  /**
   * Read a {@link GXml.DomDocument} from a {@link GLib.InputStream}
   */
  public abstract void read_stream (InputStream stream) throws GLib.Error;

  /**
   * Read a {@link GXml.DomDocument} from a {@link GLib.InputStream}
   */
  public abstract async abstract void read_stream_async (InputStream stream) throws GLib.Error;
  /**
   * Reads a {@link node} from a string
   */
  public abstract void read_string (string str) throws GLib.Error;

  /**
   * Reads synchronically {@link node} a from a string
   */
  public abstract async void read_string_async (string str) throws GLib.Error;
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML
   */
  public abstract InputStream create_stream () throws GLib.Error;
  /**
   * Creates asyncronically an {@link GLib.InputStream} to write a string representation
   * in XML
   */
  public abstract async InputStream create_stream_async () throws GLib.Error;
  /**
   * Iterates in all child nodes and append them to node.
   */
  public virtual void read_child_nodes (DomNode parent) throws GLib.Error {
    bool cont = true;
    while (cont) {
      if (parent is DomDocument) {
        cont = read_child_node (parent);
      }
      if (!move_next_node ()) return;
      if (current_is_element ())
        cont = read_child_element (parent);
      else
        cont = read_child_node (parent);
    }
  }
  /**
   * Iterates in all child nodes and append them to node.
   */
  public async virtual void read_child_nodes_async (DomNode parent) throws GLib.Error {
    bool cont = true;
    while (cont) {
      Idle.add (read_child_nodes_async.callback);
      yield;
      if (!move_next_node ()) return;
      if (current_is_element ())
        cont = read_child_element (parent);
      else
        cont = read_child_node (parent);
    }
  }
  /**
   * Creates a new {@link DomNode} and append it to
   * parent: depending on current node's type found by parser.
   *
   * If current found node is a {@link DomElement}, it is not parsed.
   * If you want to parse it use {@link read_element} method.
   *
   * Returns: true if node has been created and appended to parent.
   */
  public abstract bool read_child_node (DomNode parent) throws GLib.Error;
  /**
   * Reads current found element
   */
  public virtual bool read_child_element (DomNode parent) throws GLib.Error {
    if (!current_is_element ())
      throw new DomError.INVALID_NODE_TYPE_ERROR
        (_("Invalid attempt to parse an element node, when current found node is not"));
    bool isempty = current_is_empty_element ();
    DomNode n = null;
    if (!read_element_property (parent, out n))
      if (!add_element_collection (parent, out n)) {
        n = create_element (parent);
        read_element (n as DomElement);
    }
    if (n == null) return false;
    if (!isempty)
      read_child_nodes (n);
    return true;
  }
  /**
   * Creates a new {@link DomElement} and append it as a child of parent: for current
   * read node, only if parent: have a property as {@link DomElement} type and current
   * node have same local name as property element.
   *
   * Returns: true if element is set to a new object and it is set as a child of parent:
   * as a property.
   */
  public virtual bool read_element_property (DomNode parent,
                                    out DomNode element) throws GLib.Error {
    element = null;
    if (!(parent is GXml.Object)) return false;
    foreach (ParamSpec pspec in
              ((GXml.Object) parent).get_property_element_list ()) {
      if (pspec.value_type.is_a (typeof (Collection))) continue;
      //if (!pspec.value_type.is_instantiatable ()) continue;
      var obj = GLib.Object.new (pspec.value_type,
                            "owner-document", node.owner_document) as DomElement;
      if (obj.local_name.down ()
             == current_node_name ().down ()) {
        Value v = Value (pspec.value_type);
        parent.append_child (obj as DomNode);
        v.set_object (obj);
        parent.set_property (pspec.name, v);
        read_element (obj as DomElement);
        element = obj as DomNode;
        return true;
      }
    }
    return false;
  }
  /**
   * Creates a new {@link DomElement} and append it as a child of parent: for current
   * read node, only if parent: have a property as {@link Collection} type and current
   * node have same local name as collection {@link Collection.items_name}
   *
   * Returns: true if element is set to a new object, it is set as a child of parent:
   * and has been added to a parent:'s collection property.
   */
  public virtual bool add_element_collection (DomNode parent,
                  out DomNode element) throws GLib.Error {
    element = null;
    if (!(parent is GXml.Object)) return false;
    foreach (ParamSpec pspec in
              ((GXml.Object) parent).get_property_element_list ()) {
      if (!(pspec.value_type.is_a (typeof (Collection)))) continue;
      Collection col;
      Value vc = Value (pspec.value_type);
      parent.get_property (pspec.name, ref vc);
      col = vc.get_object () as Collection;
      if (col == null) {
        col = GLib.Object.new (pspec.value_type,
                          "element", parent) as Collection;
        vc.set_object (col);
        parent.set_property (pspec.name, vc);
      }
      if (col.items_type == GLib.Type.INVALID
          || !(col.items_type.is_a (typeof (GXml.Object)))) {
        throw new DomError.INVALID_NODE_TYPE_ERROR
                    (_("Collection '%s' hasn't been constructed properly: items' type property was not set at construction time or set to invalid type"), col.get_type ().name ());
      }
      GLib.Type obj_type = GLib.Type.INVALID;
      if (col is CollectionParent) {
        HashTable<string,GLib.Type> obj_types = null;
        if (!types.contains (col.get_type ())) {
          obj_types = ((CollectionParent) col).types;
          types.insert (col.get_type (), obj_types);
        } else {
          obj_types = types.lookup (col.get_type ());
        }
        if (obj_types != null) {
          string n = current_node_name ().down ();
          if (obj_types.contains (n)) {
            obj_type = obj_types.lookup (n);
          }
        }
      } else {
        if (col.items_name == "" || col.items_name == null) {
          throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Collection '%s' hasn't been constructed properly: items' name property was not set at construction time"), col.get_type ().name ());
        }
        if (col.element == null || !(col.element is GXml.Object)) {
          throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Collection '%s' hasn't been constructed properly: element property was not set at construction time"), col.get_type ().name ());
        }
        if (!(col.element is GXml.Object)) {
          throw new DomError.INVALID_NODE_TYPE_ERROR
                      (_("Invalid object of type '%s' doesn't implement GXml.Object interface: can't be handled by the collection"), col.element.get_type ().name ());
        }
        if (col.items_name.down () == current_node_name ().down ()) {
          if (parent.owner_document == null)
            throw new DomError.HIERARCHY_REQUEST_ERROR
                        (_("No document is set to node"));
            obj_type = col.items_type;
        }
      }
      if (obj_type != GLib.Type.INVALID) {
        var obj = GLib.Object.new (obj_type,
                              "owner-document", node.owner_document) as DomElement;
        parent.append_child (obj);
        read_element (obj as DomElement);
        col.append (obj);
        element = obj;
        return true;
      }
    }
    return false;
  }
  /**
   * Read all children node feed by stream.
   */
  public abstract void read_child_nodes_stream (GLib.InputStream istream) throws GLib.Error;
  /**
   * Read children nodes from string
   */
  public virtual void read_child_nodes_string (string str) throws GLib.Error {
    if (str == "")
      throw new ParserError.INVALID_DATA_ERROR (_("Invalid document string, it is empty or is not allowed"));
    var stream = new GLib.MemoryInputStream.from_data (str.data);
    read_child_nodes_stream (stream);
  }
  /**
   * Reads all child nodes as string
   */
  public abstract string read_unparsed () throws GLib.Error;
  /**
   * Use parser to go to next parsed node.
   */
  public abstract bool move_next_node () throws GLib.Error;
  /**
   * Check if current node has children.
   */
  public abstract bool current_is_empty_element ();
  /**
   * Check if current node found by parser, is a {@link DomElement}
   */
  public abstract bool current_is_element ();
  /**
   * Check if current node found by parser, is a {@link DomDocument}
   */
  public abstract bool current_is_document();
  /**
   * Returns current node's local name, found by parser.
   */
  public abstract string current_node_name ();
  /**
   * Creates a new {@link DomElement} and append it as a child of parent.
   */
  public abstract DomElement? create_element (DomNode parent) throws GLib.Error;
  /**
   * Reads an element's attributes, setting its values and taking care about their
   * namespaces.
   */
  public abstract void read_element (DomElement element) throws GLib.Error;
}
