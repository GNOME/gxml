/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* implements DomException
   note usage at:
   http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-BBACDC08 */

namespace GXml.Dom {
	public errordomain DomError {
		/* These error codes are from the IDL: TODO: find out when I should use them */
		/* TODO: probably want to document them :) */
		INDEX_SIZE_ERR, DOMSTRING_SIZE_ERR, HIERARCHY_REQUEST_ERR, WRONG_DOCUMENT_ERR, INVALID_CHARACTER_ERR, NO_DATA_ALLOWED_ERR,
		NO_MODIFICATION_ALLOWED_ERR, NOT_FOUND_ERR, NOT_SUPPORTED_ERR, INUSE_ATTRIBUTE_ERR,
		/* These error codes are mine, and should perhaps come from a separate domain */
		DOM, INVALID_DOC, INVALID_ROOT
	}
}