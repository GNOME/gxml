#include <gxml/gxml.h>

int main () {
  GXmlDocument *doc;

  doc = gxml_document_new ();

  /* <bookElement></bookElement> */
  GXmlElement *elem;
  elem = gxml_document_create_element (doc, "bookElement");
  printf ("Book element: %s\n", gxml_node_to_string (GXML_NODE (elem), FALSE, 0));

  GXmlDocumentFragment *docfragment;
  docfragment = gxml_document_create_document_fragment (doc);
  printf ("Document fragment: %s\n", gxml_node_to_string (GXML_NODE (docfragment), FALSE, 0));

  /* <book>Between the book tags is text!</book> */
  GXmlText *text;
  text = gxml_document_create_text_node (doc, "Between the book tags is text!");
  printf ("Text node: %s\n", gxml_node_to_string (GXML_NODE (text), FALSE, 0));

  /* <book><!-- comment: I really like this book -->The fault in our stars</book> */
  GXmlComment *comment;
  comment = gxml_document_create_comment (doc, "comment: I really like this book");
  printf ("Comment: %s\n", gxml_node_to_string (GXML_NODE (comment), FALSE, 0));

  /* <![CDATA[non-XML data like code or special entities]]> */
  GXmlCDATASection *cdata;
  cdata = gxml_document_create_cdata_section (doc, "non-XML data like code or special entities");
  printf ("CDATA section: %s\n", gxml_node_to_string (GXML_NODE (cdata), FALSE, 0));

  /* <?xml href="style.xsl" type="text/xml"?> */
  GXmlProcessingInstruction *pi;
  pi = gxml_document_create_processing_instruction (doc, "xml", "href=\"style.xsl\" type=\"text/xml\"");
  printf ("Processing Instruction: %s\n", gxml_node_to_string (GXML_NODE (pi), FALSE, 0));

  /* <element id=""> */
  GXmlAttr *attr;
  attr = gxml_document_create_attribute (doc, "id");
  printf ("Attribute: %s\n", gxml_node_to_string (GXML_NODE (attr), FALSE, 0));

  /* &apos;   (for an apostrophe, ') */
  GXmlEntityReference *entref;
  entref = gxml_document_create_entity_reference (doc, "apos");
  printf ("Entity reference: %s\n", gxml_node_to_string (GXML_NODE (entref), FALSE, 0));

  gxml_node_append_child (GXML_NODE (doc), GXML_NODE (elem));

  g_object_unref (pi);
  g_object_unref (entref);
  g_object_unref (attr);
  g_object_unref (doc);

  return 0;
}
