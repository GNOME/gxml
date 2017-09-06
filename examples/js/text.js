#!/usr/bin/gjs

const GXml = imports.gi.GXml;

// Setup
var doc = GXml.GomDocument.new ();
doc.append_child (doc.create_element ("Diary"));

var text = doc.create_text_node ("I am the very model of a modern Major General.");

print ("Document before inserting text:\n" +
       doc.write_string ());

doc.document_element.append_child (text);

print ("Document after inserting text:\n" +
       doc.write_string ());

print ("Nodes of document element 'Diary' before split_text:");
for (var node = doc.document_element.first_child; node != null; node = node.next_sibling) {
    print ("  Node: " + node.get_node_name()+":"+node.get_node_value ());
}

text.split_text (20);

print ("\nNodes of document element 'Diary' after split_text:");
for (var node = doc.document_element.first_child; node != null; node = node.next_sibling) {
    print ("  Node: " + node.get_node_name()+":"+node.get_node_value ());
}

print ("\nWARNING: the above does not work as desired, since libxml2 automatically merges neighbouring Text nodes.  You should see two Nodes for each part of the split.  This will hopefully be addressed in the future.");

/* To see Text manipulated as CharacterData, go see the CharacterData example */



