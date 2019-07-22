/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*-  */
/* librescl
 *
 * Copyright (C) 2013-2015 Daniel Espinosa <esodan@gmail.com>
 *
 * librescl is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * librescl is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using GXml;


public class Performance
{
  /**
   * Iterate recursively through all node and children nodes in document.
   */
  public static void iterate (GXml.Node node) {
    foreach (GXml.Node n in node.children_nodes) {
      int i = node.children_nodes.size;
#if DEBUG
      string name = n.name;
      string val = n.value;
      GLib.message ("Node: "+name+" Val: "+val+ " Children: "+i.to_string ());
#endif
      if (i > 0)
        Performance.iterate (n);
    }
  }
  public static void iterate_dom (GXml.DomNode node) {
    foreach (GXml.DomNode n in node.child_nodes) {
      int i = n.child_nodes.size;
#if DEBUG
      string name = n.node_name;
      string val = n.node_value;
      GLib.message ("Node: "+name+" Val: "+val+ " Children: "+i.to_string ());
#endif
      if (i > 0)
        Performance.iterate_dom (n);
    }
  }
  public static void add_tests ()
  {
    Test.add_func ("/gxml/performance/read/document",
    () => {
      try {
        Test.timer_start ();
        double time;
        var d = new Document.from_path (GXmlTestConfig.TEST_DIR + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Load large document: %g seconds", time);
        Test.timer_start ();
        iterate_dom (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Itirate over all loaded nodes: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });Test.add_func ("/gxml/performance/read/gdocument",
    () => {
      try {
        Test.timer_start ();
        double time;
        var d = new GDocument.from_path (GXmlTestConfig.TEST_DIR + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Load large document: %g seconds", time);
        Test.timer_start ();
        iterate (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Itirate over all loaded nodes: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/se-deserialize/document",
    () => {
      try {
        double time;
        GomDocument doc;
        var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR + "/test-large.xml");
        assert (f.query_exists ());
        Test.timer_start ();
        var bs = new GomBookStore ();
        bs.read_from_file (f);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "deserialize/performance: %g seconds", time);
        var of = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR + "/test-large-new.xml");
        Test.timer_start ();
        bs.write_file (of);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Serialize/performance: %g seconds", time);
        assert (of.query_exists ());
        try { of.delete (); } catch { assert_not_reached (); }
        // Check read structure
        GLib.message ("Document Root: "+bs.owner_document.document_element.node_name);
        assert (bs.owner_document.document_element.node_name.down () == "bookstore");
        assert (bs.child_nodes.length > 0);
        var ns = bs.get_elements_by_tag_name ("book");
        assert (ns.length > 0);
        GLib.message ("Books: "+bs.books.length.to_string ());
        /*assert (bs.books.length > 0);
        var b = bs.books.get_item (0) as GomBook;
        assert (b != null);
        assert (b.year == "2015");*/
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/deserialize/gdocument",
    () => {
      try {
        double time;
        Test.timer_start ();
        var d = new GDocument.from_path (GXmlTestConfig.TEST_DIR + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "open document from path: %g seconds", time);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "deserialize/performance: %g seconds", time);
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });

    Test.add_func ("/gxml/performance/serialize/gdocument",
    () => {
      try {
        double time;
        Test.timer_start ();
        var d = new GDocument.from_path (GXmlTestConfig.TEST_DIR + "/test-large.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument open document from path: %g seconds", time);
        Test.message ("Starting Deserializing...");
        for (int i = 0; i < 1000000; i++);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument deserialize/performance: %g seconds", time);
        for (int i = 0; i < 1000000; i++);
        Test.timer_start ();
        var d2 = new GDocument ();
        bs.serialize (d2);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument serialize/performance: %g seconds", time);
        for (int i = 0; i < 1000000; i++);
        Test.timer_start ();
        var nf = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR + "/test-large-tw.xml");
        d2.indent = true;
        d2.save_as (nf);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument Write to disk serialize/performance: %g seconds", time);
        for (int i = 0; i < 1000000; i++);
        assert (nf.query_exists ());
        nf.delete ();
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });

    Test.add_func ("/gxml/performance/serialize/gdocument/read_doc",
    () => {
      try {
        double time;
        Test.timer_start ();
        GLib.File f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR + "/test-large.xml");
        assert (f.query_exists ());
        var d = new GDocument ();
        TDocument.read_doc (d, f, null);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument open document from path: %g seconds", time);
        Test.message ("Starting Deserializing...");
        for (int i = 0; i < 1000000; i++);
        Test.timer_start ();
        var bs = new BookStore ();
        bs.deserialize (d);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument deserialize/performance: %g seconds", time);
        for (int i = 0; i < 1000000; i++);
        Test.timer_start ();
        var d2 = new GDocument ();
        bs.serialize (d2);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument serialize/performance: %g seconds", time);
        for (int i = 0; i < 1000000; i++);
        Test.timer_start ();
        var nf = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR + "/test-large-tw.xml");
        d2.indent = true;
        d2.save_as (nf);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument Write to disk serialize/performance: %g seconds", time);
        for (int i = 0; i < 1000000; i++);
        assert (nf.query_exists ());
        nf.delete ();
      } catch (GLib.Error e) {
#if DEBUG
        GLib.message ("ERROR: "+e.message);
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/hashmap/post-deserialization/disable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new HTopElement ();
        for (int i = 0; i < 30000; i++) {
          var e1 = new HElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.elements.set (e1.name, e1);
          var e2 = new HElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.elements.set (e2.name, e2);
        }
        assert (ce.elements1.elements.size == 30000);
        assert (ce.elements2.elements.size == 30000);
        ce.serialize (d);
        d.save_as (f);
        assert (d.root != null);
        assert (d.root.children_nodes.size == 2);
        assert (d.root.children_nodes[0].children_nodes.size == 30000);
        assert (d.root.children_nodes[1].children_nodes.size == 30000);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new HTopElement ();
        cep.elements1.elements.enable_deserialize = false;
        cep.elements2.elements.enable_deserialize = false;
        cep.deserialize (gd);
        assert(cep.elements1.elements.size == 0);
        assert(cep.elements2.elements.size == 0);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling C1 deserialize_children()...");
        Test.timer_start ();
        assert (cep.elements1.elements.deserialize_children ());
        assert (cep.elements1.elements.size == 30000);
        assert (!cep.elements1.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C1: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
        Test.message ("Calling C2 deserialize_children()...");
        Test.timer_start ();
        cep.elements2.elements.deserialize_children ();
        assert (!cep.elements2.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C2: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
				if (f.query_exists ()) f.delete ();
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/hashmap/post-deserialization/enable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new HTopElement ();
        for (int i = 0; i < 30000; i++) {
          var e1 = new HElement ();
          e1.name = "1E"+i.to_string ();
          ce.elements1.elements.set (e1.name, e1);
          var e2 = new HElement ();
          e2.name = "2E"+i.to_string ();
          ce.elements2.elements.set (e2.name, e2);
        }
        assert (ce.elements1.elements.size == 30000);
        assert (ce.elements2.elements.size == 30000);
        ce.serialize (d);
        d.save_as (f);
        assert (d.root != null);
        assert (d.root.children_nodes.size == 2);
        assert (d.root.children_nodes[0].children_nodes.size == 30000);
        assert (d.root.children_nodes[1].children_nodes.size == 30000);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Enable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new HTopElement ();
        cep.elements1.elements.enable_deserialize = true;
        cep.elements2.elements.enable_deserialize = true;
        cep.deserialize (gd);
        assert(cep.elements1.elements.size == 30000);
        assert(cep.elements2.elements.size == 30000);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "GDocument Enable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling C1 deserialize_children()...");
        Test.timer_start ();
        assert (cep.elements1.elements.size == 30000);
        assert (!cep.elements1.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C1: Enable Deserialize Collection. Deserialized from NODE: %g seconds", time);
        Test.message ("Calling C2 deserialize_children()...");
        Test.timer_start ();
        assert (!cep.elements2.elements.deserialize_children ());
        assert (!cep.elements2.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "C2: Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
				if (f.query_exists ()) f.delete ();
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/arraylist/post-deserialization/disable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new CElement ();
        for (int i = 0; i < 30000; i++) {
          var e = new AElement ();
          ce.elements.add (e);
        }
        ce.serialize (d);
        d.save_as (f);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Disable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new CElement ();
        cep.elements.enable_deserialize = false;
        cep.deserialize (gd);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling deserialize_children()...");
        Test.timer_start ();
        cep.elements.deserialize_children ();
        assert (!cep.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Disable Deserialize Collection. Deserialized from NODE: %g seconds", time);
				if (f.query_exists ()) f.delete ();
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/performance/gdocument/arraylist/post-deserialization/enable",
    () => {
      try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
				if (f.query_exists ()) f.delete ();
        double time;
        Test.message ("Starting generating document...");
        Test.timer_start ();
        var d = new GDocument ();
        var ce = new CElement ();
        for (int i = 0; i < 30000; i++) {
          var e = new AElement ();
          ce.elements.add (e);
        }
        ce.serialize (d);
        d.save_as (f);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Created document: %g seconds", time);
        Test.message ("Starting deserializing document: Enable collection deserialization...");
        Test.timer_start ();
        var gd = new GDocument.from_path (GXmlTestConfig.TEST_SAVE_DIR+"/post-des-test-file.xml");
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Opening doc: %g seconds", time);
        Test.message ("Start deseralization of GDocument");
        Test.timer_start ();
        var cep = new CElement ();
        cep.elements.enable_deserialize = true;
        cep.deserialize (gd);
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Enable Deserialize Collection. Deserialized from doc: %g seconds", time);
        Test.message ("Calling deserialize_children()...");
        Test.timer_start ();
        cep.elements.deserialize_children ();
        assert (!cep.elements.deserialize_children ());
        time = Test.timer_elapsed ();
        Test.minimized_result (time, "Enable Deserialize Collection. Deserialized from NODE: %g seconds", time);
				if (f.query_exists ()) f.delete ();
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
  }
}
