/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class CharacterDataTest : GXmlTest  {
	public static void add_tests () {
		Test.add_func ("/gxml/characterdata/data", () => {
				try {
					string str = "It does not do to dwell on dreams and forget to live, remember that.";
					Document doc;
					Text txt = get_text_new_doc (str, out doc);

					assert (txt.data == str);
					assert (txt.data == txt.node_value);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/characterdata/length", () => {
				try {
					string str = "After all, to the well-organized mind, death is but the next great adventure.";
					Document doc;
					Text txt = get_text_new_doc (str, out doc);

					assert (txt.length == str.length);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/characterdata/substring_data", () => {
				try {
					Document doc;
					Text txt = get_text_new_doc ("The trouble is, humans do have a knack of choosing precisely those things that are worst for them.", out doc);
					string str = txt.substring_data (4, 7);

					assert (str == "trouble");

					// TODO: test bounds
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/characterdata/append_data", () => {
				try {
					string str_start = "Never trust anything that can think for itself";
					string str_whole = "Never trust anything that can think for itself if you can't see where it keeps its brain.";
					Document doc;
					Text txt = get_text_new_doc ("Never trust anything that can think for itself", out doc);

					assert (txt.data == str_start);
					txt.append_data (" if you can't see where it keeps its brain.");
					assert (txt.data == str_whole);
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/characterdata/insert_data", () => {
				try {
					Document doc;
					Text txt = get_text_new_doc ("It is our choices that show what we are, far more than our abilities.", out doc);
					txt.insert_data (35, " truly");
					assert (txt.data == "It is our choices that show what we truly are, far more than our abilities.");
					// TODO: test bounds
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/characterdata/delete_data", () => {
				try {
					Document doc;
					Text txt = get_text_new_doc ("Happiness can be found, even in the darkest of times, if one only remembers to turn on the light.", out doc);
					txt.delete_data (14, 65);
					assert (txt.data == "Happiness can turn on the light.");
					// TODO: test bounds
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/characterdata/replace_data", () => {
				try {
					// TODO: test bounds

					Document doc;
					Text txt = get_text_new_doc ("In dreams, we enter a world that's entirely our own.", out doc);
					txt.replace_data (3, 6, "the refrigerator");
					assert (txt.data == "In the refrigerator, we enter a world that's entirely our own.");
				} catch (GXml.DomError e) {
					Test.message ("%s", e.message);
					assert_not_reached ();
				}
			});
	}
}
