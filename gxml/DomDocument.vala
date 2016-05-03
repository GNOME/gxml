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

public interface GXml.DomDocument : GLib.Object, GXml.DomNode, GXml.DomParentNode, GXml.DomNonElementParentNode {
  public abstract DomImplementation implementation { get; }
  public abstract string URL { get; }
  public abstract string documentURI { get; }
  public abstract string origin { get; }
  public abstract string compatMode { get; }
  public abstract string characterSet { get; }
  public abstract string contentType { get; }

  public abstract DomDocumentType? doctype { get; }
  public abstract DomElement? documentElement { get; }

  public abstract DomHTMLCollection getElementsByTagName(string localName);
  public abstract DomHTMLCollection getElementsByTagNameNS(string? namespace, string localName);
  public abstract DomHTMLCollection getElementsByClassName(string classNames);

  public abstract DomElement createElement(string localName);
  public abstract DomElement createElementNS(string? namespace, string qualifiedName);
  public abstract DomDocumentFragment createDocumentFragment();
  public abstract DomText createTextNode(string data);
  public abstract DomComment createComment(string data);
  public abstract DomProcessingInstruction createProcessingInstruction(string target, string data);

  public abstract DomNode importNode(DomNode node, bool deep = false);
  public abstract DomNode adoptNode(DomNode node);

  public abstract DomEvent createEvent(string interface);

  public abstract DomRange createRange();

  // NodeFilter.SHOW_ALL = 0xFFFFFFFF
  public abstract DomNodeIterator createNodeIterator(DomNode root, ulong whatToShow = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null);
  public abstract DomTreeWalker createTreeWalker(DomNode root, ulong whatToShow = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null);
}

public interface GXml.DomXMLDocument : GLib.Object, GXml.DomDocument {}

public interface GXml.DomImplementation : GLib.Object {
  public abstract DomDocumentType createDocumentType(string qualifiedName, string publicId, string systemId);
  public abstract DomXMLDocument createDocument(string? namespace, string? qualifiedName, DocumentType? doctype = null);
  public abstract Document createHTMLDocument(string title);

  public abstract bool hasFeature(); // useless; always returns true
}

public interface GXml.DomDocumentFragment : GLib.Object, GXml.DomNode, GXml.DomParentNode, GXml.DomNonElementParentNode {}

public interface GXml.DomDocumentType : GLib.Object, GXml.DomNode, GXml.DomChildNode {
  public abstract string name { get; }
  public abstract string publicId { get; }
  public abstract string systemId { get; }
}


