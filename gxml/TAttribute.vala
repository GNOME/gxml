/* TAttribute.vala
 *
 * Copyright (C) 2015-2016  Daniel Espinosa <esodan@gmail.com>
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
 * Class implemeting {@link GXml.Attribute} interface, not tied to libxml-2.0 library.
 */
public class GXml.TAttribute : GXml.TNode, GXml.Attribute
{
  protected Gee.ArrayList<GXml.Node> _namespaces;
  public TAttribute (GXml.Document d, string name, string value)
    requires (d is TDocument)
  {
    _doc = d;
    _name = name;
    _value = value;
  }
  // Node
  public override Gee.List<GXml.Namespace> namespaces {
    owned get {
      if (_namespaces == null) _namespaces = new Gee.ArrayList<GXml.Node> ();
      return _namespaces.ref () as Gee.List<GXml.Namespace>;
    }
  }
  // Attribute
  public Namespace @namespace {
    owned get {
      if (_namespaces == null) _namespaces = new Gee.ArrayList<GXml.Node> ();
      return (Namespace) namespaces.get (0).ref ();
    }
    set {
      namespaces.add (value);
    }
  }
  public string? prefix {
    owned get {
      return @namespace.prefix;
    }
  }
}
