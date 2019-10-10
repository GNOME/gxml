/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GXmlDomCollections.vala
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
 * DOM4 Setteable token list, powered by libxml2 library.
 */
public class GXml.SettableTokenList : GXml.TokenList, GXml.DomSettableTokenList {
  public string value {
    owned get  { return to_string (); }
    set {
      string[] s = value.split (" ");
      for (int i = 0; i < s.length; i++) {
        ((Gee.ArrayList<string>) this).add (s[i]);
      }
    }
  }

  public SettableTokenList (DomElement e, string? attr) {
    base (e, attr);
  }

}

