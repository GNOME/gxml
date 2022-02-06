/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* xNode.vala
 *
 * Copyright (C) 2015,2016  Yannick Inizan <inizan.yannick@gmail.com>
 * Copyright (C) 2015,2016  Daniel Espinosa <esodan@gmail.com>
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
 *      Yannick Inizan <inizan.yannick@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;
using Xml;

namespace GXml {
	/**
   * HML parsing support. Document handling
   */
	public class XHtmlDocument : XDocument, DomHtmlDocument {
		public static int default_options {
			get {
				return Html.ParserOption.NONET | Html.ParserOption.NOWARNING | Html.ParserOption.NOERROR | Html.ParserOption.NOBLANKS;
			}
		}

		public XHtmlDocument.from_path (string path, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_path (path), options);
		}

		public XHtmlDocument.from_uri (string uri, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_uri (uri), options);
		}

		/**
		 * This method parse strings in a {@link GLib.File} using {@link Html.Doc.read_memory} method.
		 * Refer to libxml2 documentation about limitations on parsing.
		 *
		 * In order to use a different parser, may you want to load in memory your file,
		 * then create a new {@link XHtmlDocument} using a constructor better fitting
		 * your document content or source.
		 */
		public XHtmlDocument.from_file (File file, int options = 0, Cancellable? cancel = null) throws GLib.Error {
			var istream = new GLib.DataInputStream (file.read ());
			string text = istream.read_upto ("\0", -1, null);
			this.from_string (text, options);
		}
		/**
		 * This method parse strings using {@link Html.Doc.read_memory} method.
		 * Refer to libxml2 documentation about limitations on parsing.
		 */
		public XHtmlDocument.from_string (string html, int options = 0) {
			base.from_doc (Html.Doc.read_memory ((char[]) html, html.length, "", null, options));
		}
		/**
		 * This method parse strings using {@link Html.ParserCtxt} class.
		 * Refer to libxml2 documentation about limitations on parsing.
		 */
		public XHtmlDocument.from_string_context (string html, int options = 0) {
			Html.ParserCtxt ctx = new Html.ParserCtxt ();
			Xml.Doc *doc = ctx.read_memory ((char[]) html, html.length, "", null, options);
			base.from_doc (doc);
		}
		/**
		 * This method parse strings using {@link Html.Doc.read_doc} method.
		 * Refer to libxml2 documentation about limitations on parsing.
		 */
		public XHtmlDocument.from_string_doc (string html, int options = 0) {
			base.from_doc (Html.Doc.read_doc (html, "", null, options));
		}
		// DomHtmlDocument implementation
		public void read_from_string (string str) {
			if (this.doc != null) {
				delete this.doc;
				this.doc = null;
			}

			this.doc = Html.Doc.read_memory ((char[]) str, str.length, "", null, 0);
		}

		public void read_from_string_tolerant (string str) throws GLib.Error {
			Html.ParserCtxt ctx = new Html.ParserCtxt ();
			if (this.doc != null) {
				delete this.doc;
				this.doc = null;
			}

			this.doc = ctx.read_memory ((char[]) str, str.length, "", null, 0);
		}
		public string to_html () throws GLib.Error {
			string buffer;
			int len = 0;
			((Html.Doc*) doc)->dump_memory (out buffer, out len);
			message (len.to_string ());
			return buffer.dup ();
		}

		public override string to_string () {
			string t = "";
			try {
				t = to_html ();
			} catch (GLib.Error e) {
				warning (_("Error while converting HTML document to string: %s"), e.message);
			}

			return t;
		} 
		/**
		 * Search all {@link GXml.Element} with a property called "class" and with a
		 * value as a class apply to a node.
		 *//*
		public GXml.DomElementList get_elements_by_class_name (string klass) {
			var rl = new GXml.DomElementList ();
			var l = root.get_elements_by_property_value ("class", klass);
			foreach (GXml.DomElement n in l) {
				var p = n.attributes.get ("class");
				if (p == null) continue;
				if (" " in p.node_value) {
					foreach (string ks in p.node_value.split (" ")) {
						if (ks == klass)
							rl.add (n);
					}
				} else if (klass == p.node_value) {
					rl.add (n);
				}
			}
			return rl;
		}*/
		/**
		 * Get first node where 'id' attribute has given value.
		 *//*
		public GXml.DomElement? get_element_by_id (string id) {
			var l = root.get_elements_by_property_value ("id", id);
			foreach (GXml.DomElement n in l) {
				var p = n.attributes.get ("id");
				if (p == null) continue;
				if (p.node_value == id) return (GXml.DomElement?) n;
			}
			return null;
		}*/
	}
}
