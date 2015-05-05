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

class TwDocumentTest : GXmlTest {
	public static void add_tests () {
		Test.add_func ("/gxml/tw-document/root", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
				if (f.query_exists ()) f.delete ();
				var d = new TwDocument (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
				var e = d.create_element ("root");
				d.childs.add (e);
				assert (d.childs.size == 1);
				assert (d.root != null);
				assert (d.root.name == "root");
				assert (d.root.value == null);
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
			});
		Test.add_func ("/gxml/tw-document/save/root", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TwDocument (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					var e = d.create_element ("root");
					d.childs.add (e);
					assert (d.childs.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == null);
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root/>" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/tw-document/save/root/attribute", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TwDocument (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					var e = d.create_element ("root");
					d.childs.add (e);
					assert (d.childs.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == null);
					var root = (GXml.Element) d.root;
					root.set_attr ("Pos","on");
					var at1 = root.get_attr ("Pos");
					assert (at1 != null);
					assert (at1.value == "on");
					root.set_attr ("tKm","1000");
					var at2 = root.get_attr ("tKm");
					assert (at2 != null);
					assert (at2.value == "1000");
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root" in ((string)buffer));
					assert ("Pos=\"on\"" in ((string)buffer));
					assert ("tKm=\"1000\"" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/tw-document/save/root/content", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TwDocument (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					var e = d.create_element ("root");
					d.childs.add (e);
					assert (d.childs.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == null);
					var root = (GXml.Element) d.root;
					root.content = "GXml TwDocument Test";
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root" in ((string)buffer));
					assert (">GXml TwDocument Test<" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/tw-document/save/root/childs", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TwDocument (GXmlTestConfig.TEST_SAVE_DIR+"/tw-test.xml");
					var e = d.create_element ("root");
					d.childs.add (e);
					assert (d.childs.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == null);
					var root = (GXml.Element) d.root;
					var e1 = (GXml.Element) d.create_element ("child");
					e1.set_attr ("name","Test1");
					root.childs.add (e1);
					var e2 = (GXml.Element) d.create_element ("child");
					e2.set_attr ("name","Test2");
					root.childs.add (e2);
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root>" in ((string)buffer));
					assert ("</root>" in ((string)buffer));
					assert ("<child name=\"Test1\"/>" in ((string)buffer));
					assert ("<child name=\"Test2\"/>" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/tw-document/root/childs-childs", () => {
#if DEBUG
				GLib.message (@"TwDocument root childs/childs...");
#endif
			try {
#if DEBUG
				GLib.message (@"Checking file to save to...");
#endif
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-large.xml");
				if (f.query_exists ()) f.delete ();
#if DEBUG
				GLib.message (@"Creating Document...");
#endif
				var d = new TwDocument (GXmlTestConfig.TEST_SAVE_DIR+"/tw-large.xml");
				var e = d.create_element ("bookstore");
				d.childs.add (e);
				assert (d.childs.size == 1);
				assert (d.root != null);
				assert (d.root.name == "bookstore");
				assert (d.root.value == null);
				var r = (GXml.Element) d.root;
				r.set_attr ("name","The Great Book");
#if DEBUG
				GLib.message (@"Creating chidls...");
#endif
				for (int i = 0; i < 5000; i++){
					var b = (GXml.Element) d.create_element ("book");
					r.childs.add (b);
					var aths = (GXml.Element) d.create_element ("Authors");
					b.childs.add (aths);
					var ath1 = (GXml.Element) d.create_element ("Author");
					aths.childs.add (ath1);
					var name1 = (GXml.Element) d.create_element ("Name");
					name1.content = "Fred";
					ath1.childs.add (name1);
					var email1 = (GXml.Element) d.create_element ("Email");
					email1.content = "fweasley@hogwarts.co.uk";
					ath1.childs.add (email1);
					var ath2 = (GXml.Element) d.create_element ("Author");
					aths.childs.add (ath2);
					var name2 = (GXml.Element) d.create_element ("Name");
					name2.content = "Greoge";
					ath2.childs.add (name2);
					var email2 = (GXml.Element) d.create_element ("Email");
					email2.content = "gweasley@hogwarts.co.uk";
					ath2.childs.add (email2);
				}
				assert (d.root.childs.size == 5000);
				foreach (GXml.Node n in d.root.childs) {
					assert (n.childs.size == 1);
					foreach (GXml.Node cn in n.childs) {
						assert (cn.childs.size == 2);
						foreach (GXml.Node ccn in cn.childs) {
							assert (ccn.childs.size == 2);
						}
					}
				}
			}
			catch (GLib.Error e) {
				GLib.message (@"ERROR: $(e.message)");
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/tw-document/save/childs-childs", () => {
#if DEBUG
				GLib.message (@"TwDocument root childs/childs...");
#endif
			try {
#if DEBUG
				GLib.message (@"Checking file to save to...");
#endif
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/tw-large.xml");
				if (f.query_exists ()) f.delete ();
#if DEBUG
				GLib.message (@"Creating Document...");
#endif
				var d = new TwDocument (GXmlTestConfig.TEST_SAVE_DIR+"/tw-large.xml");
				var e = d.create_element ("bookstore");
				d.childs.add (e);
				assert (d.childs.size == 1);
				assert (d.root != null);
				assert (d.root.name == "bookstore");
				assert (d.root.value == null);
				var r = (GXml.Element) d.root;
				r.set_attr ("name","The Great Book");
#if DEBUG
				GLib.message (@"Creating chidls...");
#endif
				for (int i = 0; i < 30000; i++){
					var b = (GXml.Element) d.create_element ("book");
					r.childs.add (b);
					var aths = (GXml.Element) d.create_element ("Authors");
					b.childs.add (aths);
					var ath1 = (GXml.Element) d.create_element ("Author");
					aths.childs.add (ath1);
					var name1 = (GXml.Element) d.create_element ("Name");
					name1.content = "Fred";
					ath1.childs.add (name1);
					var email1 = (GXml.Element) d.create_element ("Email");
					email1.content = "fweasley@hogwarts.co.uk";
					ath1.childs.add (email1);
					var ath2 = (GXml.Element) d.create_element ("Author");
					aths.childs.add (ath2);
					var name2 = (GXml.Element) d.create_element ("Name");
					name2.content = "Greoge";
					ath2.childs.add (name2);
					var email2 = (GXml.Element) d.create_element ("Email");
					email2.content = "gweasley@hogwarts.co.uk";
					ath2.childs.add (email2);
				}
				assert (d.root.childs.size == 30000);
				d.save ();
				var istream = f.read ();
				uint8[] buffer = new uint8[2048];
				istream.read (buffer, null);
				istream.close ();
				assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
				assert ("<bookstore name=\"The Great Book\">" in ((string)buffer));
				assert ("<book>" in ((string)buffer));
				assert ("<Authors>" in ((string)buffer));
				assert ("<Author>" in ((string)buffer));
			}
			catch (GLib.Error e) {
				GLib.message (@"ERROR: $(e.message)");
				assert_not_reached ();
			}
		});
	}
}
