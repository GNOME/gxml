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
 * DOM4 character handling interface
 */
public interface GXml.DomCharacterData : GLib.Object,
                  GXml.DomNode,
                  GXml.DomNonDocumentTypeChildNode,
                  GXml.DomChildNode
{
	/**
	 * Null is an empty string.
	 */
  public abstract string data { owned get; set; }

  public virtual int length {
    get {
      Init.init ();
      if (this.data == null) return 0;
      return this.data.length;
    }
  }
  public virtual string substring_data (int offset, int count) throws GLib.Error {
    Init.init ();
    if (((int)offset) > this.data.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for substring"));
    int end = (int) (offset + count);
    if (!(end < data.length)) end = data.length;
    return data.slice ((int) offset, end);
  }
  public virtual void append_data  (string data) {
    Init.init ();
    this.data += data;
  }
  public virtual void insert_data  (int offset, string data) throws GLib.Error {
    Init.init ();
    replace_data (offset, 0, data);
  }
  public virtual void delete_data  (int offset, int count) throws GLib.Error {
    Init.init ();
    replace_data (offset, count, "");
  }
  public new virtual void replace_data (int offset, int count, string data) throws GLib.Error {
    Init.init ();
    if (((int)offset) > this.data.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for replace data"));
    int end = (int) (offset + count);
    if (!(end < this.data.length)) end = this.data.length;
    this.data = this.data.splice ((int) offset, end, data);
  }
}

/**
 * DOM4 text node
 */
public interface GXml.DomText : GXml.DomCharacterData {
  public virtual GXml.DomText split_text (int offset) throws GLib.Error {
    Init.init ();
    if (offset >= data.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset to split text"));
    var nt = this.owner_document.create_text_node (this.data.slice ((int)offset, this.data.length));
    this.delete_data (offset, this.data.length);
    var n = this.parent_node.append_child (nt) as DomText;
    // This will not work with libxml2 library as it doesn't support
    // continuos text nodes, then it just concatecate text nodes data
    // as added to parent
    return n;
  }
  public virtual string whole_text {
    owned get {
      Init.init ();
      string s = "";
      if (this.previous_sibling is DomText)
        s += ((DomText) this.previous_sibling).whole_text;
      s += data;
      if (this.next_sibling is DomText)
        s += ((DomText) this.next_sibling).whole_text;
      return s;
    }
  }
}
/**
 * DOM4 Processing Instruction node
 */
public interface GXml.DomProcessingInstruction : GXml.DomCharacterData {
  public abstract string target { owned get; }
}

/**
 * DOM4 comment node
 */
public interface GXml.DomComment : GXml.DomCharacterData {}

