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

/**
 * A DOM4 implementation of {@link DomCharacterData}, for one step parsing.
 *
 * This object avoids pre and post XML parsing, by using a one step parsing
 * to translate text XML tree to an GObject based tree.
 */
public class GXml.CharacterData : GXml.Node,
                          DomNonDocumentTypeChildNode,
                          DomChildNode,
                          DomCharacterData
{
  // DomCharacterData
  public string data { owned get { return _node_value; } set { _node_value = value; } }

  construct {
    _node_value = "";
  }
  // DomNonDocumentTypeChildNode
  public DomElement? previous_element_sibling {
    owned get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == 0)
          return null;
        for (var j = i; j >= 1; j--) {
          var n = parent_node.child_nodes.item (j - 1);
          if (n is DomElement)
			return n as DomElement;
        }
      }
      return null;
    }
  }
  public DomElement? next_element_sibling {
    owned get {
      if (parent_node != null) {
        var i = parent_node.child_nodes.index_of (this);
        if (i == parent_node.child_nodes.length - 1)
          return null;
        for (var j = i; j < parent_node.child_nodes.length - 1; j--) {
          var n = parent_node.child_nodes.item (j + 1);
          if (n is DomElement)
            return (DomElement) n;
        }
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

/**
 * A DOM4 implementation of {@link DomText}, for one step parsing.
 *
 * This object avoids pre and post XML parsing, by using a one step parsing
 * to translate text XML tree to an GObject based tree.
 */
public class GXml.Text : GXml.CharacterData,
                          DomText

{
  construct {
    _node_type = DomNode.NodeType.TEXT_NODE;
    _local_name = "#text";
  }

  public Text (DomDocument doc, string data) {
    _document = doc;
    _node_value = data;
  }
}

/**
 * A DOM4 implementation of {@link DomProcessingInstruction}, for one step parsing.
 *
 * This object avoids pre and post XML parsing, by using a one step parsing
 * to translate text XML tree to an GObject based tree.
 */
public class GXml.ProcessingInstruction : GXml.CharacterData,
                                            DomProcessingInstruction
{
  // DomProcessingInstruction
  public string target { owned get { return _local_name; } }
  construct {
    _node_type = DomNode.NodeType.PROCESSING_INSTRUCTION_NODE;
  }
  public ProcessingInstruction (DomDocument doc, string target, string data) {
    _document = doc;
    _node_value = data;
    _local_name = target;
  }
}

/**
 * A DOM4 implementation of {@link DomComment}, for one step parsing.
 *
 * This object avoids pre and post XML parsing, by using a one step parsing
 * to translate text XML tree to an GObject based tree.
 */
public class GXml.Comment : CharacterData,
                              DomComment
{
  construct {
    _node_type = DomNode.NodeType.COMMENT_NODE;
    _local_name = "#comment";
  }
  public Comment (DomDocument doc, string data) {
    _document = doc;
    _node_value = data;
  }
}
