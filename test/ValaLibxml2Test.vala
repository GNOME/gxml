/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXmlDom;

class ValaLibxml2Test : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/vala_libxml2/xmlHashTable", () => {
				try {
					Xml.HashTable *table = new Xml.HashTable (10);
					assert (table->size () == 0);
					table->add_entry ("maple", "syrup");
					assert (table->size () == 1);

					// new one should return 0, increase size
					assert (table->add_entry ("swiss", "cheese") == 0);
					assert (table->size () == 2);

					// duplicate should fail
					assert (table->add_entry ("swiss", "cheese") == -1);
					assert (table->size () == 2);

					// remove one, size should decrease
					assert (table->remove_entry ("maple", null) == 0);
					assert (table->size () == 1);

					// try removing it again, it shouldn't exist, should fail
					assert (table->remove_entry ("maple", null) == -1);
					assert (table->size () == 1);
					
					assert (table->lookup ("swiss") == "cheese");

					table->free (/* should pass it a string deallocator */ null);
					/* deallocator: takes (void *payload, string name), just frees payload */
					// TODO: figure out a way to test whether table was freed
				} catch (Error e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
	}
}