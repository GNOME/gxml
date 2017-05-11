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
 * Parser Error codes for {@link DomNode} parsing objects
 */
public errordomain GXml.ParserError {
  INVALID_DATA_ERROR,
  INVALID_FILE_ERROR,
  INVALID_STREAM_ERROR
}

/**
 * XML parser engine for {@link DomDocument} implementations.
 */
public interface GXml.Parser : Object {
  /**
   * Controls if, when writing to a file, a backup should
   * be created.
   */
  public abstract bool backup { get; set; }
  /**
   * Controls if, when writing, identation should be used.
   */
  public abstract bool indent { get; set; }
  /**
   * A {@link GXml.DomDocument} to read to or write from
   */
  public abstract DomNode node { get; }
  /**
   * Writes a {@link GXml.DomDocument} to a {@link GLib.File}
   */
  public virtual void write_file (GLib.File file,
                            GLib.Cancellable? cancellable)
                            throws GLib.Error {
    var ostream = file.replace (null, backup,
                            GLib.FileCreateFlags.NONE, cancellable);
    write_stream (ostream, cancellable);
  }
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
   * Writes a {@link GXml.DomDocument} to a {@link GLib.OutputStream}
   */
  public virtual void read_file (GLib.File file,
                                    GLib.Cancellable? cancellable)
                                    throws GLib.Error {
    if (!file.query_exists ())
      throw new GXml.ParserError.INVALID_FILE_ERROR (_("File doesn't exist"));
    read_stream (file.read (), cancellable);
  }

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
}
