/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Implementation.vala
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
	/**
	 * Describes the features available in this
	 * implementation of the DOM.
	 *
	 * This can be accessed from a {@link GXml.Document}
	 * object. Provided a possible feature and the feature's
	 * version, it can tell the client whether it is here
	 * implemented.
	 *
	 * Version: DOM Level 1 Core
	 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-102161490]]
	 */
	public class Implementation {
		internal Implementation () {
		}

		private void check_namespace (string? namespace_uri, string? qualified_name) {
			if (qualified_name == null && namespace_uri != null) {
				GXml.warning (DomException.NAMESPACE, "qualified_name is null but namespace_uri [%s] is not.  Both should either be null or not null.".printf (namespace_uri));
			}
			if (qualified_name != null) {
				Document.check_invalid_characters (qualified_name, "new Document's root");

				string[] parts = qualified_name.split (":");
				if (parts.length == 2) {
					// we have a prefix!
					if (namespace_uri == null) {
						// but we don't have a namespace :|
						GXml.warning (DomException.NAMESPACE, "namespace_uri is null but qualified_name [%s] has prefixed part.  Both should either be null or not null.".printf (qualified_name));
					}

					string expected_uri = "http://www.w3.org/XML/1998/namespace";
					if (parts[0] == "xml" && namespace_uri != expected_uri) {
						GXml.warning (DomException.NAMESPACE, "qualified_name '%s' specifies namespace 'xml' but namespace_uri is '%s' and not '%s'".printf (qualified_name, namespace_uri, expected_uri));
					}
				}
			}
			// TODO: We should apparently also report a NAMESPACE_ERR if "the qualifiedName is malformed"; find out what that means
			if (namespace_uri != null && ! this.has_feature ("XML")) {
				// Right now, has_feature should always return true for 'XML' so we shouldn't trip this error
				GXml.warning (DomException.NAMESPACE, "Implementation lacks feature 'XML' but a namespace_uri ('%s') was specified anyway.".printf (namespace_uri));
			}
		}

		// Not using Node's, because this doctype shouldn't have ANY owner yet
		protected void check_wrong_document (DocumentType? doctype) {
			if (doctype != null && doctype.owner_document != null) {
				GXml.warning (DomException.WRONG_DOCUMENT, "The supplied doctype is already connected to an existing document.");
			}

		}

		/**
		 * Creates a Document according to this {@link GXml.Implementation}.
		 *
		 * Version: DOM Level 3 Core
		 * URL: [[http://www.w3.org/TR/DOM-Level-3-Core/core.html#Level-2-Core-DOM-createDocument]]

		 * @param namespace_uri URI for the namespace in which this Document belongs, or `null`.
		 * @param qualified_name A qualified name for the Document, or `null`.
		 * @param doctype The type of the document, or `null`.
		 *
		 * @return The new document.
		 */
		public Document create_document (string? namespace_uri, string? qualified_name, DocumentType? doctype) {
			Document doc;

			check_namespace (namespace_uri, qualified_name);
			check_wrong_document (doctype);
			// TODO: also want to report if the doctype was created by a different implementation; of which we have no way of determining right now

			doc = new Document.with_implementation (this, namespace_uri, qualified_name, doctype);
			return doc;
		}

		/**
		 * Reports whether we support a feature at a given version level.
		 *
		 * Version: DOM Level 1 Core
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-hasFeature]]
		 *
		 * TODO: implement more of this, using libxml2's parser.h's xmlGetFeature, xmlHasFeature, etc.
		 *
		 * @param feature A feature we might support, usually something like 'xml' or 'html'.
		 * @param version A possible version of the feature, or null if any version will do.
		 *
		 * @return true if we support the specified feature, false otherwise.
		 */
		public bool has_feature (string feature, string? version = null) {
			/* Level 1 is limited to "xml" and "html" (icase) */
			switch (feature) {
			case "xml": // TODO find better way to handle case insensitivity
			case "XML":
				switch (version) {
				case null:
				case "1.0":
					return true;
				default:
					return false;
				}
			case "html":
			case "HTML":
				// TODO: do we support HTML?
			default:
				/* TODO: add in libxml-2.0 (I already created a commented stub
				Xml.has_feature (feature);
				*/
				return false;
			}
		}
	}
}
