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
 * DOM4 List of string tokens, powered by libxml2 library.
 */
public class GXml.TokenList : Gee.ArrayList<string>, GXml.DomTokenList {
  protected DomElement _element;
  protected string _attr = null;

  public int length { get { return size; } }
  public string? item (int index) { return base.get (index); }

  public TokenList (DomElement e, string? attr) {
    _element = e;
    _attr = attr;
    if (_attr != null) {
      var av = _element.get_attribute (_attr);
      if (av == "") return;
      if (" " in av) {
        string[] s = av.split (" ");
        for (int i = 0; i < s.length; i++) {
          ((Gee.ArrayList<string>) this).add (s[i]);
        }
      } else {
        ((Gee.ArrayList<string>) this).add (av);
      }
    }
  }

  public new bool contains (string token) throws GLib.Error {
    if (token == "")
      throw new GXml.DomError.SYNTAX_ERROR (_("DOM: Invalid token. No empty string could be used as token to check if it is contained in token list"));
    if (" " in token)
      throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: Invalid token. No white spaces could be included as token to check if it is contained in token list"));
    return base.contains (token);
  }

  public new void add (string[] tokens) throws GLib.Error {
    foreach (string s in tokens) {
        if (s == "")
          throw new GXml.DomError.SYNTAX_ERROR (_("DOM: Invalid token. Empty string can't be used as token"));
        if (" " in s)
          throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: Invalid token. White spaces can't be used as token"));
        base.add (s);
    }
    update ();
  }
  public new void remove (string[] tokens) {
    for (int i = 0; i < size; i++) {
      string s = get (i);
      foreach (string ts in tokens) {
        if (s == ts) base.remove_at (i);
      }
    }
    update ();
  }
  /**
   * A convenient method to remove or add tokens. If force is true, this method
   * will add it to the list of tokens, same as {@link add}. If force is false
   * will remove a token from the list {@link remove}
   */
  public bool toggle (string token, bool force = false, bool auto = true) throws GLib.Error {
    if (token == "")
      throw new GXml.DomError.SYNTAX_ERROR (_("DOM: Invalid token. Empty string can't be used as token"));
    if (" " in token)
      throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: Invalid token. White spaces can't be used as token"));
    if (contains (token) && auto) { // FIXME: missing force use
      remove_at (index_of (token));
      return false;
    } else {
      if (!force) return false;
    }
    update ();
    return true;
  }
  public void update () {
    if (_element == null) return;
    if (_attr == null) return;
    try  { _element.set_attribute (_attr, this.to_string ()); }
    catch (GLib.Error e) { warning (_("Update Error: ")+e.message); }
  }
  public string to_string () {
    string s = "";
    for (int i = 0; i < size; i++ ) {
        s += this.get (i);
        if (i+1 < size) s += " ";
    }
    return s;
  }
}

