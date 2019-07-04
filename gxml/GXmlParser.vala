/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2019  Daniel Espinosa <esodan@gmail.com>
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


private class GXml.GParser : Object, Parser {
  private GDocument document;
  private DomNode _node;

  public GParser (GDocument doc) {
    document = doc;
    _node = doc;
  }

  // Parser Interface
	public GXml.DomElement? create_element (GXml.DomNode parent) throws GLib.Error { return null; }
	public GLib.InputStream create_stream () throws GLib.Error {
	  string str = document.libxml_to_string ();
	  return new MemoryInputStream.from_data (str.data);
	}
	public async GLib.InputStream create_stream_async () throws GLib.Error {
	  Idle.add (create_stream_async.callback);
  yield;
	  return create_stream ();
	}
	public bool current_is_document () { return false; }
	public bool current_is_element () { return false; }
	public bool current_is_empty_element () { return false; }
	public string current_node_name () { return node.node_name; }
	public bool move_next_node () throws GLib.Error { return false; }
	public bool read_child_node (GXml.DomNode parent) throws GLib.Error { return false; }
	public void read_child_nodes_stream (GLib.InputStream istream) throws GLib.Error {}
	public void read_element (GXml.DomElement element) throws GLib.Error {}
	public void read_stream (GLib.InputStream stream) throws GLib.Error
	{
  var b = new MemoryOutputStream.resizable ();
  b.splice (stream, 0);
  if (b.data == null)
    throw new DocumentError.INVALID_DOCUMENT_ERROR (_("stream doesn't provide data"));
  read_string ((string) b.data);
	}
	public async void read_stream_async (GLib.InputStream stream) throws GLib.Error
	{
	  Idle.add (read_stream_async.callback);
  yield;
  read_stream (stream);
	}
	public void read_string (string str) throws GLib.Error
	{
  Xml.reset_last_error ();
  document.doc = Xml.Parser.parse_memory (str, (int) str.length);
  var e = Xml.get_last_error ();
  if (e != null) {
    var errmsg = _("Parser Error for string");
    string s = GNode.libxml2_error_to_string (e);
    if (s != null)
      errmsg = ".  ";
    throw new GXml.Error.PARSER (errmsg);
  }
  if (document.doc == null)
    document.doc = new Xml.Doc ();
	}
	public async void read_string_async (string str) throws GLib.Error
	{
	  Idle.add (read_string_async.callback);
  yield;
	  read_string (str);
	}
	public string read_unparsed () throws GLib.Error {
	  return "";
	}
	public void write_stream (GLib.OutputStream stream) throws GLib.Error
	{
	  var istream = create_stream ();
	  stream.splice (istream, OutputStreamSpliceFlags.CLOSE_SOURCE, cancellable);
	}
	public async void write_stream_async (GLib.OutputStream stream) throws GLib.Error
	{
	  var istream = yield create_stream_async ();
	  yield stream.splice_async (istream, OutputStreamSpliceFlags.CLOSE_SOURCE, 0, cancellable);
	}
	public string write_string () throws GLib.Error {
  return document.libxml_to_string ();
	}
	public async string write_string_async () throws GLib.Error {
	  Idle.add (write_string_async.callback);
  yield;
  return write_string ();
	}
	public bool backup { get; set; }
	public bool indent { get; set; }
	public GXml.DomNode node { get { return _node; } }
	public Cancellable? cancellable { get; set; }
}

