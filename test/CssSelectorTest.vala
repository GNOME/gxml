/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
 *
 * Copyright (C) 2017  Daniel Espinosa <esodan@gmail.com>
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

class CssSelectorTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/css-selector/all", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("*");
				assert (cp.selectors.size == 1);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ALL);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				assert (cp.match (r));
				assert (cp.match (c1));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/node", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child");
				assert (cp.selectors.size == 1);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				assert (!cp.match (r));
				assert (cp.match (c1));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/attribute/value", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop]");
				foreach (CssSelectorData sel in cp.selectors) {
					message ("Type: "+sel.selector_type.to_string ()+" : "+sel.data+" : "+sel.value);
				}
				assert (cp.selectors.size == 3);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var si = cp.selectors[1];
				assert (si != null);
				assert (si.selector_type == CssSelectorType.INSIDE);
				var sa = cp.selectors[2];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop", "val");
				r.append_child (c2);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (cp.match (c2));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/attribute/contains", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop~=\"val\"]");
				foreach (CssSelectorData sel in cp.selectors) {
					message ("Type: "+sel.selector_type.to_string ()+" : "+sel.data+" : "+sel.value);
				}
				assert (cp.selectors.size == 3);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var si = cp.selectors[1];
				assert (si != null);
				assert (si.selector_type == CssSelectorType.INSIDE);
				var sa = cp.selectors[2];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_CONTAINS);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop", "val calc soup");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop", "calc val soup");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop", "calc secondary soup");
				r.append_child (c4);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (cp.match (c2));
				assert (cp.match (c3));
				assert (!cp.match (c4));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/attribute/starts_with", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop^=\"val\"]");
				foreach (CssSelectorData sel in cp.selectors) {
					message ("Type: "+sel.selector_type.to_string ()+" : "+sel.data+" : "+sel.value);
				}
				assert (cp.selectors.size == 3);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var si = cp.selectors[1];
				assert (si != null);
				assert (si.selector_type == CssSelectorType.INSIDE);
				var sa = cp.selectors[2];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_START_WITH);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop", "val");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop", "value");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop", "secondaryvalue");
				r.append_child (c4);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (cp.match (c2));
				assert (cp.match (c3));
				assert (!cp.match (c4));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/attribute-value", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop=\"val\"]");
				foreach (CssSelectorData sel in cp.selectors) {
					message ("Type: "+sel.selector_type.to_string ()+" : "+sel.data+" : "+sel.value);
				}
				assert (cp.selectors.size == 3);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var si = cp.selectors[1];
				assert (si != null);
				assert (si.selector_type == CssSelectorType.INSIDE);
				var sa = cp.selectors[2];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_EQUAL);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop", "t");
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop", "val");
				r.append_child (c3);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (!cp.match (c2));
				assert (cp.match (c3));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/class-only", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse (".warning");
				foreach (CssSelectorData sel in cp.selectors) {
					message ("Type: "+sel.selector_type.to_string ()+" : "+sel.data+" : "+sel.value);
				}
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.INSIDE);
				var si = cp.selectors[1];
				assert (si != null);
				assert (si.selector_type == CssSelectorType.CLASS);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				c1.set_attribute ("class", "error");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("class", "warning");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("class", "error warning");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("class", "error calc");
				r.append_child (c4);
				var c5 = d.create_element ("child");
				r.append_child (c5);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (cp.match (c2));
				assert (cp.match (c3));
				assert (!cp.match (c4));
				assert (!cp.match (c5));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/class-element", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child.warning");
				foreach (CssSelectorData sel in cp.selectors) {
					message ("Type: "+sel.selector_type.to_string ()+" : "+sel.data+" : "+sel.value);
				}
				assert (cp.selectors.size == 3);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var si = cp.selectors[1];
				assert (si != null);
				assert (si.selector_type == CssSelectorType.INSIDE);
				var sc = cp.selectors[2];
				assert (sc != null);
				assert (sc.selector_type == CssSelectorType.CLASS);
				var d = new GomDocument ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("children");
				c1.set_attribute ("class", "error");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("class", "warning");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("class", "error warning");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("class", "error calc");
				r.append_child (c4);
				var c5 = d.create_element ("child");
				r.append_child (c5);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (cp.match (c2));
				assert (cp.match (c3));
				assert (!cp.match (c4));
				assert (!cp.match (c5));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
	}
}
