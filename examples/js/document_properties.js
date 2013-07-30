#!/usr/bin/gjs

const GXml = imports.gi.GXml;

let xml = "<?xml version=\"1.0\"?><!DOCTYPE bookshelf><Bookshelf><Owner fullname=\"John Green\"/><Books><Book author=\"John Green\" title=\"The Fault in Our Stars\"/><Book author=\"Jane Austen\" title=\"Pride &amp; Prejudice\"/><Book author=\"J.D. Salinger\" title=\"Nine Stories\"/></Books></Bookshelf>";
let doc = GXml.Document.from_string (xml);

print ("A document's node_name is: " + doc.node_name + " (which should always be '#document')\n");

print ("The document's doctype is: " + doc.doctype.name + " (which should be 'bookshelf')\n");

let impl = doc.implementation;
print ("GXml's implementation that created this document has the features\n  xml 1.0? " +
       (impl.has_feature ("xml", "1.0") ? "true" : "false") +
       " (should be true)\n  html? " +
       (impl.has_feature ("html", null) ? "true" : "false") +
       " (should be false)\n");

print ("Document has root element with name: " + doc.document_element.node_name + " (should be 'Bookshelf')");
