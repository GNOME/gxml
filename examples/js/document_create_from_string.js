#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

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

create_a_document_from_a_string ();
