#include <gxml/gxml.h>
#include <stdio.h>

int main () {
  char *xml;
  GXmlDocument *doc;

  xml = "<?xml version=\"1.0\"?><!DOCTYPE bookshelf><Bookshelf><Owner fullname=\"John Green\"/><Books><Book author=\"John Green\" title=\"The Fault in Our Stars\"/><Book author=\"Jane Austen\" title=\"Pride &amp; Prejudice\"/><Book author=\"J.D. Salinger\" title=\"Nine Stories\"/></Books></Bookshelf>";
  doc = gxml_document_new_from_string (xml);

  const gchar *doc_node_name;
  doc_node_name = gxml_node_get_node_name (GXML_NODE (doc));
  printf ("A document's node_name is: %s (which should always be '#document')\n\n", doc_node_name);

  GXmlDocumentType *doctype; // TODO: have renamed to GXmlDocType
  const gchar *doctype_name; // we don't want to have to free this

  doctype = gxml_document_get_doctype (doc);
  doctype_name = gxml_document_type_get_name (doctype);
  printf ("The document's doctype is: %s (which should be 'bookshelf')\n\n", doctype_name);

  GXmlImplementation *impl;
  impl = gxml_document_get_implementation (doc);

  printf ("GXml's implementation that created this document has the features\n  xml 1.0? %s (should be true)\n  html? %s (should be false)\n\n", gxml_implementation_has_feature (impl, "xml", "1.0") ? "true" : "false", gxml_implementation_has_feature (impl, "html", NULL) ? "true" : "false");

  GXmlElement *root;
  const gchar *root_node_name;
  root = gxml_document_get_document_element (doc);
  root_node_name = gxml_node_get_node_name (GXML_NODE (root));

  printf ("Document has root element with name: %s (should be Bookshelf)\n", root_node_name);

  g_object_unref (doc);

  return 0;
}
