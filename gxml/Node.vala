/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
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
 * Base interface providing basic functionalities to all GXml interfaces.
 */
public interface GXml.Node : Object
{
  /**
   * Collection of Namespaces applied to this {@link GXml.Node}.
   */
  public abstract Gee.List<GXml.Namespace> namespaces { owned get; }
  /**
   * Collection of {@link GXml.Node} as childs.
   *
   * Depend on {@link GXml.Node} type, this childs could of different, like,
   * elements, element's contents or properties.
   */
  [Deprecated (since="0.10.0", replace="children")]
  public virtual Gee.BidirList<GXml.Node> childs { owned get { return children; } }
  /**
   * Collection of {@link GXml.Node} as childs.
   *
   * Depend on {@link GXml.Node} type, this childs could of different, like,
   * elements, element's contents or properties.
   */
  public abstract Gee.BidirList<GXml.Node> children { owned get; }
  /**
   * Attributes in this {@link GXml.Node}.
   */
  public abstract Gee.Map<string,GXml.Node> attrs { owned get; }
  /**
   * Node's name. The meaning differs, depending on node's type.
   */
  public abstract string name { owned get; }
  /**
   * Node's value. The meaning differs, depending on node's type.
   */
  public abstract string @value { owned get; set; }
  /**
   * Node's type as a enumeration.
   */
  public abstract GXml.NodeType type_node { get; }
  /**
   * Node's XML document holding this node.
   */
  public abstract GXml.Document document { get; }
  /**
   * Node's XML document holding this node.
   */
  public abstract GXml.Node parent { owned get; }
  /**
   * Get first child with given name, or null. 
   */
  public new virtual GXml.Node? get (string key) {
    foreach (var child in children)
      if (child.name == key)
        return child;
    return null;
  }
  /**
   * Search all child {@link GXml.Element} with a given property's name and with
   * value contained in text.
   */
  public virtual GXml.ElementList
   get_elements_by_property_value (string property, string value)
  {
    var list = new GXml.ElementList ();
    if (!(this is GXml.Element)) return list;
    foreach (var child in children) {
      if (child is GXml.Element) {
        list.add_all (child.get_elements_by_property_value (property, value));
        if (child.attrs == null) continue;
        var cls = child.attrs.get (property);
        if (cls == null) {
          continue;
        }
        if (value in cls.value)
            list.add ((GXml.Element) child);
      }
    }
    return list;
  }
  /**
   * Node's string representation.
   */
  public abstract string to_string ();
  /**
   * Set a namespace to this node.
   *
   * Search for existing document's namespaces and applies it if found or creates
   * a new one, appending to document's namespaces collection.
   */
  public abstract bool set_namespace (string uri, string? prefix);
  /**
   * Node's defaults namespace's prefix.
   *
   * This allways returns first {@link GXml.Namespace}'s prefix in {@link GXml.Node}'s
    * namespaces collection.
   */
  public virtual string ns_prefix () { return namespaces.first ().prefix; }
  /**
   * Node's defaults namespace's URI.
   *
   * This allways returns first {@link GXml.Namespace}'s URI in {@link GXml.Node}'s
   * namespaces collection.
   */
  public virtual string ns_uri () { return namespaces.first ().uri; }
  /**
   * Copy a {@link GXml.Node} relaing on {@link GXml.Document} to other {@link GXml.Node}.
   *
   * node could belongs from different {@link GXml.Document}, while source is a node
   * belonging to given document.
   *
   * Just {@link GXml.Element} objects are supported. For attributes, use
   * {@link GXml.Element.set_attr} method, passing source's name and value as arguments.
   *
   * @param doc a {@link GXml.Document} owning destiny node
   * @param node a {@link GXml.Element} to copy nodes to
   * @param source a {@link GXml.Element} to copy nodes from, it could be holded by different {@link GXml.Document}
   */
  public static bool copy (GXml.Document doc, GXml.Node node, GXml.Node source, bool deep)
  {
#if DEBUG
    GLib.message ("Copying GXml.Node");
#endif
    if (node is GXml.Document) return false;
    if (source is GXml.Element && node is GXml.Element) {
#if DEBUG
    GLib.message ("Copying source and destiny nodes are GXml.Elements... copying...");
    GLib.message ("Copying source's attributes to destiny node");
#endif
      foreach (GXml.Node p in source.attrs.values) {
        ((GXml.Element) node).set_attr (p.name, p.value); // TODO: Namespace
      }
#if DEBUG
      GLib.message ("Copying source's child nodes to destiny node");
#endif
      foreach (Node c in source.children) {
        if (c is Element) {
          if (c.name == null) continue;
#if DEBUG
            GLib.message (@"Copying child Element node: $(c.name)");
#endif
          if (!deep){
#if DEBUG
            GLib.message (@"No deep copy was requested, skeeping node $(c.name)");
#endif
            continue;
          }
          try {
            var e = doc.create_element (c.name); // TODO: Namespace
            node.childs.add (e);
            copy (doc, e, c, deep);
          } catch {}
        }
        if (c is Text) {
          if (c.value == null) {
            GLib.warning (_("Text node with NULL string"));
            continue;
          }
          var t = doc.create_text (c.value);
          node.children.add (t);
#if DEBUG
          GLib.message (@"Copying source's Text node '$(source.name)' to destiny node with text: $(c.value) : Size= $(node.childs.size)");
          GLib.message (@"Added Text: $(node.childs.get (node.childs.size - 1))");
#endif
        }
      }
    }
    return false;
  }
}

/**
 * Convenient class for a list of {@link GXml.Node} objects based on
 * {@link Gee.ListArray}, with good support for bindings.
 */
public class GXml.NodeList : Gee.ArrayList<GXml.Node> {
  public new GXml.Node get (int index) { return base.get (index); }
  public new GXml.Node[] to_array () {
    return (GXml.Node[])  ((Gee.Collection<GXml.Node>) this).to_array ();
  }
}

