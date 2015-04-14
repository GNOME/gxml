/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* EntityReference.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011, 2015  Daniel Espinosa <esodan@gmail.com>
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
/* TODO: do we need an EntityReference? find out what it's used for */
// TODO: figure out some way to represent this from libxml2, or handle it ourselves
//       may not even need it while based on libxml2
// It's possible that libxml2 already expands entity references and that this class
// won't be used
// TODO: make sure that character entity references (like the one used in the example above, are valid

namespace GXml {
	/**
	 * A reference to an unparsed {@link GXml.Entity}, like "&apos;" for an apostrophe.
	 * 
	 * To create one, use {@link GXml.Document.create_entity_reference}.
	 * 
	 * The entity name, e.g. "apos", is stored as the EntityReference's `node_name`.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-11C98490]]
	 */
	public class EntityReference : xNode {
		internal EntityReference (string refname, Document doc) {
			// TODO: may want to handle refname differently
			base (NodeType.ENTITY_REFERENCE, doc); // TODO: what should we pass up?
			this.node_name = refname;
		}
		// TODO: not sure if that's correct
		/**
		 * Stores the reference entity's name ("apos" for &apos;).
		 */
		public override string node_name {
			get;
			private set;
		}
	}
}
