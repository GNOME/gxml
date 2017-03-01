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

class SerializableGeeCollectionsTDocumentTest : GXmlTest
{
  class Citizen : SerializableObjectModel
  {
    public string ctype { get; set; }
    public override bool serialize_use_xml_node_value () { return true; }
    public override string to_string () { return @"Citizen: $ctype"; }
    public override string node_name () { return "citizen"; }

    public class Array : SerializableArrayList<Citizen> {}
  }
  class Asteroid : SerializableObjectModel
  {
    public int size { get; set; }
    public Asteroid.with_size (int size) { this.size = size; }
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

  public static void add_tests ()
  {
    Test.add_func ("/gxml/tw/serializable/convined_gee_containers/de-se-deserialize",
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
      <space name="Beta Centaury">
        <planet name="Tronex">
          <citizen ctype="Human">10000M</citizen>
          <citizen ctype="Cat">100000M</citizen>
        </planet>
        <planet name="Palax" />
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
        var sb = new SpaceBase ();
        // TODO: implement deserialize TDocument
        sb.deserialize (doc);
        assert (sb.charge_zone != null);
        assert (sb.charge_zone.spaceships != null);
        assert (sb.charge_zone.spaceships.size == 2);
        var sbsh1 = sb.charge_zone.spaceships.get ("MacToy", "A1234");
        assert (sbsh1 != null);
        assert (sbsh1.spaces != null);
        assert (sbsh1.spaces.size == 2);
        // Check serialize
        var ndoc = new TDocument ();
        sb.serialize (ndoc);
        assert (ndoc.root != null);
        assert (ndoc.root.name == "base");
        assert (ndoc.root.children_nodes.size == 2);
        var cz = ndoc.root.children_nodes.get (0);
        assert (cz != null);
        assert (cz.name.down () == "chargezone");
        assert (cz.attrs.get ("name").value == "A1-1");
        assert (cz.children_nodes.size == 2);
        bool fmactoy = false;
        bool fmemphis = false;
        foreach (GXml.Node sh in cz.children_nodes) {
          if (sh.name == "ship" && sh.attrs.get ("manufacturer").value == "MacToy") {
            fmactoy = true;
            assert (sh.attrs.get ("manufacturer").value == "MacToy");
            assert (sh.attrs.get ("model").value == "A1234");
            assert (sh.children_nodes.size == 5); // 2 nodes 3 texts (identation)
            bool falphac = false;
            bool fgalax = false;
            foreach (GXml.Node s in sh.children_nodes){
              if (s.name == "space" && s.attrs.get ("name").value == "Alpha Centaury") {
                falphac = true;
                assert (s.attrs.get ("name").value == "Alpha Centaury");
                assert (s.children_nodes.size == 2);
                bool fearth = false;
                bool fplaton = false;
                foreach (GXml.Node p1 in s.children_nodes) {
                  if (p1.name == "planet" && p1.attrs.get ("name").value == "Earth") {
                    fearth = true;
                    assert (p1.name == "planet");
                    assert (p1.attrs.get ("name").value == "Earth");
                    assert (p1.children_nodes.size == 2);
                    var c1 = p1.children_nodes.get (0);
                    assert (c1 != null);
                    assert (c1.name == "citizen");
                    assert (c1.attrs.get ("ctype").value == "Human");
                    assert (((Element)c1).content == "1M");
                    assert (c1.children_nodes.size == 1);
                    var c2 = p1.children_nodes.get (1);
                    assert (c2 != null);
                    assert (c2.name == "citizen");
                    assert (c2.attrs.get ("ctype").value == "Ghost");
                    assert (((Element) c2).content == "10M");
                  }
                  if (p1.name == "planet" && p1.attrs.get ("name").value == "Platon") {
                    fplaton = true;
                    assert (p1.name == "planet");
                    assert (p1.attrs.get ("name").value == "Platon");
                    assert (p1.children_nodes.size == 0);
                  }
                }
                assert (fearth);
                assert (fplaton);
              }
              if (s.name == "space" && s.attrs.get ("name").value == "Galax") {
                fgalax = true;
                assert (s.attrs.get ("name").value == "Galax");
                assert (s.children_nodes.size == 2);
                bool fsaminon = false;
                foreach (GXml.Node p in s.children_nodes) {
                  if (p.name == "planet" && p.attrs.get ("name").value == "Saminon") {
                    fsaminon = true;
                    var h = p.children_nodes.get (0);
                    assert (h != null);
                    assert (h.name == "citizen");
                    assert (h.attrs.get ("ctype").value == "Humanes");
                    assert (h.children_nodes.size == 1);
                    assert (((Element) h).content == "100M");
                    var j = p.children_nodes.get (1);
                    assert (j != null);
                    assert (j.name == "citizen");
                    assert (j.attrs.get ("ctype").value == "Jeties");
                    assert (j.children_nodes.size == 1);
                    assert (((Element) j).content == "1000M");
                  }
                }
                assert (fsaminon);
              }
            }
            assert (falphac);
          }
          if (sh.name == "ship" && sh.attrs.get ("manufacturer").value == "Memphis") {
            fmemphis = true;
            assert (sh.name == "ship");
            assert (sh.attrs.get ("manufacturer").value == "Memphis");
            assert (sh.attrs.get ("model").value == "AB1");
            assert (sh.children_nodes.size == 3); // 1 node 3 texts (identation)
            bool fbetac = false;
            foreach (GXml.Node s in sh.children_nodes){
              if (s.name == "space" && s.attrs.get ("name").value == "Beta Centaury") {
                fbetac = true;
                assert (s.attrs.get ("name").value == "Beta Centaury");
                assert (s.children_nodes.size == 2);
                bool ftronex = false;
                bool fpalax = false;
                foreach (GXml.Node p in s.children_nodes) {
                  if (p.name == "planet" && p.attrs.get ("name").value == "Tronex") {
                    ftronex = true;
                    assert (p.name == "planet");
                    assert (p.attrs.get ("name").value == "Tronex");
                    assert (p.children_nodes.size == 2);
                    var cp = p.children_nodes.get (0);
                    assert (cp.name == "citizen");
                    assert (cp.attrs.get ("ctype").value == "Human");
                    assert (((Element)cp).content == "10000M");
                    var cp2 = p.children_nodes.get (1);
                    assert (cp2.name == "citizen");
                    assert (cp2.attrs.get ("ctype").value == "Cat");
                    assert (((Element)cp2).content == "100000M");
                  }
                  if (p.name == "planet" && p.attrs.get ("name").value == "Palax") {
                    fpalax = true;
                    assert (p.name == "planet");
                    assert (p.attrs.get ("name").value == "Palax");
                    assert (p.children_nodes.size == 0);
                  }
                }
                assert (ftronex);
                assert (fpalax);
              }
              assert (fbetac);
            }
          }
        }
        assert (fmactoy);
        assert (fmemphis);
        var st = ndoc.root.children_nodes.get (1);
        assert (st != null);
        assert (st.name.down () == "storage");
        assert (st.attrs.get ("name").value == "B4-A4");
        assert (st.children_nodes.size == 1);
        bool fr = false;
        foreach (GXml.Node r in st.children_nodes) {
          if (r.name == "refaction" && r.attrs.get ("manufacturer").value == "MacToy") {
            fr = true;
            assert (r.name == "refaction");
            assert (r.attrs.get ("manufacturer").value == "MacToy");
            assert (r.attrs.get ("model").value == "Fly045");
            assert (r.children_nodes.size == 5); // 2 nodes 3 texts (identation)
            bool frmactoy = false;
            bool frmega = false;
            foreach (GXml.Node rsh in r.children_nodes) {
              if (rsh.name == "ship" && rsh.attrs.get ("manufacturer").value == "MacToy") {
                frmactoy = true;
                assert (rsh.attrs.get ("manufacturer").value == "MacToy");
                assert (rsh.attrs.get ("model").value == "A1234");
                assert (rsh.children_nodes.size == 0);
              }
              if (rsh.name == "ship" && rsh.attrs.get ("manufacturer").value == "MegaTrench") {
                frmega = true;
                assert (rsh.attrs.get ("manufacturer").value == "MegaTrench");
                assert (rsh.attrs.get ("model").value == "G045-1");
                assert (rsh.children_nodes.size == 0);
              }
            }
            assert (frmactoy);
            assert (frmega);
          }
        }
        assert (fr);
#if DEBUG
        ndoc.indent = true;
        stdout.printf (@"$ndoc");
#endif
      }
      catch (GLib.Error e) {
#if DEBUG
        stdout.printf (@"ERROR: $(e.message)");
#endif
        assert_not_reached ();
      }
    });
    Test.add_func ("/gxml/tw/serializable/convined_gee_containers/se-deserialize-unknowns",
    () => {
      try {
        // TODO: TDocument Read XML files
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
        assert (s.charge_zone != null);
        assert (s.charge_zone.spaceships.size == 2);
        var mssh = s.charge_zone.spaceships.@get ("MacToy","A1234");
        assert (mssh != null);
        
        assert (s.storage != null);
        assert (mssh.spaces.size == 2);
        assert (s.storage != null);
        assert (s.storage.refactions.size == 1);
        var refaction = s.storage.refactions.@get ("MacToy","Fly045");
        assert (refaction != null);
        assert (refaction.unknown_serializable_properties != null);
        assert (refaction.unknown_serializable_properties.size == 0);
        assert (refaction.unknown_serializable_nodes.size == 5); // 1 node 4 texts (identation)
        var doc = new TDocument ();
        s.serialize (doc);
        assert (doc.root.name == "base");
        //stdout.printf (@"$doc\n");
        foreach (GXml.Node n in doc.root.children_nodes) {
          if (n is Element) {
            if (n.name == "ChargeZone") {
              
            }
            if (n.name == "storage") {
              bool unkfound = false;
              bool tfound = false;
              bool attrfound = false;
              foreach (GXml.Node sn in n.children_nodes) {
                if (sn is Element) {
                  if (sn.name == "refaction") {
                    foreach (GXml.Node rn in sn.children_nodes) {
                      if (rn is Element) {
                        //stdout.printf (@"Refaction current node: '$(rn.name)'\n");
                        if (rn.name == "ship") {
                          var atr = rn.attrs.get ("manufacturer");
                          assert (atr != null);
                          if (atr.value == "MegaTrench") {
                            var shanattr = rn.attrs.get ("unknown");
                            if (shanattr != null) {
                              attrfound = true;
                              assert (shanattr.value == "UNKNOWN ATTR");
                            }
                            foreach (GXml.Node shn in rn.children_nodes) {
                              //stdout.printf (@"Refaction: Ship MegaTrench: Node: $(shn.name)\n");
                              if (shn is Text) {
                                tfound = true;
                                assert (shn.value == "TEST_TEXT");
                              }
                            }
                          }
                        }
                        if (rn.name == "UnknownAttribute") {
                          unkfound = true;
                          var nattr = rn.attrs.get ("name");
                          assert (nattr != null);
                          assert (nattr.value == "nothing");
                        }
                      }
                    }
                  }
                }
              }
              assert (attrfound);
              assert (tfound);
              assert (unkfound);
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
  }
}
