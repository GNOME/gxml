/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* TwCDATATest.vala
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

class TwProcessingInstructionTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/tw-comment", () => {
			try {
				var d = new TwDocument ();
				var r = d.create_element ("root");
				d.childs.add (r);
				var pi = d.create_pi ("xslt","transform");
				assert (pi.name == "#processinginstruction");
				assert (pi.value == "transform");
				d.root.childs.add (pi);
				assert (d.root.childs.size == 1);
				string str = d.to_string ();
				assert ("<root><?xslt transform?></root>" in str);
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
