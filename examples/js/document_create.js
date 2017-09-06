#!/usr/bin/gjs

const GXml = imports.gi.GXml;

let doc = GXml.GomDocument.new ();

/* <book></book> */
let elem = doc.create_element ("book");
print ("Book element: " + elem.write_string ());

/* <book>Between the book tags is text!</book> */
let text = doc.create_text_node ("Between the book tags is text!");
print ("Text: " + text.data);

/* <book><!-- comment: I really like this book -->The fault in our stars</book> */
let comment = doc.create_comment ("comment: I really like this book");
print ("Comment: " + comment.data);

/* <?xml href="style.xsl" type="text/xml"?> */
let pi = doc.create_processing_instruction ("xml", "href=\"style.xsl\" type=\"text/xml\"");
print ("Processing Instruction: " + pi.data);

/* <element id=""> */
elem.set_attribute ("id", "001");
print ("Attribute id: " + elem.get_attribute ("id"));
