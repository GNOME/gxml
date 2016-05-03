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
  public abstract DomElement? getElementById(string elementId);
}

public interface GXml.DomParentNode : GLib.Object {
  public abstract DomHTMLCollection children { get; }
  public abstract DomElement? firstElementChild { get; }
  public abstract DomElement? lastElementChild { get; }
  public abstract ulong childElementCount { get; }

  public abstract DomElement? querySelector(string selectors);
  public abstract DomNodeList querySelectorAll(string selectors);
}

public interface GXml.DomNonDocumentTypeChildNode : GLib.Object {
  public abstract DomElement? previousElementSibling { get; }
  public abstract DomElement? nextElementSibling { get; }
}

public interface GXml.DomChildNode : GLib.Object {
  public abstract void remove();
}


public interface GXml.DomNodeList : GLib.Object, Gee.BidirList<GXml.DomNode>  {
  public abstract DomNode? item (ulong index);
  public abstract ulong length { get; }
}

public interface GXml.DomHTMLCollection : GLib.Object, Gee.BidirList<GXml.DomNode> {
  public abstract ulong length { get; }
  public abstract DomElement? item (ulong index);
  public abstract DomElement? namedItem (string name);
}

public interface GXml.DomNamedNodeMap : GLib.Object {
  public abstract DomNode getNamedItem(string name);
  public abstract DomNode setNamedItem(DomNode arg) throws GXml.DomError;
  public abstract DomNode removeNamedItem(string name) throws GXml.DomError;
  public abstract DomNode item (ulong index);
  public abstract ulong length { get; }
  // Introduced in DOM Level 2:
  public abstract DomNode getNamedItemNS(string namespaceURI, string localName) throws GXml.DomError;
  // Introduced in DOM Level 2:
  public abstract DomNode setNamedItemNS(DomNode arg) throws GXml.DomError;
  // Introduced in DOM Level 2:
  public abstract DomNode removeNamedItemNS(string namespaceURI, string localName) throws GXml.DomError;
}


