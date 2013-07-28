#include <gxml/gxml.h>
#include <stdio.h>

int main () {
  char *xml;
  char *str;
  GXmlDocument *doc;

  xml = "<?xml version=\"1.0\"?><Bookshelf><Owner fullname=\"John Green\"/><Books><Book author=\"John Green\" title=\"The Fault in Our Stars\"/><Book author=\"Jane Austen\" title=\"Pride &amp; Prejudice\"/><Book author=\"J.D. Salinger\" title=\"Nine Stories\"/></Books></Bookshelf>";

  doc = gxml_document_new_from_string (xml);

  str = gxml_node_to_string (GXML_NODE (doc), TRUE, 2);
  printf ("%s:\n%s\n", __FILE__, str);
  g_free (str);

  g_object_unref (doc);

  return 0;
}
