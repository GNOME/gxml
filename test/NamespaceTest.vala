/**
 * Copyright 2015, Daniel Espinosa <esodan@gmail.com>
 *
 */

using GXml;

class NamespaceTest : GXmlTest {

	public static void add_tests () {
		Test.add_func ("/gxml/domnode/namespace", () => {
		  var d = new Document ();
		  var e = d.create_element ("root");
		  e.add_namespace_attr ("http://www.gnome.org/GXml", "gxml");
		  e.add_namespace_attr ("http://www.gnome.org/GXmlSerializable", "gxmls");
		  d.append_child (e);
		  assert (e.to_string () == "<root xmlns:gxml=\"http://www.gnome.org/GXml\" xmlns:gxmls=\"http://www.gnome.org/GXmlSerializable\"/>");
		  assert (e.set_namespace ("http://www.gnome.org/GXml", "gxml"));
		  assert (e.to_string () == "<gxml:root xmlns:gxml=\"http://www.gnome.org/GXml\" xmlns:gxmls=\"http://www.gnome.org/GXmlSerializable\"/>");
		  var c = d.create_element ("child");
		  e.append_child (c);
		  assert (c.set_namespace ("http://www.gnome.org/GXml", "gxml"));
		  assert (c.to_string () == "<gxml:child/>");
		  var c2 = d.create_element ("subchild");
		  e.append_child (c2);
		  assert (c2.set_namespace ("http://www.gnome.org/GXmlSerializable", "gxmls"));
		  assert (c2.to_string () == "<gxmls:subchild/>");
		  var c3 = d.create_element ("testnode");
		  // Check if an Element with no namespaces will not fail and go to root
		  e.append_child (c3);
		  c3.set_namespace ("http://www.gnome.org/GXml", "gxml");
		  assert (c3.to_string () == "<gxml:testnode/>");
		});
	}
}
