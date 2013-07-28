#include <glib.h>
#include <glib-object.h>
#include <gxml/gxml.h>

int main (void) {
  GObject *obj;

  obj = g_object_newv (G_TYPE_OBJECT, 0, NULL);
  g_object_unref (obj);

  return 0;
}
