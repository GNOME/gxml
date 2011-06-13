/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class AttrTest {
	private static Document get_doc () {
		Document doc = null;
		try {
			doc = new Document.for_path ("test.xml");
		} catch (DomError e) {
		}
		return doc;
	}

	private static Attr get_attr_new_doc (string name, string value) {
		return get_attr (name, value, get_doc ());
	}

	private static Attr get_attr (string name, string value, Document doc) {
		Attr attr = doc.create_attribute (name);
		attr.value = value;
		return attr;
	}

	private static Element get_elem (string name, Document doc) {
		Element elem = doc.create_element (name);
		return elem;
	}

	public static void add_attribute_tests () {
		Test.add_func ("/gdom/attribute/parent_node", () => {
				Document doc = get_doc ();
				Element elem = get_elem ("creature", doc);
				Attr attr = get_attr ("breed", "Dragons", doc);

				assert (attr.parent_node == null);
				elem.set_attribute_node (attr);
				assert (attr.parent_node == null);
			});
		Test.add_func ("/gdom/attribute/previous_sibling", () => {
				Document doc = get_doc ();
				Element elem = get_elem ("creature", doc);
				Attr attr1 = get_attr ("breed", "Dragons", doc);
				Attr attr2 = get_attr ("size", "large", doc);

				elem.set_attribute_node (attr1);
				elem.set_attribute_node (attr2);

				assert (attr1.previous_sibling == null);
				assert (attr2.previous_sibling == null);
			});
		Test.add_func ("/gdom/attribute/next_sibling", () => {
				Document doc = get_doc ();
				Element elem = get_elem ("creature", doc);
				Attr attr1 = get_attr ("breed", "Dragons", doc);
				Attr attr2 = get_attr ("size", "large", doc);

				elem.set_attribute_node (attr1);
				elem.set_attribute_node (attr2);

				assert (attr1.next_sibling == null);
				assert (attr2.next_sibling == null);
			});
	}
}