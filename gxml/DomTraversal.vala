/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
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

public interface GXml.DomNodeIterator : GLib.Object {
  public abstract DomNode         root { get; }
  public abstract DomNode         reference_node { get; }
  public abstract bool            pointer_before_reference_node { get; }
  public abstract ulong           what_to_show   { get; }
  public abstract DomNodeFilter?  filter         { get; }

  public abstract DomNode?        next_node     ();
  public abstract DomNode?        previous_node ();

  public abstract void detach();
}

public interface GXml.DomTreeWalker {
  public abstract DomNode         root { get; }
  public abstract ulong           what_to_show { get; }
  public abstract DomNodeFilter?  filter { get; }
  public abstract DomNode         current_node { get; set; }

  public abstract DomNode?        parent_node ();
  public abstract DomNode?        first_child ();
  public abstract DomNode?        last_child  ();
  public abstract DomNode?        previous_sibling();
  public abstract DomNode?        next_sibling();
  public abstract DomNode?        previous_node();
  public abstract DomNode?        next_node();
}

public interface GXml.DomNodeFilter : GLib.Object {
  // Constants for acceptNode()
  public const ushort FILTER_ACCEPT = 1;
  public const ushort FILTER_REJECT = 2;
  public const ushort FILTER_SKIP = 3;

  // Constants for whatToShow
  public const ulong SHOW_ALL = (ulong) 0xFFFFFFFF;
  public const ulong SHOW_ELEMENT = 0x1;
  public const ulong SHOW_ATTRIBUTE = 0x2; // historical
  public const ulong SHOW_TEXT = 0x4;
  public const ulong SHOW_CDATA_SECTION = 0x8; // historical
  public const ulong SHOW_ENTITY_REFERENCE = 0x10; // historical
  public const ulong SHOW_ENTITY = 0x20; // historical
  public const ulong SHOW_PROCESSING_INSTRUCTION = 0x40;
  public const ulong SHOW_COMMENT = 0x80;
  public const ulong SHOW_DOCUMENT = 0x100;
  public const ulong SHOW_DOCUMENT_TYPE = 0x200;
  public const ulong SHOW_DOCUMENT_FRAGMENT = 0x400;
  public const ulong SHOW_NOTATION = 0x800; // historical

  public abstract ushort accept_node (DomNode node);
}
