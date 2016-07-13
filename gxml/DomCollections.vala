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


public interface GXml.DomNonElementParentNode : GLib.Object {
  public abstract DomElement? get_element_by_id (string elementId);
}

public interface GXml.DomParentNode : GLib.Object {
  public abstract DomHTMLCollection children { get; }
  public abstract DomElement? first_element_child { get; }
  public abstract DomElement? last_element_child { get; }
  public abstract ulong child_element_count { get; }

  public abstract DomElement? query_selector (string selectors);
  public abstract DomNodeList query_selector_all (string selectors);
}

public interface GXml.DomNonDocumentTypeChildNode : GLib.Object {
  public abstract DomElement? previous_element_sibling { get; }
  public abstract DomElement? next_element_sibling { get; }
}

public interface GXml.DomChildNode : GLib.Object {
  public abstract void remove ();
}


public interface GXml.DomNodeList : GLib.Object, Gee.BidirList<GXml.DomNode>  {
  public abstract DomNode? item (ulong index);
  public abstract ulong length { get; }
}

public interface GXml.DomHTMLCollection : GLib.Object, Gee.BidirList<GXml.DomNode> {
  public abstract ulong length { get; }
  public abstract DomElement? item (ulong index);
  public abstract DomElement? named_item (string name);
}

public interface GXml.DomNamedNodeMap : GLib.Object {
  public abstract DomNode get_named_item (string name);
  public abstract DomNode set_named_item (DomNode arg) throws GXml.DomError;
  public abstract DomNode remove_named_item (string name) throws GXml.DomError;
  public abstract DomNode item (ulong index);
  public abstract ulong length { get; }
  // Introduced in DOM Level 2:
  public abstract DomNode get_named_item_ns (string namespaceURI, string localName) throws GXml.DomError;
  // Introduced in DOM Level 2:
  public abstract DomNode set_named_item_ns (DomNode arg) throws GXml.DomError;
  // Introduced in DOM Level 2:
  public abstract DomNode remove_named_item_ns (string namespaceURI, string localName) throws GXml.DomError;
}


public interface GXml.DomNodeIterator {
  public DomNode root { get; }
  public DomNode reference_node { get; }
  public bool pointer_before_reference_node { get; };
  public ulong what_to_show { get; }
  public DomNodeFilter? filter { get; }

  public DomNode? next_node();
  public DomNode? previous_node();

  public void detach();
}

public class GXml.DomNodeFilter : Object {
  // Constants for acceptNode()
  public const ushort FILTER_ACCEPT = 1;
  public const ushort FILTER_REJECT = 2;
  public const ushort FILTER_SKIP = 3;

  // Constants for whatToShow
  public const ulong SHOW_ALL = 0xFFFFFFFF;
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

  public ushort acceptNode(Node node); // FIXME:
}

public interface GXml.DomTreeWalker : Object {
  public abstract DomNode root { get; }
  public abstract ulong what_to_show { get; }
  public abstract DomNodeFilter? filter { get; }
  public abstract DomNode current_node { get; }

  public abstract DomNode? parentNode();
  public abstract DomNode? firstChild();
  public abstract DomNode? lastChild();
  public abstract DomNode? previousSibling();
  public abstract DomNode? nextSibling();
  public abstract DomNode? previousNode();
  public abstract DomNode? nextNode();
}

