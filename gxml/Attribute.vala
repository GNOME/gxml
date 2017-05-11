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
 * DOM4 Interface to handle XML tags properties, powered by libxml2 library.
 *
 * Its features relays on {@link GXml.Node} interface inplementation to access
 * {@link GXml.Element} properties.
 *
 * Attribute's name could be get from {@link GXml.Node.name} property. Its value
 * should be get from {@link GXml.Node.value} property.
 */
public interface GXml.Attribute : Object, GXml.Node {
  public abstract GXml.Namespace? @namespace { owned get; set; }
  public abstract string? prefix { owned get; }
}

