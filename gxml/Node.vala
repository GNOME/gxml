/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* ObjectModel.vala
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

public interface GXml.Node : Object
{
  public abstract Gee.LinkedList<GXml.Namespace> namespaces { get; }
  public abstract Gee.LinkedList<GXml.Node> childs { get; }
  public abstract Gee.Map<string,GXml.Node> attrs { get; }
  public abstract string name { get; construct set; }
  public abstract string @value { get; set; }
  public abstract GXml.NodeType type_node { get; construct set; }
  public abstract GXml.Document document { get; construct set; }
  public abstract GXml.Node copy ();
  public abstract string to_string ();
  public virtual string ns_prefix () { return namespaces.first ().prefix; }
  public virtual string ns_urf () { return namespaces.first ().uri; }
}

