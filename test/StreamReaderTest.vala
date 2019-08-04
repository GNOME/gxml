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

class ContentNode : GXml.Element {
	string _val = null;
	public string val {
		get {
			 _val = text_content;
			 return _val;
		}
		set {
			 text_content = _val;
		}
	}
}

class Name : ContentNode {
	construct {
		try {
			initialize ("Name");
		} catch (GLib.Error e) {
			warning ("Error: %s", e.message);
		}
	}
}
class Email : ContentNode {
	construct {
		try {
			initialize ("Email");
		} catch (GLib.Error e) {
			warning ("Error: %s", e.message);
		}
	}
}

class Author : GXml.Element {
	public Name name { get; set; }
	public Email email { get; set; }
	construct {
		try {
			initialize ("Author");
		} catch (GLib.Error e) {
			warning ("Error: %s", e.message);
		}
	}
	public class Collection : GXml.ArrayList {
		construct {
			try {
				initialize (typeof (Author));
			} catch (GLib.Error e) {
				warning ("Error: %s", e.message);
			}
		}
	}
}

class Authors : GXml.Element {
	public Author.Collection authors { get; set; }
	construct {
		try {
			initialize ("Authors");
			set_instance_property ("authors");
		} catch (GLib.Error e) {
			warning ("Error: %s", e.message);
		}
	}
}

class Book : GXml.Element {
	[Description(nick="::year")]
	public int year { get; set; }
	[Description(nick="::ISBN")]
	public string ISBN { get; set; }
	public Authors authors { get; set; }
	construct {
		try {
			initialize ("Book");
		} catch (GLib.Error e) {
			warning ("Error: %s", e.message);
		}
	}
	public class Collection : GXml.ArrayList {
		construct {
			try {
				initialize (typeof (Book));
			} catch (GLib.Error e) {
				warning ("Error: %s", e.message);
			}
		}
	}
}

class BookStore : GXml.Element {
	public Name name { get; set; }
	public Book.Collection books { get; set; }
	construct {
		try {
			initialize ("BookStore");
			set_instance_property ("books");
		} catch (GLib.Error e) {
			warning ("Error: %s", e.message);
		}
	}
}
class Library : GXml.Document {
	[Description(nick="::ROOT")]
	public BookStore store { get; set; }
	public void read (string str) throws GLib.Error {
		var istream = new MemoryInputStream.from_data (str.data, null);
		var sr = new StreamReader (istream);
		sr.read_document (this);
	}
}

