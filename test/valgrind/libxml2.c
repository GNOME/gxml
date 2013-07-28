#include <libxml/tree.h>
#include <stdio.h>
#include <string.h>

int main (void) {
  char *str = "<Bookshelf><Book>Text</Book></Bookshelf>";
  xmlDoc *doc = xmlReadMemory (str, strlen (str), NULL, NULL, 0);

  // to string
  xmlChar *mem;
  int size;
  xmlDocDumpFormatMemoryEnc (doc, &mem, &size, NULL, 0);
  printf ("[%s]\n", (char*)mem);
  xmlFree (mem);

  // set attribute
  xmlNode *root = xmlDocGetRootElement (doc);
  xmlAttr *attr = xmlSetProp (root, "name", "Alice");
  
  xmlFreeDoc (doc);

  /* In C, you'd call this when you were done with the library;
     TODO: do we want to expose this in Vala?  We can't automatically run
     it when we're done using the library from Vala, sadly. */
  //xmlCleanupParser ();

  return 0;
}
