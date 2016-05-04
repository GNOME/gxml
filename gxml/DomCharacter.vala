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
  public abstract ulong length { get; }
  public abstract string substring_data (ulong offset, ulong count);
  public abstract void append_data  (string data);
  public abstract void insert_data  (ulong offset, string data);
  public abstract void delete_data  (ulong offset, ulong count);
  public abstract void replace_data (ulong offset, ulong count, string data);
}

public interface GXml.DomText : GXml.DomCharacterData {
  public abstract GXml.DomText split_text(ulong offset);
  public abstract string whole_text { get; }
}

public interface GXml.DomProcessingInstruction : GXml.DomCharacterData {
  public abstract string target { get; }
}

public interface GXml.DomComment : GXml.DomCharacterData {}

