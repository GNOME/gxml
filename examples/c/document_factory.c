#include <gxml/gxml.h>

int main () {
  GXmlDocument *doc;

  doc = gxml_document_new ();

  /* <bookElement> */
  GXmlElement *elem;
  elem = gxml_document_create_element (doc, "tagname");

  GXmlDocumentFragment *docfragment;
  docfragment = gxml_document_create_document_fragment (doc);

  /* <book>Between the book tags is text!</book> */
  GXmlText *text;
  text = gxml_document_create_text_node (doc, "Here is some text in an XML document");

  /* <book><!-- comment: I really like this one -->The fault in our stars</book> */
  GXmlComment *comment;
  comment = gxml_document_create_comment (doc, "Here is an XML comment");

  /* <![CDATA[non-XML data like code or special entities]]> */
  GXmlCDATASection *cdata;
  cdata = gxml_document_create_cdata_section (doc, "non-XML data like code or special entities");

  /* <?xml href="style.xsl" type="text/xml"?> */
  GXmlProcessingInstruction *pi;
  pi = gxml_document_create_processing_instruction (doc, "xml", "href=\"style.xsl\" type=\"text/xml\"");

  /* <element id=""> */
  GXmlAttr *attr;
  attr = gxml_document_create_attribute (doc, "id");

  /* &apos;   (for an apostrophe, ') */
  GXmlEntityReference *entref;
  entref = gxml_document_create_entity_reference (doc, "apos");

  gxml_node_append_child (GXML_NODE (doc), GXML_NODE (elem));

  g_object_unref (elem);
  g_object_unref (pi);
  g_object_unref (entref);
  g_object_unref (attr);
  g_object_unref (docfragment);
  g_object_unref (text);
  g_object_unref (comment);
  g_object_unref (cdata);
  g_object_unref (doc);

  return 0;
}
