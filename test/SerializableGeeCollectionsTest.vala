/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/**
 *
 *  GXml.Serializable.GeeCollectionsTest
 *
 *  Authors:
 *
 *       Daniel Espinosa <esodan@gmail.com>
 *
 *
 *  Copyright (c) 2013-2015 Daniel Espinosa
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using GXml;
using Gee;


class SerializableGeeCollectionsTest : GXmlTest
{
  class Citizen : SerializableObjectModel
  {
    public string ctype { get; set; }
    public string get_value () { return serialized_xml_node_value; }
    public void set_value (string val) { serialized_xml_node_value = val; }
    //Enable set GElement content
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
  class Planet : SerializableContainer, SerializableMapKey<string>
  {
    public string get_map_key () { return name; }
    public string name { get; set; }
    public Citizen.Array citizens { get; set; }
    public Planet.named (string name) { this.name = name; }
    public override string node_name () { return "planet"; }
    public override string to_string () { return name; }

    public override void init_containers ()
    {
      if (citizens == null)
        citizens = new Citizen.Array ();
    }

    public class Collection : SerializableTreeMap<string,Planet> {}
  }
  class Space : SerializableContainer, SerializableMapKey<string>
  {
    public string get_map_key () { return name; }
    public string name { get; set; }
    public Planet.Collection planets { get; set; }
    public Asteroid.Array asteroids { get; set; }
    
    public Space.named (string name) { this.name = name; }
    
    public override string node_name () { return "space"; }
    public override string to_string () { return name; }
    public override void init_containers ()
    {
      if (asteroids == null)
        asteroids = new Asteroid.Array ();
      if (planets == null)
        planets = new Planet.Collection ();
    }
    public class Collection : SerializableTreeMap<string,Space> {}
  }
  class Refaction : SerializableContainer, SerializableMapDualKey<string,string>
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
    public override bool get_enable_unknown_serializable_property () { return true; }

    public override void init_containers ()
    {
      if (spaceships == null)
        spaceships = new SpaceShip.Collection ();
    }

    public class Collection : SerializableDualKeyMap<string,string,Refaction> {}
  }
  class SpaceShip : SerializableContainer, SerializableMapDualKey<string,string>
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
    public override bool get_enable_unknown_serializable_property () { return true; }

    public override void init_containers ()
    {
      if (spaces == null)
        spaces = new Space.Collection ();
    }

    public class Collection : SerializableDualKeyMap<string,string,SpaceShip> {}
  }
  
  class ChargeZone : SerializableContainer
  {
    public string name { get; set; }
    public SpaceShip.Collection spaceships { get; set; }
    
    public override string node_name () { return "ChargeZone"; }
    public override string to_string () { return name; }
    public override void init_containers ()
    {
      if (spaceships == null)
        spaceships = new SpaceShip.Collection ();
    }
  }
  class Storage : SerializableContainer
  {
    public string name { get; set; }
    public Refaction.Collection refactions { get; set; }
    
    public override string node_name () { return "storage"; }
    public override string to_string () { return name; }
    public override void init_containers ()
    {
      if (refactions == null)
        refactions = new Refaction.Collection ();
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

  class BallFill : SerializableObjectModel
  {
    public string name { get; set; default = "Fill"; }
    public void set_text (string txt) { serialized_xml_node_value = txt; }
    public override string to_string () { return name; }
    public override string node_name () { return "BallFill"; }
    public override bool serialize_use_xml_node_value () { return true; }
  }

  class Ball : SerializableObjectModel
  {
    public string name { get; set; default = "Ball"; }
    public BallFill ballfill { get; set; }
    public override string to_string () { return name; }
    public override string node_name () { return "Ball"; }
    public class Array : SerializableArrayList<Ball> {
      public override bool deserialize_proceed () { return false; }
    }
  }

  class SmallBag : SerializableObjectModel
  {
    public string name { get; set; default = "SmallBag"; }
    public Ball.Array balls { get; set; default = new Ball.Array (); }
    public override string to_string () { return name; }
    public override string node_name () { return "SmallBag"; }
    public class Array : SerializableArrayList<SmallBag> {
      public override bool deserialize_proceed () { return false; }
    }
  }

  class BigBag : SerializableObjectModel
  {
    public string name { get; set; default = "ball"; }
    public SmallBag.Array bags { get; set; default = new SmallBag.Array (); }
    public override string to_string () { return name; }
    public override string node_name () { return "BigBag"; }
  }

  public static void add_tests ()
  {
    Test.add_func ("/gxml/serializable/convined_gee_containers/deserialize",
    () => {
      try {
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
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
        var doc = new GDocument.from_string ("""<?xml version="1.0"?>
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
        var ndoc = new GDocument ();
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
        if (ndoc.root == null) {
          stdout.printf ("ERROR: No ROOT element\n");
          assert_not_reached ();
        }
        if (ndoc.root.name != "base") {
          stdout.printf ("ERROR: Bad ROOT name\n");
          assert_not_reached ();
        }
        assert (ndoc.root.children.size > 0);
        int i = 0;
        foreach (GXml.Node n in ndoc.root.children)
        {
          i++;
          if (n is Text) { if (n.value != "") assert_not_reached (); }
          if (n.name == "ChargeZone") {
            foreach (GXml.Node cn in n.children)
            {
              if (n is Text) { if (n.value != "") assert_not_reached (); }
              
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
    Test.add_func ("/gxml/serializable/convined_gee_containers/se-deserialize-unknowns",
    () => {
      try {
        var org_doc = new GDocument.from_string ("""<?xml version="1.0"?>
<base name="AlphaOne" >
  <chargezone name="A1-1">
    <ship manufacturer="MacToy" model="A1234">
      <space name="Alpha Centaury">
        <planet name="Earth">
          <citizen ctype="Human">1M</citizen>
          <citizen ctype="Ghost">10M</citizen>
        </planet>
        <planet name="Galiumt" />
      </space>
      <space name="Galax">
        <planet name="Saminon">
          <citizen ctype="Humanes">100M</citizen>
          <citizen ctype="Jeties">1000M</citizen>
        </planet>
        <planet name="Keymanth" />
      </space>
    </ship>
    <ship manufacturer="Memphis" model="AB1">
      <space name="Proximity">
        <planet name="Pluton">
          <citizen ctype="Ork">10000M</citizen>
          <citizen ctype="Gyk">100000M</citizen>
        </planet>
        <planet name="Mercury" />
      </space>
    </ship>
  </chargezone>
  <storage name="B4-A4">
    <refaction manufacturer="MacToy" model="Fly045">
      <ship manufacturer="MacToy" model="A1234" />
      <ship manufacturer="MegaTrench" model="G045-1" unknown="UNKNOWN ATTR">TEST_TEXT</ship>
      <UnknownAttribute name="nothing" />
    </refaction>
  </storage>
</base>""");
        var s = new SpaceBase ();
        s.deserialize (org_doc);
        if (s.charge_zone == null) {
          stdout.printf (@"ERROR: No charge Zone for $(s.name)\n");
          assert_not_reached ();
        }
        if (s.charge_zone.spaceships.size != 2) {
          stdout.printf (@"ERROR: Bad SpaceShip size: $(s.charge_zone.spaceships.size)\n");
          assert_not_reached ();
        }
        var mssh = s.charge_zone.spaceships.@get ("MacToy","A1234");
        if (mssh == null) {
          stdout.printf (@"ERROR: No spaceship MacToy/A1234\n");
          assert_not_reached ();
        }
        
        if (s.storage == null) {
          stdout.printf (@"ERROR: No storage\n");
          assert_not_reached ();
        }
        if (mssh.spaces.size != 2) {
          stdout.printf (@"ERROR: Bad spaces number for MacToy/A1234: $(mssh.spaces.size)\n");
          assert_not_reached ();
        }
        if (s.storage == null) {
          stdout.printf (@"ERROR: No storage\n");
          assert_not_reached ();
        }
        if (s.storage.refactions.size != 1) {
          stdout.printf (@"ERROR: Bad number of refactions: got $(s.storage.refactions.size)\n");
          assert_not_reached ();
        }
        var refaction = s.storage.refactions.@get ("MacToy","Fly045");
        if (refaction == null) {
          stdout.printf (@"ERROR: No Refaction MacToy/Fly045 found!\n");
          assert_not_reached ();
        }
        var ups = refaction.unknown_serializable_properties;
        assert (ups != null);
        assert (ups.size == 0);
        var uns = refaction.unknown_serializable_nodes;
#if DEBUG
        GLib.message (@"Unknown nodes: $(uns.size.to_string ())");
        foreach (GXml.Node n in uns) {
          GLib.message ("Uknown node: "+n.name);
        }
#endif
        assert (uns.size == 5); // 4 texts 1 node
        var doc = new GDocument ();
        s.serialize (doc);
        if (doc.root.name != "base") {
          stdout.printf (@"ERROR: bad root node name\n");
          assert_not_reached ();
        }
        //stdout.printf (@"$doc\n");
        foreach (GXml.Node n in doc.root.children) {
          if (n is GElement) {
            if (n.name == "ChargeZone") {
              
            }
            if (n.name == "storage") {
              bool unkfound = false;
              bool tfound = false;
              bool attrfound = false;
              foreach (GXml.Node sn in n.children) {
                if (sn is GElement) {
                  if (sn.name == "refaction") {
                    foreach (GXml.Node rn in sn.children) {
                      if (rn is GElement) {
                        //stdout.printf (@"Refaction current node: '$(rn.name)'\n");
                        if (rn.name == "ship") {
                          var atr = ((GElement) rn).get_attr ("manufacturer");
                          if (atr == null) {
                            stdout.printf (@"ERROR: No attribute manufacturer for Ship\n");
                            assert_not_reached ();
                          }
                          if (atr.value == "MegaTrench") {
                            var shanattr = ((GElement) rn).get_attr ("unknown");
                            if (shanattr != null) {
                              attrfound = true;
                              if (shanattr.value != "UNKNOWN ATTR") {
                                stdout.printf (@"ERROR: Invalid Text Node Value for ship MegaTrench: $(shanattr.value)\n");
                                assert_not_reached ();
                              }
                            }
                            foreach (GXml.Node shn in rn.children) {
                              //stdout.printf (@"Refaction: Ship MegaTrench: Node: $(shn.name)\n");
                              if (shn is Text) {
                                tfound = true;
                                if (shn.value != "TEST_TEXT") {
                                  stdout.printf (@"ERROR: Invalid Text Node Value for ship MegaTrench: $(shn.value)\n");
                                  assert_not_reached ();
                                }
                              }
                            }
                          }
                        }
                        if (rn.name == "UnknownAttribute") {
                          unkfound = true;
                          var nattr = ((GElement) rn).get_attr ("name");
                          if (nattr == null) {
                            stdout.printf (@"ERROR: No Unknown Attribute Node with attribute name\n");
                            assert_not_reached ();
                          }
                          if (nattr.value != "nothing") {
                            stdout.printf (@"ERROR: Invalid unknown attribute node's attribute name value: found $(nattr.value)\n");
                            assert_not_reached ();
                          }
                        }
                      }
                    }
                  }
                }
              }
              if (!attrfound) {
                stdout.printf (@"ERROR: No Unknown AttributeText found for ship MegaTrench\n");
                assert_not_reached ();
              }
              if (!tfound) {
                stdout.printf (@"ERROR: No Text Node Value found for ship MegaTrench\n");
                assert_not_reached ();
              }
              if (!unkfound) {
                stdout.printf (@"ERROR: No Unknown Attribute Node found for storage\n");
                assert_not_reached ();
              }
            }
          }
          if (n is Text) {
            stdout.printf (@"ROOT NODE VALUE: '$(n.value)'\n");
          }
        }
    }
      catch (GLib.Error e) {
        stdout.printf (@"ERROR: $(e.message)");
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/serializable/containers/post-deserialization/serialize",
    () => {
      try {
        // Construct Bag contents
        var bag = new BigBag ();
        assert (bag.bags != null);
        for (int i = 0; i < 2; i++) {
          var sbag = new SmallBag ();
          assert (sbag.balls != null);
          for (int j = 0; j < 2; j++) {
            var b = new Ball ();
            sbag.balls.add (b);
          }
          assert (sbag.balls.size == 2);
          bag.bags.add (sbag);
        }
        assert (bag.bags.size == 2);
        // Construct XML
        var d = new TwDocument ();
        bag.serialize (d);
        assert (d.root != null);
        assert (d.root.name == "BigBag");
        assert (d.root.children.size == 2);
        assert (d.root.children[0].name == "SmallBag");
        assert (d.root.children[0].children.size == 2);
        assert (d.root.children[0].children[0].name == "Ball");
        // Deserialize
        var bag2 = new BigBag ();
        bag2.deserialize (d);
        assert (bag2.bags.size == 0);
        // Serialize
        var d2 = new TwDocument ();
        bag2.serialize (d2);
        assert (d2.root != null);
        assert (d2.root.name == "BigBag");
        assert (d2.root.children.size == 2);
        assert (d2.root.children[0].name == "SmallBag");
        assert (d2.root.children[0].children.size == 2);
        assert (d2.root.children[0].children[0].name == "Ball");
      } catch (GLib.Error e) {
        GLib.message ("ERROR: "+e.message);
        assert_not_reached ();
      }
    });
  }
}
