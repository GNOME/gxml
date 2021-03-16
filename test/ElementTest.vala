/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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

public class DefaultNs : GXml.Element {
	[Description (nick="::xlink:Link")]
	public string link { get; set; }
	construct {
			try { initialize ("defaultNs"); }
			catch (GLib.Error e) { warning ("Error: "+e.message); }
	}
}

public interface NoInstantiatable : GLib.Object, GXml.Object {
	public abstract string name { get; set; }
}
public interface Property : GLib.Object, GXml.Property {}

class ObjectParent : GXml.Element {
	construct {
		try { initialize ("root"); }
		catch (GLib.Error e) { warning ("Error: "+e.message); }
	}
	[Description (nick="::text")]
	public string text { get; set; }
	[Description (nick="::prop")]
	public ObjectProperty prop { get; set; }
	[Description (nick="::prop1")]
	public ObjectProperty prop1 { get; set; }
	[Description (nick="::prop2")]
	public ObjectProperty prop2 { get; set; }
	[Description (nick="::prop3")]
	public ObjectProperty prop3 { get; set; }
	public class ObjectProperty : GLib.Object, GXml.Property {
		public string? value { owned get; set; }
		public bool validate_value (string? val) {
			return true;
		}
	}
	public ObjectChild child { get; set; }
	public class ObjectChild : GXml.Element {
		construct {
			try { initialize ("child"); }
			catch (GLib.Error e) { warning ("Error: "+e.message); }
		}
	}
}

class ElementTest : GLib.Object  {
	public class ParsedDelayed : GXml.Element {
		construct {
			try { initialize ("root"); }
			catch (GLib.Error e) { warning ("Error: "+e.message); }
			parse_children = false;
		}
	}
	public class Instantiatable : GXml.Element, NoInstantiatable {
		[Description (nick="::name")]
		public string name { get; set; }
		construct { initialize ("Instantiatable"); }
	}
	public class Top : GXml.Element {
		public NoInstantiatable inst {
			get { return inst_i; } set { inst_i = value as Instantiatable; }
		}
		public Instantiatable inst_i { get; set; }
		[Description (nick="::pq")]
		public Property pq { get; set; }
		construct { initialize ("Top"); }
	}
	public class GProperty : GXml.String, Property {}
	public class GTop : GXml.Element {
		public NoInstantiatable inst { get; set; }
		public Instantiatable inst_i {
			get { return inst as Instantiatable; }
			set { inst = value as NoInstantiatable; }
		}
		// Order Matters: Put first instantiatable properties
		[Description (nick="::pq")]
		public GProperty gpq {
			get { return pq as GProperty; }
			set { pq = value as Property; }
		}
		// Don't tag non-instantiatable properties
		// Here works because an instantiatable property is placed first
		// but will fail if you derive or implement a interferface
		[Description (nick="::pq")]
		public Property pq { get; set; }
		construct { initialize ("Top"); }
	}
	public class Potion : GXml.Element {
		[Description (nick="::c:name")]
		public string cname { get; set; }
		public Ingredient ingredient { get; set; }
		construct {
			initialize ("Potion");
			try {
				set_attribute_ns ("http://www.w3.org/2000/xmlns", "xmlns:c","http://c.org/1.0");
			} catch (GLib.Error e) { warning ("Error: "+e.message); }
		}
	}
	public class Ingredient : GXml.Element, MappeableElement {
		[Description (nick="::c:name")]
		public string cname { get; set; }
		public Method.Map methods { get; set; }
		construct { initialize ("ingredient"); }
		public string get_map_key () { return cname; }
		public class Map : GXml.HashMap {
			construct {
				try {
					initialize (typeof (Ingredient));
				} catch (GLib.Error e) { warning ("Error: "+e.message); }
			}
		}
	}
	public class Method : GXml.Element, MappeableElement {
		[Description (nick="::c:name")]
		public string cname { get; set; }
		construct { initialize ("method"); }
		public string get_map_key () { return cname; }
		public class Map : GXml.HashMap {
			construct {
				try {
					initialize (typeof (Method));
				} catch (GLib.Error e) { warning ("Error: "+e.message); }
			}
		}
	}
	public class Repository : GXml.Element
 {
    [Description (nick="::version")]
    public string version { get; set; }

    public Namespace ns { get; set; }

