/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
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

public interface GXml.DomRange : GLib.Object {
  public abstract DomNode start_container { get; }
  public abstract int start_offset { get; }
  public abstract DomNode end_container { get; }
  public abstract int end_offset { get; }
  public abstract bool collapsed { get; }
  public abstract DomNode common_ancestor_container { get; }

  public abstract void set_start        (DomNode node, int offset) throws GLib.Error;
  public abstract void set_end          (DomNode node, int offset) throws GLib.Error;
  public abstract void set_start_before (DomNode node) throws GLib.Error;
  public abstract void set_start_after  (DomNode node) throws GLib.Error;
  public abstract void set_end_before   (DomNode node) throws GLib.Error;
  public abstract void set_end_after    (DomNode node) throws GLib.Error;
  public abstract void collapse         (bool to_start = false) throws GLib.Error;
  public abstract void select_node      (DomNode node) throws GLib.Error;
  public abstract void select_node_contents (DomNode node) throws GLib.Error;

  public abstract int compare_boundary_points (BoundaryPoints how, DomRange sourceRange) throws GLib.Error;

  public abstract void delete_contents () throws GLib.Error;
  public abstract DomDocumentFragment? extract_contents() throws GLib.Error;
  public abstract DomDocumentFragment? clone_contents() throws GLib.Error;
  public abstract void insert_node(DomNode node);
  public abstract void surround_contents(DomNode newParent);

  public abstract DomRange clone_range();
  public abstract void detach ();

  public abstract bool  is_point_in_range (DomNode node, int offset);
  public abstract short compare_point     (DomNode node, int offset);

  public abstract bool  intersects_node   (DomNode node);

  public abstract string to_string ();
  public enum BoundaryPoints {
     START_TO_START = 0,
     START_TO_END,
     END_TO_END,
     END_TO_START
  }
}
