#!/usr/bin/gjs

const GXml = imports.gi.GXml;

let xml = "<?xml version=\"1.0\"?><Bookshelf><Owner fullname=\"John Green\"/><Books><Book author=\"John Green\" title=\"The Fault in Our Stars\"/><Book author=\"Jane Austen\" title=\"Pride &amp; Prejudice\"/><Book author=\"J.D. Salinger\" title=\"Nine Stories\"/></Books></Bookshelf>";
let doc = GXml.GomDocument.from_string (xml);
print ("Parsed: "+doc.write_string ());

print ("A document's node_name is: " + doc.node_name + " (which should always be '#document')\n");

// To be implemented
//print ("The document's doctype is: " + doc.doctype.node_name + " (which should be 'bookshelf')\n");

let impl = doc.implementation;
print ("GXml's implementation that created this document has the features\n  xml 1.0? " +
       (impl.has_feature ("xml", "1.0") ? "true" : "false") +
       " (should be true)\n  html? " +
       (impl.has_feature ("html", null) ? "true" : "false") +
       " (always true - FIXME)\n");

print ("Document has root element with name: " + doc.document_element.node_name + " (should be 'Bookshelf')");
