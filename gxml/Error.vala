namespace GXml {
	public errordomain Error {
		PARSER, WRITER;
	}

	internal static string libxml2_error_to_string (Xml.Error *e) {
		return "%s:%s:%d: %s:%d: %s".printf (
			e->level.to_string ().substring (8 /* skipping XML_ERR_ */),
			e->domain.to_string ().substring (9 /* skipping XML_FROM_ */),
			e->code, e->file == null ? "<io>" : e->file, e->line, e->message);
	}
}