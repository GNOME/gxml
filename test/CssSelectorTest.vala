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

class CssSelectorTest : GLib.Object {
	public static int main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/gxml/css-selector/all", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("*");
				assert (cp.selectors.size == 1);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ALL);
				var d = new GXml.Document ();
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
				var d = new GXml.Document ();
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
				cp.parse ("child[prop-name]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE);
				var d = new GXml.Document ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "val");
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
				cp.parse ("child[prop-name~=\"val\"]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_CONTAINS);
				var d = new GXml.Document ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "val calc soup");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "calc val soup");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "calc secondary soup");
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
				cp.parse ("child[prop-name^=\"val\"]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_STARTS_WITH);
				var d = new GXml.Document ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "val");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "value");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
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
		Test.add_func ("/gxml/css-selector/element/attribute/starts_with_word", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop-name|=\"val\"]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_STARTS_WITH_WORD);
				var d = new GXml.Document ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "val-");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "value");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (cp.match (c2));
				assert (!cp.match (c3));
				assert (!cp.match (c4));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/attribute/ends_with", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop-name$=\"val\"]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_ENDS_WITH);
				var d = new GXml.Document ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
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
		Test.add_func ("/gxml/css-selector/element/attribute-value-unquoted", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop-name=va7u3_unqu§ted]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_EQUAL);
				var d = new GXml.Document ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "t");
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "va7u3_unqu§ted");
				r.append_child (c3);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (!cp.match (c2));
				assert (cp.match (c3));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element/attribute-value", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child[prop-name=\"val\"]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_EQUAL);
				var d = new GXml.Document ();
				var r = d.create_element ("root");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "t");
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "val");
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
				assert (cp.selectors.size == 1);
				var si = cp.selectors[0];
				assert (si != null);
				assert (si.selector_type == CssSelectorType.CLASS);
				var d = new GXml.Document ();
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
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sc = cp.selectors[1];
				assert (sc != null);
				assert (sc.selector_type == CssSelectorType.CLASS);
				var d = new GXml.Document ();
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
		Test.add_func ("/gxml/css-selector/pseudo/root", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("toplevel:root");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.PSEUDO_CLASS);
				var d = new GXml.Document ();
				var r = d.create_element ("toplevel");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				assert (cp.match (r));
				assert (!cp.match (c1));
				assert (!cp.match (c2));
				assert (!cp.match (c3));
				assert (!cp.match (c4));
				var d2 = new XDocument () as DomDocument;
				var r2 = d2.create_element ("toplevel");
				d2.append_child (r2);
				var c1g = d2.create_element ("child");
				r2.append_child (c1g);
				var c2g = d2.create_element ("child");
				c2g.set_attribute ("prop-name", "subval");
				r2.append_child (c2g);
				var c3g = d2.create_element ("child");
				c3g.set_attribute ("prop-name", "techval");
				r2.append_child (c3g);
				var c4g = d2.create_element ("child");
				c4g.set_attribute ("prop-name", "secondaryvalue");
				r2.append_child (c4g);
				assert (cp.match (r));
				assert (!cp.match (c1g));
				assert (!cp.match (c2g));
				assert (!cp.match (c3g));
				assert (!cp.match (c4g));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/pseudo/non-hmtl/enable-disable-checked", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("radio[enable=\"true\"]");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.ATTRIBUTE_EQUAL);
				var d = new GXml.Document ();
				var r = d.create_element ("HTML");
				d.append_child (r);
				var c1 = d.create_element ("BODY");
				r.append_child (c1);
				var c2 = d.create_element ("radio");
				c2.set_attribute ("enable", "true");
				r.append_child (c2);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (cp.match (c2));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/pseudo/empty", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("child:empty");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.PSEUDO_CLASS);
				var d = new GXml.Document ();
				var r = d.create_element ("toplevel");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				var c5 = d.create_element ("common");
				c4.append_child (c5);
				assert (!c1.has_child_nodes ());
				assert (!c2.has_child_nodes ());
				assert (!c3.has_child_nodes ());
				assert (c4.has_child_nodes ());
				assert (!c5.has_child_nodes ());
				assert (!cp.match (r));
				assert (cp.match (c1));
				assert (cp.match (c2));
				assert (cp.match (c3));
				assert (!cp.match (c4));
				assert (!cp.match (c5));
				var d2 = new XDocument () as DomDocument;
				var r2 = d2.create_element ("toplevel");
				d2.append_child (r2);
				var c1g = d2.create_element ("child");
				r2.append_child (c1g);
				var c2g = d2.create_element ("child");
				c2g.set_attribute ("prop-name", "subval");
				r2.append_child (c2g);
				var c3g = d2.create_element ("child");
				c3g.set_attribute ("prop-name", "techval");
				r2.append_child (c3g);
				var c4g = d2.create_element ("child");
				c4g.set_attribute ("prop-name", "secondaryvalue");
				r2.append_child (c4g);
				var c5g = d2.create_element ("common");
				c4g.append_child (c5g);
				assert (!cp.match (r));
				assert (cp.match (c1g));
				assert (cp.match (c2g));
				assert (cp.match (c3g));
				assert (!cp.match (c4g));
				assert (!cp.match (c5g));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/pseudo/first-child", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("second:first-child");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.PSEUDO_CLASS);
				var d = new GXml.Document ();
				var r = d.create_element ("toplevel");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				var c5 = d.create_element ("second");
				c3.append_child (c5);
				var c6 = d.create_element ("second");
				c4.append_child (c6);
				assert (c1 == ((DomParentNode) c1.parent_node).first_element_child);
				assert (c2 != ((DomParentNode) c2.parent_node).first_element_child);
				assert (c3 != ((DomParentNode) c3.parent_node).first_element_child);
				assert (c4 != ((DomParentNode) c4.parent_node).first_element_child);
				assert (c5 == ((DomParentNode) c5.parent_node).first_element_child);
				assert (c6 == ((DomParentNode) c6.parent_node).first_element_child);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (!cp.match (c2));
				assert (!cp.match (c3));
				assert (!cp.match (c4));
				assert (cp.match (c5));
				assert (cp.match (c6));
				var d2 = new XDocument () as DomDocument;
				var r2 = d2.create_element ("toplevel");
				d2.append_child (r2);
				var c1g = d2.create_element ("child");
				r2.append_child (c1g);
				var c2g = d2.create_element ("child");
				c2g.set_attribute ("prop-name", "subval");
				r2.append_child (c2g);
				var c3g = d2.create_element ("child");
				c3g.set_attribute ("prop-name", "techval");
				r2.append_child (c3g);
				var c4g = d2.create_element ("child");
				c4g.set_attribute ("prop-name", "secondaryvalue");
				r2.append_child (c4g);
				var c5g = d2.create_element ("second");
				c3g.append_child (c5g);
				var c6g = d2.create_element ("second");
				c4g.append_child (c6g);
				assert (!cp.match (r));
				assert (!cp.match (c1g));
				assert (!cp.match (c2g));
				assert (!cp.match (c3g));
				assert (!cp.match (c4g));
				assert (cp.match (c5g));
				assert (cp.match (c6g));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/pseudo/last-child", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("second:last-child");
				assert (cp.selectors.size == 2);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				assert (s.combiner == CssCombiner.NONE);
				var sa = cp.selectors[1];
				assert (sa != null);
				assert (sa.selector_type == CssSelectorType.PSEUDO_CLASS);
				var d = new GXml.Document ();
				var r = d.create_element ("toplevel");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				var c5 = d.create_element ("second");
				c3.append_child (c5);
				var c6 = d.create_element ("second");
				c4.append_child (c6);
				var c7 = d.create_element ("second");
				c4.append_child (c7);
				assert (!cp.match (r));
				assert (!cp.match (c1));
				assert (!cp.match (c2));
				assert (!cp.match (c3));
				assert (!cp.match (c4));
				assert (cp.match (c5));
				assert (!cp.match (c6));
				assert (cp.match (c7));
				var d2 = new XDocument () as DomDocument;
				var r2 = d2.create_element ("toplevel");
				d2.append_child (r2);
				var c1g = d2.create_element ("child");
				r2.append_child (c1g);
				var c2g = d2.create_element ("child");
				c2g.set_attribute ("prop-name", "subval");
				r2.append_child (c2g);
				var c3g = d2.create_element ("child");
				c3g.set_attribute ("prop-name", "techval");
				r2.append_child (c3g);
				var c4g = d2.create_element ("child");
				c4g.set_attribute ("prop-name", "secondaryvalue");
				r2.append_child (c4g);
				var c5g = d2.create_element ("second");
				c3g.append_child (c5g);
				var c6g = d2.create_element ("second");
				c4g.append_child (c6g);
				var c7g = d2.create_element ("second");
				c4g.append_child (c7g);
				assert (!cp.match (r));
				assert (!cp.match (c1g));
				assert (!cp.match (c2g));
				assert (!cp.match (c3g));
				assert (!cp.match (c4g));
				assert (cp.match (c5g));
				assert (!cp.match (c6g));
				assert (cp.match (c7g));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element-namespace", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("namespace|second");
				assert (cp.selectors.size == 1);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var d = new GXml.Document ();
				var r = d.create_element ("toplevel");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				var c5 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c3.append_child (c5);
				var c6 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c4.append_child (c6);
				var c7 = d.create_element_ns ("http://gxml.org", "namespace:second");
				message (d.write_string ());
				assert (!cp.match (r));
				assert (cp.match (c5));
				assert (cp.match (c6));
				assert (cp.match (c7));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element-namespace/all", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("*|second");
				assert (cp.selectors.size == 1);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var d = new GXml.Document ();
				var r = d.create_element ("toplevel");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				var c5 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c3.append_child (c5);
				var c6 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c4.append_child (c6);
				var c7 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c4.append_child (c7);
				var c8 = d.create_element ("second");
				c4.append_child (c8);
				message (d.write_string ());
				assert (!cp.match (r));
				assert (cp.match (c5));
				assert (cp.match (c6));
				assert (cp.match (c7));
				assert (cp.match (c8));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});
		Test.add_func ("/gxml/css-selector/element-namespace/none", () => {
			try {
				var cp = new CssSelectorParser ();
				cp.parse ("|second");
				assert (cp.selectors.size == 1);
				var s = cp.selectors[0];
				assert (s != null);
				assert (s.selector_type == CssSelectorType.ELEMENT);
				var d = new GXml.Document ();
				var r = d.create_element ("toplevel");
				d.append_child (r);
				var c1 = d.create_element ("child");
				r.append_child (c1);
				var c2 = d.create_element ("child");
				c2.set_attribute ("prop-name", "subval");
				r.append_child (c2);
				var c3 = d.create_element ("child");
				c3.set_attribute ("prop-name", "techval");
				r.append_child (c3);
				var c4 = d.create_element ("child");
				c4.set_attribute ("prop-name", "secondaryvalue");
				r.append_child (c4);
				var c5 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c3.append_child (c5);
				var c6 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c4.append_child (c6);
				var c7 = d.create_element_ns ("http://gxml.org", "namespace:second");
				c4.append_child (c7);
				var c8 = d.create_element ("second");
				c4.append_child (c8);
				message (d.write_string ());
				assert (!cp.match (r));
				assert (!cp.match (c5));
				assert (!cp.match (c6));
				assert (!cp.match (c7));
				assert (cp.match (c8));
			} catch (GLib.Error e){
				warning ("ERROR: "+e.message);
			}
		});

		Test.run ();

		return 0;
	}
}
