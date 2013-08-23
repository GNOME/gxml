#include <gxml/gxml.h>
#include <stdio.h>

int main () {
  GXmlDocument *doc;

  doc = gxml_document_new_from_path ("bookshelf.xml");

  gxml_document_save_to_path (doc, "output/bookshelf_save_to_path.xml");

  g_object_unref (doc);

  return 0;
}
