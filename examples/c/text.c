#include <gxml/gxml.h>

int main () {
  GXmlDocument *doc;
  GXmlNode *diary;

  /* Setup */
  doc = gxml_document_new ();
  diary = GXML_NODE (gxml_document_create_element (doc, "Diary"));
  gxml_node_append_child (GXML_NODE (doc), diary);

  GXmlText *text;
  gchar *str;
  text = gxml_document_create_text_node (doc, "I am the very model of a modern Major General.");

  printf ("Document before inserting text:\n%s\n\n",
	  str = gxml_node_to_string (GXML_NODE (doc), TRUE, 0));
  g_free (str);

  gxml_node_append_child (diary, GXML_NODE (text));

  printf ("Document after inserting text:\n%s\n\n",
	  str = gxml_node_to_string (GXML_NODE (doc), TRUE, 0));
  g_free (str);

  printf ("Nodes of document element 'Diary' before split_text:\n");
  GXmlNode *node;
  for (node = gxml_node_get_first_child (diary); node != NULL; node = gxml_node_get_next_sibling (node)) {
    printf ("  Node: %s\n", str = gxml_node_to_string (node, TRUE, 0));
    g_free (str);
  }

  gxml_text_split_text (text, 20);

  printf ("\nNodes of document element 'Diary' after split_text:\n");
  for (node = gxml_node_get_first_child (diary); node != NULL; node = gxml_node_get_next_sibling (node)) {
    printf ("  Node: %s\n", str = gxml_node_to_string (node, TRUE, 0));
    g_free (str);
  }

  printf ("\nWARNING: the above does not work as desired, since libxml2 automatically\n"
	  " merges neighbouring Text nodes.  You should see two Nodes for each part\n"
	  " of the split.  This will hopefully be addressed in the future.\n");

  /* To see Text manipulated as CharacterData, go see the CharacterData example */

  return 0;
}



  
