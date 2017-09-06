#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* For more examples, view node's child management code */

// Setup
var doc = GXml.GomDocument.from_string ("<Refrigerator><Food name='cheese' /><Food name='tomatoes' /><Food name='avocado' /></Refrigerator>");

var foods_list = doc.get_elements_by_tag_name ("Food");


print ("Our refrigerator:\n" + doc.write_string ());

print ("\nThe length of the list:  " + foods_list.get_length ()+"\n");

print ("\nAccessing the second food item from a nodelist using .item ():\n  " +
       foods_list.item (1).get_attribute ('name'));

for (var i = 0; i < foods_list.get_length (); i++) {
    var food = foods_list.item (i);
    print ("  " + i + ":" + food.write_string ());
}
