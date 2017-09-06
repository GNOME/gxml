#!/usr/bin/gjs

const GXml = imports.gi.GXml;

print ("CharacterData isn't directly instantiable, but its subclasses Text and Comment are!\n");

// Setup
var doc = GXml.GomDocument.from_path ("bookshelf_node.xml");
var books_list = doc.document_element.get_elements_by_tag_name ("Book");
var book = books_list.get_element (0);

// Create a Text node for CharacterData
var text = doc.create_text_node ("Some infinities are bigger than other infinities");
var comment = doc.create_comment ("As he read, I fell in love the way you fall asleep:");

/* Data representation */

print ("Stringifying Text:\n" +
       text.data + "\n\n" +
       "Text's CharacterData's data:\n" +
       text.data + "\n\n" +
       "Text's CharacterData's length:\n" +
       text.get_length () + "\n\n" +
       "Stringifying Comment:\n" +
       comment.data + "\n\n" +
       "Comment's CharacterData's data:\n" +
       comment.data + "\n\n" +
       "Comment's CharacterData's length:\n" +
       comment.get_length () + "\n\n");

/* CharacterData operations */

book.append_child (text);
print ("Book with our Text as its child (its content):\n" + book.write_string ());

book.replace_child (comment, text);
print ("\nBook with our Comment as its child (its content):\n" + book.write_string ());

comment.append_data (" slowly, and then all at once");
print ("\nBook after appending more data to Comment:\n" + book.write_string ());

comment.replace_data (3, 2, "Gus");
print ("\nBook after replacing 'he' with 'Gus':\n" + book.write_string ());

comment.delete_data (20, 8);
print ("\nBook after deleting 'in love ':\n" + book.write_string ());

comment.insert_data (20, "in love ");
print ("\nBook after inserting 'in love ':\n" + book.write_string ());

/* You can see some more examples by looking at Comment and Text's examples */
