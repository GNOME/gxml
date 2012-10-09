#!/usr/bin/python

from gi.repository import GXml;
from gi.repository import Gio;

def create_a_document ():
    authors = ["John Green", "Jane Austen", "J.D. Salinger"];
    titles = ["The Fault in Our Stars", "Pride & Prejudice", "Nine Stories"];

    doc = GXml.Document.new ();
    root = doc.create_element ("Bookshelf");
    doc.append_child (root);
    root.set_attribute ("fullname", "John Green");
    
    books = doc.create_element ("Books");
    root.append_child (books);
    
    for i in range (len (authors)):
        book = doc.create_element ("Book");
        book.set_attribute ("author", authors[i]);
        book.set_attribute ("title", titles[i]);
        books.append_child (book);
    
    print "create_a_document:\n", doc.to_string (True, 4);
    if None == doc.to_string (True, 4):
        print "ERROR: doc to string was null, but shouldn't be";

def create_a_document_from_a_string ():
    xml = """<?xml version="1.0"?>
<Bookshelf>
<Owner fullname="John Green"/>
<Books>
<Book author="John Green" title="The Fault in Our Stars"/>
<Book author="Jane Austen" title="Pride &amp; Prejudice"/>
<Book author="J.D. Salinger" title="Nine Stories"/>
</Books>
</Bookshelf>""";
    doc = GXml.Document.from_string (xml);
    print "create_a_document_from_a_string:\n", doc.to_string (True, 4);
    # TODO: why does this not indent when printed?

def create_a_document_from_a_file ():
    can = Gio.Cancellable ();
    gfile = Gio.File.new_for_path ("bookshelf.xml");
    doc = GXml.Document.from_gfile (gfile, can);
    print "create_a_document_from_a_file:\n", doc.to_string (True, 4); # TODO: do these two values actually do anything?

def create_a_document_from_a_path ():
    doc = GXml.Document.from_path ("bookshelf.xml");
    print "create_a_document_from_a_path:\n", doc.to_string (True, 4); # TODO: do these two values actually do anything?

def saving_a_document_to_a_path ():
    doc = GXml.Document.from_path ("bookshelf.xml");
    doc.save_to_path ("bookshelf2.xml");
    

create_a_document ();
create_a_document_from_a_string ();
create_a_document_from_a_file ();
create_a_document_from_a_path ();
saving_a_document_to_a_path ();

