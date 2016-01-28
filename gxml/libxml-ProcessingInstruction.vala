/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* ProcessingInstruction.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011-2015  Daniel Espinosa <esodan@gmail.com>
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
	 * To create one, use {@link GXml.xDocument.create_processing_instruction}.
	 *
	 * For an example of a ProcessingInstruction, this one specifies a stylesheet:
	 * {{{stylesheet href="style.xsl" type="text/xml"}}}
	 *
	 * The general form is
	 * {{{pi_target processing instruction data}}}
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1004215813]]
	 */
	public class xProcessingInstruction : xNode, GXml.ProcessingInstruction {
		string _target;
		string _data;
		internal xProcessingInstruction (string target, string data, xDocument doc) {
			base (NodeType.PROCESSING_INSTRUCTION, doc); // TODO: want to pass a real Xml.Node* ?
			this._target = target;
			this._data = data;
		}

		/**
		 * The target for the processing instruction, like "xml-stylesheet".
		 */
		public string target {
			owned get { return _target.dup (); }
		}

		/**
		 * The data used by the target, like {{{href="style.xsl" type="text/xml"}}}
		 */
		public string data /* throws DomError (not supported yet) */ {
			owned get {
				return _data.dup ();
			}
		}
		/**
		 * The target name.
		 */
		public override string node_name {
			get {
				return this._target;
			}
			private set {
			}
		}
		/**
		 * The target's data.
		 */
		public override string? node_value {
			get {
				return this._data;
			}
			private set {
			}
		}

	}
}
