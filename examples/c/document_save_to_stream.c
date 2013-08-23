#include <gxml/gxml.h>
#include <stdio.h>

int main () {
  GXmlDocument *doc;
  GFile *outfile;
  GFileOutputStream *outstream;
  GCancellable *can = g_cancellable_new ();

  doc = gxml_document_new_from_path ("bookshelf.xml");

  outfile = g_file_new_for_path ("output/bookshelf_save_to_stream.xml");
  outstream = g_file_replace (outfile, NULL, FALSE, G_FILE_CREATE_REPLACE_DESTINATION, can, NULL);
  gxml_document_save_to_stream (doc, G_OUTPUT_STREAM (outstream), can);

  g_object_unref (doc);
  // TODO: figure out how to close/unref outstream and outfile

  return 0;
}
