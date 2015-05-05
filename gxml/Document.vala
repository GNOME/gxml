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

public errordomain GXml.DocumentError {
  INVALID_DOCUMENT_ERROR,
  INVALID_FILE
}

/**
 * Interface to handle XML documents.
 *
 * Provides basic interfaces to read and create XML documents.
 */
public interface GXml.Document : Object, GXml.Node
{
  /**
   * Controls if writting this documents should use indent.
   */
  public abstract bool indent { get; set; }
  /**
   * XML document root node as a {@link GXml.Element}.
   */
  public abstract GXml.Node root { get; }
  /**
   * Stores a {@link GLib.File} to save/read XML documents to/from.
   */
  public abstract GLib.File file { get; set; }
  /**
   * This method should create a new {@link GXml.Element}.
   *
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}.
   */
  public abstract GXml.Node create_element (string name);
  /**
   * This method should finalize a new created {@link GXml.Element}.
   *
   * Once a {@link GXml.Element} was created and setup, you should finalize it
   * by calling this method. Is a good practice to call this function, even if
   * current implemention doesn't requires it.
   *
   * Setup a new {@link GXml.Element} include: set its attributes and add childs
   * {@link GXml.Node}. When finish, call this function.
   *
   * This function is useful when using {@link GXml.TextWriter} implementations.
   */
  public virtual void finalize_element () { return; }
  /**
   * Creates a new {@link GXml.Text}.
   *
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}, like a {@link GXml.Element} node.
   */
  public abstract GXml.Node create_text (string text);
  /**
   * This method should finalize a new created {@link GXml.Text}.
   *
   * Once a {@link GXml.Text} was created and setup, you should finalize it
   * by calling this method. Is a good practice to call this function, even if
   * current implemention doesn't requires it.
   *
   * Setup a new {@link GXml.Text} include: set its text, done when it is created.
   * When finish, call this fucntion.
   *
   * This function is useful when using {@link GXml.TextWriter} implementations.
   */
  public virtual void finalize_text () { return; }
  /**
   * Creates a new {@link GXml.Comment}.
   *
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}, like a {@link GXml.Element} node.
   */
  public abstract GXml.Node create_comment (string text);
  /**
   * This method should finalize a new created {@link GXml.Comment}.
   *
   * Once a {@link GXml.Comment} was created and setup, you should finalize it
   * by calling this method. Is a good practice to call this function, even if
   * current implemention doesn't requires it.
   *
   * Setup a new {@link GXml.Comment} include: set its text, done when it is created.
   * When finish, call this fucntion.
   *
   * This function is useful when using {@link GXml.TextWriter} implementations.
   */
  public virtual void finalize_comment () { return; }
  /**
   * Save this {@link GXml.Document} to {@link GXml.Document.file}
   */
  public abstract bool save (GLib.Cancellable? cancellable = null) throws GLib.Error;
  /**
   * Save this {@link GXml.Document} to given {@link GLib.File}
   *
   * This overrides actual {@link GXml.Document.file}
   */
  public virtual bool save_as (GLib.File f, GLib.Cancellable? cancellable = null) throws GLib.Error
  {
    if (f.query_exists ()) {
      f = file;
      save (cancellable);
      return true;
    }
    return false;
  }
  /**
   * Creates a new {@link GXml.Document} using default implementation class.
   *
   * As an interface you can create your own implementation of it, but if 
   * default one is required use this.
   */
  public static GXml.Document new_default ()
  {
   return new xDocument ();
  }
  /**
   * Creates a new {@link GXml.Document} from a file path using default implementation class.
   *
   * As an interface you can create your own implementation of it, but if 
   * default one is required use this.
   */
  public static GXml.Document new_default_for_path (string path)
   throws GLib.Error
  {
   File f = File.new_for_path (path);
   return GXml.Document.new_default_for_file (f);
  }
  /**
   * Creates a new {@link GXml.Document} from a {@link GLib.File} using default implementation class.
   *
   * As an interface you can create your own implementation of it, but if 
   * default one is required use this.
   */
  public static GXml.Document new_default_for_file (GLib.File f)
   throws GLib.Error
  {
    var d = new xDocument.from_path (f.get_path ());
    if (!f.query_exists ())
      throw new DocumentError.INVALID_FILE ("Invalid file");
    d.file = f;
    return d;
  }
}
