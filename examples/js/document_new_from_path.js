#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

function create_a_document_from_a_path () {
    let doc = GXml.Document.from_path ( "bookshelf.xml");
    print ("create_a_document_from_a_path:\n" + doc.to_string (true, 4));
}

create_a_document_from_a_path ();
