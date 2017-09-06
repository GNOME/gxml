#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

function create_a_document_from_a_path () {
    let doc = GXml.GomDocument.from_path ( "bookshelf.xml");
    print ("create_a_document_from_a_path:\n" + doc.write_string ());
}

create_a_document_from_a_path ();
