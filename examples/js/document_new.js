#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

function create_a_document () {
    var authors = [ "John Green", "Jane Austen", "J.D. Salinger" ];
    var titles = [ "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" ];

    try {
        let doc = GXml.GomDocument.new ();
        let root = doc.create_element ("Bookshelf");
        doc.append_child (root);
        let owner = doc.create_element ("Owner");
        root.append_child (owner);
        owner.set_attribute ("fullname", "John Green");

        let books = doc.create_element ("Books");
        root.append_child (books);

        for (var i = 0; i < authors.get_length (); i++) {
            let book = doc.create_element ("Book");
            book.set_attribute ("author", authors[i]);
            book.set_attribute ("title", titles[i]);
            books.append_child (book);
        }

	print ("create_a_document:\n" + doc.write_string ());
    } catch (error) {
	print (error.message);
    }
}

create_a_document ();
