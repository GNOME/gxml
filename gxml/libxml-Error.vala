namespace GXml {
	/**
	 * Errors for parse and writer.
	 */
	public errordomain Error {
		NOT_SUPPORTED, /* TODO: GET RID OF THIS */
		PARSER, WRITER;
	}

	// TODO: replace usage of this with GXml.get_last_error_msg
	internal static string libxml2_error_to_string (Xml.Error *e) {
		return _("%s:%s:%d: %s:%d: %s").printf (
			e->level.to_string ().replace ("XML_ERR_",""),
			e->domain.to_string ().replace ("XML_FROM_",""),
			e->code, e->file == null ? "<io>" : e->file, e->line, e->message);
	}
}
