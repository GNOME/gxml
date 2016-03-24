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

class TElementTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/t-element/api", () => {
			try {
			var d = new TDocument ();
			var e = (Element) d.create_element ("element");
			d.children.add (e);
			assert (d.children.size == 1);
			assert (d.root.name == "element");
			e.set_attr ("attr1","val1");
			assert (d.root.attrs.get ("attr1") != null);
			assert (d.root.attrs.get ("attr1").value == "val1");
			assert (e.attrs.size == 1);
			assert (e.children.size == 0);
			var child = (Element) d.create_element ("child");
			assert (child != null);
			e.children.add (child);
			assert (e.children.size == 1);
			child.set_attr ("cattr1", "cval1");
			var c = (Element) e.children.get (0);
			assert (c != null);
			assert (c.name == "child");
			assert (c.attrs.get ("cattr1") != null);
			assert (c.attrs.get ("cattr1").value == "cval1");
			e.remove_attr ("cattr1");
			assert (e.attrs.size == 1);
			assert (e.attrs.get ("cattr1") == null);
			assert (c.content == "");
			c.content = "";
			assert (c.content == "");
			assert (c.children.size == 1);
			c.content = "HELLO CONTENT";
			assert (c.children.size == 1);
			assert (c.content == "HELLO CONTENT");
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/content", () => {
			try {
			var d = new TDocument ();
			var e = (Element) d.create_element ("element");
			d.children.add (e);
			assert (d.children.size == 1);
			assert (d.root.name == "element");
			e.content = "HELLO";
			assert (e.content == "HELLO");
			assert (d.root.children.size == 1);
			e.content = "TIME";
			assert (d.root.children.size == 1);
			assert (e.content == "TIME");
			var t = d.create_text (" OTHER");
			e.children.add (t);
			assert (e.children.size == 2);
			assert (d.root.children.size == 2);
			assert (e.content == "TIME OTHER");
			e.children.clear ();
			assert (e.children.size == 0);
			assert (e.content == "");
			var c = d.create_element ("child");
			e.children.add (c);
			e.content = "KNOW";
			assert (e.children.size == 2);
			assert (e.content == "KNOW");
			e.content = "";
			assert (e.children.size == 2);
			e.children.clear ();
			assert (e.content == "");
			var t1 = d.create_text ("TEXT1");
			var c1 = d.create_element ("child2");
			var t2 = d.create_text ("TEXT2");
			e.children.add (t1);
			e.children.add (c1);
			e.children.add (t2);
			assert (e.children.size == 3);
			assert (e.content == "TEXT1TEXT2");
			e.content = null;
			assert (e.children.size == 1);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/namespaces/default", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", null);
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://www.gnome.org/gxml\">" in str);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/namespaces/default-prefix", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", "gxml");
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns:gxml=\"http://www.gnome.org/gxml\">" in str);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/namespaces/default-prefix-null", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", null);
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://www.gnome.org/gxml\">" in str);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/namespaces/default/enable-prefix_default_ns", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Set default namespace
			d.set_namespace ("http://www.gnome.org/gxml", "gxml");
			d.prefix_default_ns = true;
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<gxml:root xmlns:gxml=\"http://www.gnome.org/gxml\">" in str);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			r.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			var e = d.create_element ("child");
			r.children.add (e);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("nons");
			e.children.add (e2);
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
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces/default/basic", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.children.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.children.add (e3);
			e3.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e4 = d.create_element ("childrenons");
			e3.children.add (e4);
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
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces/enable-prefix_default_ns", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			d.prefix_default_ns = true;
			d.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			r.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			var e = d.create_element ("child");
			r.children.add (e);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (r.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("nons");
			e.children.add (e2);
			e2.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (r.namespaces.size == 1);
			assert (e2.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e22 = d.create_element ("nonsd");
			e2.children.add (e22);
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
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces/default/1", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.children.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.children.add (e3);
			e3.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e4 = d.create_element ("childrenons");
			e3.children.add (e4);
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
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces/default/enable-ns_top", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			// All namespaces declaration should be on root node
			d.ns_top = true;
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.children.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.children.add (e3);
			e3.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var e4 = d.create_element ("childrenons");
			e3.children.add (e4);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (e4.namespaces.size == 0);
			assert (d.namespaces.size == 3);
			var c2 = d.create_element ("soup");
			d.root.children.add (c2);
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
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces/child-default", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			// All namespaces declaration should be on root node
			d.ns_top = true;
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.children.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.children.add (e3);
			e3.set_namespace ("http://www.gnome.org/", null);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			// This child should use http://www.gnome.org/ namespace by default, no prefix
			var e4 = d.create_element ("childrenons");
			e3.children.add (e4);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (e4.namespaces.size == 0);
			assert (d.namespaces.size == 3);
			var c2 = d.create_element ("soup");
			d.root.children.add (c2);
			// apply default namespace, should avoid prefix
			c2.set_namespace ("http://git.gnome.org/browse/gxml", null);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://git.gnome.org/browse/gxml\" xmlns:dg=\"http://developer.gnome.org/\">" in str);
			assert ("<soup/>" in str);
			assert ("</root>" in str);
			assert ("<dg:child>" in str);
			assert ("<children/>" in str);
			assert ("<nons xmlns=\"http://www.gnome.org/\">" in str);
			assert ("<childrenons/>" in str);
			assert ("</nons>" in str);
			assert ("</dg:child>" in str);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces/child-default/enable-prefix_default_ns", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", null);
			d.prefix_default_ns = true;
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			e.set_namespace ("http://developer.gnome.org/", "dg");
			assert (e.namespaces.size == 1);
			assert (d.namespaces.size == 2);
			var e2 = d.create_element ("children");
			e.children.add (e2);
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (d.namespaces.size == 2);
			var e3 = d.create_element ("nons");
			e.children.add (e3);
			e3.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			// This child should use http://www.gnome.org/ namespace by default, no prefix
			var e4 = d.create_element ("childrenons");
			e3.children.add (e4);
			e4.set_namespace ("http://www.gnome.org/", "ns");
			assert (e.namespaces.size == 1);
			assert (e2.namespaces.size == 0);
			assert (e3.namespaces.size == 1);
			assert (e4.namespaces.size == 1);
			assert (d.namespaces.size == 3);
			var c2 = d.create_element ("soup");
			d.root.children.add (c2);
			// apply default namespace, should avoid prefix
			c2.set_namespace ("http://git.gnome.org/browse/gxml", null);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns=\"http://git.gnome.org/browse/gxml\">" in str);
			assert ("<soup/>" in str);
			assert ("</root>" in str);
			assert ("<dg:child xmlns:dg=\"http://developer.gnome.org/\">" in str);
			assert ("<children/>" in str);
			assert ("<ns:nons xmlns:ns=\"http://www.gnome.org/\">" in str);
			assert ("<ns:childrenons/>" in str);
			assert ("</ns:nons>" in str);
			assert ("</dg:child>" in str);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/multiple-namespaces/default/enable-prefix_default_ns", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			// All namespaces declaration should be on root node
			d.prefix_default_ns = true;
			var e = d.create_element ("child");
			r.children.add (e);
			assert (d.namespaces.size == 1);
			var e2 = d.create_element ("children");
			e.children.add (e2);
			var e3 = d.create_element ("nons");
			e.children.add (e3);
			var e4 = d.create_element ("childrenons");
			e3.children.add (e4);
			var c2 = d.create_element ("soup");
			d.root.children.add (c2);
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
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/attr-namespace/default", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			d.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			var c = (Element) d.create_element ("child");
			r.children.add (c);
			c.set_attr ("at","val");
			var a = c.get_attr ("at");
			assert (a != null);
