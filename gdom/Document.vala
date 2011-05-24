/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class Document : Node {
		public DocumentType doctype {
			get;
			private set;
		}
		public Implementation implementation {
			get;
			private set;
		}
		public Element document_element {
			get;
			private set;
		}

		Element create_element (string tag_name) throws DomError {
			return null; // STUB
		}
		DocumentFragment create_document_fragment () {
			return null; // STUB
		}
		Text create_text_node (string data) {
			return null; // STUB
		}
		Comment create_comment (string data) {
			return null; // STUB
		}
		CDATASection create_cdata_section (string data) throws DomError {
			return null; // STUB
		}
		ProcessingInstruction create_processing_instruction (string target, string data) throws DomError {
			return null; // STUB
		}
		Attr create_attribute (string name) throws DomError {
			return null; // STUB
		}
		EntityReference create_entity_reference (string name) throws DomError {
			return null; // STUB
		}
		List<Node> get_elements_by_tag_name (string tagname) {
			return new List<Node> (); // STUB
		}
	}
}
