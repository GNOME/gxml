#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* Setup */
var doc = GXml.Document.from_path ("bookshelf_node.xml");
var bookshelf = doc.document_element;
print ("Bookshelf, without any comments:\n" +
       bookshelf.to_string (true, 0));

/* Placing comments in the tree */

var comment = doc.create_comment ("this bookshelf is small");
doc.insert_before (comment, bookshelf);
print ("\nAfter trying to insert a comment before our root element:\n" +
       doc.to_string (true, 0));

comment = doc.create_comment ("its owner is an important author");
var owner = bookshelf.first_child;
bookshelf.insert_before (comment, owner);
print ("\nAfter inserting a comment before our <owner>:\n" +
       bookshelf.to_string (true, 0));

comment = doc.create_comment ("I should buy more books");
var books = owner.next_sibling;
books.append_child (comment);
print ("\nAfter appending a comment in <books>:\n" +
       bookshelf.to_string (true, 0));

var book = books.first_child;
comment = doc.create_comment ("this pretty cool book will soon be a pretty cool movie");
book.append_child (comment);
print ("\nAfter adding a comment to an empty <book> node:\n" +
       bookshelf.to_string (true, 0));

/* Comments as CharacterData */

print ("\nStringified Comments have <!-- -->, like this one:\n" +
       comment.to_string (true, 0));

print ("\nComments are CharacterData, so previous comment's data:\n" +
       comment.data);
       
print ("\nComments are CharacterData, so previous comment's length:\n" +
       comment.length);

comment.append_data (".  Did you read it?");
print ("\nComment after using CharacterData's append_data ():\n" +
       comment.to_string (true, 0));

comment.replace_data (12, 4, "awesome");
print ("\nComment after using CharacterData's replace_data () (cool -> awesome).\n" +
       "Note that this affects the data as seen in CharacterData's .data property, excluding the comment's surrounding <!-- and -->:\n" +
       comment.to_string (true, 0));
