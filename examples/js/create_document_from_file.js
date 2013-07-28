#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

function create_a_document_from_a_file () {
    let file = Gio.File.new_for_path ("bookshelf.xml");
    let can = new Gio.Cancellable ();
    let doc = GXml.Document.from_gfile (file, can);
    print ("create_a_document_from_a_file:\n" + doc.to_string (true, 4));
}

create_a_document_from_a_file ();
