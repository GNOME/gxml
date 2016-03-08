/* TNamespace.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
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
 * Class implemeting {@link GXml.Namespace}, not tied to libxml-2.0 library.
 */
public class GXml.TNamespace : GXml.TNode, GXml.Namespace
{
  private string _uri = null;
  private string _prefix = null;
  public TNamespace (GXml.Document d, string uri, string? prefix)
    requires (d is TDocument)
  {
    _doc = d;
    ((TDocument) document).tw = ((TDocument) d).tw;
    _uri = uri;
    _prefix = prefix;
  }
  // GXml.Namespace
  public string uri { owned get { return _uri.dup (); } }
  public string @prefix { owned get { return _prefix.dup (); } }
}
