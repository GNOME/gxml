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

/**
 * DOM4 class for child nodes, powered by libxml2 library.
 */
public class GXml.XChildNode : GXml.XNode,
              GXml.DomChildNode
{
  // DomChildNode
  public void remove () {
    if (parent_node != null) {
      var i = parent_node.child_nodes.index_of (this);
      parent_node.child_nodes.remove_at (i);
    }
  }
}

public class GXml.XNonDocumentChildNode : GXml.XChildNode,
              GXml.DomNonDocumentTypeChildNode
{

  // DomNonDocumentTypeChildNode
  public DomElement? previous_element_sibling {
    owned get {
      if (_node == null) return null;
      var n = _node->previous_element_sibling ();
      if (n == null) return null;
      return new XElement (owner_document as XDocument, n);
    }
  }
  public DomElement? next_element_sibling {
    owned get {
      if (_node == null) return null;
      var n = _node->next_element_sibling ();
      if (n == null) return null;
      return new XElement (owner_document as XDocument, n);
    }
  }
}
