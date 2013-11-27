using GXml;
using Gee;



class SerializableGeeCollectionsTest : GXmlTest
{
  class Planet : SerializableObjectModel, SerializableMapId<string>
  {
    public string id () { return name; }
    public string name { get; set; }
    public Planet.named (string name) { this.name = name; }
    public override string node_name () { return "planet"; }
    public override string to_string () { return name; }

    public class Collection : SerializableTreeMap<string,Planet> {}
  }
  class Space : SerializableObjectModel, SerializableMapId<string>
  {
    public string id () { return name; }
    public string name { get; set; }
    public Planet.Collection planets { get; set; }
    
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
  class Refaction : SerializableObjectModel, SerializableMapDualId<string,string>
  {
    public string model { get; set; }
    public string manufacturer { get; set; }
    public SpaceShip.Collection spaceships { get; set; }

    public Refaction.named (string manufacturer, string model)
    {
      this.manufacturer = manufacturer;
      this.model = model;
    }
    
    public string primary_id () { return manufacturer; }
    public string secondary_id () { return model; }
    
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
  class SpaceShip : SerializableObjectModel, SerializableMapDualId<string,string>
  {
    public string model { get; set; }
    public string manufacturer { get; set; }
    public Space.Collection tested { get; set; }

    public SpaceShip.named (string manufacturer, string model)
    {
      this.manufacturer = manufacturer;
      this.model = model;
    }
    
    public string primary_id () { return manufacturer; }
    public string secondary_id () { return model; }
    
    public override string node_name () { return "ship"; }
    public override string to_string () { return model; }
    public override GXml.Node? deserialize (GXml.Node node)
                                    throws GLib.Error
                                    requires (node is GXml.Element)
    {
      Element element = (Element) node;
      if (element.has_child_nodes ()) {
        if (tested == null)
          tested = new Space.Collection ();
        tested.deserialize (element);
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
        if (ship.tested.size != 1) {
          stdout.printf (@"ERROR: Ship: incorrect size must be 1 got : $(ship.tested.size)\n$(doc)\n");
          assert_not_reached ();
        }
        var space = ship.tested.@get ("Alpha Centaury");
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
  }
}
