#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* For more examples, view node's child management code */

// Setup
var doc = GXml.Document.from_string ("<Refrigerator><Food name='cheese' /><Food name='tomatoes' /><Food name='avocado' /></Refrigerator>");

var foods_list = doc.get_elements_by_tag_name ("Food");


print ("Our refrigerator:\n" + doc.to_string (true, 0));

print ("\nThe length of the list:\n  " + foods_list.length);

print ("\nStringify the list:\n  " + foods_list.to_string (true));

print ("\nAccessing the second food item from a nodelist using .item ():\n  " +
       foods_list.item (1).get_attribute ('name'));

print ("\nAccessing the second food item from a nodelist using .nth ():\n  " +
       foods_list.nth (1).get_attribute ('name'));

print ("\nAccessing the second food item from a nodelist using .nth_data ():\n  " +
       foods_list.nth_data (1).get_attribute ('name'));

print ("\nAccessing the first food item with .first:\n  " +
       foods_list.first ().get_attribute ('name'));

print ("\nAccessing the last food item with .last:\n  " +
       foods_list.last ().get_attribute ('name'));

print ("\nAccessing the food item 2 previous to the last with .nth_prev ():\n  " +
       foods_list.nth_prev (foods_list.last (), 2).get_attribute ('name'));

print ("\nFinding the index for the last food item with .find ():\n  " +
       foods_list.find (foods_list.last ()));

print ("\nFinding the index for the last food item with .position ():\n  " +
       foods_list.position (foods_list.last ()));

print ("\nFinding the index for the last food item with .index ():\n  " +
       foods_list.index (foods_list.last ()));

/* TODO: this isn't wonderfully efficient; we want to do a foreach
   style loop on it, for (var a : list) {..., or have a NodeList thing
   to get the next one */
print ("Traverse the list:");
for (var i = 0; i < foods_list.length; i++) {
    var food = foods_list.nth (i);
    print ("  " + i + ":" + food.to_string (true, 0));
}

/* TODO:
   Figure out how to handle GFunc 
print ("\nOperate on each food item using .foreach ()\n");
foods_list.foreach (function (a) {
    });
*/

/* TODO:
   Figure out how to handle GCompareFunc
print ("\nFinding the index for the food item with the same name, using .find_custom ():\n" +
       foods_list.find_custom (foods_list.last (), function (a, b) {
	   print ("DBG: " + a + "; " + b + "; ");
	   return 2;
       }, foods_list));
*/
