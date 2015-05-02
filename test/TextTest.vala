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

class TextTest : GXmlTest {
	public static void add_tests () {
		/* NOTE: GXml.Node name and node value behaviour tested by NodeTest */

		Test.add_func ("/gxml/text/split_text", () => {
				xDocument doc;
				xText txt1 = get_text_new_doc ("Constant vigilance!", out doc);
				xText txt2 = txt1.split_text (5);

				assert (txt1.node_value == "Const");
				assert (txt2.node_value == "ant vigilance!");

				/* TODO: libxml2 doesn't allow txt siblings, so for now
				   splitting text creates an unattached second Text
				   node.  It might still be useful if you wanted to insert
				   an element in between, like with HTML markup? */
				/*
				  assert (txt1.parent_node == txt2.parent_node);
				  assert (txt1.next_sibling == txt2);
				  assert (txt1 == txt2.previous_sibling);
				*/

				txt2 = txt1.split_text (0);
				assert (txt1.node_value == "");
				assert (txt2.node_value == "Const");

				txt1 = txt2.split_text (5);
				assert (txt1.node_value == "");
				assert (txt2.node_value == "Const");

				txt1 = txt2.split_text (-2);
				test_error (DomException.INDEX_SIZE);
				assert (txt1.node_value == ""); // TODO: decide if we want to return null instead
				assert (txt2.node_value == "Const");

				txt1 = txt2.split_text (10);
				test_error (DomException.INDEX_SIZE);
				assert (txt1.node_value == ""); // TODO: decide if we want to return null instead
				assert (txt2.node_value == "Const");
			});
	}
}
