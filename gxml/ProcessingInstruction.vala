/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* ProcessingInstruction.vala
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
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

namespace GXml {
	// TODO: libxml2 doesn't seem to have PI objects, but does
	//       have a function to call when one is parsed.  Let's not
	//       worry about supporting this for right now.

	/**
	 * Stores processor-specific information with the document in
	 * a textual format.
	 *
	 * To create one, use {@link GXml.Document.create_processing_instruction}.
	 *
	 * For an example of a ProcessingInstruction, this one specifies a stylesheet:
	 * {{{&lt;?xml-stylesheet href="style.xsl" type="text/xml"?>}}}
	 *
	 * The general form is
	 * {{{&lt;?pi_target processing instruction data?>}}}
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1004215813]]
	 */
	public class ProcessingInstruction : DomNode {
		internal ProcessingInstruction (string target, string data, Document doc) {
			base (NodeType.PROCESSING_INSTRUCTION, doc); // TODO: want to pass a real Xml.Node* ?
			this.target = target;
			this.data = data;
		}

		/**
		 * The target for the processing instruction, like "xml-stylesheet".
		 */
		public string target {
			get;
			private set;
		}

		private string _data;

		/**
		 * The data used by the target, like {{{href="style.xsl" type="text/xml"}}}
		 */
		// TODO: confirm that data here is freeform attributes
		public string data /* throws DomError (not supported yet) */ {
			get {
				return _data;
			}
			set {
				this.check_read_only ();
				this._data = value;
			}
		}
		/**
		 * The target name.
		 */
		public override string node_name {
			get {
				return this.target;
			}
			private set {
			}
		}
		/**
		 * The target's data.
		 */
		public override string? node_value {
			get {
				return this.data;
			}
			private set {
			}
		}

	}
}
