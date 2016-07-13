/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
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

public interface GXml.DomCharacterData : GLib.Object, GXml.DomNode, GXml.DomNonDocumentTypeChildNode, GXml.DomChildNode {
	/**
	 * Null is an empty string.
	 */
  public abstract string data { get; set; }

  public virtual ulong length { get { return this.data.length; } }
  public virtual string substring_data (ulong offset, ulong count) throws GLib.Error {
    if (((int)offset) > this.data.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for substring"));
    int c = (int) count;
    if (c > this.data.length) c = this.data.length;
    return this.data[(int)offset:(int)c];
  }
  public virtual void append_data  (string data) {
    this.data += data;
  }
  public virtual void insert_data  (ulong offset, string data) throws GLib.Error {
    replace_data (offset, 0, data);
  }
  public virtual void delete_data  (ulong offset, ulong count) throws GLib.Error {
    replace_data (offset, count, "");
  }
  public virtual void replace_data (ulong offset, ulong count, string data) throws GLib.Error {
    if (((int)offset) > this.data.length)
      throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for replace data"));
    int c = (int) count;
    if (((int)offset + c) > str.length) c = str.length - (int)offset;

    string s = this.data[0:(int)offset];
    string s2 = this.data[0:(s.length - (int)offset - c)];
    string sr = data[0:(int)count];
    str = s+sr+s2;
  }
}

public interface GXml.DomText : GXml.DomCharacterData {
  public abstract GXml.DomText split_text(ulong offset);
  public abstract string whole_text { get; }
}

public interface GXml.DomProcessingInstruction : GXml.DomCharacterData {
  public abstract string target { get; }
}

public interface GXml.DomComment : GXml.DomCharacterData {}

