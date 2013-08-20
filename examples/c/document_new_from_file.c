#include <gxml/gxml.h>
#include <stdio.h>

int main () {
  GXmlDocument *doc;
  GFile *file;
  char *str;
  GCancellable *can = g_cancellable_new ();

  file = g_file_new_for_path ("bookshelf.xml");
  doc = gxml_document_new_from_gfile (file, can); // TODO: want to change this function name to "from file"

  str = gxml_node_to_string (GXML_NODE (doc), TRUE, 2);
  printf ("%s:\n%s\n", __FILE__, str);
  g_free (str);

  g_object_unref (doc);
  // TODO: how do you free a GFile?  g_object_unref ()?


  return 0;
}
