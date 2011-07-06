/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class NodeListTest : GXmlTest {
	private static Element get_elem (string name) {
		return get_doc ().create_element (name);
	}

	public static void add_tests () {
		Test.add_func ("/gxml/nodelist/length", () => {
			});
	}
}
