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


public class GXml.GDomTokenList : Gee.ArrayList<string>, GXml.DomTokenList {
  protected DomElement _element;
  protected string _attr = null;

  public ulong length { get { return size; } }
  public string? item (ulong index) { return base.get ((int) index); }

  public GDomTokenList (DomElement e, string? attr) {
    _element = e;
    _attr = attr;
    if (_attr != null) {
      var av = _element.get_attribute (_attr);
      if (av == "") return;
      if (" " in av) {
        string[] s = av.split (" ");
        for (int i = 0; i < s.length; i++) {
          (this as Gee.ArrayList<string>).add (s[i]);
        }
      }
    }
  }

  public new bool contains (string token) throws GLib.Error {
    if (token == "")
      throw new GXml.DomError.SYNTAX_ERROR (_("DOM: No empty string could be toggle"));
    if (" " in token)
      throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: No white spaces should be included to toggle"));
    return base.contains (token);
  }

  public new void add (string[] tokens) throws GLib.Error {
    foreach (string s in tokens) {
        if (s == "")
          throw new GXml.DomError.SYNTAX_ERROR (_("DOM: No empty string could be a token"));
        if (" " in s)
          throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: No white spaces should be included in token"));
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
  public bool toggle (string token, bool force = false, bool auto = true) throws GLib.Error {
    if (token == "")
      throw new GXml.DomError.SYNTAX_ERROR (_("DOM: No empty string could be toggle"));
    if (" " in token)
      throw new GXml.DomError.INVALID_CHARACTER_ERROR (_("DOM: No white spaces should be included to toggle"));
    if (contains (token) && auto) { // FIXME: missing force use
      remove_at (index_of (token));
      return false;
    }
    update ();
    return true;
  }
  public void update () {
    if (_element == null) return;
    if (_attr == null) return;
    _element.set_attribute (_attr, this.to_string ());;
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

public class GXml.GDomSettableTokenList : GXml.GDomTokenList, GXml.DomSettableTokenList {
  public string value {
    owned get  { return to_string (); }
    set {
      string[] s = value.split (" ");
      for (int i = 0; i < s.length; i++) {
        (this as Gee.ArrayList<string>).add (s[i]);
      }
    }
  }

  public GDomSettableTokenList (DomElement e, string? attr) {
    base (e, attr);
  }

}

public class GXml.GDomHTMLCollection : Gee.ArrayList<GXml.DomElement>,
              GXml.DomHTMLCollection
{
  public ulong length { get { return size; } }
  public DomElement? item (ulong index) { return base.get ((int) index); }
  public DomElement? named_item (string name) {
    foreach (DomElement e in this) {
      if (e.node_name == name) return e;
    }
    return null;
  }
}
