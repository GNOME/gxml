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

public interface GXml.DomElement : GLib.Object, GXml.DomNode, GXml.DomParentNode, GXml.DomNonDocumentTypeChildNode, GXml.DomChildNode {
  public abstract string? namespaceURI { get; }
  public abstract string? prefix { get; }
  public abstract string localName { get; }
  public abstract string tagName { get; }

  public abstract string id { get; set; }
  public abstract string className  { get; set; }
  public abstract DomTokenList classList { get; }

  public abstract DomNamedNodeMap attributes { get; }
  public abstract string? getAttribute(string name);
  public abstract string? getAttributeNS(string? namespace, string localName);
  public abstract void setAttribute(string name, string value);
  public abstract void setAttributeNS(string? namespace, string name, string value);
  public abstract void removeAttribute(string name);
  public abstract void removeAttributeNS(string? namespace, string localName);
  public abstract bool hasAttribute(string name);
  public abstract bool hasAttributeNS(string? namespace, string localName);


  public abstract DomHTMLCollection getElementsByTagName(string localName);
  public abstract DomHTMLCollection getElementsByTagNameNS(string? namespace, string localName);
  public abstract DomHTMLCollection getElementsByClassName(string classNames);
}

