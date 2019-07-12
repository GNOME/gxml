/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
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

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */
using Gee;

/**
 * Implementers should use constructor with one argument {@link GXml.DomMutationCallback}
 * to use internally.
 */
public interface GXml.DomMutationObserver : GLib.Object {
  public abstract void observe (Node target, DomMutationObserverInit options);
  public abstract void disconnect ();
  public abstract Gee.List<DomMutationRecord> take_records ();
}

public delegate void GXml.DomMutationCallback (Gee.List<DomMutationRecord> mutations, DomMutationObserver observer);

public class GXml.DomMutationObserverInit : GLib.Object {
  public bool child_list { get; set; default = false; }
  public bool attributes { get; set; }
  public bool character_data { get; set; }
  public bool subtree { get; set; default = false; }
  public bool attribute_old_value { get; set; }
  public bool character_data_old_value { get; set; }
  public Gee.List<string> attribute_filter { get; set; }
}

public interface GXml.DomMutationRecord : GLib.Object {
  public abstract string mtype { get; }
  public abstract DomNode target { owned get; }
  public abstract DomNodeList added_nodes { owned get; set; }
  public abstract DomNodeList removed_nodes { owned get; set; }
  public abstract DomNode? previous_sibling { owned get; }
  public abstract DomNode? next_sibling { owned get; }
  public abstract string? attribute_name { get; }
  public abstract string? attribute_namespace { get; }
  public abstract string? old_value { get; }
}
