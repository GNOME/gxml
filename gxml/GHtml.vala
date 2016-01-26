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

namespace GXml {
	public class HtmlDocument : GXml.xDocument {
		public static int default_options {
			get {
				return Html.ParserOption.NONET | Html.ParserOption.NOWARNING | Html.ParserOption.NOERROR | Html.ParserOption.NOBLANKS;
			}
		}
		
		public HtmlDocument.from_path (string path, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_path (path), options);
		}
		
		public HtmlDocument.from_uri (string uri, int options = 0) throws GLib.Error {
			this.from_file (File.new_for_uri (uri), options);
		}
		
		public HtmlDocument.from_file (File file, int options = 0, Cancellable? cancel = null) throws GLib.Error {
			uint8[] data;
			file.load_contents (cancel, out data, null);
			this.from_string ((string)data, options);
		}
		
		public HtmlDocument.from_string (string html, int options = 0) {
			base.from_libxml2 (Html.Doc.read_memory (html.to_utf8(), html.length, "", null, options));
		}
		/**
		 * Search all {@link GXml.Element} with a property called "class" and with a
		 * value as a class apply to a node.
		 */
		public Gee.List<GXml.Node> get_elements_by_class_name (string klass) {
			var rl = new Gee.ArrayList<GXml.Node> ();
			var l = root.get_elements_by_property_value ("class", klass);
			foreach (GXml.Node n in l) {
				var p = n.attrs.get ("class");
				if (p == null) continue;
				if (" " in p.value) {
					foreach (string ks in p.value.split (" ")) {
						if (ks == klass)
							rl.add (n);
					}
				} else if (klass == p.value) {
					rl.add (n);
				}
			}
			return rl;
		}
		/**
		 * Get first node where 'id' attribute has given value.
		 */
		public GXml.Node? get_element_by_id (string id) {
			var l = root.get_elements_by_property_value ("id", id);
			foreach (GXml.Node n in l) {
				var p = n.attrs.get ("id");
				if (p == null) continue;
				if (p.value == id) return n;
			}
			return null;
		}
	}
}
