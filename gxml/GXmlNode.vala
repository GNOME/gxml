/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
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
 * Base interface providing basic functionalities to all GXml interfaces.
 */
public abstract class GXml.GNode : Object, GXml.Node
{
  protected GXml.GDocument _doc;
  protected Xml.Node *_node;

  construct { Init.init (); }

  // GXml.Node
  public virtual bool set_namespace (string uri, string? prefix)
  {
    if (_node == null) return false;
    return ((_node->new_ns (uri, prefix)) != null);
  }
  public virtual Gee.Map<string,GXml.Node> attrs { owned get { return new GHashMapAttr (_doc, _node); } }
  public virtual Gee.BidirList<GXml.Node> children { owned get { return new GListChildren (_doc, _node); } }
  public virtual Gee.List<GXml.Namespace> namespaces { owned get { return new GListNamespaces (_doc, _node); } }
  public virtual GXml.Document document { get { return _doc; } }
  public virtual GXml.NodeType type_node {
    get {
      if (_node == null) return GXml.NodeType.X_UNKNOWN;
      return (GXml.NodeType) _node->type;
    }
  }
  public virtual string name {
    owned get {
      if (_node == null) return "#noname";
      return _node->name.dup ();
    }
  }

  public virtual string @value {
    owned get {
      if (_node == null) return "";
      return _node->get_content ();
    }
    set {
      if (_node == null) return;
      _node->set_content (value);
    }
  }
  public virtual string to_string () { return get_type ().name (); }
  public Xml.Node* get_internal_node () { return _node; }
  // Static
  public static GXml.Node to_gnode (GXml.GDocument doc, Xml.Node *node) {
    var t = (GXml.NodeType) node->type;
    switch (t) {
      case GXml.NodeType.ELEMENT:
        return new GElement (doc, node);
      case GXml.NodeType.ATTRIBUTE:
        return new GAttribute (doc, (Xml.Attr*) node);
      case GXml.NodeType.TEXT:
        return new GText (doc, node);
      case GXml.NodeType.CDATA_SECTION:
        return new GCDATA (doc, node);
      case GXml.NodeType.ENTITY_REFERENCE:
        return null;
      case GXml.NodeType.ENTITY:
        return null;
      case GXml.NodeType.PROCESSING_INSTRUCTION:
        return new GProcessingInstruction (doc, node);
      case GXml.NodeType.COMMENT:
        return new GComment (doc, node);
      case GXml.NodeType.DOCUMENT:
        return new GDocument.from_doc (node->doc);
      case GXml.NodeType.DOCUMENT_TYPE:
        return null;
      case GXml.NodeType.DOCUMENT_FRAGMENT:
        return null;
      case GXml.NodeType.NOTATION:
        return null;
    }
    return null;
  }
}

