/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Notation.vala
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
	// TODO: see if we can actually support these via libxml2, I can't seem to get to them through Xml.DTD
	/**
	 * Used in defining {@link GXml.DocumentType}s to declare the format of {@link GXml.Entity} and {@link GXml.ProcessingInstruction}s.
	 *
	 * Used collectively in defining DocumentTypes. A Notation can
	 * declare the format of unparsed entities or
	 * ProcessingInstruction targets.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-5431D1B9]]
	 */
	public class Notation : Node {
		// private Xml.Notation *notation; // TODO: wrap libxml's xmlNotation

		/**
		 * The declared name for the notation.
		 */
		public override string node_name {
			get {
				// TODO: needs to be set to the declared name of the notation
				return ""; // notation->name;
			}
			private set {
			}
		}
		/**
		 * The public identifier for the notation, or %NULL if not set.
		 */
		public string? public_id {
			get {
				return null; // notation->public_id;
			}
			private set {
			}
		}
		/**
		 * The system identifier for the notation, or %NULL if not set.
		 */
		public string? system_id {
			get {
				return null; // notation->system_id;
			}
			private set {
			}
		}
		internal Notation (/* Xml.Notation *notation, */ Document doc) {
			base (NodeType.NOTATION, doc); // STUB
			//this.notation = notation;
		}
	}

}
