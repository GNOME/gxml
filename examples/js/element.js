#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* Elements are a type of Node.  To see more of what you can do with an Element,
   view the node examples */

// Setup 1
var doc = GXml.GomDocument.from_string ("<Tree type='leafy' wisdom='great'>Yggdrasil</Tree>");
var tree = doc.document_element;

print ("Stringify Tree element:\n" + tree.write_string ());

print ("\nGet Tree element's tag name:\n  " + tree.tag_name);
print ("\nGet Tree element's content:\n  " + tree.content);
print ("\nGet Tree element's 'type' attribute:\n  " + tree.get_attribute ('type'));

tree.set_attribute ("type", "lush");
print ("\nChange Tree element's 'type' to something else:\n  " + tree.write_string ());

tree.set_attribute ("roots", "abundant");
print ("\nSet a new attribute, 'roots':\n  " + tree.write_string ());

tree.remove_attribute ("type");
print ("\nRemove attribute 'type':\n  " + tree.write_string ());

tree.set_attribute ("height", "109m");
print ("\nSet a new attribute node:\n  " + tree.write_string ());

var old_attr = tree.get_attribute ("wisdom");
print ("\nGet an existing attr as a node:\n  " + old_attr);

tree.remove_attribute (old_attr);
print ("\nRemove wisdom attr by its node:\n  " + tree.write_string ());

// Setup 2
var leaves_doc = GXml.GomDocument.from_string ("<Leaves><Leaf name='Aldo' /><Leaf name='Drona' /><Leaf name='Elma' /><Leaf name='Hollo' /><Leaf name='Irch' /><Leaf name='Linder' /><Leaf name='Makar' /><Leaf name='Oakin' /><Leaf name='Olivio' /><Leaf name='Rown' /></Leaves>");
var leaves = leaves_doc.document_element;

print ("Our second example:\n" + leaves_doc.write_string ());
var leaf_list = leaves_doc.get_elements_by_tag_name ("Leaf");
print ("Show element descendants of Leaves with the tag name Leaf:\n  ");
for (var i = 0; i < leaf_list.get_length (); i++) {
	var e = leaf_list.get_element (i);
	print ("Element: "+e.write_string ());
}