    construct {
      initialize ("repository");
      try {
		    set_attribute_ns ("http://www.w3.org/2000/xmlns",
		                    "xmlns", "http://www.gtk.org/introspection/core/1.0");
		    set_attribute_ns ("http://www.w3.org/2000/xmlns",
		                    "xmlns:c", "http://www.gtk.org/introspection/c/1.0");
		    set_attribute_ns ("http://www.w3.org/2000/xmlns",
		                      "xmlns:glib", "http://www.gtk.org/introspection/glib/1.0");
		   } catch (GLib.Error e) { warning ("Error: "+e.message); }
      version = "1.2";
    }
 }
 public class Namespace : GXml.Element
 {
    TClass.Map _classes;
    [Description (nick="::name")]
    public string name { get; set; }
    [Description (nick="::version")]
    public string version { get; set; }
    [Description (nick="::c:prefix")]
    public string cprefix { get; set; }
    public TClass.Map classes {
      get {
        if (_classes == null)
          set_instance_property ("classes");
        return _classes;
      }
      set {
        if (_classes != null) {
          try { clean_property_elements ("classes"); }
        	catch (GLib.Error e) { warning ("Error: "+e.message); }
        }
        _classes = value;
      }
    }
    construct {
      initialize ("namespace");
      _classes = new TClass.Map ();
      try { _classes.initialize_element (this); }
      catch (GLib.Error e) { warning ("Error: "+e.message); }
    }
 }
 public class TClass : GXml.Element, MappeableElement
 {
    [Description (nick="::name")]
    public string name { get; set; }
    [Description (nick="::version")]
    public string version { get; set; }
    [Description (nick="::c:prefix")]
    public string cprefix { get; set; }

    construct {
      initialize ("class");
    }

    public string get_map_key () { return name; }
    public class Map : GXml.HashMap {
      construct {
        try { initialize (typeof (TClass)); }
        catch (GLib.Error e) { warning ("Error: "+e.message); }
      }
    }
 }
 public class ElementType : GXml.Element {
    [Description (nick="::type")]
    public string ttype { get; set; }

