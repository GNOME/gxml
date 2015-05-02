/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* CharacterDataTest.vala
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

class CharacterDataTest : GXmlTest  {
	public static void add_tests () {
		Test.add_func ("/gxml/characterdata/data", () => {
				string str = "It does not do to dwell on dreams and forget to live, remember that.";
				xDocument doc;
				xText txt = get_text_new_doc (str, out doc);

				assert (txt.data == str);
				assert (txt.data == txt.node_value);
			});
		Test.add_func ("/gxml/characterdata/length", () => {
				string str = "After all, to the well-organized mind, death is but the next great adventure.";
				xDocument doc;
				xText txt = get_text_new_doc (str, out doc);

				assert (txt.length == str.length);
			});
		Test.add_func ("/gxml/characterdata/substring_data", () => {
				xDocument doc;
				xText txt = get_text_new_doc ("The trouble is, humans do have a knack of choosing precisely those things that are worst for them.", out doc);
				string str = txt.substring_data (4, 7);

				assert (str == "trouble");

				// TODO: test bounds
			});
		Test.add_func ("/gxml/characterdata/append_data", () => {
				string str_start = "Never trust anything that can think for itself";
				string str_whole = "Never trust anything that can think for itself if you can't see where it keeps its brain.";
				xDocument doc;
				xText txt = get_text_new_doc ("Never trust anything that can think for itself", out doc);

				assert (txt.data == str_start);
				txt.append_data (" if you can't see where it keeps its brain.");
				assert (txt.data == str_whole);
			});
		Test.add_func ("/gxml/characterdata/insert_data", () => {
				xDocument doc;
				xText txt = get_text_new_doc ("It is our choices that show what we are, far more than our abilities.", out doc);
				txt.insert_data (35, " truly");
				assert (txt.data == "It is our choices that show what we truly are, far more than our abilities.");

				txt.insert_data (0, "Yes.  ");
				assert (txt.data == "Yes.  It is our choices that show what we truly are, far more than our abilities.");

				txt.insert_data (txt.data.length, "  Indeed.");
				assert (txt.data == "Yes.  It is our choices that show what we truly are, far more than our abilities.  Indeed.");

				// should fail
				txt.insert_data (txt.data.length + 1, "  Perhaps.");
				assert (txt.data == "Yes.  It is our choices that show what we truly are, far more than our abilities.  Indeed.");

				// should fail
				txt.insert_data (-1, "  No.");
				assert (txt.data == "Yes.  It is our choices that show what we truly are, far more than our abilities.  Indeed.");
			});
		Test.add_func ("/gxml/characterdata/delete_data", () => {
				xDocument doc;
				xText txt = get_text_new_doc ("Happiness can be found, even in the darkest of times, if one only remembers to turn on the light.", out doc);
				txt.delete_data (14, 65);
				assert (txt.data == "Happiness can turn on the light.");
				// TODO: test bounds
			});
		Test.add_func ("/gxml/characterdata/replace_data", () => {
				// TODO: test bounds

				xDocument doc;
				xText txt = get_text_new_doc ("In dreams, we enter a world that's entirely our own.", out doc);
				txt.replace_data (3, 6, "the refrigerator");
				assert (txt.data == "In the refrigerator, we enter a world that's entirely our own.");
			});
	}
}
