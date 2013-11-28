using GXml;
using Gee;

class Spaces : SerializableObjectModel, SerializableMapDualKey<string,string>
{
  public string get_map_primary_key  () { return owner; }
  public string get_map_secondary_key () { return name; }
  public string name { get; set; }
  public string owner { get; set; }
  public Spaces.full ( string owner, string name)
  {
    this.name = name;
    this.owner = owner;
  }
  public override void init_properties ()
  {
    default_init_properties ();
  }
  public override string to_string () { return name; }
}

class SerializableGeeDualKeyMapTest : GXmlTest
{
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/serializable_dual_key_map/api",
    () => {
      try {
        var c = new SerializableDualKeyMap<string,string,Spaces> ();
        var o1 = new Spaces.full ("Floor", "Big");
        var o2 = new Spaces.full ("Wall", "Small");
        var o3 = new Spaces.full ("Floor", "Bigger");
        var o4 = new Spaces.full ("Wall","Smallest");
        c.set (o1.owner, o1.name, o1);
        c.set (o2.owner, o2.name, o2);
        c.set (o3.owner, o3.name, o3);
        c.set (o4.owner, o4.name, o4);
        if (c.size != 4) {
          stdout.printf (@"SIZE: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        bool found3 = false;
        bool found4 = false;
        foreach (Spaces s in c.values ()) {
          if (s.owner == "Floor" && s.name == "Big")
            found1 = true;
          if (s.owner == "Wall" && s.name == "Small")
            found2 = true;
          if (s.owner == "Floor" && s.name == "Bigger")
            found3 = true;
          if (s.owner == "Wall" && s.name == "Smallest")
            found4 = true;
        }
        if (!found1) {
          stdout.printf (@"Not found 'Floor' & 'Big':\n");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"Not found 'Wall' & 'Small':\n");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"Not found 'Floor' & 'Bigger':\n");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"Not found 'Wall' & 'Smallest':\n");
          assert_not_reached ();
        }
        found1 = found3 = false;
        foreach (Spaces s in c.values_for_key ("Floor")) {
          if (s.owner == "Floor" && s.name == "Big")
            found1 = true;
          if (s.owner == "Floor" && s.name == "Bigger")
            found3 = true;
        }
        if (!found1) {
          stdout.printf (@"Not found 'Floor' & 'Big':\n");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"Not found 'Floor' & 'Bigger':\n");
          assert_not_reached ();
        }
        found2 = found4 = true;
        foreach (string k2 in c.secondary_keys ("Wall")) {
          var s = c.get ("Wall", k2);
          if (s.owner == "Wall" && s.name == "Small")
            found2 = true;
          if (s.owner == "Wall" && s.name == "Smallest")
            found4 = true;
        }
        if (!found2) {
          stdout.printf (@"Not found 'Wall' & 'Small':\n");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"Not found 'Wall' & 'Smallest':\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
      }
    });
    Test.add_func ("/gxml/serializable/serializable_dual_key_map/serialize",
    () => {
      try {
        var c = new SerializableDualKeyMap<string,string,Spaces> ();
        var o1 = new Spaces.full ("Floor", "Big");
        var o2 = new Spaces.full ("Wall", "Small");
        var o3 = new Spaces.full ("Floor", "Bigger");
        var o4 = new Spaces.full ("Wall","Smallest");
        c.set (o1.owner, o1.name, o1);
        c.set (o2.owner, o2.name, o2);
        c.set (o3.owner, o3.name, o3);
        c.set (o4.owner, o4.name, o4);
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
        bool found3 = false;
        bool found4 = false;
        foreach (GXml.Node n in root.child_nodes) {
          if (n is Element && n.node_name == "spaces") {
            var name = ((Element) n).get_attribute_node ("name");
            var owner = ((Element) n).get_attribute_node ("owner");
            if (name != null && owner != null) {
              if (name.node_value == "Big" && owner.node_value == "Floor") found1 = true;
              if (name.node_value == "Small" && owner.node_value == "Wall") found2 = true;
              if (name.node_value == "Bigger" && owner.node_value == "Floor") found3 = true;
              if (name.node_value == "Smallest" && owner.node_value == "Wall") found4 = true;
            }
          }
        }
        if (!found1) {
          stdout.printf (@"ERROR: 'Big' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: 'Small' / 'Wall' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"ERROR: 'Bigger' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"ERROR: 'Smallest' / 'Wall' not found\n$(doc)");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/serializable_dual_key_map/deserialize",
    () => {
      try {
        var doc = new Document.from_string ("""<?xml version="1.0"?>
<root><spaces name="Small" owner="Wall"/><spaces name="Smallest" owner="Wall"/><spaces name="Big" owner="Floor"/><spaces name="Bigger" owner="Floor"/><spark /></root>""");
        var c = new SerializableDualKeyMap<string,string,Spaces> ();
        c.deserialize (doc.document_element);
        if (c.size != 4) {
          stdout.printf (@"ERROR: incorrect size must be 4 got: $(c.size)\n");
          assert_not_reached ();
        }
        bool found1 = false;
        bool found2 = false;
        bool found3 = false;
        bool found4 = false;
        foreach (Spaces s in c.values ()) {
          if (s.owner == "Floor" && s.name == "Big") found1 = true;
          if (s.owner == "Wall" && s.name == "Small") found2 = true;
          if (s.owner == "Floor" && s.name == "Bigger") found3 = true;
          if (s.owner == "Wall" && s.name == "Smallest") found4 = true;
        }
        if (!found1) {
          stdout.printf (@"ERROR: 'Big' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found2) {
          stdout.printf (@"ERROR: 'Small' / 'Wall' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found3) {
          stdout.printf (@"ERROR: 'Bigger' / 'Floor' not found\n$(doc)");
          assert_not_reached ();
        }
        if (!found4) {
          stdout.printf (@"ERROR: 'Smallest' / 'Wall' not found\n$(doc)");
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