#if DEBUG
			GLib.message (@"$d");
#endif
			a.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			assert (a.namespaces.size == 1);
			assert (d.namespaces.size == 1);
			string str = d.to_string ();
#if DEBUG
			GLib.message (@"$d");
#endif
			assert ("<root xmlns:gxml=\"http://git.gnome.org/browse/gxml\">" in str);
			assert ("<child gxml:at=\"val\"/>" in str);
			assert ("</root>" in str);
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/attr-namespace/same-name", () => {
			try {
			var d = new TDocument ();
			var r = d.create_element ("root");
			d.children.add (r);
			// Default NS
			r.set_namespace ("http://git.gnome.org/browse/gxml", "gxml");
			var ns = new TNamespace (d, "http://books.net", "book");
			r.set_namespace (ns.uri, ns.prefix);
			var c = d.create_element ("child") as Element;
			r.children.add (c);
			c.set_attr ("source","http://books.net/sources/1");
			assert (c.attrs.size == 1);
			c.set_ns_attr (ns, "source", "The History 2");
			assert (c.attrs.size == 2);
			var nsa = c.get_ns_attr ("source", "http://books.net");
			assert (nsa != null);
			assert (nsa.value == "The History 2");
			var nsat = c.attrs.get ("book:source");
			assert (nsat != null);
			assert (nsat.value == "The History 2");
			var a = c.attrs.get ("source");
			assert (a != null);
			assert (a.value == "http://books.net/sources/1");
//#if DEBUG
			GLib.message (@"$d");
//#endif
			} catch { assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-element/parent", () => {
			var doc = new TDocument ();
			var e = doc.create_element ("root");
			doc.children.add (e);
			var c = doc.create_element ("child");
			e.children.add (c);
			assert (e.children.size == 1);
			assert (e.children[0] != null);
			assert (e.children[0].name == "child");
			assert (c.parent != null);
			assert (doc.root != null);
			assert (doc.root.children[0] != null);
			assert (doc.root.children[0].name == "child");
			assert (doc.root.children[0].parent != null);
			assert (doc.root.children[0].parent.name == "root");
			assert (doc.root.parent == null);
		});
		Test.add_func ("/gxml/t-element/attribute/parent", () => {
			var doc = new TDocument ();
			var e = doc.create_element ("root");
			doc.children.add (e);
			var c = doc.create_element ("child");
			e.children.add (c);
			(e as GXml.Element).set_attr ("attr", "val");
			assert (doc.root != null);
			assert (doc.root.attrs["attr"] != null);
			assert (doc.root.attrs["attr"].parent != null);
			assert (doc.root.attrs["attr"].parent.name == "root");
		});
		Test.add_func ("/gxml/t-element/readtype", () => {
			try {
				var file = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR+"/t-read-test.xml");
				assert (file.query_exists ());
				var d = new TDocument ();
				TDocument.read_doc (d, file, null);
				assert (d.root != null);
				assert (d.root.children.size == 7);
				var n = d.root.children[6];
				assert (n != null);
				assert (n.name == "ReadTop");
				assert (n.children.size == 9);
				var nc = n.children[3];
				assert (nc != null);
				assert (nc.name == "Read");
				assert (nc.children.size == 2);
				// Remove all
				GLib.message ("Skiping nodes");
				TDocument.ReadTypeFunc f1 = (node, tr)=>{
					GLib.message ("ReadType check node: "+node.name);
					if (node.name == "NoRead" || node.name == "NoReadChild") {
						GLib.message ("Skiping node: "+node.name);
						return TDocument.ReadType.NEXT;
					}
					return TDocument.ReadType.CONTINUE;
				};
				var d2 = new TDocument ();
				TDocument.read_doc (d2, file, f1);
				assert (d2.root != null);
				assert (d2.root.children.size == 7);
				var n2 = d2.root.children[6];
				assert (n2 != null);
				assert (n2.name == "ReadTop");
				assert (n2.children.size == 4);
				GLib.message (@"$d2");
				var nc2 = n2.children[2];
				assert (nc2 != null);
				assert (nc2.name == "Read");
				assert (nc2.children.size == 1);
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
		});
	}
}
