#include <gxml/gxml.h>
#include <stdio.h>

int main () {
  GXmlDocument *doc;
  char *str;

  doc = gxml_document_new_from_path ("bookshelf.xml");
  str = gxml_node_to_string (GXML_NODE (doc), TRUE, 2);
  printf ("%s:\n%s\n", __FILE__, str);
  g_free (str);

  g_object_unref (doc);

  return 0;
}
