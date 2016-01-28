/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
 *
 * Copyright (C) 2013, 2014  Daniel Espinosa <esodan@gmail.com>
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
 * Interface to handle XML Namespaces.
 *
 * Basic information for a XML document's namespaces and applied to a given
 * {@link GXml.Node}.
 *
 * Namespace management is a matter of this or other libraries, implementing
 * this interfaces.
 */
public interface GXml.Namespace : Object
{
  /**
   * Read-only property to get namespace's URI.
   */
  public abstract string uri { owned get; }
  /**
   * Read-only property to get namespace's prefix.
   *
   * Prefix should be added to {@link GXml.Element} or {@link GXml.Attribute}
   * name in order to apply a given namespace, unless it is the default.
   */
  public abstract string prefix { owned get; }
}

