#include <glib.h>
#include <gio/gio.h>

int main (void) {
  GFile *file;

  file = g_file_new_for_path ("bookshelf.xml");

  g_object_unref (file);


  return 0;
}
