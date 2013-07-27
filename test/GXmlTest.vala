/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class GXmlTest {
	internal static void GXmlLogFunc (string? log_domain, LogLevelFlags log_levels, string message) {
		stdout.printf ("log domain [%s] log_levels [%d] message [%s]\n", log_domain, log_levels, message);
		GXmlTest.last_warning = message;
	}

	internal static string last_warning = "";
	internal static void test_last_warning (string? match) {
		if (last_warning != match) {
			Test.message ("Expected last warning [%s] but found [%s]", match, last_warning);
			Test.fail ();
		}
		last_warning = null;
	}

	public static int main (string[] args) {


		// Sets 29 as fatal flags, 16 + 8 + 4 + 1; bits 0,2,3,4, recursion,error,critical,warning; we'll want to undo that warning one so we can catch it
		Test.init (ref args);

		GLib.Log.set_handler ("gxml", GLib.LogLevelFlags.LEVEL_WARNING, GXmlTest.GXmlLogFunc);
		GLib.Log.set_always_fatal (GLib.LogLevelFlags.FLAG_RECURSION | GLib.LogLevelFlags.LEVEL_ERROR | GLib.LogLevelFlags.LEVEL_CRITICAL);

		DocumentTest.add_tests ();
		DomNodeTest.add_tests ();
		ElementTest.add_tests ();
		AttrTest.add_tests ();
		NodeListTest.add_tests ();
		TextTest.add_tests ();
		CharacterDataTest.add_tests ();
		ValaLibxml2Test.add_tests ();
		SerializationTest.add_tests ();
		SerializableTest.add_tests ();

		Test.run ();

		return 0;
	}

	internal static Document get_doc () throws DomError {
		Document doc = null;
		try {
			doc = new Document.from_path (get_test_dir () + "/test.xml");
		} catch (DomError e) {
		}
		return doc;
	}

	internal static string get_test_dir () {
		if (TEST_DIR == null || TEST_DIR == "") {
			return ".";
		} else {
			return TEST_DIR;
		}
	}

	// internal static Attr get_attr_new_doc (string name, string value) throws DomError {
	// 	return get_attr (name, value, get_doc ());
	// }

	internal static Attr get_attr (string name, string value, Document doc) throws DomError {
		Attr attr = doc.create_attribute (name);
		attr.value = value;
		return attr;
	}

	internal static Element get_elem_new_doc (string name, out Document doc) throws DomError {
		return get_elem (name, doc = get_doc ());
	}

	internal static Element get_elem (string name, Document doc) throws DomError {
		Element elem = doc.create_element (name);
		return elem;
	}

	internal static Text get_text_new_doc (string data, out Document doc) throws DomError {
		return get_text (data, doc = get_doc ());
	}

	internal static Text get_text (string data, Document doc) {
		Text txt = doc.create_text_node (data);
		return txt;
	}
}
