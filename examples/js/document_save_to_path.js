#!/usr/bin/gjs

const GXml = imports.gi.GXml;
const Gio = imports.gi.Gio;

function saving_a_document_to_a_path () {
    let doc = GXml.Document.from_path ("bookshelf.xml");
    doc.save_to_path ("output/bookshelf_save_to_path.xml");
}

saving_a_document_to_a_path ();
