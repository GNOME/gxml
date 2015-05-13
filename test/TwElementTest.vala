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
		Test.add_func ("/gxml/tw-element/namespaces/default", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", null);
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://www.gnome.org/gxml\">" in str);
		});
		Test.add_func ("/gxml/tw-element/namespaces/default-prefix", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", "gxml");
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns:gxml=\"http://www.gnome.org/gxml\">" in str);
		});
		Test.add_func ("/gxml/tw-element/namespaces/default-prefix-null", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", null);
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://www.gnome.org/gxml\">" in str);
		});
		Test.add_func ("/gxml/tw-element/namespaces/default/enable-prefix_default_ns", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", "gxml");
			d.prefix_default_ns = true;
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<gxml:root xmlns:gxml=\"http://www.gnome.org/gxml\">" in str);
		});
		Test.add_func ("/gxml/tw-element/multiple-namespaces", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			r.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("nons");
			e.childs.add (e2);
			e2.set_namespace ("http://www.gnome.org/", null);
			assert (e.namespaces.size == 1);
			assert (r.namespaces.size == 1);
			assert (e2.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns:gxml=\"http://git.gnome.org/browse/gxml\">" in str);
			assert ("</root>" in str);
			assert ("<dg:child xmlns:dg=\"http://developer.gnome.org/\">" in str);
			assert ("<nons xmlns=\"http://www.gnome.org/\"/>" in str);
		});
		Test.add_func ("/gxml/tw-element/multiple-namespaces/default", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.childs.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.childs.add (e3);
			e3.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e4 = d.create_element ("childrenons");
			e3.childs.add (e4);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (e4.namespaces.size == 0);
			assert (d.namespaces.size == 3);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://git.gnome.org/browse/gxml\">" in str);
			assert ("</root>" in str);
			assert ("<dg:child xmlns:dg=\"http://developer.gnome.org/\">" in str);
			assert ("<children/>" in str);
			assert ("<ns:nons xmlns:ns=\"http://www.gnome.org/\">" in str);
			assert ("<childrenons/>" in str);
			assert ("</ns:nons>" in str);
			assert ("</dg:child>" in str);
		});
		Test.add_func ("/gxml/tw-element/multiple-namespaces/enable-prefix_default_ns", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			d.prefix_default_ns = true;
			d.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			r.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("nons");
			e.childs.add (e2);
			e2.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (r.namespaces.size == 1);
			assert (e2.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e22 = d.create_element ("nonsd");
			e2.childs.add (e22);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<gxml:root xmlns:gxml=\"http://git.gnome.org/browse/gxml\">" in str);
			assert ("</gxml:root>" in str);
			assert ("<dg:child xmlns:dg=\"http://developer.gnome.org/\">" in str);
			assert ("<ns:nons xmlns:ns=\"http://www.gnome.org/\">" in str);
			assert ("</ns:nons>" in str);
			assert ("<gxml:nonsd/>" in str);
		});
		Test.add_func ("/gxml/tw-element/multiple-namespaces/default", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.childs.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.childs.add (e3);
			e3.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e4 = d.create_element ("childrenons");
			e3.childs.add (e4);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (e4.namespaces.size == 0);
			assert (d.namespaces.size == 3);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://git.gnome.org/browse/gxml\">" in str);
			assert ("</root>" in str);
			assert ("<dg:child xmlns:dg=\"http://developer.gnome.org/\">" in str);
			assert ("<children/>" in str);
			assert ("<ns:nons xmlns:ns=\"http://www.gnome.org/\">" in str);
			assert ("<childrenons/>" in str);
			assert ("</ns:nons>" in str);
			assert ("</dg:child>" in str);
		});
		Test.add_func ("/gxml/tw-element/multiple-namespaces/default/enable-ns_top", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			// All namespaces declaration should be on root node
			d.ns_top = true;
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.childs.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.childs.add (e3);
			e3.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e4 = d.create_element ("childrenons");
			e3.childs.add (e4);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (e4.namespaces.size == 0);
			assert (d.namespaces.size == 3);
			var c2 = d.create_element ("soup");
			d.root.childs.add (c2);
			// apply default namespace, should avoid prefix
			c2.set_namespace ("http://git.gnome.org/browse/gxml", null);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://git.gnome.org/browse/gxml\" xmlns:dg=\"http://developer.gnome.org/\" xmlns:ns=\"http://www.gnome.org/\">" in str);
			assert ("<soup/>" in str);
			assert ("</root>" in str);
			assert ("<dg:child>" in str);
			assert ("<children/>" in str);
			assert ("<ns:nons>" in str);
			assert ("<childrenons/>" in str);
			assert ("</ns:nons>" in str);
			assert ("</dg:child>" in str);
		});
		Test.add_func ("/gxml/tw-element/multiple-namespaces/default/enable-prefix_default_ns", () => {
			var d = new TwDocument ();
			var r = d.create_element ("root");
			d.childs.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			// All namespaces declaration should be on root node
			d.prefix_default_ns = true;
			var e = d.create_element ("child");
			r.childs.add (e);
			assert (d.namespaces.size == 1);
			var e2 = d.create_element ("children");
			e.childs.add (e2);
			var e3 = d.create_element ("nons");
			e.childs.add (e3);
			var e4 = d.create_element ("childrenons");
			e3.childs.add (e4);
			var c2 = d.create_element ("soup");
			d.root.childs.add (c2);
			c2.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<gxml:root xmlns:gxml=\"http://git.gnome.org/browse/gxml\">" in str);
			assert ("<gxml:soup/>" in str);
			assert ("</gxml:root>" in str);
			assert ("<gxml:child>" in str);
			assert ("<gxml:children/>" in str);
			assert ("<gxml:nons>" in str);
			assert ("<gxml:childrenons/>" in str);
			assert ("</gxml:nons>" in str);
			assert ("</gxml:child>" in str);
		});
	}
}
