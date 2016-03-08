/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* TCDATATest.vala
 *
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
 *      Daniel Espinosa <esodan@gmail.com>
 */

using GXml;

class TCDATATest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/tw-cdata", () => {
			try {
				var d = new TDocument ();
				var r = d.create_element ("root");
				d.children.add (r);
				var cd = d.create_cdata ("<test/>");
				assert (cd.value == "<test/>");
				d.root.children.add (cd);
				assert (d.root.children.size == 1);
				string str = d.to_string ();
				assert ("<root><![CDATA[<test/>]]></root>" in str);
#if DEBUG
				GLib.message (@"$d");
#endif
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
		});
	}
}
