/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* Element.vala
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
 * DOM1 Interface to access XML document's tags, properties and content.
 *
 * Provides methods to create new XML tags properties and its values, and 
 * access to tag's contents.
 */
[Version (deprecated = true, deprecated_since = "0.18", replacement = "GXml.DomElement")]
public interface GXml.Element : Object, GXml.Node
{
    /**
     * This merges all adjacent {@link GXml.Text} nodes that are
     * descendants of this {@link GXml.Element}.
     */
    public abstract void normalize ();
    /**
     * Add a new {@link GXml.Attribute} to this {@link GXml.Element}.
     *
     * You should provide a name and a value.
     */
    public abstract void set_attr (string name, string value);
    /**
     * Search for a {@link GXml.Attribute} with given name.
     *
     * All attributes could be get using {@link GXml.Node.attrs} property.
     */
    public abstract GXml.Node? get_attr (string name);
    /**
     * Search for a {@link GXml.Attribute} with given name and removes it.
     */
    public abstract void remove_attr (string name);
    /**
     * Search for a {@link GXml.Attribute} with given name and namespace and removes it.
     */
    public abstract void remove_ns_attr (string name, string uri);
    /**
     * Set an {@link GXml.Attribute} with a given name, value and namespace.
     */
    public abstract void set_ns_attr (string ns, string name, string value);
    /**
     * Search for a {@link GXml.Attribute} with a given name and namespace uri.
     *
     * To get a attibute from {@link GXml.Node.attrs} with a given namespace
     * prefix, use "prefix:name".
     */
    public abstract GXml.Node? get_ns_attr (string name, string uri);
    /**
     * This should be just a different name for {@link GXml.Node.name}.
     */
    public abstract string tag_name { owned get; }
    /**
     * This should be just a different name for {@link GXml.Node.value}.
     */
    public abstract string content { owned get; set; }
}


/**
 * Convenient class for a list of {@link GXml.Element} objects based on
 * {@link Gee.ArrayList}, with good support for bindings.
 */
public class GXml.ElementList : ArrayList<Element>, GXml.DomHTMLCollection {
  // DomHTMLCollection
  public new GXml.DomElement? get_element (int index) {
    return (GXml.DomElement?) this.get (index);
  }
}
