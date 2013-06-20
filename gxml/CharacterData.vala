/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* CharacterData.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011  Daniel Espinosa <esodan@gmail.com>
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
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

namespace GXml {
	/**
	 * CharacterData defines an interface for manipulating XML character data.
	 *
	 * It is used by the {@link GXml.CDATASection},
	 * {@link GXml.Text}, and {@link GXml.Comment} node types. For more,
	 * see:
	 * [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-FF21A306]]
	 */
	public class CharacterData : BackedNode {
		/**
		 * The character data in string form for the node.
		 * Generally equivalent to node_value.
		 */
		public string data {
			get {
				return this.node_value;
			}
			internal set {
				// TODO: should this not be private?
				this.node_value = value;
			}
		}
		/**
		 * The number of characters.
		 */
		public ulong length {
			get {
				return data.length;
			}
			private set {
			}
		}

		internal CharacterData (Xml.Node *char_node, Document doc) {
			base (char_node, doc);
			// TODO: if this was this (), it would recurse infinitely, maybe valac could detect that
		}
		/**
		 * Retrieves a substring of the character data
		 * count-characters long, starting from the character
		 * at offset.
		 */
		public string substring_data (ulong offset, ulong count) { // throws DomError
			// TODO: handle out of bounds
			return this.data.substring ((long)offset, (long)count);
		}
		/**
		 * Appends arg to the end of the character data.
		 */
		public void append_data (string arg) /* throws DomError */ {
			this.data = this.data.concat (arg);
		}
		/**
		 * Inserts arg into the character data at offset.
		 */
		public void insert_data (ulong offset, string arg) /* throws DomError */ {
			// TODO: complain about boundaries
			this.data = this.data.substring (0, (long)offset).concat (arg, this.data.substring ((long)offset));
		}
		/**
		 * Deletes a range of characters, count-characters long, starting from offset.
		 */
		public void delete_data (ulong offset, ulong count) /* throws DomError */ {
			this.data = this.data.substring (0, (long)offset).concat (this.data.substring ((long)(offset + count)));
		}
		/**
		 * Replaces a range of characters, count-characters
		 * long, starting at offset, with arg.
		 */
		public void replace_data (ulong offset, ulong count, string arg) /* throws DomError */ {
			// TODO: bounds
			this.data = this.data.substring (0, (long)offset).concat (arg, this.data.substring ((long)(offset + count)));
		}
	}
}