class GXmlTest {
	public static int main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/gxml/stream-reader/root", () => {
			string str = """<root p1="a" p2="b" ><child>ContentChild</child></root>""";
			var istream = new MemoryInputStream.from_data (str.data, null);
			var sr = new StreamReader (istream);
			try {
				var doc = sr.read ();
				message (doc.write_string ());
				var rootbuf = (string) (doc.document_element as GXml.Element).read_buffer.data;
				assert (doc.document_element.child_nodes.length > 0);
				var childbuf = (string) (doc.document_element.child_nodes.item (0) as GXml.Element).read_buffer.data;
				message (rootbuf);
				message (childbuf);
				assert (rootbuf == """<root p1="a" p2="b" ></root>""");
				assert (childbuf == """<child>ContentChild</child>""");
			} catch (GLib.Error e) {
				warning ("Error: %s", e.message);
			}
		});
		Test.add_func ("/gxml/stream-reader/child", () => {
			string str = """<root p1="a" p2="b" ><child k="p" y="9"><code/></child></root>""";
			var istream = new MemoryInputStream.from_data (str.data, null);
			var sr = new StreamReader (istream);
			try {
				var doc = sr.read ();
				message (doc.write_string ());
				var rootbuf = (string) (doc.document_element as GXml.Element).read_buffer.data;
				var childbuf = (string) (doc.document_element.child_nodes.item (0) as GXml.Element).read_buffer.data;
				message (rootbuf);
				message (childbuf);
				assert (rootbuf == """<root p1="a" p2="b" ></root>""");
				assert (childbuf == """<child k="p" y="9"><code/></child>""");
			} catch (GLib.Error e) {
				warning ("Error: %s", e.message);
			}
		});
		Test.add_func ("/gxml/stream-reader/child-multiple", () => {
			string str = """<root p1="a" p2="b" ><child k="p" y="9"><code/><code u="3">TestC</code><Tek/><Tex y="456"/></child></root>""";
			var istream = new MemoryInputStream.from_data (str.data, null);
			var sr = new StreamReader (istream);
			try {
				var doc = sr.read ();
				message (doc.write_string ());
				var rootbuf = (string) (doc.document_element as GXml.Element).read_buffer.data;
				var childbuf = (string) (doc.document_element.child_nodes.item (0) as GXml.Element).read_buffer.data;
				message (rootbuf);
				message (childbuf);
				assert (rootbuf == """<root p1="a" p2="b" ></root>""");
				assert (childbuf == """<child k="p" y="9"><code/><code u="3">TestC</code><Tek/><Tex y="456"/></child>""");
			} catch (GLib.Error e) {
				warning ("Error: %s", e.message);
			}
		});
		Test.add_func ("/gxml/stream-reader/xml-dec", () => {
			string str = """<?xml version="1.0"?>
<root p1="a" p2="b" ><child>ContentChild</child></root>""";
			var istream = new MemoryInputStream.from_data (str.data, null);
			var sr = new StreamReader (istream);
			try {
				var doc = sr.read ();
				message (doc.write_string ());
				var rootbuf = (string) (doc.document_element as GXml.Element).read_buffer.data;
				var childbuf = (string) (doc.document_element.child_nodes.item (0) as GXml.Element).read_buffer.data;
				message (rootbuf);
				message (childbuf);
				assert (rootbuf == """<root p1="a" p2="b" ></root>""");
				assert (childbuf == """<child>ContentChild</child>""");
			} catch (GLib.Error e) {
				warning ("Error: %s", e.message);
			}
		});
		Test.add_func ("/gxml/stream-reader/child-multiple/read-unparsed/sync", () => {
      var loop = new GLib.MainLoop (null);
      Idle.add (()=>{
				string str = """<root p1="a" p2="b" ><child k="p" y="9"><code/><code u="3">TestC</code><Tek/><Tex y="456"/></child></root>""";
				var istream = new MemoryInputStream.from_data (str.data, null);
				var sr = new StreamReader (istream);
				try {
					var doc = sr.read ();
					(doc.document_element as GXml.Element).parse_buffer ();
					message (doc.write_string ());
					assert ((doc.document_element as GXml.Element).read_buffer == null);
					loop.quit ();
				} catch (GLib.Error e) {
					warning ("Error while reading stream: %s", e.message);
				}
				return Source.REMOVE;
      });
      loop.run ();
		});
		Test.add_func ("/gxml/stream-reader/child-multiple/read-unparsed/async", () => {
      var loop = new GLib.MainLoop (null);
      Idle.add (()=>{
				string str = """<root p1="a" p2="b" ><child k="p" y="9"><code/><code u="3">TestC</code><Tek/><Tex y="456"/></child></root>""";
				var istream = new MemoryInputStream.from_data (str.data, null);
				var sr = new StreamReader (istream);
				try {
					var doc = sr.read ();
					(doc.document_element as GXml.Element).parse_buffer_async.begin ((obj, res)=>{
						try {
							(doc.document_element as GXml.Element).parse_buffer_async.end (res);
							message (doc.write_string ());
							assert ((doc.document_element as GXml.Element).read_buffer == null);
						} catch (GLib.Error e) {
							warning ("Error while reading stream: %s", e.message);
						}
					});
					if ((doc.document_element as GXml.Element).parse_pending () != 0) {
						return Source.CONTINUE;
					}
					loop.quit ();
				} catch (GLib.Error e) {
					warning ("Error while reading stream: %s", e.message);
				}
				return Source.REMOVE;
      });
      loop.run ();
		});
		Test.add_func ("/gxml/stream-reader/serialization", () => {
      var loop = new GLib.MainLoop (null);
      Idle.add (()=>{
				string str = """<?xml version="1.0"?>
<BookStore>
	<Name>Magic Book</Name>
	<book year="2014" isbn="ISBN83763550019---11">
    <Authors>
      <Author>
        <Name>Fred</Name>
        <Email>fweasley@hogwarts.co.uk</Email>
      </Author>
      <Author>
        <Name>George</Name>
        <Email>gweasley@hogwarts.co.uk</Email>
      </Author>
    </Authors>
    <name>Book1</name>
  </book>
	<book year="2014" isbn="ISBN83763550019---11">
    <Authors>
      <Author>
        <Name>Fred</Name>
        <Email>fweasley@hogwarts.co.uk</Email>
      </Author>
      <Author>
        <Name>George</Name>
        <Email>gweasley@hogwarts.co.uk</Email>
      </Author>
    </Authors>
    <name>Book1</name>
  </book>
</BookStore>""";
				var doc = new Library ();
				try {
					doc.read (str);
					assert (doc.document_element != null);
					assert (doc.document_element is BookStore);
					var bs = doc.document_element as BookStore;
					assert (bs != null);
					assert (bs.name != null);
					assert (bs.name is Name);
					assert (bs.books != null);
					assert (bs.books.length == 2);
					assert (bs.books.get_item (0) is Book);
					assert (bs.books.get_item (1) is Book);
					foreach (DomNode n in bs.child_nodes) {
						if (n is DomElement) {
							assert ((n as GXml.Element).read_buffer != null);
						}
					}
					bs.parse_buffer ();
					message (doc.write_string ());
					assert (bs.read_buffer == null);
					assert (bs.books != null);
					assert (bs.books.length == 2);
					var b1 = bs.books.get_item (0) as Book;
					assert (b1 != null);
					assert (b1 is Book);
					assert (b1.authors != null);
					var b2 = bs.books.get_item (0) as Book;
					assert (b2 != null);
					assert (b2 is Book);
					assert (b2.authors != null);
					loop.quit ();
				} catch (GLib.Error e) {
					warning ("Error while reading stream: %s", e.message);
				}
				return Source.REMOVE;
      });
      loop.run ();
		});
		Test.run ();

		return 0;
	}
}