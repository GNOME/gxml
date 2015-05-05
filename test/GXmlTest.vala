/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* GXmlTest.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011-2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */
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
		NamespaceTest.add_tests ();
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
		Performance.add_tests ();
		TwDocumentTest.add_tests ();

		Test.run ();

		return 0;
	}

	internal static xDocument get_doc (string? path = null) {
		xDocument doc = null;
		try {
			doc = new xDocument.from_path (path != null ? path :
						      get_test_dir () + "/test.xml");
		} catch (GXml.Error e) {
			GLib.warning (e.message);
			assert_not_reached ();
		}
		return doc;
	}

	internal static xDocument get_doc_with_ns () {
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

	internal static Attr get_attr (string name, string value, xDocument doc) {
		Attr attr = doc.create_attribute (name);
		attr.value = value;
		return attr;
	}

	internal static xElement get_elem_new_doc (string name, out xDocument doc) {
		return get_elem (name, doc = get_doc ());
	}

	internal static xElement get_elem (string name, xDocument doc) {
		xElement elem = (xElement) doc.create_element (name);
		return elem;
	}

	internal static xText get_text_new_doc (string data, out xDocument doc) {
		return get_text (data, doc = get_doc ());
	}

	internal static xText get_text (string data, xDocument doc) {
		xText txt = doc.create_text_node (data);
		return txt;
	}
}
