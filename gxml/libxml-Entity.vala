/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Entity.vala
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

namespace GXml {
	/**
	 * The content referenced by an {@link GXml.EntityReference}, and defined
	 * in a {@link GXml.DocumentType}.
	 *
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-527DCFF2]]
	 */
	public class Entity : xNode {
		private Xml.Entity *entity;

		/**
		 * A public identifier for the entity. %NULL when unspecified.
		 */
		public string public_id {
			get {
				//return this.entity->external_id; // TODO: fix libxml2 wrapper
				return "";
			}
			private set {
			}
		}
		/**
		 * A system identifier for the entity. %NULL when unspecified.
		 */
		public string system_id {
			get {
				// return this.entity->system_id; // TODO: fix libxml2 wrapper
				return "";
			}
			private set {
			}
		}
		/**
		 * The notation name for this entity if it is
		 * unparsed. This is %NULL if the entity is parsed.
		 */
		public string notation_name {
			get {
				// parsed: return null
				// unparsed: related notation's name // TODO
				// TODO: how does libxml2 associate notations with entities?
				// STUB
				return "";
			}
			private set {
			}
		}

		internal Entity (Xml.Entity *entity, Document doc) {
			base (NodeType.ENTITY, doc);

			this.entity = entity;
		}

		/* Public properties (xNode-specific) */

		public override string node_name {
			get {
				// return this.entity->name; // TODO: breaking for some reason?
				return "";
			}
			internal set {
			}
		}


		public override xNode? parent_node {
			get {
				return this.owner_document.doctype;
				// TODO: could this be differen tfrom this.entity->parent?
			}
			internal set {}
		}

		// node_value == null

		public override NodeList? child_nodes {
			owned get {
				// TODO: always create a new one?
				//       probably not a good idea; want to create one local one
				return new EntityChildNodeList (this.entity, this.owner_document);
			}
			internal set {
			}
		}

		/* Public methods (xNode-specific) */
		public override unowned xNode? insert_before (xNode new_child, xNode? ref_child) {
			return this.child_nodes.insert_before (new_child, ref_child);
		}
		public override unowned xNode? replace_child (xNode new_child, xNode old_child) {
			return this.child_nodes.replace_child (new_child, old_child);
		}
		public override unowned xNode? remove_child (xNode old_child) {
			return this.child_nodes.remove_child (old_child);
		}
		public override unowned xNode? append_child (xNode new_child) {
			return this.child_nodes.append_child (new_child);
		}
		public override bool has_child_nodes () {
			return (this.child_nodes.length > 0);
		}
		public override unowned xNode? clone_node (bool deep) {
			GLib.warning ("Cloning of Entity not yet supported");
			return this; // STUB
		}

	}
}
