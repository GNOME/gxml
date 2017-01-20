/* GXmlNamespace.vala
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
 * Class implemeting {@link GXml.Namespace}
 */
public class GXml.GNamespace : Object, GXml.Namespace
{
  private Xml.Ns *_ns;
  public GNamespace (Xml.Ns* ns) { _ns = ns; }
  public Xml.Ns* get_internal_ns () { return _ns; }
  // GXml.Namespace
  public string? uri {
    owned get {
      if (_ns == null) return null;
      return _ns->href.dup ();
    }
  }
  public string? @prefix {
    owned get {
      if (_ns == null) return null;
      return _ns->prefix.dup ();
    }
  }
}
