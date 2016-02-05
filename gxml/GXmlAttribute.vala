/* GAttribute.vala
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
 * Class implemeting {@link GXml.Attribute} interface, not tied to libxml-2.0 library.
 */
public class GXml.GAttribute : GXml.GNode, GXml.Attribute
{
  private Xml.Attr* _attr;
  public GAttribute (GDocument doc, Xml.Attr *node)
  {
    _attr = node;
    Test.message ("Attr Name: "+node->name);
    _node = _attr->parent;
    _doc = doc;
  }
  public Namespace @namespace {
    owned get {
      if (_attr == null) return null;
      if (_attr->ns == null) return null;
      return new GNamespace (_attr->ns);
    }
    set {
      
    }
  }
  public override string name {
    owned get {
      return _attr->name.dup ();
    }
  }
  public override string value {
    owned get {
      return _node->get_prop (_attr->name);
    }
    set {
      _node->set_prop (_attr->name, value);
    }
  }
  public string prefix {
    owned get {
      if (_attr == null) return "";
      if (_attr->ns == null) return "";
      return _attr->ns->prefix.dup ();
    }
  }
}
