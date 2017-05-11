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

public interface GXml.DomElement : GLib.Object,
                  GXml.DomNode,
                  GXml.DomChildNode,
                  GXml.DomNonDocumentTypeChildNode,
                  GXml.DomParentNode
{
  /**
   * Returns default namespace's uri defined in node or first found.
   */
  public abstract string? namespace_uri { owned get; }
  /**
   * Returns default namespace's prefix defined in node or first found.
   */
  public abstract string? prefix { owned get; }
  public abstract string local_name { owned get; }
  public abstract string tag_name { owned get; }

  public abstract string? id { owned get; set; }
  public abstract string? class_name  { owned get; set; }
  public abstract DomTokenList class_list { owned get; }

  public abstract DomNamedNodeMap attributes { owned get; }

  public abstract string? get_attribute (string name);
  public abstract string? get_attribute_ns (string? namespace, string local_name);
  public abstract void set_attribute (string name, string value) throws GLib.Error;
  /**
   * Set an attribute value to this element. If it doesn't exists yet, it is added
   * to the list of attributes, unless it is an namespace redefinition.
   *
   * To set a namespace declaration [[http://www.w3.org/2000/xmlns]] namespace and xmlns
   * as prefix. For default namespaces, use xmlns as name without prefix. Namespace
   * URI will be the one provided as value.
   *
   * @param name a prefixed attribute name or xmlns for default namespace declaration
   * @param value a value for the attribute or URI for namespace declaration
   */
  public abstract void set_attribute_ns (string? namespace, string name, string value) throws GLib.Error;
  public abstract void remove_attribute (string name);
  public abstract void remove_attribute_ns (string? namespace, string local_name);
  public abstract bool has_attribute (string name);
  public abstract bool has_attribute_ns (string? namespace, string local_name);


  public abstract DomHTMLCollection get_elements_by_tag_name(string local_name);
  public abstract DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name);
  public abstract DomHTMLCollection get_elements_by_class_name (string class_names);
}

public class GXml.DomElementList : Gee.ArrayList<DomElement>, GXml.DomHTMLCollection {
  // DomHTMLCollection
  public new GXml.DomElement? get_element (int index) {
    return (GXml.DomElement?) this.get (index);
  }
}
