using GXml;
using Gee;

class AElement : SerializableObjectModel
{
  public string name { get; set; }
  public AElement.named (string name) { this.name = name; }
  public override string to_string () { return name; }
}

class SerializableGeeArrayListTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/serializable_array_list/api",
    () => {
      try {
        var c = new SerializableArrayList<AElement> ();
        var o1 = new AElement.named ("Big");
        var o2 = new AElement.named ("Small");
        c.add (o1);
        c.add (o2);
        bool found1 = false;
        bool found2 = false;
        foreach (AElement o in c) {
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
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
      }
    });
    Test.add_func ("/gxml/serializable/serializable_array_list/serialize",
    () => {
      try {
        var c = new SerializableArrayList<AElement> ();
        var o1 = new AElement.named ("Big");
        var o2 = new AElement.named ("Small");
        c.add (o1);
        c.add (o2);
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
          if (n is Element && n.node_name == "aelement") {
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
    Test.add_func ("/gxml/serializable/serializable_array_list/deserialize",
    () => {
      try {
        var doc = new Document.from_string ("""<?xml version="1.0"?>
  <root><aelement name="Big"/><aelement name="Small"/></root>""");
        var c = new SerializableArrayList<AElement> ();
        c.deserialize (doc.document_element);
        if (c.size != 2) {
          stdout.printf (@"ERROR: incorrect size must be 2 got: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        foreach (AElement o in c) {
          if (o.name == "Big") found1 = true;
          if (o.name == "Small") found2 = true;
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
