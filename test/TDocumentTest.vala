/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
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

class TDocumentTest : GXmlTest {
	public class TTestObject : SerializableObjectModel
	{
		public string name { get; set; }
		public override string node_name () { return "Test"; }
		public override string to_string () { return "TestNode"; }
	}
	public static void add_tests () {
		Test.add_func ("/gxml/t-document", () => {
			try {
				var d = new TDocument ();
				assert (d.name == "#document");
				assert (d.root == null);
				assert (d.children != null);
				assert (d.attrs != null);
				assert (d.children.size == 0);
				assert (d.value == null);
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/root", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
				if (f.query_exists ()) f.delete ();
				var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
				var e = d.create_element ("root");
				d.children.add (e);
				assert (d.children.size == 1);
				assert (d.root != null);
				assert (d.root.name == "root");
				assert (d.root.value == "");
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/save/root", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					GLib.Test.message ("Saving document to: "+f.get_path ());
					assert (d.save ());
					GLib.Test.message ("Reading saved document to: "+f.get_path ());
					assert (f.query_exists ());
					var istream = f.read ();
					var ostream = new MemoryOutputStream.resizable ();
					ostream.splice (istream, 0);
					assert ("<?xml version=\"1.0\"?>" in ((string)ostream.data));
					assert ("<root/>" in ((string)ostream.data));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/save/root/attribute", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
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
		Test.add_func ("/gxml/t-document/save/root/content", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					var root = (GXml.Element) d.root;
					root.content = "GXml TDocument Test";
					assert (root.children.size == 1);
					assert (root.content == "GXml TDocument Test");
					var t = root.children.get (0);
					assert (t.value == "GXml TDocument Test");
					assert (t is GXml.Text);
					//GLib.message (@"$d");
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root" in ((string)buffer));
					assert (">GXml TDocument Test<" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/save/root/children", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					var root = (GXml.Element) d.root;
					var e1 = (GXml.Element) d.create_element ("child");
					e1.set_attr ("name","Test1");
					assert (e1.children.size == 0);
					root.children.add (e1);
					var e2 = (GXml.Element) d.create_element ("child");
					e2.set_attr ("name","Test2");
					assert (e2.children.size == 0);
					root.children.add (e2);
					assert (root.children.size == 2);
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
		Test.add_func ("/gxml/t-document/root/children-children", () => {
#if DEBUG
				GLib.message (@"TDocument root children/children...");
#endif
			try {
#if DEBUG
				GLib.message (@"Checking file to save to...");
#endif
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				if (f.query_exists ()) f.delete ();
#if DEBUG
				GLib.message (@"Creating Document...");
#endif
				var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				var e = d.create_element ("bookstore");
				d.children.add (e);
				assert (d.children.size == 1);
				assert (d.root != null);
				assert (d.root.name == "bookstore");
				assert (d.root.value == "");
				var r = (GXml.Element) d.root;
				r.set_attr ("name","The Great Book");
#if DEBUG
				GLib.message (@"Creating chidls...");
#endif
				for (int i = 0; i < 5000; i++){
					var b = (GXml.Element) d.create_element ("book");
					r.children.add (b);
					var aths = (GXml.Element) d.create_element ("Authors");
					b.children.add (aths);
					var ath1 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath1);
					var name1 = (GXml.Element) d.create_element ("Name");
					name1.content = "Fred";
					ath1.children.add (name1);
					var email1 = (GXml.Element) d.create_element ("Email");
					email1.content = "fweasley@hogwarts.co.uk";
					ath1.children.add (email1);
					var ath2 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath2);
					var name2 = (GXml.Element) d.create_element ("Name");
					name2.content = "Greoge";
					ath2.children.add (name2);
					var email2 = (GXml.Element) d.create_element ("Email");
					email2.content = "gweasley@hogwarts.co.uk";
					ath2.children.add (email2);
				}
				assert (d.root.children.size == 5000);
				foreach (GXml.Node n in d.root.children) {
					assert (n.children.size == 1);
					foreach (GXml.Node cn in n.children) {
						assert (cn.children.size == 2);
						foreach (GXml.Node ccn in cn.children) {
							assert (ccn.children.size == 2);
						}
					}
				}
			}
			catch (GLib.Error e) {
				GLib.message (@"ERROR: $(e.message)");
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/save/children-children", () => {
#if DEBUG
				GLib.message (@"TDocument root children/children...");
#endif
			try {
#if DEBUG
				GLib.message (@"Checking file to save to...");
#endif
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				if (f.query_exists ()) f.delete ();
#if DEBUG
				GLib.message (@"Creating Document...");
#endif
				var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				var e = d.create_element ("bookstore");
				d.children.add (e);
				assert (d.children.size == 1);
				assert (d.root != null);
				assert (d.root.name == "bookstore");
				assert (d.root.value == "");
				var r = (GXml.Element) d.root;
				r.set_attr ("name","The Great Book");
#if DEBUG
				GLib.message (@"Creating children...");
#endif
				for (int i = 0; i < 30000; i++){
					var b = (GXml.Element) d.create_element ("book");
					r.children.add (b);
					var aths = (GXml.Element) d.create_element ("Authors");
					b.children.add (aths);
					var ath1 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath1);
					var name1 = (GXml.Element) d.create_element ("Name");
					name1.content = "Fred";
					ath1.children.add (name1);
					var email1 = (GXml.Element) d.create_element ("Email");
					email1.content = "fweasley@hogwarts.co.uk";
					ath1.children.add (email1);
					var ath2 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath2);
					var name2 = (GXml.Element) d.create_element ("Name");
					name2.content = "Greoge";
					ath2.children.add (name2);
					var email2 = (GXml.Element) d.create_element ("Email");
					email2.content = "gweasley@hogwarts.co.uk";
					ath2.children.add (email2);
				}
				assert (d.root.children.size == 30000);
				d.save ();
				GLib.Test.message ("Reading saved file...");
				var fr = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				assert (fr.query_exists ());
				var ostream = new MemoryOutputStream.resizable ();
				ostream.splice (fr.read (), GLib.OutputStreamSpliceFlags.NONE);
				assert ("<?xml version=\"1.0\"?>" in ((string)ostream.data));
				assert ("<bookstore name=\"The Great Book\">" in ((string)ostream.data));
				assert ("<book>" in ((string)ostream.data));
				assert ("<Authors>" in ((string)ostream.data));
				assert ("<Author>" in ((string)ostream.data));
				f.delete ();
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/save/backup", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var ot = new TTestObject ();
					ot.name = "test1";
					var dt = new TDocument ();
					ot.serialize (dt);
					dt.save_as (f);
					var d = new TDocument ();
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					d.save_as (f);
					assert (f.query_exists ());
					var bf = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml~");
					assert (bf.query_exists ());
					var istream = f.read ();
					var b = new MemoryOutputStream.resizable ();
					b.splice (istream, 0);
					assert ("<?xml version=\"1.0\"?>" in ((string)b.data));
					assert ("<root/>" in ((string)b.data));
					f.delete ();
					bf.delete ();
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/to_string", () => {
			var doc = new TDocument ();
			var r = doc.create_element ("root");
			doc.children.add (r);
#if DEBUG
			GLib.message (@"$(doc)");
#endif
			string str = doc.to_string ();
			assert ("<?xml version=\"1.0\"?>" in str);
			assert ("<root/>" in str);
			assert ("<root/>" in doc.to_string ());
		});
		Test.add_func ("/gxml/t-document/namespace", () => {
				try {
					var doc = new TDocument ();
					doc.children.add (doc.create_element ("root"));
					doc.set_namespace ("http://www.gnome.org/GXml","gxml");
					Test.message ("ROOT: "+doc.to_string ());
					assert (doc.root != null);
					assert (doc.namespaces != null);
					assert (doc.namespaces.size == 1);
					assert (doc.namespaces[0].prefix == "gxml");
					assert (doc.namespaces[0].uri == "http://www.gnome.org/GXml");
					doc.root.children.add (doc.create_element ("child"));
					assert (doc.root.children != null);
					assert (doc.root.children.size == 1);
					var c = doc.root.children[0];
					c.set_namespace ("http://www.gnome.org/GXml2","gxml2");
					assert (c.namespaces != null);
					assert (c.namespaces.size == 1);
					assert (c.namespaces[0].prefix == "gxml2");
					assert (c.namespaces[0].uri == "http://www.gnome.org/GXml2");
					(c as Element).set_attr ("gxml:prop","val");
					var p = (c as Element).get_attr ("gxml:prop");
					assert (p == null);
					Test.message ("ROOT: "+doc.to_string ());
					string[] str = doc.to_string ().split("\n");
					assert (str[1] == "<root xmlns:gxml=\"http://www.gnome.org/GXml\"><gxml2:child xmlns:gxml2=\"http://www.gnome.org/GXml2\"/></root>");
					(c as Element).set_ns_attr (doc.namespaces[0], "prop", "Ten");
					Test.message ("ROOT: "+doc.root.to_string ());
					assert (c.attrs.size == 1);
					var pt = c.attrs.get ("prop");
					assert (pt != null);
					var pt2 = (c as Element).get_ns_attr ("prop", doc.namespaces[0].uri);
					str = doc.to_string ().split("\n");
					assert (str[1] == "<root xmlns:gxml=\"http://www.gnome.org/GXml\"><gxml2:child xmlns:gxml2=\"http://www.gnome.org/GXml2\" gxml:prop=\"Ten\"/></root>");
				} catch (GLib.Error e) {
					GLib.message ("ERROR: "+ e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/parent", () => {
			var doc = new TDocument ();
			assert (doc.parent == null);
		});
	}
}
