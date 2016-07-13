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

/**
 * Errors for documents handling reading/writing
 */
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
   * Controls if writting this documentsshould use namespaces
   * declaration at root {@link GXml.Element}.
   *
   * This removes full declaration at childs nodes, because they
   * are just prefixed if a prefix was defined for namespace apply.
   */
  public abstract bool ns_top { get; set; }
  /**
   * Controls if writting this document should use default namespace's prefix
   * to prefix root's childs {@link GXml.Element}.
   *
   * This removes prefix on childs using default namespace. Default namespace
   * is the first one found in {@link GXml.Node.namespaces} for this document.
   */
  public abstract bool prefix_default_ns { get; set; }
  /**
   * Controls if writting to a {@link GLib.File} creates a backup, by default
   * is true;
   */
  public abstract bool backup { get; set; }
  /**
   * XML document root node as a {@link GXml.Element}.
   */
  public abstract GXml.Node root { owned get; }
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
  public abstract GXml.Node create_element_node (string name) throws GLib.Error;
  /**
   * Creates a new {@link GXml.Text}.
   *
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}, like a {@link GXml.Element} node.
   */
  public abstract GXml.Node create_text (string text);
  /**
   * Creates a new {@link GXml.Comment}.
   *
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}, like a {@link GXml.Element} node.
   */
  public abstract GXml.Node create_comment_node (string text);
  /**
   * Creates a new {@link GXml.CDATA}.
   *
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}, like a {@link GXml.Element} node.
   */
  public abstract GXml.Node create_cdata (string text);
  /**
   * Creates a new {@link GXml.ProcessingInstruction}.
   *
   * Is a matter of you to add as a child to any other
   * {@link GXml.Node}, like a {@link GXml.Element} node.
   */
  public abstract GXml.Node create_pi (string target, string data);
  /**
   * Save this {@link GXml.Document} to {@link GXml.Document.file}
   *
   * If {@link GXml.Document.file} doesn't exists, it creates a new file to save to.
   */
  public abstract bool save (GLib.Cancellable? cancellable = null) throws GLib.Error;
  /**
   * Save this {@link GXml.Document} to given {@link GLib.File}
   */
  public abstract bool save_as (GLib.File f, GLib.Cancellable? cancellable = null) throws GLib.Error;
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
      throw new DocumentError.INVALID_FILE (_("Invalid file"));
    d.file = f;
    return d;
  }
}
