/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* DocumentType.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011,2015  Daniel Espinosa <esodan@gmail.com>
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

using Gee;

namespace GXml {
	/**
	 * Defines a xDocument, such as the entities that it can use.
	 * 
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-412266927]]
	 */
	public class xDocumentType : xNode, GXml.DocumentType {
		private Xml.Doc* doc;
		private Xml.Dtd *int_subset;
		private Xml.Dtd *ext_subset;

		/** Constructor */
		internal xDocumentType (Xml.Dtd *int_subset, Xml.Dtd *ext_subset, xDocument doc) {
			// TODO: for name, we want a real name of the doc type
			base (NodeType.DOCUMENT_TYPE, doc);

			this.doc = doc.xmldoc;
			this.int_subset = this.doc->int_subset;
			this.ext_subset = this.doc->ext_subset;
		}


		/* Public properties */

		/**
		 * That which follows DOCTYPE in the XML doctype
		 * declaration, like 'xml' or 'html'. For example, the
		 * document type name is 'html' for a document with
		 * the XML doctype declaration of
		 * {{{ <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> }}}
		 */
		public override string name {
			get {
				// TODO: is it possible for int_subset and ext_subset to have different names?
				return this.int_subset->name;
			}
		}

		/* TODO: make more static methods internal instead of public, if possible */
		internal static void myScannerFull (void *payload, void *userdata, string name1, string name2, string name3) {
			GLib.message ("scanner found [%s,%s,%s]", name1, name2, name3);
		}

		/* using GHashTable for XML's NamedNodeMap */
		/**
		 * A HashTable of entities defined for this DocumentType.
		 */
		// TODO: provide examples
		public Gee.Map<string,Entity>? entities {
			get {
				// TODO: need to create a HashTable<string,Entity> uniting these two
				//       discard duplicates
				// TODO: what type of hashtable is Xml.Dtd*'s entities?
				Xml.HashTable *table = Xmlx.doc_get_dtd_entities (this.doc);

				GLib.message ("About to scan for entities");
				table->scan_full ((Xml.HashScannerFull)myScannerFull, null);
				return null;
				// TODO: nuisance: libxml2 doesn't have entities wrapped
			}
			private set {
			}
		}
		/**
		 * A HashTable of notations defined for this DocumentType.
		 */
		// TODO: provide examples
		public Gee.Map<string,xNotation>? notations {
			get {
				// TODO: need to create a HashTable<string,xNotation> uniting the two
				//       discard duplicates
				// TODO: what type of hashtable is Xml.Dtd*'s notations?
				//Xml.HashTable *table =  this.int_subset->notations;
				return null;
				// TODO: nuisance: libxml2 doesn't have notations wrapped
			}
			private set {
			}
		}

	}
}
