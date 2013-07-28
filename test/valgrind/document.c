#include <glib.h>
#include <glib-object.h>
#include <gxml/gxml.h>

int main (void) {
  GXmlDocument *doc;

  doc = gxml_document_new ();
  g_object_unref (doc);

  return 0;
}
