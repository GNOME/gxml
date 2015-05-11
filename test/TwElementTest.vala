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

class TwElementTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/tw-element/api", () => {
			var d = new TwDocument ();
			var e = (Element) d.create_element ("element");
			d.childs.add (e);
			assert (d.childs.size == 1);
			assert (d.root.name == "element");
			e.set_attr ("attr1","val1");
			assert (d.root.attrs.get ("attr1") != null);
			assert (d.root.attrs.get ("attr1").value == "val1");
			assert (e.attrs.size == 1);
			assert (e.childs.size == 0);
			var child = (Element) d.create_element ("child");
			assert (child != null);
			e.childs.add (child);
			assert (e.childs.size == 1);
			child.set_attr ("cattr1", "cval1");
			var c = (Element) e.childs.get (0);
			assert (c != null);
			assert (c.name == "child");
			assert (c.attrs.get ("cattr1") != null);
			assert (c.attrs.get ("cattr1").value == "cval1");
			assert (c.content == "");
			c.content = "";
			assert (c.content == "");
			assert (c.childs.size == 1);
			c.content = "HELLO CONTENT";
			assert (c.childs.size == 1);
			assert (c.content == "HELLO CONTENT");
		});
		Test.add_func ("/gxml/tw-element/content", () => {
			var d = new TwDocument ();
			var e = (Element) d.create_element ("element");
			d.childs.add (e);
			assert (d.childs.size == 1);
			assert (d.root.name == "element");
			e.content = "HELLO";
			assert (e.content == "HELLO");
			assert (d.root.childs.size == 1);
			e.content = "TIME";
			assert (d.root.childs.size == 1);
			assert (e.content == "TIME");
			var t = d.create_text (" OTHER");
			e.childs.add (t);
			assert (e.childs.size == 2);
			assert (d.root.childs.size == 2);
			assert (e.content == "TIME OTHER");
			e.childs.clear ();
			assert (e.childs.size == 0);
			assert (e.content == "");
			var c = d.create_element ("child");
			e.childs.add (c);
			e.content = "KNOW";
			assert (e.childs.size == 2);
			assert (e.content == "KNOW");
			e.content = "";
			assert (e.childs.size == 2);
			e.childs.clear ();
			assert (e.content == "");
			var t1 = d.create_text ("TEXT1");
			var c1 = d.create_element ("child2");
			var t2 = d.create_text ("TEXT2");
			e.childs.add (t1);
			e.childs.add (c1);
			e.childs.add (t2);
			assert (e.childs.size == 3);
			assert (e.content == "TEXT1TEXT2");
			e.content = null;
			assert (e.childs.size == 1);
		});
	}
}
