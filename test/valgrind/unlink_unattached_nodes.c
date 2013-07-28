#include <glib.h>
#include <glib-object.h>
#include <gxml/gxml.h>

/* This test creates some nodes that are not attached to the tree.
   Run with valgrind --leak-check=full --show-reachable=yes to make
   sure that they still get cleaned up.

   (At present, doc calls free on the document, which gets rid of the
   tree. I'm testing having an additional list of new nodes that were
   created and are perhaps outside the tree.  All the nodes below,
   whether in the tree or not, will be in the new-nodes list which
   we'll try to get rid of.  The crux of the idea is using
   xmlUnlinkNode in a separate xmlList.  Let's see how this goes!);
*/

int main () {
  GXmlDocument* doc;
  GXmlElement* root;
  GXmlElement* owner1;
  GXmlElement* owner2;
  GXmlElement* book;

  doc = gxml_document_new ();

  /* This node belongs to the doc and is attached to the tree */
  root = gxml_document_create_element (doc, "Bookshelf");
  gxml_node_append_child (GXML_NODE (doc), GXML_NODE (root));
  
  /* owner1, owner2 belong to doc, but aren't part of the document tree */
  owner1 = gxml_document_create_element (doc, "Owner1"); 
  owner2 = gxml_document_create_element (doc, "Owner2");
  /* book is outside the tree as well, but is a child of owner2 */
  book = gxml_document_create_element (doc, "Book");
  gxml_node_append_child (GXML_NODE (owner2), GXML_NODE (book));

  g_object_unref (doc);
  g_object_unref (root);
  g_object_unref (owner1);
  g_object_unref (owner2);
  g_object_unref (book);

  return 0;
}
  
