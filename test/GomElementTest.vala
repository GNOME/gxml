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

public interface NoInstantiatable : Object, GomObject {
	public abstract string name { get; set; }
}
public interface Property : Object, GomProperty {}

class GomElementTest : GXmlTest  {
	public class ParsedDelayed : GomElement {
		construct {
			try { initialize ("root"); }
			catch (GLib.Error e) { warning ("Error: "+e.message); }
			parse_children = false;
		}
	}
	public class Instantiatable : GomElement, NoInstantiatable {
		[Description (nick="::name")]
		public string name { get; set; }
		construct { initialize ("Instantiatable"); }
	}
	public class Top : GomElement {
		public NoInstantiatable inst {
			get { return inst_i; } set { inst_i = value as Instantiatable; }
		}
		public Instantiatable inst_i { get; set; }
		[Description (nick="::pq")]
		public Property pq { get; set; }
		construct { initialize ("Top"); }
	}
	public class GProperty : GomString, Property {}
	public class GTop : GomElement {
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
	public class Potion : GomElement {
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
	public class Ingredient : GomElement, MappeableElement {
		[Description (nick="::c:name")]
		public string cname { get; set; }
		public Method.Map methods { get; set; }
		construct { initialize ("ingredient"); }
		public string get_map_key () { return cname; }
		public class Map : GomHashMap {
			construct {
				try {
					initialize (typeof (Ingredient));
				} catch (GLib.Error e) { warning ("Error: "+e.message); }
			}
		}
	}
	public class Method : GomElement, MappeableElement {
		[Description (nick="::c:name")]
		public string cname { get; set; }
		construct { initialize ("method"); }
		public string get_map_key () { return cname; }
		public class Map : GomHashMap {
			construct {
				try {
					initialize (typeof (Method));
				} catch (GLib.Error e) { warning ("Error: "+e.message); }
			}
		}
	}
	public class Repository : GomElement
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
 public class Namespace : GomElement
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
 public class TClass : GomElement, MappeableElement
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
    public class Map : GomHashMap {
      construct {
        try { initialize (typeof (TClass)); }
        catch (GLib.Error e) { warning ("Error: "+e.message); }
      }
    }
 }
	public static void add_tests () {
	Test.add_func ("/gxml/gom-element/read/namespace_uri", () => {
			DomDocument doc = null;
			try {
				doc = new GomDocument.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"><ingredient products:name=\"spider\"/></magic:Potion></Potions>");
				GXml.GomNode root = (GXml.GomNode) doc.document_element;
				assert (root != null);
				assert (root.node_name == "Potions");
				GXml.GomNode node = (GXml.GomNode) root.child_nodes[0];
				assert (node != null);
				assert (node is DomElement);
				assert ((node as DomElement).local_name == "Potion");
				assert (node.node_name == "magic:Potion");
				assert ((node as DomElement).namespace_uri == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).prefix == "magic");
				assert ((node as DomElement).attributes.size == 2);
				GLib.message ("Attributes: "+(node as DomElement).attributes.size.to_string ());
				assert ((node as DomElement).get_attribute ("xmlns:magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute ("xmlns:products") == "http://diagonalley.co.uk/products");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/","products") == "http://diagonalley.co.uk/products");
				assert (node.lookup_prefix ("http://diagonalley.co.uk/products") == "products");
				assert (node.lookup_namespace_uri ("products") == "http://diagonalley.co.uk/products");
				(node as DomElement).set_attribute_ns ("http://www.w3.org/2000/xmlns", "xmlns:gxmlt","http://org.gnome.org/GXmlTest/");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/namespace_uri", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<Potions><magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://diagonalley.co.uk/products\"/></Potions>");
				GXml.GomNode root = (GXml.GomNode) doc.document_element;
				assert (root != null);
				assert (root.node_name == "Potions");
				GXml.GomNode node = (GXml.GomNode) root.child_nodes[0];
				assert (node != null);
				assert (node is DomElement);
				assert ((node as DomElement).local_name == "Potion");
				assert (node.node_name == "magic:Potion");
				assert ((node as DomElement).namespace_uri == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).prefix == "magic");
#if DEBUG
				message ("Element: "+(node as GomElement).write_string ());
				message ("Attributes: "+(node as DomElement).attributes.length.to_string ());
				foreach (string k in (node as DomElement).attributes.keys) {
					string v = (node as DomElement).get_attribute (k);
					if (v == null) v = "NULL";
					GLib.message ("Attribute: "+k+"="+v);
				}
#endif
				message ((node as GomElement).write_string ());
				assert ((node as DomElement).attributes.length == 2);
				assert ((node as DomElement).get_attribute ("xmlns:magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert ((node as DomElement).get_attribute ("xmlns:products") == "http://diagonalley.co.uk/products");
				assert ((node as DomElement).get_attribute_ns ("http://www.w3.org/2000/xmlns/","products") == "http://diagonalley.co.uk/products");
				assert (node.lookup_prefix ("http://diagonalley.co.uk/products") == "products");
				assert (node.lookup_namespace_uri ("products") == "http://diagonalley.co.uk/products");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});Test.add_func ("/gxml/gom-element/read/namespace/redefinition", () => {
			DomDocument doc = null;
			try {
				doc = new GomDocument.from_string ("<magic:Potion xmlns:magic=\"http://hogwarts.co.uk/magic\" xmlns:products=\"http://hogwarts.co.uk/magic\"><magic:Arc/><products:Diamond/></magic:Potion>");
				var r = doc.document_element;
				assert (r != null);
				assert (r.local_name == "Potion");
				assert (r.get_attribute_ns ("http://www.w3.org/2000/xmlns/", "magic") == "http://hogwarts.co.uk/magic");
				assert (r.get_attribute_ns ("http://www.w3.org/2000/xmlns/", "products") == "http://hogwarts.co.uk/magic");
				assert (r.child_nodes.length == 2);
				var n1 = r.child_nodes.item (0);
				assert (n1 != null);
				assert (n1 is DomElement);
				assert ((n1 as DomElement).local_name == "Arc");
				assert ((n1 as DomElement).prefix == "magic");
				assert ((n1 as DomElement).namespace_uri == "http://hogwarts.co.uk/magic");
				var n2 = r.child_nodes.item (1);
				assert (n2 != null);
				assert (n2 is DomElement);
				assert ((n2 as DomElement).local_name == "Diamond");
				assert ((n2 as DomElement).prefix == "products");
				assert ((n2 as DomElement).namespace_uri == "http://hogwarts.co.uk/magic");
			} catch (GLib.Error e) {
				GLib.warning (e.message);
			}
		});
		Test.add_func ("/gxml/gom-element/attributes", () => {
			try {
				GomDocument doc = new GomDocument.from_string ("<root />");
				assert (doc.document_element != null);
				GomElement elem = (GomElement) doc.create_element ("alphanumeric");
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
				GomAttr attr = elem.attributes.get_named_item ("owl") as GomAttr;
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
				assert (elem.attributes.size == 2);
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
				message ((elem as GomElement).write_string ());
				child.set_attribute_ns ("http://www.w3c.org/test","xtest:val","Value");
				assert (elem.get_attribute_ns ("http://www.w3.org/2000/xmlns/","xtest") == "http://www.w3c.org/test");
				assert (elem.get_attribute_ns ("http://www.w3.org/2000/xmlns","xtest") == "http://www.w3c.org/test");
				assert (child.get_attribute_ns ("http://www.w3c.org/test","val") == "Value");
			} catch (GLib.Error e) {
				GLib.message (e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/gom-element/attributes/property-ns", () => {
			try {
				string str = """<Potion xmlns:c="http://c.org/1.0" c:name="edumor"><ingredient c:name="spider"><child/><method c:name="move"/></ingredient></Potion>""";
				var p = new Potion ();
				assert (p.node_name == "Potion");
				assert (p.cname == null);
				assert (p.get_attribute_ns ("http://www.w3.org/2000/xmlns", "c") == "http://c.org/1.0");
				p.read_from_string (str);
				message (p.write_string ());
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
		Test.add_func ("/gxml/gom-element/attribute-ns/collection", () => {
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
	<class name="Repository" c:type="GirpRepository" glib:type-name="GirpRepository" glib:get-type="girp_repository_get_type" glib:type-struct="RepositoryClass" parent="GXml.GomElement">
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
		Test.add_func ("/gxml/gom-element/lookup-prefix", () => {
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
	<class name="Repository" c:type="GirpRepository" glib:type-name="GirpRepository" glib:get-type="girp_repository_get_type" glib:type-struct="RepositoryClass" parent="GXml.GomElement">
	</class>
</namespace>
</repository>""";
				var d = new GomDocument.from_string (str);
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
		Test.add_func ("/gxml/gom-element/content/add_aside_child_nodes", () =>{
			try {
				var doc = new GomDocument ();
				var root = (GomElement) doc.create_element ("root");
				doc.child_nodes.add (root);
				var n = (GomElement) doc.create_element ("child");
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
		Test.add_func ("/gxml/gom-element/content/keep_child_nodes", () =>{
			try {
				var doc = new GomDocument ();
				var root = (GomElement) doc.create_element ("root");
				doc.child_nodes.add (root);
				var n = (GomElement) doc.create_element ("child");
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
		Test.add_func ("/gxml/gom-element/parent", () => {
			try {
				var doc = new GomDocument.from_string ("<root><child/></root>");
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
		Test.add_func ("/gxml/gom-element/remove", () => {
			try {
				var doc = new GomDocument.from_string ("<root><child/></root>");
				assert (doc.document_element != null);
				assert (doc.document_element.parent_node is GXml.DomNode);
				assert (doc.document_element.parent_node is GXml.DomDocument);
				assert (doc.document_element.child_nodes.length == 1);
				assert (doc.document_element.child_nodes[0] is DomChildNode);
				(doc.document_element.child_nodes[0] as DomChildNode).remove ();
				assert (doc.document_element.child_nodes.length == 0);
				assert ("<root/>" in  doc.write_string ());
		  } catch (GLib.Error e) {
		    GLib.message ("Error: "+e.message);
		    assert_not_reached ();
		  }
		});
		Test.add_func ("/gxml/gom-element/parsed-delayed", () => {
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
		Test.add_func ("/gxml/gom-element/write/string", () => {
			try {
				var n = new GomElement ();
				n.initialize ("Node");
				n.set_attribute ("name","value");
				var n2 = n.owner_document.create_element ("Node2") as GomElement;
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
		Test.add_func ("/gxml/gom-element/write/stream", () => {
			try {
				var n = new GomElement ();
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
		Test.add_func ("/gxml/gom-element/write/input_stream", () => {
			try {
				var n = new GomElement ();
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
		Test.add_func ("/gxml/gom-element/previous_element_sibling", () => {
			try {
				var doc = new GomDocument.from_string ("<root> <child/> <child/></root>");
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
				assert ((doc.document_element.child_nodes[1] as DomElement).next_element_sibling != null);
				assert ((doc.document_element.child_nodes[1] as DomElement).next_element_sibling is DomElement);
				assert ((doc.document_element.child_nodes[1] as DomElement).next_element_sibling.node_name == "child");
				assert (doc.document_element.child_nodes[2] != null);
				assert (doc.document_element.child_nodes[2].parent_node != null);
				assert (doc.document_element.child_nodes[2].parent_node.node_name == "root");
				assert (doc.document_element.child_nodes[2] is DomText);
				assert (doc.document_element.child_nodes[3] != null);
				assert (doc.document_element.child_nodes[3] is DomElement);
				assert (doc.document_element.child_nodes[3].node_name == "child");
				assert ((doc.document_element.child_nodes[3] as DomElement).previous_element_sibling != null);
				assert ((doc.document_element.child_nodes[3] as DomElement).previous_element_sibling is DomElement);
				assert ((doc.document_element.child_nodes[3] as DomElement).previous_element_sibling.node_name == "child");
				} catch (GLib.Error e) {
					Test.message (e.message);
					assert_not_reached ();
				}
		});
		Test.add_func ("/gxml/gom-element/css-selector", () => {
			try {
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
		Test.add_func ("/gxml/gom-element/no-instantiatable/avoid", () => {
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
		Test.add_func ("/gxml/gom-element/no-instantiatable/set", () => {
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
	}
}