    construct {
      initialize ("elementType");
    }
 }
	public static int main (string[] args) {
	Test.init (ref args);
	Test.add_func ("/gxml/element/read/namespace_uri", () => {
			DomDocument doc = null;
			try {
				doc = new GXml.Document.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"><ingredient products:name=\"spider\"/></magic:Potion></Potions>");
				GXml.Node root = (GXml.Node) doc.document_element;
				assert (root != null);
				assert (root.node_name == "Potions");
				GXml.Node node = (GXml.Node) root.child_nodes[0];
				assert (node != null);
				assert (node is DomElement);
				assert (((DomElement) node).local_name == "Potion");
				assert (node.node_name == "magic:Potion");
				assert (((DomElement) node).namespace_uri == "http://hogwarts.co.uk/magic");
				assert (((DomElement) node).prefix == "magic");
				assert (((DomElement) node).attributes.size == 2);
				GLib.message ("Attributes: "+((DomElement) node).attributes.size.to_string ());
				assert (((DomElement) node).get_attribute ("xmlns:magic") == "http://hogwarts.co.uk/magic");
				assert (((DomElement) node).get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert (((DomElement) node).get_attribute ("xmlns:products") == "http://diagonalley.co.uk/products");
				assert (((DomElement) node).get_attribute_ns ("http://www.w3.org/2000/xmlns/","products") == "http://diagonalley.co.uk/products");
				assert (node.lookup_prefix ("http://diagonalley.co.uk/products") == "products");
				assert (node.lookup_namespace_uri ("products") == "http://diagonalley.co.uk/products");
				((DomElement) node).set_attribute_ns ("http://www.w3.org/2000/xmlns", "xmlns:gxmlt","http://org.gnome.org/GXmlTest/");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/element/namespace_uri", () => {
			try {
				GXml.Document doc = new GXml.Document.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.Node root = (GXml.Node) doc.document_element;
				assert (root != null);
				assert (root.node_name == "Potions");
				GXml.Node node = (GXml.Node) root.child_nodes[0];
				assert (node != null);
				assert (node is DomElement);
				assert (((DomElement) node).local_name == "Potion");
				assert (node.node_name == "magic:Potion");
				assert (((DomElement) node).namespace_uri == "http://hogwarts.co.uk/magic");
				assert (((DomElement) node).prefix == "magic");
#if DEBUG
				message ("Element: "+((DomElement) node).write_string ());
				message ("Attributes: "+((DomElement) node).attributes.length.to_string ());
				foreach (string k in ((DomElement) node).attributes.keys) {
					string v = ((DomElement) node).get_attribute (k);
					if (v == null) v = "NULL";
					GLib.message ("Attribute: "+k+"="+v);
				}
#endif
				message (((GXml.Element) node).write_string ());
				assert (((DomElement) node).attributes.length == 2);
				assert (((DomElement) node).get_attribute ("xmlns:magic") == "http://hogwarts.co.uk/magic");
				assert (((DomElement) node).get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert (((DomElement) node).get_attribute ("xmlns:products") == "http://diagonalley.co.uk/products");
				assert (((DomElement) node).get_attribute_ns ("http://www.w3.org/2000/xmlns/","products") == "http://diagonalley.co.uk/products");
				assert (node.lookup_prefix ("http://diagonalley.co.uk/products") == "products");
				assert (node.lookup_namespace_uri ("products") == "http://diagonalley.co.uk/products");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});Test.add_func ("/gxml/element/read/namespace/redefinition", () => {
			DomDocument doc = null;
			try {
				doc = new GXml.Document.from_string ("<magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://hogwarts.co.uk/magic\"><magic:Arc/><products:Diamond/></magic:Potion>");
				var r = doc.document_element;
				assert (r != null);
				assert (r.local_name == "Potion");
				assert (r.get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert (r.get_attribute_ns ("http://www.w3.org/2000/xmlns/", "products") == "http://hogwarts.co.uk/magic");
				assert (r.child_nodes.length == 2);
				var n1 = r.child_nodes.item (0);
				assert (n1 != null);
				assert (n1 is DomElement);
				assert (((DomElement) n1).local_name == "Arc");
				assert (((DomElement) n1).prefix == "magic");
				assert (((DomElement) n1).namespace_uri == "http://hogwarts.co.uk/magic");
				var n2 = r.child_nodes.item (1);
				assert (n2 != null);
				assert (n2 is DomElement);
				assert (((DomElement) n2).local_name == "Diamond");
				assert (((DomElement) n2).prefix == "products");
				assert (((DomElement) n2).namespace_uri == "http://hogwarts.co.uk/magic");
			} catch (GLib.Error e) {
				GLib.warning (e.message);
			}
		});
		Test.add_func ("/gxml/element/attributes", () => {
			try {
				GXml.Document doc = new GXml.Document.from_string ("<root />");
				assert (doc.document_element != null);
				GXml.Element elem = (GXml.Element) doc.create_element ("alphanumeric");
				doc.document_element.child_nodes.add (elem);
				assert (elem.attributes != null);
				assert (elem.attributes.size == 0);
				elem.set_attribute ("alley", "Diagon");
				elem.set_attribute ("train", "Hogwarts Express");
				assert (elem.attributes.size == 2);
				var parser = new XParser (doc);
				Test.message ("Getting attributes value alley... Node: "+parser.write_string ());
				assert (elem.attributes.get_named_item ("alley").node_value == "Diagon");
				assert (elem.attributes.get_named_item ("train").node_value == "Hogwarts Express");

				elem.set_attribute ("owl", "Hedwig");
				GXml.Attr attr = elem.attributes.get_named_item ("owl") as GXml.Attr;
				assert (attr != null);
				assert (attr.node_value == "Hedwig");

				assert (elem.attributes.size == 3);
				assert (elem.get_attribute ("owl") == "Hedwig");

				elem.attributes.remove_named_item ("alley");

				assert (elem.get_attribute ("alley") == null);
				assert (elem.attributes.size == 2);
				elem.remove_attribute ("owl");
				assert (elem.attributes.size == 1);

				elem.set_attribute_ns ("http://www.w3.org/2000/xmlns/", "xmlns:gxml",
															"http://www.gnome.org/GXml");
				assert (elem.attributes.size == 2);
				elem.set_attribute_ns ("http://www.gnome.org/GXml", "gxml:xola","Mexico");
				assert (elem.attributes.size == 3);
				assert (elem.get_attribute_ns ("http://www.gnome.org/GXml", "xola") == "Mexico");
				elem.remove_attribute_ns ("http://www.gnome.org/GXml", "xola");
				assert (elem.get_attribute_ns ("http://www.gnome.org/GXml", "xola") == null);
				assert (elem.get_attribute ("xola") == null);
				assert (elem.attributes.size == 2);
				elem.id = "idnode";
				assert ("id=\"idnode\"" in elem.write_string ());
				assert (elem.id == "idnode");
				try {
					elem.set_attribute_ns ("http://www.gnome.org/GXml", "gxml2:xola","Mexico");
					assert_not_reached ();
				} catch (GLib.Error e) {
					GLib.message ("Correctly Cough Error:"+e.message);
				}
				assert (elem != null);
				assert (elem.attributes != null);
				assert (elem.attributes.size == 3);
				var n = doc.create_element ("node");
				elem.append_child (n);
				var child = doc.create_element ("child");
				n.append_child (child);
				elem.set_attribute_ns ("http://www.w3.org/2000/xmlns","xmlns:xtest","http://www.w3c.org/test");
				assert (elem.lookup_prefix ("http://www.w3c.org/test") == "xtest");
				assert (n.lookup_prefix ("http://www.w3c.org/test") == "xtest");
				assert (child.lookup_prefix ("http://www.w3c.org/test") == "xtest");
				assert (elem.lookup_namespace_uri ("xtest") == "http://www.w3c.org/test");
				assert (n.lookup_namespace_uri ("xtest") == "http://www.w3c.org/test");
				assert (child.lookup_namespace_uri ("xtest") == "http://www.w3c.org/test");
				message (((GXml.Element) elem).write_string ());
				child.set_attribute_ns ("http://www.w3c.org/test","xtest:val","Value");
				assert (elem.get_attribute_ns ("http://www.w3.org/2000/xmlns/","xtest") == "http://www.w3c.org/test");
				assert (elem.get_attribute_ns ("http://www.w3.org/2000/xmlns","xtest") == "http://www.w3c.org/test");
				assert (child.get_attribute_ns ("http://www.w3c.org/test","val") == "Value");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/element/attributes/property-ns", () => {
			try {
				string str = """<Potion xmlns:c="http://c.org/1.0" c:name="edumor"><ingredient c:name="spider"><child/><method c:name="move"/></ingredient></Potion>""";
				var p = new Potion ();
				assert (p.node_name == "Potion");
				assert (p.cname == null);
				assert (p.get_attribute_ns ("http://www.w3.org/2000/xmlns", "c") == "http://c.org/1.0");
				p.read_from_string (str);
				message (p.write_string ());
				assert (p.get_attribute_ns ("http://c.org/1.0", "name") == "edumor");
				assert (p.cname == "edumor");
				assert (p.ingredient != null);
				assert (p.ingredient.cname == "spider");
				assert (p.ingredient.methods != null);
				assert (p.ingredient.methods.length == 1);
				var m = p.ingredient.methods.get_item (0) as Method;
				assert (m.cname == "move");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/element/attribute-ns/collection", () => {
			try {
				string str = """<?xml version="1.0"?>
<repository version="1.2" xmlns="http://www.gtk.org/introspection/core/1.0" xmlns:c="http://www.gtk.org/introspection/c/1.0" xmlns:glib="http://www.gtk.org/introspection/glib/1.0">
<include name="GXml" version="0.16"/>
<package name="girp-0.2"/>
<c:include name="girp.h"/>
<namespace name="Girp" version="0.2" c:prefix="Girp">
	<attribute name="ccode.gir-version" value="0.2"/>
	<attribute name="ccode.cheader-filename" value="girp.h"/>
	<attribute name="ccode.gir-namespace" value="Girp"/>
	<class name="Repository" c:type="GirpRepository" glib:type-name="GirpRepository" glib:get-type="girp_repository_get_type" glib:type-struct="RepositoryClass" parent="GXml.GXml.Element">
	</class>
</namespace>
</repository>""";
				var r = new Repository ();
				r.read_from_string (str);
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/element/lookup-prefix", () => {
			try {
				string str = """<?xml version="1.0"?>
<repository version="1.2" xmlns="http://www.gtk.org/introspection/core/1.0" xmlns:c="http://www.gtk.org/introspection/c/1.0" xmlns:glib="http://www.gtk.org/introspection/glib/1.0">
<include name="GXml" version="0.16"/>
<package name="girp-0.2"/>
<c:include name="girp.h"/>
<namespace name="Girp" version="0.2" c:prefix="Girp">
	<attribute name="ccode.gir-version" value="0.2"/>
	<attribute name="ccode.cheader-filename" value="girp.h"/>
	<attribute name="ccode.gir-namespace" value="Girp"/>
	<class name="Repository" c:type="GirpRepository" glib:type-name="GirpRepository" glib:get-type="girp_repository_get_type" glib:type-struct="RepositoryClass" parent="GXml.GXml.Element">
	</class>
</namespace>
</repository>""";
				var d = new GXml.Document.from_string (str);
				assert (d.document_element.node_name == "repository");
				var lt = d.document_element.get_elements_by_tag_name ("class");
				assert (lt.length == 1);
				var n = lt[0];
				assert (n.node_name == "class");
				assert (n.lookup_namespace_uri ("c") == "http://www.gtk.org/introspection/c/1.0");
				assert (n.lookup_prefix ("http://www.gtk.org/introspection/c/1.0") == "c");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/element/content/add_aside_child_nodes", () =>{
			try {
				var doc = new GXml.Document ();
				var root = (GXml.Element) doc.create_element ("root");
				doc.child_nodes.add (root);
				var n = (GXml.Element) doc.create_element ("child");
				root.child_nodes.add (n);
				var t = doc.create_text_node ("TEXT1");
				root.child_nodes.add (t);
				var parser = new XParser (doc);
				string s = parser.write_string ().split ("\n")[1];
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/element/content/keep_child_nodes", () =>{
			try {
				var doc = new GXml.Document ();
				var root = (GXml.Element) doc.create_element ("root");
				doc.child_nodes.add (root);
				var n = (GXml.Element) doc.create_element ("child");
				root.child_nodes.add (n);
				var t = doc.create_text_node ("TEXT1") as DomText;
				root.child_nodes.add (t);
				var parser = new XParser (doc);
				string s = parser.write_string ().split ("\n")[1];
				assert (s == "<root><child/>TEXT1</root>");
			} catch (GLib.Error e) {
				Test.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/element/parent", () => {
			try {
				var doc = new GXml.Document.from_string ("<root><child/></root>");
				assert (doc.document_element != null);
				assert (doc.document_element.parent_node is GXml.DomNode);
				assert (doc.document_element.parent_node is GXml.DomDocument);
				assert (doc.document_element.child_nodes[0] != null);
				assert (doc.document_element.child_nodes[0].parent_node != null);
				assert (doc.document_element.child_nodes[0].parent_node.node_name == "root");
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/remove", () => {
			try {
				var doc = new GXml.Document.from_string ("<root><child/></root>");
				assert (doc.document_element != null);
				assert (doc.document_element.parent_node is GXml.DomNode);
				assert (doc.document_element.parent_node is GXml.DomDocument);
				assert (doc.document_element.child_nodes.length == 1);
				assert (doc.document_element.child_nodes[0] is DomChildNode);
				((DomChildNode) doc.document_element.child_nodes[0]).remove ();
				assert (doc.document_element.child_nodes.length == 0);
				assert ("<root/>" in  doc.write_string ());
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/parsed-delayed", () => {
			try {
				var n = new ParsedDelayed ();
				n.read_from_string ("<root><child p1=\"Value1\" p2=\"Value2\"><child2/></child></root>");
				assert (n.unparsed != null);
				assert (n.unparsed == "<child p1=\"Value1\" p2=\"Value2\"><child2/></child>");
				assert (!n.has_child_nodes ());
				assert (n.child_nodes.length == 0);
				n.read_unparsed ();
				assert (n.has_child_nodes ());
				assert (n.child_nodes.length == 1);
				assert (n.unparsed == null);
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/write/string", () => {
			try {
				var n = new GXml.Element ();
				n.initialize ("Node");
				n.set_attribute ("name","value");
				var n2 = n.owner_document.create_element ("Node2") as GXml.Element;
				n.append_child (n2);
				string str = n.write_string ();
				assert ("<Node" in str);
				assert ("<Node name=\"value\"><Node2/></Node>" in str);
				str = n2.write_string ();
				assert ("<Node2/>" in str);
				assert (!("<Node name=\"value\"><Node2/></Node>" in str));
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/write/stream", () => {
			try {
				var n = new GXml.Element ();
				n.initialize ("Node");
				n.set_attribute ("name","value");
				var ostream = new MemoryOutputStream.resizable ();
				n.write_stream (ostream);
				string str = (string) ostream.data;
				assert ("<Node" in str);
				assert ("<Node name=\"value\"/>" in str);
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/write/input_stream", () => {
			try {
				var n = new GXml.Element ();
				n.initialize ("Node");
				n.set_attribute ("name","value");
				var ostream = new MemoryOutputStream.resizable ();
				var istream = n.create_stream ();
				ostream.splice (istream, GLib.OutputStreamSpliceFlags.NONE);
				string str = (string) ostream.data;
				assert ("<Node" in str);
				assert ("<Node name=\"value\"/>" in str);
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/previous_element_sibling", () => {
			try {
				var doc = new GXml.Document.from_string ("<root> <child/> <child/></root>");
				assert (doc.document_element != null);
				assert (doc.document_element.parent_node is GXml.DomNode);
				assert (doc.document_element.parent_node is GXml.DomDocument);
				assert (doc.document_element.child_nodes[0] != null);
				assert (doc.document_element.child_nodes[0].parent_node != null);
				assert (doc.document_element.child_nodes[0].parent_node.node_name == "root");
				assert (doc.document_element.child_nodes[0] is DomText);
				assert (doc.document_element.child_nodes[1] != null);
				assert (doc.document_element.child_nodes[1] is DomElement);
				assert (doc.document_element.child_nodes[1].node_name == "child");
				assert (((DomElement) doc.document_element.child_nodes[1]).next_element_sibling != null);
				assert (((DomElement) doc.document_element.child_nodes[1]).next_element_sibling is DomElement);
				assert (((DomElement) doc.document_element.child_nodes[1]).next_element_sibling.node_name == "child");
				assert (doc.document_element.child_nodes[2] != null);
				assert (doc.document_element.child_nodes[2].parent_node != null);
				assert (doc.document_element.child_nodes[2].parent_node.node_name == "root");
				assert (doc.document_element.child_nodes[2] is DomText);
				assert (doc.document_element.child_nodes[3] != null);
				assert (doc.document_element.child_nodes[3] is DomElement);
				assert (doc.document_element.child_nodes[3].node_name == "child");
				assert (((DomElement) doc.document_element.child_nodes[3]).previous_element_sibling != null);
				assert (((DomElement) doc.document_element.child_nodes[3]).previous_element_sibling is DomElement);
				assert (((DomElement) doc.document_element.child_nodes[3]).previous_element_sibling.node_name == "child");
				} catch (GLib.Error e) {
					Test.message (e.message);
					assert_not_reached ();
				}
		});
		Test.add_func ("/gxml/element/css-selector", () => {
			try {
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
				var n1 = r.query_selector ("child");
				assert (n1 != null);
				assert (n1.get_attribute ("class") == "error");
				var n2 = r.query_selector ("child.warning");
				assert (n2 != null);
				assert (n2.get_attribute ("class") == "warning");
				var n3 = r.query_selector ("child[class]");
				assert (n3 != null);
				assert (n3.get_attribute ("class") == "error");
				var n4 = r.query_selector ("child[class=\"error calc\"]");
				assert (n4 != null);
				assert (n4.get_attribute ("class") == "error calc");
				var l1 = r.query_selector_all ("child");
				assert (l1 != null);
				message (l1.length.to_string ());
				assert (l1.length == 5);
				assert (l1.item (4).node_name == "child");
				var l2 = r.query_selector_all ("child[class]");
				assert (l2 != null);
				assert (l2.length == 4);
				assert (l2.item (3).node_name == "child");
				var l3 = r.query_selector_all ("child[class=\"error\"]");
				assert (l3 != null);
				assert (l3.length == 1);
				assert (l3.item (0).node_name == "child");
				var c6 = d.create_element ("child");
				c6.set_attribute ("prop", "val1");
				r.append_child (c6);
				var c7 = d.create_element ("child");
				c7.set_attribute ("prop", "val1");
				r.append_child (c7);
				var l4 = r.query_selector_all ("child[prop=\"val1\"]");
				assert (l4 != null);
				assert (l4.length == 2);
				assert (l4.item (0).node_name == "child");
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/no-instantiatable/avoid", () => {
			try {
				string str = """<Top pq="Qlt"><Instantiatable name="Nop"/></Top>""";
				var t = new Top ();
				t.read_from_string (str);
				assert (t.inst != null);
				assert (t.inst.name == "Nop");
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/no-instantiatable/set", () => {
			try {
				string str = """<Top pq="Qlt"><Instantiatable name="Nop"/></Top>""";
				var t = new GTop ();
				t.read_from_string (str);
				assert (t.inst != null);
				assert (t.inst.name == "Nop");
				assert (t.pq != null);
				assert (t.pq.value == "Qlt");
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/ordered-attributes", () => {
			try {
				var e = new GXml.Element ();
				e.set_attribute ("a1", "v1");
				e.set_attribute ("a2", "v2");
				e.set_attribute ("a3", "v3");
				e.set_attribute ("a4", "v4");
				assert (e.attributes.length == 4);
				for (int i = 0; i < e.attributes.length; i++) {
					assert (e.attributes.item (i) != null);
				}
				assert (e.attributes.item (0) != null);
				assert (e.attributes.item (0).node_name == "a1");
				assert (e.attributes.item (0).node_value == "v1");
				assert (e.attributes.item (1) != null);
				assert (e.attributes.item (1).node_name == "a2");
				assert (e.attributes.item (1).node_value == "v2");
				assert (e.attributes.item (2) != null);
				assert (e.attributes.item (2).node_name == "a3");
				assert (e.attributes.item (2).node_value == "v3");
				assert (e.attributes.item (3) != null);
				assert (e.attributes.item (3).node_name == "a4");
				assert (e.attributes.item (3).node_value == "v4");
				e.remove_attribute ("a3");
				assert (e.attributes.length == 3);
				assert (e.attributes.item (2) != null);
				assert (e.attributes.item (2).node_name == "a4");
				assert (e.attributes.item (2).node_value == "v4");
				assert (e.attributes.item (3) == null);

				var e2 = new GXml.Element ();
				e2.set_attribute_ns ("http://www.w3.org/2000/xmlns", "xmlns:gxml", "http://wiki.gnome.org/GXml");
				e2.set_attribute_ns ("http://wiki.gnome.org/GXml", "gxml:a1", "v1");
				e2.set_attribute_ns ("http://wiki.gnome.org/GXml", "gxml:a2", "v2");
				e2.set_attribute_ns ("http://wiki.gnome.org/GXml", "gxml:a3", "v3");
				e2.set_attribute_ns ("http://wiki.gnome.org/GXml", "gxml:a4", "v4");
				assert (e2.attributes.length == 5);
				for (int i = 0; i < e2.attributes.length; i++) {
					assert (e2.attributes.item (i) != null);
				}
				assert (e2.attributes.item (0) != null);
				assert (e2.attributes.item (0).node_name == "xmlns:gxml");
				assert (e2.attributes.item (0).node_value == "http://wiki.gnome.org/GXml");
				assert (e2.attributes.item (1) != null);
				assert (e2.attributes.item (1).node_name == "gxml:a1");
				assert (e2.attributes.item (1).node_value == "v1");
				assert (e2.attributes.item (2) != null);
				assert (e2.attributes.item (2).node_name == "gxml:a2");
				assert (e2.attributes.item (2).node_value == "v2");
				assert (e2.attributes.item (3) != null);
				assert (e2.attributes.item (3).node_name == "gxml:a3");
				assert (e2.attributes.item (3).node_value == "v3");
				assert (e2.attributes.item (4) != null);
				assert (e2.attributes.item (4).node_name == "gxml:a4");
				assert (e2.attributes.item (4).node_value == "v4");
				e2.remove_attribute_ns ("http://wiki.gnome.org/GXml", "a3");
				assert (e2.attributes.length == 4);
				assert (e2.attributes.item (3) != null);
				assert (e2.attributes.item (3).node_name == "gxml:a4");
				assert (e2.attributes.item (3).node_value == "v4");
				assert (e2.attributes.item (4) == null);
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/object-attributes/attributes-collection", () => {
			try {
				var e = new ObjectParent ();
				assert (e.text == null);
				assert (e.prop == null);
				assert (e.attributes != null);
				assert (e.attributes.length == 0);
				e.set_attribute ("text", "value1");
				assert (e.get_attribute ("text") == "value1");
				e.set_attribute ("prop", "value_prop");
				message ("Attribute: prop: %s", e.get_attribute ("prop"));
				assert (e.get_attribute ("prop") == "value_prop");
				assert (e.text != null);
				assert (e.prop != null);
				assert (e.attributes.length == 2);
				message ("Attr 0: %s:%s", e.attributes.item (0).node_name, e.attributes.item (0).node_value);
				foreach (string k in e.attributes.keys) {
					var a = e.attributes.get (k) as DomAttr;
					message ("Attr: %s:%s", a.name, a.@value);
				}
				assert (((DomAttr) e.attributes.item (0)).@value == "value1");
				assert (((DomAttr) e.attributes.item (1)).@value == "value_prop");
				e.set_attribute ("p1", "prop1");
				e.set_attribute ("p2", "prop2");
				e.set_attribute ("p3", "prop3");
				assert (e.attributes.length == 5);
				assert (((DomAttr) e.attributes.item (0)).@value == "value1");
				assert (((DomAttr) e.attributes.item (1)).@value == "value_prop");
				assert (((DomAttr) e.attributes.item (2)).@value == "prop1");
				assert (((DomAttr) e.attributes.item (3)).@value == "prop2");
				assert (((DomAttr) e.attributes.item (4)).@value == "prop3");
				e.set_attribute_ns ("http://www.w3.org/2000/xmlns/", "xmlns:t", "http://www.gnome.org/gxml/test");
				e.set_attribute_ns ("http://www.gnome.org/gxml/test", "t:p1", "prop1_test");
				e.set_attribute_ns ("http://www.gnome.org/gxml/test", "t:p2", "prop2_test");
				assert (e.get_attribute_ns ("http://www.gnome.org/gxml/test", "p1") == "prop1_test");
				assert (e.get_attribute_ns ("http://www.gnome.org/gxml/test", "p2") == "prop2_test");
				assert (e.attributes.length == 8);
				assert (((DomAttr) e.attributes.item (0)).@value == "value1");
				assert (((DomAttr) e.attributes.item (1)).@value == "value_prop");
				assert (((DomAttr) e.attributes.item (2)).@value == "prop1");
				assert (((DomAttr) e.attributes.item (3)).@value == "prop2");
				assert (((DomAttr) e.attributes.item (4)).@value == "prop3");
				assert (((DomAttr) e.attributes.item (5)).@value == "http://www.gnome.org/gxml/test");
				assert (((DomAttr) e.attributes.item (6)).@value == "prop1_test");
				assert (((DomAttr) e.attributes.item (7)).@value == "prop2_test");
				e.id = "di1";
				assert (e.id == "di1");
				assert (e.get_attribute ("id") == "di1");
				assert (e.attributes.length == 9);
				assert (e.attributes.item (8) != null);
				assert (((DomAttr) e.attributes.item (8)).@value == "di1");
				e.child = GLib.Object.new (typeof (ObjectParent.ObjectChild),
															"owner-document", e.owner_document) as ObjectParent.ObjectChild;
				e.append_child (e.child);
				assert (e.child != null);
				message (e.write_string ());
				var e2 = new ObjectParent ();
				e2.read_from_string (e.write_string ());
				message (e.write_string ());
				assert (e2.child != null);
				// Check attributes collection structure
				assert (e.attributes is DomNamedNodeMap);
				foreach (string k in e.attributes.keys) {
					var item = e.attributes.get (k) as DomAttr;
					assert (item != null);
				}
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/object-attributes/attributes-update", () => {
			try {
				var e = new ObjectParent ();
				e.id = "id1";
				assert (e.get_attribute ("id") == "id1");
				e.set_attribute ("id", "id2");
				assert (e.get_attribute ("id") == "id2");
				assert (e.id == "id2");
				assert (((DomAttr) e.attributes.item (0)).value == "id2");
				e.set_attribute ("prop", "val_prop");
				assert (e.prop != null);
				assert (e.prop is ObjectParent.ObjectProperty);
				assert (e.prop.value == "val_prop");
				assert (e.get_attribute ("prop") == "val_prop");
				assert (((DomAttr) e.attributes.item (1)).value == "val_prop");
				e.set_attribute ("prop1", "val_prop1");
				assert (e.prop1 != null);
				assert (e.prop1 is ObjectParent.ObjectProperty);
				assert (e.prop1.value == "val_prop1");
				assert (e.get_attribute ("prop1") == "val_prop1");
				assert (((DomAttr) e.attributes.item (2)).value == "val_prop1");
				e.set_attribute ("prop2", "val_prop2");
				assert (e.prop2 != null);
				assert (e.prop2 is ObjectParent.ObjectProperty);
				assert (e.prop2.value == "val_prop2");
				assert (e.get_attribute ("prop2") == "val_prop2");
				assert (((DomAttr) e.attributes.item (3)).value == "val_prop2");
				e.set_attribute ("prop3", "val_prop3");
				assert (e.prop3 != null);
				assert (e.prop3 is ObjectParent.ObjectProperty);
				assert (e.prop3.value == "val_prop3");
				assert (e.get_attribute ("prop3") == "val_prop3");
				assert (((DomAttr) e.attributes.item (4)).value == "val_prop3");
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/object-attributes/attributes-no-ns-same-name", () => {
			try {
				string str = """<elementType type="Val1" xsi:type="Val2" >VAL3</elementType>""";
				var n = new ElementType ();
				n.notify["ttype"].connect (()=>{
					message ("Moddiffied ttype = %s", n.ttype);
				});
				n.read_from_string (str);
				message (n.ttype);
				message (n.get_attribute ("type"));
				message (n.get_attribute_ns ("http://www.w3.org/2001/XMLSchema-instance", "type"));
				assert (n.ttype == "Val1");
				assert (n.get_attribute_ns ("http://www.w3.org/2001/XMLSchema-instance", "type") == "Val2");
				message (n.get_attribute ("type"));
				assert (n.get_attribute ("type") == "Val1");
			} catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/element/default-ns/xlink", () => {
			try {
				var dns = new DefaultNs ();
				dns.link = "http://www.gnome.org/";
				message (dns.write_string ());
				string str = """<defaultNs xlink:link="http://www.gnome.org/"/>""";
				dns = new DefaultNs ();
				dns.read_from_string (str);
				message (dns.write_string ());
				assert (dns.get_attribute_ns ("http://www.w3.org/1999/xlink", "link") == "http://www.gnome.org/");
			} catch (GLib.Error e) {
		    GLib.warning ("Error: "+e.message);
		  }
		});


		Test.run ();

		return 0;
	}
}
