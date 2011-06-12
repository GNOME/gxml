/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public enum NodeType {
		/* NOTE: bug in vala?  if I don't have == 0, I fail when creating
		   this class because I can't set default values for NodeType properties
		   GLib-GObject-CRITICAL **: g_param_spec_enum: assertion `g_enum_get_value (enum_class, default_value) != NULL' failed */
		X_UNKNOWN = 0,
		ELEMENT = 1,
		ATTRIBUTE,
		TEXT,
		CDATA_SECTION,
		ENTITY_REFERENCE,
		ENTITY,
		PROCESSING_INSTRUCTION,
		COMMENT,
		DOCUMENT,
		DOCUMENT_TYPE,
		DOCUMENT_FRAGMENT,
		NOTATION;
	}
}