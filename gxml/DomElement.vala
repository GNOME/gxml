/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
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

public interface GXml.DomElement : GLib.Object,
                  GXml.DomNode,
                  GXml.DomParentNode,
                  GXml.DomNonDocumentTypeChildNode,
                  GXml.DomChildNode
{
  public abstract string? namespace_uri { owned get; }
  public abstract string? prefix { owned get; }
  public abstract string local_name { owned get; }
  public abstract string tag_name { owned get; }

  public abstract string? id { owned get; set; }
  public abstract string? class_name  { owned get; set; }
  public abstract DomTokenList class_list { owned get; }

  public abstract DomNamedNodeMap attributes { owned get; }

  public abstract string? get_attribute (string name);
  public abstract string? get_attribute_ns (string? namespace, string local_name);
  public abstract void set_attribute (string name, string? value);
  public abstract void set_attribute_ns (string? namespace, string name, string? value);
  public abstract void remove_attribute (string name);
  public abstract void remove_attribute_ns (string? namespace, string local_name);
  public abstract bool has_attribute (string name);
  public abstract bool has_attribute_ns (string? namespace, string local_name);


  public abstract DomHTMLCollection get_elements_by_tag_name(string local_name);
  public abstract DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name);
  public abstract DomHTMLCollection get_elements_by_class_name (string class_names);
}

public class GXml.DomElementList : Gee.ArrayList<DomElement>, GXml.DomHTMLCollection {}
