/* GXmlComment.vala
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
 * Class implemeting {@link GXml.Comment} interface, not tied to libxml-2.0 library.
 */
public class GXml.GComment : GXml.GNode, GXml.Comment, GXml.DomCharacterData, GXml.DomComment
{
  public GComment (GDocument doc, Xml.Node *node)
  {
    _node = node;
    _doc = doc;
  }
  public override string name {
    owned get {
      return "#comment".dup ();
    }
  }
  // GXml.Comment
  public string str { owned get { return base.value; } }

  public string data {
    get {
      return str;
    }
    set {
      str = value;
    }
  }
  public ulong length { get { return str.length; } }
  public string substring_data (ulong offset, ulong count) throws GLib.Error {
    if (((int)offset) > str.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for substring"));
    int c = (int) count;
    if (c > str.length) c = str.length;
    return str[(int)offset:(int)c];
  }
  public void append_data  (string data) {
    str += data;
  }
  public void insert_data  (ulong offset, string data) throws GLib.Error {
    replace_data (offset, 0, data);
  }
  public void delete_data  (ulong offset, ulong count) throws GLib.Error {
    replace_data (offset, count, "");
  }
  public void replace_data (ulong offset, ulong count, string data) throws GLib.Error {
    if (((int)offset) > str.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for replace data"));
    int c = (int) count;
    if (((int)offset + c) > str.length) c = str.length - (int)offset;

    string s = str[0:(int)offset];
    string s2 = str[0:(s.length - (int)offset - c)];
    string sr = data[0:(int)count];
    str = s+sr+s2;
  }
}
