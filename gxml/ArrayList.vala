/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 * ArrayList.vala
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
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;

/**
 * A class implementing {@link Collection} to store references to
 * child {@link DomElement} of {@link Collection.element}, using an index.
 *
 * {{{
 *   public class YourObject : GXml.Element {
 *    [Description (nick="::Name")]
 *    public string name { get; set; }
 *   }
 *   public class YourList : GXml.ArrayList {
 *    construct {
 *      try { initialize (typeof (YourObject)); }
 *      catch (GLib.Error e) {
 *        warning ("Initialization error for collection type: %s : %s"
 *             .printf (get_type ().name(), e.message));
 *      }
 *    }
 *   }
 * }}}
 */
public class GXml.ArrayList : GXml.BaseCollection, GXml.List {
  public override bool validate_append (int index, DomElement element) throws GLib.Error {
    return true;
  }
}

