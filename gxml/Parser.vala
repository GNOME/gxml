/* TNode.vala
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
 * XML parser engine for {@link DomDocument} implementations.
 */
public interface GXml.Parser : Object {
  /**
   * A {@link GXml.DomDocument} to read to or write from
   */
  public abstract DomDocument document { get; }
  /**
   * Writes a {@link GXml.DomDocument} to a {@link GLib.File}
   */
  public abstract void write (GLib.File f,
                            GLib.Cancellable? cancellable) throws GLib.Error;
  /**
   * Writes a {@link GXml.DomDocument} to a string
   */
  public abstract string write_string () throws GLib.Error;
  /**
   * Writes a {@link GXml.DomDocument} to a {@link GLib.OutputStream}
   */
  public abstract void write_stream (OutputStream stream,
                                    GLib.Cancellable? cancellable) throws GLib.Error;

  /**
   * Read a {@link GXml.DomDocument} from a {@link GLib.File}
   */
  public abstract void read (GLib.File f,
                            GLib.Cancellable? cancellable) throws GLib.Error;
  /**
   * Read a {@link GXml.DomDocument} from a {@link GLib.InputStream}
   */
  public abstract void read_stream (InputStream stream,
                                   GLib.Cancellable? cancellable) throws GLib.Error;
  /**
   * Read a {@link GXml.DomDocument} from a {@link GLib.File}
   */
  public abstract void read_string (string str,
                                   GLib.Cancellable? cancellable) throws GLib.Error;
  /**
   * From data stream read until a node is found. You should check its type
   * using {@link current_type}
   */
  public abstract bool read_node (DomNode node) throws GLib.Error;
}
