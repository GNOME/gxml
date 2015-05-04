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
 * Interface to handle XML documents.
 *
 * Provides basic interfaces to read and create XML documents.
 */
public interface GXml.Document : Object, GXml.Node
{
  /**
   * XML document root node as a {@link GXml.Element}.
   */
  public abstract GXml.Node root { get; }
  /**
   * Stores a {@link GLib.File} to save/read XML documents to/from.
   */
  public abstract GLib.File file { get; set; }
  /**
   * This method should create a new {@link GXml.Element}.
   * 
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}.
   */
  public abstract GXml.Node create_element (string name);
  /**
   * Creates a new {@link GXml.Text}.
   * 
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}, like a {@link GXml.Element} node.
   */
  public abstract GXml.Node create_text (string text);
}
