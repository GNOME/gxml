#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

function saving_a_document_to_a_path () {
    let doc = GXml.GomDocument.from_path ("bookshelf.xml");
    var f = Gio.File.new_for_path ("bookshelf_save_to_path.xml")
    doc.write_file (f);
    if (!f.query_exists (null)) print ("Can't create file");
}

saving_a_document_to_a_path ();
