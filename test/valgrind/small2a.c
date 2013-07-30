#include <glib.h>
#include <glib-object.h>
#include <gxml/gxml.h>

/**
 * In this one, we DO attach the owner node.
 */
int main (int argc, char ** argv) {
  GXmlDocument* doc;
  GXmlElement* root;
  GXmlElement* owner;
	
  doc = gxml_document_new ();
  root = gxml_document_create_element (doc, "Bookshelf");
  gxml_node_append_child (GXML_NODE (doc), GXML_NODE (root));
  owner = gxml_document_create_element (doc, "Owner");
  // do attach owner
  gxml_node_append_child (GXML_NODE (root), GXML_NODE (owner));
	
  g_object_unref (owner);
  g_object_unref (root);
  g_object_unref (doc);

  return 0;
}



