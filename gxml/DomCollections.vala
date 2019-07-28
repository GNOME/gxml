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


public interface GXml.DomNonElementParentNode : GLib.Object {
  public abstract DomElement? get_element_by_id (string element_id) throws GLib.Error;
}

public interface GXml.DomParentNode : GLib.Object {
  public abstract DomHTMLCollection children { owned get; }
  public abstract DomElement? first_element_child { owned get; }
  public abstract DomElement? last_element_child { owned get; }
  public abstract int child_element_count { get; }

  /**
   * Select first matched {@link GXml.DomElement} if exists.
   * @param selectors valid CSS Level 3 selectors.
   * @return first matched {@link GXml.DomElement}, or null if nodes aren't found.
   */
  public virtual DomElement? query_selector (string selectors) throws GLib.Error {
    var list = query_selector_all (selectors);
    if (list.size == 0)
      return null;
    return list.item (0) as DomElement;
  }
  /**
   * Select all {@link GXml.DomElement} child and descendents that match CSS Level 3 selectors.
   * @param selectors valid CSS Level 3 selectors.
   * @return a {@link GXml.DomNodeList} with all matched nodes, or throw an Error if selectors are invalid. 
   */
  public abstract DomNodeList query_selector_all (string selectors) throws GLib.Error;
  /**
   * Search all child {@link GXml.Element} with a given property's name and with
   * value contained in text.
   */
  public virtual GXml.DomElementList
   get_elements_by_property_value (string property, string value)
  {
    var list = new GXml.DomElementList ();
    foreach (DomElement child in children) {
      if (child == null) continue;
      list.add_all (child.get_elements_by_property_value (property, value));
      if (child.attributes == null) continue;
      var cls = child.get_attribute (property);
      if (cls == null) continue;
      if (value == cls)
          list.add ((GXml.DomElement) child);
    }
    return list;
  }
}

public interface GXml.DomNonDocumentTypeChildNode : GLib.Object {
  public abstract DomElement? previous_element_sibling { owned get; }
  public abstract DomElement? next_element_sibling { owned get; }
}

public interface GXml.DomChildNode : GLib.Object {
  public abstract void remove ();
}


public interface GXml.DomNodeList : GLib.Object, Gee.BidirList<GXml.DomNode>  {
  public abstract DomNode? item (int index);
  public abstract int length { get; }
}

public interface GXml.DomHTMLCollection : GLib.Object, Gee.BidirList<GXml.DomElement> {
  public abstract new GXml.DomElement? get_element (int index); // FIXME: See bug #768913
  public virtual new GXml.DomElement[] to_array () {
    return (GXml.DomElement[]) ((Gee.Collection<GXml.DomElement>) this).to_array ();
  }
  public virtual int length { get { return (int) size; } }
  public virtual DomElement? item (int index) { return this.get ((int) index); }
  public virtual DomElement? named_item (string name) {
      foreach (GXml.DomElement e in this) {
          if (e.node_name == name) return e;
      }
      return null;
  }
}


/**
 * Document's node iterator.
 *
 * If you want to filter while you go though the tree
 * set a handler for the {@link accept_node} signal
 */
public interface GXml.DomNodeIterator : GLib.Object {
  public abstract DomNode root { get; }
  public abstract DomNode reference_node { get; }
  public abstract bool pointer_before_reference_node { get; }
  /**
   * This is a value of {@link DomNodeFilter} constant SHOW.
   */
  public abstract int what_to_show { get; }

  public signal DomNodeFilter.Filter accept_node (DomNode node);

  public abstract DomNode? next_node();
  public abstract DomNode? previous_node();

  public abstract void detach();
}

/**
 * No implemented jet. This can lead to API changes in future versions.
 */
public class GXml.DomNodeFilter : GLib.Object {
  public enum Filter {
    ACCEPT = 1,
    REJECT,
    SKIP
  }

  // Constants for whatToShow
  public const int SHOW_ALL = (int) 0xFFFFFFFF;
  public const int SHOW_ELEMENT = (int) 0x1;
  public const int SHOW_ATTRIBUTE = (int) 0x2; // historical
  public const int SHOW_TEXT = (int) 0x4;
  public const int SHOW_CDATA_SECTION = (int) 0x8; // historical
  public const int SHOW_ENTITY_REFERENCE = (int) 0x10; // historical
  public const int SHOW_ENTITY = (int) 0x20; // historical
  public const int SHOW_PROCESSING_INSTRUCTION = (int) 0x40;
  public const int SHOW_COMMENT = (int) 0x80;
  public const int SHOW_DOCUMENT = (int) 0x100;
  public const int SHOW_DOCUMENT_TYPE = (int) 0x200;
  public const int SHOW_DOCUMENT_FRAGMENT = (int) 0x400;
  public const int SHOW_NOTATION = (int) 0x800; // historical
}


/**
 * Document tree walker.
 *
 * If you want to filter while you go though the tree
 * set a handler for the {@link accept_node} signal
 */
public interface GXml.DomTreeWalker : GLib.Object {
  public abstract DomNode root { get; }
  public abstract int what_to_show { get; }
  public abstract DomNode current_node { get; }

  public signal DomNodeFilter.Filter accept_node (DomNode node);

  public abstract DomNode? parent_node();
  public abstract DomNode? first_child();
  public abstract DomNode? last_child();
  public abstract DomNode? previous_sibling();
  public abstract DomNode? next_sibling();
  public abstract DomNode? previous_node();
  public abstract DomNode? next_node();
}

public interface GXml.DomNamedNodeMap : GLib.Object, Gee.Map<string,DomNode> {
  public abstract int length { get; }
  public abstract DomNode? item (int index);
  public abstract DomNode? get_named_item (string name);
  public abstract DomNode? set_named_item (DomNode node) throws GLib.Error;
  public abstract DomNode? remove_named_item (string name) throws GLib.Error;
  // Introduced in DOM Level 2:
  public abstract DomNode? remove_named_item_ns (string namespace_uri, string localName) throws GLib.Error;
  // Introduced in DOM Level 2:
  public abstract DomNode? get_named_item_ns (string namespace_uri, string local_name) throws GLib.Error;
  // Introduced in DOM Level 2:
  public abstract DomNode? set_named_item_ns (DomNode node) throws GLib.Error;
}

public interface GXml.DomTokenList : GLib.Object, Gee.BidirList<string> {
  public abstract int   length   { get; }
  public abstract string? item     (int index);
  public abstract bool    contains (string token) throws GLib.Error;
  public abstract void    add      (string[] tokens) throws GLib.Error;
  public abstract void    remove   (string[] tokens);
  /**
   * If auto is true, adds token if not present and removing if it is, @force value
   * is taken in account. If auto is false, then @force is considered; if true adds
   * token, if false removes it.
   */
  public abstract bool    toggle   (string token, bool force = false, bool auto = true) throws GLib.Error;
  public abstract string  to_string ();
}


/**
 * No implemented jet. This can lead to API changes in future versions.
 */
public interface GXml.DomSettableTokenList : GLib.Object, GXml.DomTokenList {
  public abstract string @value { owned get; set; }
}
