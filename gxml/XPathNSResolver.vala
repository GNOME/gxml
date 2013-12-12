/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* XPathNSResolver.vala
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
namespace GXml.XPath {

	/**
	 * Structure used for bounding prefixes with namespace URIs.
	 *
	 * [[http://www.w3.org/TR/2004/NOTE-DOM-Level-3-XPath-20040226/xpath.html#XPathNSResolver]]
	 */
	public class NSResolver : Gee.TreeMap<string, string> {

		/**
		 * Creates namespace resolver with prefix to URI mapping provided as flat
		 * array of strings (first element is prefix, second is namespace URI for
		 * that prefix, then another prefix and so on).
		 */
		public NSResolver (string? prefix1 = null, ...) {
			var l = va_list ();
			string? prefix = prefix1; /* One implicit argument is required */
			string? uri = l.arg ();

			base ();

			while (true) {
				if (prefix == null || uri == null)
					break;
				this[prefix] = uri;
				prefix = l.arg ();
				if (prefix == null)
					break;
				uri = l.arg ();
			}
		}

		/**
		 * Returns the associated namespace URI or null if none is found.
		 */
		public string? lookup_namespace_uri (string prefix) {
			return this[prefix];
		}

	}
}
