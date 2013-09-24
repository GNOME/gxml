#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* Elements are a type of Node.  To see more of what you can do with an Element,
   view the node examples */

// Setup 1
var doc = GXml.Document.from_string ("<Tree type='leafy' wisdom='great'>Yggdrasil</Tree>");
var tree = doc.document_element;

print ("Stringify Tree element:\n" + tree.to_string (true, 0));

print ("\nGet Tree element's tag name:\n  " + tree.tag_name);
print ("\nGet Tree element's content:\n  " + tree.content);
print ("\nGet Tree element's 'type' attribute:\n  " + tree.get_attribute ('type'));

tree.set_attribute ("type", "lush");
print ("\nChange Tree element's 'type' to something else:\n  " + tree.to_string (true, 0));

tree.set_attribute ("roots", "abundant");
print ("\nSet a new attribute, 'roots':\n  " + tree.to_string (true, 0));

tree.remove_attribute ("type");
print ("\nRemove attribute 'type':\n  " + tree.to_string (true, 0));

var new_attr = doc.create_attribute ("height");
new_attr.value = "109m";
tree.set_attribute_node (new_attr);
print ("\nSet a new attribute node:\n  " + tree.to_string (true, 0));

var old_attr = tree.get_attribute_node ("wisdom");
print ("\nGet an existing attr as a node:\n  " + old_attr.to_string (true, 0));

tree.remove_attribute_node (old_attr);
print ("\nRemove wisdom attr by its node:\n  " + tree.to_string (true, 0));

// Setup 2
var leaves_doc = GXml.Document.from_string ("<Leaves><Leaf name='Aldo' /><Leaf name='Drona' /><Leaf name='Elma' /><Leaf name='Hollo' /><Leaf name='Irch' /><Leaf name='Linder' /><Leaf name='Makar' /><Leaf name='Oakin' /><Leaf name='Olivio' /><Leaf name='Rown' /></Leaves>");
var leaves = leaves_doc.document_element;

print ("Our second example:\n" + leaves_doc.to_string (true, 0));
var leaf_list = leaves_doc.get_elements_by_tag_name ("Leaf");
print ("Show element descendants of Leaves with the tag name Leaf:\n  " + leaf_list.to_string (true));

/* TODO: when we support sibling text nodes (that is, when we're not
 * using libxml2), then we can add a normalize () example */
