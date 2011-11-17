/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* implements DomException
   note usage at:
   http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-BBACDC08 */
namespace GXmlDom {
	/**
	 * Describes various error states. For more, see
	 * [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-BBACDC08]]
	 */
	public errordomain DomError {
		/* These error codes are from the IDL: TODO: find out when I should use them */
		/* TODO: probably want to document them :) */
		/**
		 * An index or size is out of range, like less than 0 or exceeding some upper bound.
		 */
		INDEX_SIZE,
		/**
		 * Text exceeds the maximum size supported in our string implementation.
		 */ // TODO: figure out what the limits of strings are in vala
		DOMSTRING_SIZE,
		/**
		 * A node asked to be inserted into an invalid location.
		 */
		HIERARCHY_REQUEST,
		/**
		 * A node created for one document wanted to be used in another.
		 */
		WRONG_DOCUMENT,
		/**
		 * An invalid character was found in a name.
		 */ // TODO: which characters are invalid?
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
		INVALID_ROOT
	}
}
