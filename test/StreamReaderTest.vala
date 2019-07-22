/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* GXmlTest.vala
 *
 * Copyright (C) 2019  Daniel Espinosa <esodan@gmail.com>
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
 *      Daniel Espinosa <esodan@gmail.com>
 */
using GXml;

class GXmlTest {
	public static int main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/gxml/stream-reader", () => {
			string str = """<root p1="a" p2="b" ><child>ContentChild</child></root>""";
			var istream = new MemoryInputStream.from_data (str.data, null);
			var sr = new StreamReader (istream);
			try {
				var doc = sr.read ();
				message (doc.write_string ());
				message ((doc.document_element as GXml.Element).unparsed);
				message ((doc.document_element.child_nodes.item (0) as GXml.Element).unparsed);
				assert ((doc.document_element as GXml.Element).unparsed == """<root p1="a" p2="b" ></root>""");
				assert ((doc.document_element.child_nodes.item(0) as GXml.Element).unparsed == """<child>ContentChild</child>""");
			} catch (GLib.Error e) {
				warning ("Error: %s", e.message);
			}
		});
		Test.run ();

		return 0;
	}
}
