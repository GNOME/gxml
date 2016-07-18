/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
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

class HtmlDocumentTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/htmldocument/api/element_id", () => {
			try {
				var doc = new HtmlDocument.from_path (GXmlTestConfig.TEST_DIR+"/index.html");
				Test.message ("Checking root element...");
				assert (doc.root != null);
				assert (doc.root.name.down () == "html".down ());
				Test.message ("Searching for elemento with id 'user'...");
				var n = doc.get_element_by_id ("user");
				assert (n != null);
				assert (n.node_name == "p");
				assert (n is GXml.Element);
				assert (((GXml.Element) n).content == "");
			} catch (GLib.Error e){
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/htmldocument/api/element_class", () => {
			try {
				var doc = new HtmlDocument.from_path (GXmlTestConfig.TEST_DIR+"/index.html");
				Test.message ("Checking root element...");
				assert (doc.root != null);
				assert (doc.root.name.down () == "html".down ());
				Test.message ("Searching for element with property class and value app...");
				var np = doc.root.get_elements_by_property_value ("class","app");
				assert (np != null);
				assert (np.size == 2);
				Test.message ("Searching for elemento with class 'app'...");
				var l = doc.get_elements_by_class_name ("app");
				assert (l != null);
				assert (l.size == 2);
				bool fdiv, fp;
				fdiv = fp = false;
				foreach (GXml.DomElement e in l) {
					if (e.node_name == "div") fdiv = true;
					if (e.node_name == "p") fp = true;
				}
				assert (fdiv);
				assert (fp);
			} catch (GLib.Error e){
				Test.message ("ERROR: "+e.message);
				assert_not_reached ();
			}
		});
	}
}
