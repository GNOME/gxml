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

using GXml;
using Gee;

/**
 * DOM4 implementation of {@link DomAttr}.
 */
public class GXml.Attr : GXml.Node, GXml.DomAttr {
  protected string _namespace_uri;
  protected GXml.Property prop = null;
  public string local_name { owned get { return _local_name; } }
  public string name {
    owned get {
      string s = "";
      if (_prefix != null && _prefix != "") s = _prefix+":";
      return s+_local_name;
    }
  }
  public string? namespace_uri { owned get { return _namespace_uri; } }
  public string? prefix {
    owned get {
      if (_prefix == "") return null;
      return _prefix;
    }
  }
  public string value {
    owned get {
      if (prop != null) {
        return prop.value;
      }
      return _node_value;
    }
    set {
      if (prop != null) {
        prop.value = value;
      } else {
        _node_value = value;
      }
    }
  }

  public bool is_referenced { get { return prop != null; } }

  construct { _child_nodes = null; }

  public Attr (DomElement element, string name, string val) {
    _document = element.owner_document;
    _parent = element;
    _local_name = name;
    _node_value = val;
    assert (node_value == val);
    prop = null;
  }
  public Attr.namespace (DomElement element, string namespace_uri, string? prefix, string name, string val) {
    _document = element.owner_document;
    _parent = element;
    _local_name = name;
    _node_value = val;
    _namespace_uri = namespace_uri;
    _prefix = prefix;
    prop = null;
  }
  public Attr.reference (DomElement element, string name) {
    _document = element.owner_document;
    _parent = element;
    _local_name = name;
    _node_value = null;
    prop = new StringRef (element as GXml.Object, name);
  }
}
