/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* implements DomException
   note usage at:
   http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-BBACDC08 */

namespace GXml.Dom {
	public errordomain DomError {
		/* These error codes are from the IDL: TODO: find out when I should use them */
		/* TODO: probably want to document them :) */
		INDEX_SIZE, DOMSTRING_SIZE, HIERARCHY_REQUEST, WRONG_DOCUMENT, INVALID_CHARACTER, NO_DATA_ALLOWED,
		NO_MODIFICATION_ALLOWED, NOT_FOUND, NOT_SUPPORTED, INUSE_ATTRIBUTE,
		/* These error codes are mine, and should perhaps come from a separate domain */
		DOM, INVALID_DOC, INVALID_ROOT
	}
}