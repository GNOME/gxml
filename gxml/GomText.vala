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

public class GXml.GomText : GomNode,
                          DomCharacterData,
                          DomNode,
                          DomNonDocumentTypeChildNode,
                          DomChildNode,
                          DomText

{
  construct {
    _node_type = DomNode.NodeType.TEXT_NODE;
    _local_name = "#TEXT";
  }
  // DomCharacterData
  public string data { owned get; set; }
  // DomNonDocumentTypeChildNode
  public DomElement? previous_element_sibling {
    get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == 0) return null;
        var n = parent_node.child_nodes.item (i - 1);
        if (n is DomElement) return (DomElement) n;
        return null;
      }
      return null;
    }
  }
  public DomElement? next_element_sibling {
    get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == parent_node.child_nodes.length - 1) return null;
        var n = parent_node.child_nodes.item (i + 1);
        if (n is DomElement) return (DomElement) n;
        return null;
      }
      return null;
    }
  }
  // DomChildNode
  public void remove () {
    if (parent_node != null) {
      var i = parent_node.child_nodes.index_of (this);
      parent_node.child_nodes.remove_at (i);
    }
  }
}

public class GXml.GomProcessingInstruction : GomNode,
              DomCharacterData,
              DomProcessingInstruction
{
  protected string _target = null;
  // DomCharacterData
  public string data { owned get { return _node_value; } set { _node_value = value; } }

  construct {
    _node_type = DomNode.NodeType.PROCESSING_INSTRUCTION_NODE;
    _local_name = "#PROCESSING_INSTRUCTION";
  }
}

public class GXml.GomComment : GomNode,
                                  DomCharacterData,
                                  DomComment
{
  // DomCharacterData
  public string data { owned get; set; }
  construct {
    _node_type = DomNode.NodeType.COMMENT_NODE;
    _local_name = "#COMMENT";
  }
}
