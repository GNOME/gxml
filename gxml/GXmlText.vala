/* GXmlText.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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
 * Class implemeting {@link GXml.Text} interface, not tied to libxml-2.0 library.
 */
public class GXml.GText : GXml.GCharacterData, GXml.Text, GXml.DomText
{
  public GText (GDocument doc, Xml.Node *node)
  {
    _node = node;
    _doc = doc;
  }
  public override string name {
    owned get {
      return "#text".dup ();
    }
  }
  // GXml.DomText
  public GXml.DomText split_text(ulong offset) throws GLib.Error {
    if (offset >= data.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset to split text"));
    long l = (long) offset;
    string ns = data[0:l];
    string nd = data[data.length - l: data.length];
    var nt = this.owner_document.create_text_node (ns);
    (this.parent_node.child_nodes as Gee.List<DomNode>).insert (this.parent_node.child_nodes.index_of (this), nt);
    return nt;
  }
  public string whole_text {
    owned get {
      string s = "";
      if (this.previous_sibling is DomText)
        s += (this.previous_sibling as DomText).whole_text;
      s += data;
      if (this.next_sibling is DomText)
        s += (this.next_sibling as DomText).whole_text;
      return s;
    }
  }
}
