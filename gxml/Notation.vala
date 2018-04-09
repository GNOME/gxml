/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* Notation.vala
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
 * DOM1 Interface to handle notation elements
 *
 * Used in defining {@link GXml.DocumentType}s to declare the format of
 * {@link GXml.Entity} and {@link GXml.ProcessingInstruction}s.
 *
 * Used collectively in defining DocumentTypes. A Notation can
 * declare the format of unparsed entities or
 * ProcessingInstruction targets.
 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-5431D1B9]]
 */
[Version (deprecated = true, deprecated_since = "0.18", replacement = "")]
public interface GXml.Notation : Object, GXml.Node
{
  public abstract string? public_id { get; }
  public abstract string? external_id { get; }
}

/**
 * Dummy definition for entity.
 */
[Version (deprecated = true, deprecated_since = "0.18", replacement = "")]
public interface GXml.Entity : Object, GXml.Node {}
