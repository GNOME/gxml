/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class GXmlTest {
	internal static void GXmlLogFunc (string? log_domain, LogLevelFlags log_levels, string message) {
		// Hush, we don't want to actually show errors; we'll be testing for those
	}

	internal static void test_error (GXml.DomException expected) {
		if (expected != GXml.last_error) {
			stderr.printf ("Expected last error [%s] but found [%s]", expected.to_string (), GXml.last_error.to_string ());
			Test.message ("Expected last error [%s] but found [%s]", expected.to_string (), GXml.last_error.to_string ());
			Test.fail ();
		}

		// clear it
		GXml.last_error = DomException.NONE;
	}

	public static int main (string[] args) {


		// Sets 29 as fatal flags, 16 + 8 + 4 + 1; bits 0,2,3,4, recursion,error,critical,warning; we'll want to undo that warning one so we can catch it
		Test.init (ref args);

		// silence warnings we'll be testing for
		GLib.Log.set_handler ("gxml", GLib.LogLevelFlags.LEVEL_WARNING, GXmlTest.GXmlLogFunc);
		GLib.Log.set_always_fatal (GLib.LogLevelFlags.FLAG_RECURSION | GLib.LogLevelFlags.LEVEL_ERROR | GLib.LogLevelFlags.LEVEL_CRITICAL);

		DocumentTest.add_tests ();
		NodeTest.add_tests ();
		ElementTest.add_tests ();
		AttrTest.add_tests ();
		NodeListTest.add_tests ();
		TextTest.add_tests ();
		CharacterDataTest.add_tests ();
		ValaLibxml2Test.add_tests ();
		SerializationTest.add_tests ();
		SerializableTest.add_tests ();
		SerializableObjectModelTest.add_tests ();
		SerializableGeeTreeMapTest.add_tests ();
		SerializableGeeHashMapTest.add_tests ();
		SerializableGeeDualKeyMapTest.add_tests ();
		SerializableGeeArrayListTest.add_tests ();
		SerializableGeeCollectionsTest.add_tests ();
		SerializableBasicTypeTest.add_tests ();
		SerializableEnumerationTest.add_tests ();

		Test.run ();

		return 0;
	}

	internal static Document get_doc (string? path = null) {
		Document doc = null;
		try {
			doc = new Document.from_path (path != null ? path :
						      get_test_dir () + "/test.xml");
		} catch (GXml.Error e) {
			GLib.warning (e.message);
			assert_not_reached ();
		}
		return doc;
	}

	internal static Document get_doc_with_ns () {
		return get_doc (get_test_dir () + "/test_with_ns.xml");
	}

	internal static string get_test_dir () {
		if (TEST_DIR == null || TEST_DIR == "") {
			return ".";
		} else {
			return TEST_DIR;
		}
	}

	// internal static Attr get_attr_new_doc (string name, string value) {
	// 	return get_attr (name, value, get_doc ());
	// }

	internal static Attr get_attr (string name, string value, Document doc) {
		Attr attr = doc.create_attribute (name);
		attr.value = value;
		return attr;
	}

	internal static Element get_elem_new_doc (string name, out Document doc) {
		return get_elem (name, doc = get_doc ());
	}

	internal static Element get_elem (string name, Document doc) {
		Element elem = doc.create_element (name);
		return elem;
	}

	internal static Text get_text_new_doc (string data, out Document doc) {
		return get_text (data, doc = get_doc ());
	}

	internal static Text get_text (string data, Document doc) {
		Text txt = doc.create_text_node (data);
		return txt;
	}
}
