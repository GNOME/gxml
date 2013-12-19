using GXml;
using Gee;



class SerializableGeeCollectionsTest : GXmlTest
{
  class Citizen : SerializableObjectModel
  {
    public string ctype { get; set; }
    public string get_value () { return serialized_xml_node_value; }
    public void set_value (string val) { serialized_xml_node_value = val; }
    //Enable set Element content
    public override bool serialize_use_xml_node_value () { return true; }
    public override string to_string () { return @"Citizen: $ctype"; }
    public override string node_name () { return "citizen"; }

    public class Array : SerializableArrayList<Citizen> {}
  }
  class Asteroid : SerializableObjectModel
  {
    public int size { get; set; }
    public Asteroid.with_size (int size) { this.size = size; }
    public string get_value () { return serialized_xml_node_value; }
    public void set_value (string val) { serialized_xml_node_value = val; }
    public override string to_string () { return @"$size"; }
    public override string node_name () { return "asteroid"; }
    
    public class Array : SerializableArrayList<Asteroid> {}
  }
  class Planet : SerializableObjectModel, SerializableMapKey<string>
  {
    public string get_map_key () { return name; }
    public string name { get; set; }
    public Citizen.Array citizens { get; set; }
    public Planet.named (string name) { this.name = name; }
    public override string node_name () { return "planet"; }
    public override string to_string () { return name; }
    public override GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node is GXml.Element)
    {
      Element element = (Element) node;
      if (element.has_child_nodes ()) {
        if (citizens == null)
          citizens = new Citizen.Array ();
        citizens.deserialize (element);
      }
      return default_deserialize (node);
    }

