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


