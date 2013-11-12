using GXml;
using Gee;

class Space : SerializableObjectModel, SerializableMapId<string>
{
  public string id () { return name; }
  public string name { get; set; }
  public Space.named (string name) { this.name = name; }
  public override string to_string () { return name; }
}

class SerializableGeeTreeMapTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/serializable_tree_map/api",
    () => {
      try {
        var c = new SerializableTreeMap<string,Space> ();
        var o1 = new Space.named ("Big");
        var o2 = new Space.named ("Small");
        c.set (o1.name, o1);
        c.set (o2.name, o2);
        bool found1 = false;
        bool found2 = false;
        foreach (Space o in c.values) {
          if (o.name == "Big") found1 = true;
          if (o.name == "Small") found2 = true;
        }
        if (!found1) {
          stdout.printf (@"Big is not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"Small is not found\n");
          assert_not_reached ();
        }
        found1 = found2 = false;
        foreach (string k in c.keys) {
          if ((c.@get (k)).name == "Big") found1 = true;
          if ((c.@get (k)).name == "Small") found2 = true;
        }
        if (!found1) {
          stdout.printf (@"Big key value is not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"Small key value is not found\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
      }
    });
    Test.add_func ("/gxml/serializable/serializable_tree_map/serialize",
    () => {
      try {
        var c = new SerializableTreeMap<string,Space> ();
        var o1 = new Space.named ("Big");
        var o2 = new Space.named ("Small");
        c.set (o1.name, o1);
        c.set (o2.name, o2);
        var doc = new Document ();
        var root = doc.create_element ("root");
        doc.append_child (root);
        c.serialize (root);
        if (!root.has_child_nodes ()) {
          stdout.printf (@"ERROR: root node have no childs $(doc)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (GXml.Node n in root.child_nodes) {
          if (n is Element && n.node_name == "space") {
            var name = ((Element) n).get_attribute_node ("name");
            if (name != null) {
              if (name.node_value == "Big") found1 = true;
              if (name.node_value == "Small") found2 = true;
            }
          }
        }
        if (!found1) {
          stdout.printf (@"ERROR: Big space node is not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: Small space node is not found\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/serializable_tree_map/deserialize",
    () => {
      try {
        var doc = new Document.from_string ("""<?xml version="1.0"?>
  <root><space name="Big"/><space name="Small"/></root>""");
        var c = new SerializableTreeMap<string,Space> ();
        c.deserialize (doc.document_element);
        if (c.size != 2) {
          stdout.printf (@"ERROR: incorrect size must be 2 got: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (string k in c.keys) {
          if ((c.@get (k)).name == "Big") found1 = true;
          if ((c.@get (k)).name == "Small") found2 = true;
        }
        if (!found1) {
          stdout.printf (@"ERROR: Big key value is not found\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: Small key value is not found\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
  }
}
