#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* Setup */
var doc = GXml.GomDocument.from_path ("bookshelf_node.xml");
var bookshelf = doc.document_element;
print ("Bookshelf, without any comments:\n" +
       bookshelf.write_string ());

/* Placing comments in the tree */

var comment = doc.create_comment ("this bookshelf is small");
doc.insert_before (comment, bookshelf);
print ("\nAfter trying to insert a comment before our root element:\n" +
       doc.write_string ());

comment = doc.create_comment ("its owner is an important author");
var owner = bookshelf.first_child;
bookshelf.insert_before (comment, owner);
print ("\nAfter inserting a comment before our <owner>:\n" +
       bookshelf.write_string ());

comment = doc.create_comment ("I should buy more books");
var books = owner.next_sibling;
books.append_child (comment);
print ("\nAfter appending a comment in <books>:\n" +
       bookshelf.write_string ());

var book = books.first_child;
comment = doc.create_comment ("this pretty cool book will soon be a pretty cool movie");
book.append_child (comment);
print ("\nAfter adding a comment to an empty <book> node:\n" +
       bookshelf.write_string ());

/* Comments as CharacterData */

print ("\nStringified Comments have <!-- -->, like this one:\n" +
       comment.data);

print ("\nComments are CharacterData, so previous comment's data:\n" +
       comment.data);
       
print ("\nComments are CharacterData, so previous comment's length:\n" +
       comment.get_length ());

comment.append_data (".  Did you read it?");
print ("\nComment after using CharacterData's append_data ():\n" +
       comment.data);

comment.replace_data (12, 4, "awesome");
print ("\nComment after using CharacterData's replace_data () (cool -> awesome).\n" +
       "Note that this affects the data as seen in CharacterData's .data property, excluding the comment's surrounding <!-- and -->:\n" +comment.data);
