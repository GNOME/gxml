/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* DomException.vala
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
	 * Last error exception for DOM.
	 */
	public static DomException last_error = DomException.NONE;

	/**
	 * Log DOM exception warnings.
	 * 
	 * @param exception rised
	 * @param message message to log
	 */
	[Version (deprecated=true, deprecated_since="0.8.1", replacement="exeption")]
	public static void warning (GXml.DomException ex, string message) {
		GXml.exception (ex, message);
	}

	/**
	 * Log DOM exception warnings.
	 * 
	 * @param exception rised
	 * @param message message to log
	 */
	[Version (deprecated=true, deprecated_since="0.12", replacement="GLib.Error per methods")]
	public static void exception (GXml.DomException ex, string message) {
		GXml.last_error = ex;	
#if DEBUG
		GLib.warning ("%s", message);
#endif
	}

	/**
	 * Describes various error states. For more, see
	 * 
	 * Version: DOM Level 1 Core<<BR>>
	 * URL: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-BBACDC08]]
	 */
	public enum DomException {
		/**
		 * Indicates that there has not been a recent error
		 */
		NONE,

		/* These error codes are from the IDL: TODO: find out when I should use them */
		/* TODO: probably want to document them :) */
		/**
		 * An index or size is out of range, like less than 0 or exceeding some upper bound.
		 */
		INDEX_SIZE,
		// TODO: figure out what the limits of strings are in vala
		/**
		 * Text exceeds the maximum size supported in our string implementation.
		 */
		DOMSTRING_SIZE,
		/**
		 * A node asked to be inserted into an invalid location.
		 */
		HIERARCHY_REQUEST,
		/**
		 * A node created for one document wanted to be used in another.
		 */
		WRONG_DOCUMENT,
		// TODO: which characters are invalid?
		/**
		 * An invalid character was found in a name.
		 */
		INVALID_CHARACTER,
		/**
		 * Tried to specify data for a node that did not support it.
		 */
		NO_DATA_ALLOWED,
		/**
		 * Attempted to modify a read-only node.
		 */
		NO_MODIFICATION_ALLOWED,
		/**
		 * A reference to a non-existent node was made.
		 */
		NOT_FOUND,
		/**
		 * A request was made for something that this implementation does not support.
		 */
		NOT_SUPPORTED,
		/**
		 * An element tried to make use of an attribute already attached to another element.
		 */
		INUSE_ATTRIBUTE,

		/* These error codes are mine,
		   and should perhaps come from a separate domain */
		/**
		 * Generic error in creating the DOM.
		 */
		DOM,
		/**
		 * A document could not be parsed due to invalid XML.
		 */
		INVALID_DOC,
		/**
		 * A document lacked a root element.
		 */
		INVALID_ROOT,

		/**
		 * There was an issue with the namespace.  A qualified name's prefix may have disagreed with the corresponding namespace or vice versa.
		 *
		 * Version: DOM Level 3 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/DOM-Level-3-Core/core.html#DOMException-NAMESPACE_ERR]]
		 */
		NAMESPACE,
		//TODO: consider better naming for this
		/**
		 * Non-DOM error
		 */
		X_OTHER;
	}
}

