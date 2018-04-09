/* TComment.vala
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
 * DOM1 Class implemeting {@link GXml.Comment} interface, not tied to libxml-2.0 library.
 */
[Version (deprecated = true, deprecated_since = "0.18", replacement = "GXml.GomComment")]
public class GXml.TComment : GXml.TNode, GXml.Comment
{
  private string _str = "";
  construct {
    _name = "#comment";
    _node_type = GXml.NodeType.COMMENT;
  }
  public TComment (GXml.Document doc, string text)
    requires (doc is GXml.TDocument)
  {
    _doc = doc;
    _str = text;
  }
  // GXml.Node
  public override string @value {
    owned get { return _str.dup (); }
    set {  }
  }
  // GXml.Comment
  public string str { owned get { return _str.dup (); } set { _str = value; }}
}