    public class Collection : SerializableTreeMap<string,Planet> {}
  }
  class Space : SerializableObjectModel, SerializableMapKey<string>
  {
    public string get_map_key () { return name; }
    public string name { get; set; }
    public Planet.Collection planets { get; set; }
    public Asteroid.Array asteroids { get; set; }
    
    public Space.named (string name) { this.name = name; }
    
    public override string node_name () { return "space"; }
    public override string to_string () { return name; }
    public override GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node is GXml.Element)
    {
      Element element = (Element) node;
      if (element.has_child_nodes ()) {
        if (planets == null)
          planets = new Planet.Collection ();
        planets.deserialize (element);
      }
      return default_deserialize (node);
    }

    public class Collection : SerializableTreeMap<string,Space> {}
  }
  class Refaction : SerializableObjectModel, SerializableMapDualKey<string,string>
  {
    public string model { get; set; }
    public string manufacturer { get; set; }
    public SpaceShip.Collection spaceships { get; set; }

    public Refaction.named (string manufacturer, string model)
    {
      this.manufacturer = manufacturer;
      this.model = model;
    }
    
    public string get_map_primary_key () { return manufacturer; }
    public string get_map_secondary_key () { return model; }
    
    public override string node_name () { return "refaction"; }
    public override string to_string () { return model; }
    public override GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node is GXml.Element)
    {
      Element element = (Element) node;
      if (element.has_child_nodes ()) {
        if (spaceships == null)
          spaceships = new SpaceShip.Collection ();
        spaceships.deserialize (element);
      }
      return default_deserialize (node);
    }

    public class Collection : SerializableDualKeyMap<string,string,Refaction> {}
  }
  class SpaceShip : SerializableObjectModel, SerializableMapDualKey<string,string>
  {
    public string model { get; set; }
    public string manufacturer { get; set; }
    public Space.Collection spaces { get; set; }

    public SpaceShip.named (string manufacturer, string model)
    {
      this.manufacturer = manufacturer;
      this.model = model;
    }
    
    public string get_map_primary_key () { return manufacturer; }
    public string get_map_secondary_key () { return model; }
    
    public override string node_name () { return "ship"; }
    public override string to_string () { return model; }
    public override GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node is GXml.Element)
    {
      Element element = (Element) node;
      if (element.has_child_nodes ()) {
        if (spaces == null)
          spaces = new Space.Collection ();
        spaces.deserialize (element);
      }
      return default_deserialize (node);
    }

    public class Collection : SerializableDualKeyMap<string,string,SpaceShip> {}
  }
  
  class ChargeZone : SerializableObjectModel
  {
    public string name { get; set; }
    public SpaceShip.Collection spaceships { get; set; }
    
    public override string node_name () { return "ChargeZone"; }
    public override string to_string () { return name; }
    public override GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node is Element)
    {
      var element = (Element) node;
      if (element.has_child_nodes ()) {
        if (spaceships == null)
          spaceships = new SpaceShip.Collection ();
        spaceships.deserialize (element);
      }
      return default_deserialize (node);
    }
  }
  class Storage : SerializableObjectModel
  {
    public string name { get; set; }
    public Refaction.Collection refactions { get; set; }
    
    public override string node_name () { return "storage"; }
    public override string to_string () { return name; }
    public override GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node is Element)
    {
      var element = (Element) node;
      if (element.has_child_nodes ()) {
        if (refactions == null)
          refactions = new Refaction.Collection ();
        refactions.deserialize (element);
      }
      return default_deserialize (node);
    }
  }

  class SpaceBase : SerializableObjectModel
  {
    public string name { get; set; }
    public ChargeZone charge_zone { get; set; }
    public Storage storage { get; set; }
    public override string node_name () { return "base"; }
    public override string to_string () { return name; }
  }
  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/convined_gee_containers/deserialize",
    () => {
      try {
        var doc = new Document.from_string ("""<?xml version="1.0"?>
<base name="AlphaOne" >
  <chargezone name="A1-1">
    <ship manufacturer="MacToy" model="A1234">
      <space name="Alpha Centaury">
        <planet name="Earth" />
        <planet name="Platon" />
      </space>
    </ship>
  </chargezone>
  <storage name="B4-A4">
    <refaction manufacturer="MacToy" model="Fly045">
      <ship manufacturer="MacToy" model="A1234" />
      <ship manufacturer="MegaTrench" model="G045-1" />
    </refaction>
  </storage>
</base>""");
        var b = new SpaceBase ();
        b.deserialize (doc);
        // Storage
        if (b.storage == null) {
          stdout.printf (@"ERROR: no storage exists:\n$(doc)\n");
          assert_not_reached ();
        }
        var storage = b.storage;
        if (storage.refactions == null) {
          stdout.printf (@"ERROR: no refactions exists:\n$(doc)\n");
          assert_not_reached ();
        }
        if (storage.refactions.size != 1) {
          stdout.printf (@"ERROR: Storage: incorrect size must be 1 got : $(storage.refactions.size)\n$(doc)\n");
          assert_not_reached ();
        }
        var refaction = storage.refactions.@get ("MacToy", "Fly045");
        if (refaction == null) {
          stdout.printf (@"ERROR: no refaction MacToy / Fly045 exists:\n$(doc)\n");
          assert_not_reached ();
        }
        if (refaction.spaceships.size != 2) {
          stdout.printf (@"ERROR: Refaction: incorrect size must be 2 got : $(refaction.spaceships.size)\n$(doc)\n");
          assert_not_reached ();
        }
        var ship1 = refaction.spaceships.@get ("MacToy", "A1234");
        if (ship1 == null) {
          stdout.printf (@"ERROR: no refaction for Ship MacToy / A1234 exists:\n$(doc)\n");
          assert_not_reached ();
        }
        var ship2 = refaction.spaceships.@get ("MegaTrench", "G045-1");
        if (ship2 == null) {
          stdout.printf (@"ERROR: no refaction for Ship MegaTrench / G045-1 exists:\n$(doc)\n");
          assert_not_reached ();
        }
        // ChargeZone
        if (b.charge_zone == null) {
          stdout.printf (@"ERROR: no charge_zone exists:\n$(doc)\n");
          assert_not_reached ();
        }
        var charge = b.charge_zone;
        if (charge.spaceships == null) {
          stdout.printf (@"ERROR: no spaceships exists:\n$(doc)\n");
          assert_not_reached ();
        }
        if (charge.spaceships.size != 1) {
          stdout.printf (@"ERROR: SpaceShips: incorrect size must be 1 got: $(charge.spaceships.size)\n$(doc)\n");
          assert_not_reached ();
        }
        var ship = charge.spaceships.@get ("MacToy", "A1234");
        if (ship == null) {
          stdout.printf (@"ERROR: Ship MacToy/A1234 not found:\n$(doc)\n");
          assert_not_reached ();
        }
        if (ship.spaces.size != 1) {
          stdout.printf (@"ERROR: Ship: incorrect size must be 1 got : $(ship.spaces.size)\n$(doc)\n");
          assert_not_reached ();
        }
        var space = ship.spaces.@get ("Alpha Centaury");
        if (space == null) {
          stdout.printf (@"ERROR: Space Alpha Centaury not found:\n$(doc)\n");
          assert_not_reached ();
        }
        if (space.planets.size != 2) {
          stdout.printf (@"ERROR: Space size incorrect, must be 2 got:$(space.planets.size)\n$(doc)\n");
          assert_not_reached ();
        }
        var earth = space.planets.@get("Earth");
        if (earth == null) {
          stdout.printf (@"ERROR: Planet Earth not found:\n$(doc)\n");
          assert_not_reached ();
        }
        var platon = space.planets.@get("Platon");
        if (platon == null) {
          stdout.printf (@"ERROR: Planet Platon not found:\n$(doc)\n");
          assert_not_reached ();
        }
      }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/convined_gee_containers/de-se-deserialize",
    () => {
      try {
        var doc = new Document.from_string ("""<?xml version="1.0"?>
<base name="AlphaOne" >
  <chargezone name="A1-1">
    <ship manufacturer="MacToy" model="A1234">
      <space name="Alpha Centaury">
        <planet name="Earth">
          <citizen ctype="Human">1M</citizen>
          <citizen ctype="Ghost">10M</citizen>
        </planet>
        <planet name="Platon" />
      </space>
      <space name="Galax">
        <planet name="Saminon">
          <citizen ctype="Humanes">100M</citizen>
          <citizen ctype="Jeties">1000M</citizen>
        </planet>
        <planet name="Platon" />
      </space>
    </ship>
    <ship manufacturer="Memphis" model="AB1">
      <space name="Alpha Centaury">
        <planet name="Earth">
          <citizen ctype="Human">10000M</citizen>
          <citizen ctype="Ghost">100000M</citizen>
        </planet>
        <planet name="Platon" />
      </space>
    </ship>
  </chargezone>
  <storage name="B4-A4">
    <refaction manufacturer="MacToy" model="Fly045">
      <ship manufacturer="MacToy" model="A1234" />
      <ship manufacturer="MegaTrench" model="G045-1" />
    </refaction>
  </storage>
</base>""");
        var s = new SpaceBase ();
        s.deserialize (doc);
        if (s.charge_zone == null) {
          stdout.printf (@"ERROR: (1de) No charge zone\n");
          assert_not_reached ();
        }
        if (s.charge_zone.spaceships == null) {
          stdout.printf (@"ERROR: (1de) No spaceships\n");
          assert_not_reached ();
        }
        if (s.charge_zone.spaceships.size != 2) {
          stdout.printf (@"ERROR: (1de) incorrect spaceships number. Expected 2, got $(s.charge_zone.spaceships.size)\n");
          assert_not_reached ();
        }
        var s1 = s.charge_zone.spaceships.get ("MacToy", "A1234");
        if (s1 == null) {
          stdout.printf (@"ERROR: No spaceship MacToy/A1234 found\n");
          assert_not_reached ();
        }
        if (s1.spaces == null) {
          stdout.printf (@"ERROR: No spaces for spaceship MacToy/A1234 found\n");
          assert_not_reached ();
        }
        if (s1.spaces.size != 2) {
          stdout.printf (@"ERROR: Incorrect spaces size for spaceship MacToy/A1234. Expected 2, got: $(s1.spaces.size)\n");
          assert_not_reached ();
        }
        // Check First serialize
        var ndoc = new Document ();
        s.serialize (ndoc);
        var ns = new SpaceBase ();
        ns.deserialize (ndoc);
        if (ns.serialized_xml_node_value != null) {
          stdout.printf (@"ERROR: wrong base node content, should be '' got: '$(ns.serialized_xml_node_value)''");
          assert_not_reached ();
        }
        if (ns.charge_zone.spaceships.size != 2) {
          stdout.printf (@"ERROR: wrong spaceships size. Expected 2, got: $(ns.charge_zone.spaceships.size)\n");
          foreach (SpaceShip sh in ns.charge_zone.spaceships.values ()) {
            stdout.printf (@"Ship: $(sh.manufacturer)\n");
          }
          stdout.printf (@"$ndoc");
          assert_not_reached ();
        }
        var chip = ns.charge_zone.spaceships.get ("MacToy","A1234");
        if (chip.spaces.size != 2) {
          stdout.printf (@"ERROR: wrong spaces size. Expected 2, got: $(chip.spaces.size)");
          assert_not_reached ();
        }
        // Check xml structure
        if (ndoc.document_element == null) {
          stdout.printf ("ERROR: No ROOT element\n");
          assert_not_reached ();
        }
        if (ndoc.document_element.node_name != "base") {
          stdout.printf ("ERROR: Bad ROOT name\n");
          assert_not_reached ();
        }
        if (!ndoc.document_element.has_child_nodes ()) {
          stdout.printf ("ERROR: No ROOT's child nodes\n");
          assert_not_reached ();
        }
        int i = 0;
        foreach (GXml.Node n in ndoc.document_element.child_nodes)
        {
          i++;
          if (n is Text) { if (n.node_value != "") assert_not_reached (); }
          if (n.node_name == "ChargeZone") {
            foreach (GXml.Node cn in n.child_nodes)
            {
              if (n is Text) { if (n.node_value != "") assert_not_reached (); }
              
            }
          }
        }
        if (i != 2) {
          stdout.printf (@"ERROR: Bad ROOT child nodes. Expected 5, got $(i)\n");
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
