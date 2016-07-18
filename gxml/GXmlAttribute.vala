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
public class GXml.GAttribute : GXml.GNode, GXml.Attribute, GXml.DomAttr
{
  private Xml.Attr* _attr;
  public GAttribute (GDocument doc, Xml.Attr *node)
  {
    _attr = node;
    _node = _attr->parent;
    _doc = doc;
  }
  public override Gee.List<GXml.Namespace> namespaces {
    owned get {
      var l = new Gee.ArrayList<GXml.Namespace> ();
      if (_attr->ns == null) return l;
      l.add (new GNamespace (_attr->ns));
      return l;
    }
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
      return _attr->name.dup (); // FIXME: Check if name is namespace+local_name
    }
  }
  public override string value {
    owned get {
      if (_node == null) return  null;
      if (_attr->ns == null) {
        return _node->get_no_ns_prop (_attr->name);
      }
      else
        return _node->get_ns_prop (_attr->name, _attr->ns->href);
    }
    set {
      if (_node == null) return;
      if (_attr->ns == null)
        _node->set_prop (_attr->name, value);
      else
        _node->set_ns_prop (_attr->ns, _attr->name, value);
    }
  }
  public string? prefix {
    owned get {
      if (_attr == null) return "";
      if (_attr->ns == null) return "";
      return _attr->ns->prefix.dup ();
    }
  }
  public override GXml.Node parent {
    owned get {
      if (_attr == null) return null;
      return to_gnode (document as GDocument, _node);
    }
  }
  // DomAttr implementation
  public string? namespace_uri {
    owned get {
      if (namespace == null) return null;
      return namespace.uri;
    }
  }
  /*public string? DomAttr.prefix {
    get {
      if (namespace == null) return null;
      return namespace.prefix;
    }
  }*/
  public string local_name { owned get { return (this as GXml.Node).name; } }
  /*public string GXml.DomAttr.name {
    get {
      if (namespace == null) return (this as GXml.Node).name;
      string s = namespace.prefix+":"+(this as GXml.Node).name;
      return s;
    }
  }
  public string @value {
    get {
      return (this as GXml.Node).value;
    }
    set {
      (this as GXml.Node).value = value;
    }
  }*/
}
