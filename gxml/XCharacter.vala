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
 * DOM4 Base class for character data, powered by libxml2 library.
 */
public class GXml.XCharacterData : GXml.XNonDocumentChildNode,
              GXml.DomCharacterData
{
  // GXml.Character
  public string str {
    owned get { return base.value; }
    set { base.value = value; }
  }
  // GXml.DomCharacterData
  public string data {
    owned get {
      return str;
    }
    set {
      str = value;
    }
  }

}
