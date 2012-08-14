/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
// TODO: want a method to convert NodeType to a string

/**
 * Enumerates possible NodeTypes.
 *
 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1950641247]]
 */
public enum GXml.NodeType {
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
