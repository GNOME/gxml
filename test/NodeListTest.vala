/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class NodeListTest {
	private static Document get_doc () {
		Document doc = null;
		try {
			doc = new Document.for_path ("test.xml");
		} catch (DomError e) {
		}
		return doc;
	}

	private static Element get_elem (string name) {
		return get_doc ().create_element (name);
	}

	public static void add_tests () {
		Test.add_func ("/gxml/nodelist/length", () => {
			});
	}
}
