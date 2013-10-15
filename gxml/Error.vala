namespace GXml {
	public errordomain Error {
		NOT_SUPPORTED, /* TODO: GET RID OF THIS */
		PARSER, WRITER;
	}

	// TODO: rename
	/**
	 * Returns error message for last registered error.
	 */
	internal static string get_last_error_msg () {
		Xml.Error* error = Xml.Error.get_last_error ();

		if (error == null)
			return "No error reported by libxml2";
		else
			return libxml2_error_to_string (error);
	}

	// TODO: replace usage of this with GXml.get_last_error_msg
	internal static string libxml2_error_to_string (Xml.Error *e) {
		return "%s:%s:%d: %s:%d: %s".printf (
			e->level.to_string ().substring (8 /* skipping XML_ERR_ */),
			e->domain.to_string ().substring (9 /* skipping XML_FROM_ */),
			e->code, e->file == null ? "<io>" : e->file, e->line, e->message);
	}
}