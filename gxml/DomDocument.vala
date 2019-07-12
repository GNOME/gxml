/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016-2019  Daniel Espinosa <esodan@gmail.com>
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

public interface GXml.DomDocument : GLib.Object,
									GXml.DomNode,
									GXml.DomParentNode,
									GXml.DomNonElementParentNode
{
  public abstract DomImplementation implementation { get; }
  public abstract string url { get; }
  public abstract string document_uri { get; }
  public abstract string origin { get; }
  public abstract string compat_mode { get; }
  public abstract string character_set { get; }
  public abstract string content_type { get; }

  public abstract DomDocumentType? doctype { owned get; }
  public abstract DomElement? document_element { owned get; }

  public abstract DomHTMLCollection get_elements_by_tag_name (string local_name);
  public abstract DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name);
  public abstract DomHTMLCollection get_elements_by_class_name(string classNames);

  public abstract DomElement create_element    (string local_name) throws GLib.Error;
  public abstract DomElement create_element_ns (string? namespace, string qualified_name) throws GLib.Error;
  public abstract DomDocumentFragment create_document_fragment();
  public abstract DomText create_text_node (string data) throws GLib.Error;
  public abstract DomComment create_comment (string data) throws GLib.Error;
  public abstract DomProcessingInstruction create_processing_instruction (string target, string data) throws GLib.Error;

  public abstract DomNode import_node (DomNode node, bool deep = false) throws GLib.Error;
  public abstract DomNode adopt_node (DomNode node) throws GLib.Error;

  /**
   * No implemented jet. This can lead to API changes in future versions.
   */
  public abstract DomEvent create_event (string interface) throws GLib.Error;

  /**
   * No implemented jet. This can lead to API changes in future versions.
   */
  public abstract DomRange create_range();

  /**
   * Creates a {@link DomNodeIterator}.
   *
   * Consider to connect to {@link DomNodeIterator.accept_node} in order to
   * filter the nodes you iterate on.
   *
   * See at {@link DomNodeFilter} for the constant value of @what_to_show
   */
  public abstract DomNodeIterator create_node_iterator (DomNode root, int whatToShow = (int) 0xFFFFFFFF);

  /**
   * Creates a {@link DomTreeWalker}.
   *
   * Consider to connect to {@link DomTreeWalker.accept_node} in order to
   * filter the nodes you iterate on.
   *
   * See at {@link DomNodeFilter} for the constant value of @what_to_show
   */
  public abstract DomTreeWalker create_tree_walker (DomNode root, int what_to_show = (int) 0xFFFFFFFF);

  /**
   * Writes a dump XML representation of document to a file.
   */
  public virtual void write_file (GLib.File file, Cancellable? cancellable = null) throws GLib.Error
  {
    Parser parser = get_xml_parser ();
    parser.write_file (file);
  }
  /**
   * Writes asynchronically a dump XML representation of document to a file.
   */
  public virtual async void write_file_async (GLib.File file,
                            Cancellable? cancellable = null) throws GLib.Error
  {
    Parser parser = get_xml_parser ();
    yield parser.write_file_async (file);
  }
  /**
   * Writes a dump XML representation of document to a stream.
   */
  public virtual void write_stream (GLib.OutputStream stream,
                            Cancellable? cancellable = null) throws GLib.Error
  {
    Parser parser = get_xml_parser ();
    parser.write_stream (stream);
  }
  /**
   * Writes a dump XML representation of document to a stream.
   */
  public virtual async void write_stream_async (GLib.OutputStream stream,
                            Cancellable? cancellable = null) throws GLib.Error
  {
    Parser parser = get_xml_parser ();
    yield parser.write_stream_async (stream);
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GXml.Document}
   */
  public virtual InputStream create_stream () throws GLib.Error {
    Parser parser = get_xml_parser ();
    return parser.create_stream ();
  }
  /**
   * Creates an {@link GLib.InputStream} to write a string representation
   * in XML of {@link GXml.Document}
   */
  public virtual async InputStream create_stream_async (Cancellable? cancellable = null) throws GLib.Error {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    return yield parser.create_stream_async ();
  }
  /**
   * Serialize {@link GXml.Document} to a string.
   */
  public virtual string write_string (Cancellable? cancellable = null) throws GLib.Error {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    return parser.write_string ();
  }
  /**
   * Serialize {@link GXml.Document} to a string.
   */
  public virtual async string write_string_async (Cancellable? cancellable = null) throws GLib.Error
  {
    Idle.add (write_string_async.callback);
    yield;
    return write_string (cancellable);
  }
  /**
   * Reads a file contents and parse it to document.
   */
  public virtual void read_from_file (GLib.File file,
                              Cancellable? cancellable = null) throws GLib.Error {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    parser.read_file (file);
  }
  /**
   * Reads a file contents and parse it to document.
   */
  public virtual async void read_from_file_async (GLib.File file,
                              Cancellable? cancellable = null) throws GLib.Error {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    yield parser.read_file_async (file);
  }
  /**
   * Reads a string and parse it to document.
   */
  public virtual void read_from_string (string str, Cancellable? cancellable = null) throws GLib.Error {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    parser.read_string (str);
  }
  /**
   * Reads a string and parse it to document.
   */
  public virtual async void read_from_string_async (string str,
                              Cancellable? cancellable = null) throws GLib.Error {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    yield parser.read_string_async (str);
  }
  /**
   * Reads a string and parse it to document.
   */
  public virtual void read_from_stream (GLib.InputStream stream,
                              Cancellable? cancellable = null) throws GLib.Error
  {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    parser.read_stream (stream);
  }
  /**
   * Reads a string and parse it to document.
   */
  public virtual async void read_from_stream_async (GLib.InputStream stream,
                              Cancellable? cancellable = null) throws GLib.Error
  {
    Parser parser = get_xml_parser ();
    parser.cancellable = cancellable;
    yield parser.read_stream_async (stream);
  }
  /**
   * Returns a default XML {@link Parser} to use with this object.
   */
  public abstract Parser get_xml_parser ();
  /**
   * Set a default XML {@link Parser} to use with this object.
   */
  public abstract void set_xml_parser (Parser parser);
}

public errordomain GXml.DomDocumentError {
  FILE_NOT_FOUND_ERROR,
  INVALID_DOCUMENT_ERROR
}

public interface GXml.DomXMLDocument : GLib.Object, GXml.DomDocument {}

/**
 * Not implemented yet. This can lead to API changes in future versions.
 */
public interface GXml.DomImplementation : GLib.Object {
  public abstract DomDocumentType create_document_type (string qualified_name, string public_id, string system_id) throws GLib.Error;
  public abstract DomXMLDocument create_document (string? nspace,
                                                  string? qualified_name,
                                                  DomDocumentType? doctype = null) throws GLib.Error;
  public abstract DomDocument create_html_document (string title);

  public virtual bool has_feature() { return true; } // useless; always returns true
}

/**
 * Not implemented yet. This can lead to API changes in future versions.
 */
public interface GXml.DomDocumentFragment : GLib.Object,
                                            GXml.DomNode,
                                            GXml.DomParentNode,
                                            GXml.DomNonElementParentNode
{}

/**
 * Not implemented yet. This can lead to API changes in future versions.
 */
public interface GXml.DomDocumentType : GLib.Object, GXml.DomNode, GXml.DomChildNode {
  public abstract string name { get; }
  public abstract string public_id { get; }
  public abstract string system_id { get; }
}


