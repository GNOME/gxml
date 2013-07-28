#!/usr/bin/gjs

const GXml = imports.gi.GXml;

let doc = GXml.Document.new ();

/* <book></book> */
let elem = doc.create_element ("book");
print ("Book element: " + elem.to_string (false, 0));

let docfragment = doc.create_document_fragment ();
print ("Fragment: " + docfragment.to_string (false, 0));

/* <book>Between the book tags is text!</book> */
let text = doc.create_text_node ("Between the book tags is text!");
print ("Text: " + text.to_string (false, 0));

/* <book><!-- comment: I really like this book -->The fault in our stars</book> */
let comment = doc.create_comment ("comment: I really like this book");
print ("Comment: " + comment.to_string (false, 0));

/* <![CDATA[non-XML data like code or special entities]]> */
let cdata = doc.create_cdata_section ("non-XML data like code or special entities");
print ("CDATA section: " + cdata.to_string (false, 0));

/* <?xml href="style.xsl" type="text/xml"?> */
let pi = doc.create_processing_instruction ("xml", "href=\"style.xsl\" type=\"text/xml\"");
print ("Processing Instruction: " + pi.to_string (false, 0));

/* <element id=""> */
let attr = doc.create_attribute ("id");
print ("Attribute: " + attr.to_string (false, 0));

/* &apos;   (for an apostrophe, ') */
let entref = doc.create_entity_reference ("apos");
print ("Entity reference: " + entref.to_string (false, 0));
