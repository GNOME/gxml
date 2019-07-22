#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* Setup */
var doc = GXml.GomDocument.from_path ("bookshelf_node.xml");
var bookshelf = doc.document_element;
var date_today = doc.create_element ("Date");
date_today.append_child (doc.create_text_node ("Today"));


/* Stringification */
print ("Stringifying bookshelf:\n" + bookshelf.write_string () + "\n\n");

/* Adding clones */
var date_clone_shallow = date_today.clone_node (false);
var date_clone_deep = date_today.clone_node (true);

bookshelf.append_child (date_clone_shallow);
bookshelf.append_child (date_clone_deep);

print ("Bookshelf after adding clones:\n" + bookshelf.write_string () + "\n\n");

var book_list = doc.get_elements_by_tag_name ("Book");
print (book_list.constructor)
print ("Book nodes found: "+book_list.get_length ());
var first_book = book_list.get_element (0);

var ath = first_book.get_attribute ("author");
var att = first_book.get_attribute ("title");
print ("Author: "+ath+" Title: "+att);

var attrs = first_book.get_attributes ();
print ("Attrs type:"+attrs.constructor);

print ("\n");

/* Access the owner document from the node */
var owner_document = bookshelf.get_owner_document ();

print ("The owner document for Bookshelf looks like:\n" + owner_document.write_string () + "\n\n");

/* Check node types */
var author_attr = first_book.get_attribute ("author");

print ("A:");
for (var x in GXml.NodeType) {
    print (x);
}
var test = GXml.NodeType['DOCUMENT'];
print (test);
print (GXml.NodeType.DOCUMENT);

print ("\nGet class");
print (GXml.NodeType);

print ("Document is of type: " + doc.node_type); // .to_string ());
/* How do we support macro wrappers from C in JS? 
print ("Bookshelf is of type: %s\n", bookshelf.node_type.to_string ());
print ("Bookshelf is of type: %s\n", author_attr.node_type.to_string ());
*/

