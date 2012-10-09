#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

function create_a_document () {
    var authors = [ "John Green", "Jane Austen", "J.D. Salinger" ];
    var titles = [ "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" ];

    try {
	let doc = GXml.Document.new ();
	let root = doc.create_element ("Bookshelf");
	doc.append_child (root);
	let owner = doc.create_element ("Owner");
	root.append_child (owner);
	owner.set_attribute ("fullname", "John Green");

	let books = doc.create_element ("Books");
	root.append_child (books);

	for (var i = 0; i < authors.length; i++) {
	    let book = doc.create_element ("Book");
	    book.set_attribute ("author", authors[i]);
	    book.set_attribute ("title", titles[i]);
	    books.append_child (book);
	}

	print ("create_a_document:\n" + doc.to_string (true, 4));
    } catch (error) {
	print (error.message);
    }
}

function create_a_document_from_a_string () {
    let xml = "<?xml version=\"1.0\"?>\
<Bookshelf>\
<Owner fullname=\"John Green\"/>\
<Books>\
<Book author=\"John Green\" title=\"The Fault in Our Stars\"/>\
<Book author=\"Jane Austen\" title=\"Pride &amp; Prejudice\"/>\
<Book author=\"J.D. Salinger\" title=\"Nine Stories\"/>\
</Books>\
</Bookshelf>";
    let doc = GXml.Document.from_string (xml);
    print ("create_a_document_from_a_string:\n" + doc.to_string (true, 4));
    
}

function create_a_document_from_a_file () {
    let file = Gio.File.new_for_path ("bookshelf.xml");
    let can = new Gio.Cancellable ();
    let doc = GXml.Document.from_gfile (file, can);
    print ("create_a_document_from_a_file:\n" + doc.to_string (true, 4));
}

function create_a_document_from_a_path () {
    let doc = GXml.Document.from_path ( "bookshelf.xml");
    print ("create_a_document_from_a_path:\n" + doc.to_string (true, 4));
}

function saving_a_document_to_a_path () {
    let doc = GXml.Document.from_path ("bookshelf.xml");
    doc.save_to_path ("bookshelf2.xml");
}

create_a_document ();
create_a_document_from_a_string ();
create_a_document_from_a_file ();
create_a_document_from_a_path ();
saving_a_document_to_a_path ();
