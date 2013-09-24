#include <gxml/gxml.h>

#define GET_NAME_ATTR(x) gxml_element_get_attribute (GXML_ELEMENT (x), "name")

int main () {
  GXmlDocument *doc;

  doc = gxml_document_new_from_string ("<Refrigerator><Food name='cheese' /><Food name='tomatoes' /><Food name='avocado' /></Refrigerator>");

  GXmlNodeList *foods_list = gxml_document_get_elements_by_tag_name (doc, "Food");

  gchar *str;

  printf ("Our refrigerator:\n%s\n\n", str = gxml_node_to_string (GXML_NODE (doc), TRUE, 0));
  g_free (str);

  printf ("The length of the list:\n  %lu\n\n", gxml_node_list_get_length (foods_list));

  printf ("Stringify the list:\n  %s\n\n", str = gxml_node_list_to_string (foods_list, TRUE));
  g_free (str);

  printf ("Accessing the second food item from a nodelist using .item ():\n  %s\n\n",
	  GET_NAME_ATTR (gxml_node_list_item (foods_list, 1)));

  printf ("Accessing the second food item from a nodelist using .nth ():\n  %s\n\n",
	  GET_NAME_ATTR (gxml_node_list_nth (foods_list, 1)));

  printf ("Accessing the second food item from a nodelist using .nth_data ():\n  %s\n\n",
	  GET_NAME_ATTR (gxml_node_list_nth_data (foods_list, 1)));

  printf ("Accessing the first food item with .first:\n  %s\n\n",
	  GET_NAME_ATTR (gxml_node_list_first (foods_list)));

  printf ("Accessing the last food item with .last:\n  %s\n\n",
	  GET_NAME_ATTR (gxml_node_list_last (foods_list)));

  GXmlNode *last = gxml_node_list_last (foods_list);
  GXmlNode *prev;
  prev = gxml_node_list_nth_prev (foods_list, last, 2);
  printf ("Accessing the food item 2 previous to the last with .nth_prev ():\n  %s\n\n",
	  GET_NAME_ATTR (prev));

  printf ("Finding the index for the last food item with .find ():\n  %d\n\n", 
	  gxml_node_list_find (foods_list, last));

  printf ("Finding the index for the last food item with .position ():\n  %d\n\n",
	  gxml_node_list_position (foods_list, last));

  printf ("Finding the index for the last food item with .index ():\n  %d\n\n",
	  gxml_node_list_index (foods_list, last));

  /* TODO: this isn't wonderfully efficient; we want to do a foreach
     style loop on it, for (var a : list) {..., or have a NodeList thing
     to get the next one */
  printf ("Traverse the list:\n");
  int i;
  for (i = 0; i < gxml_node_list_get_length (foods_list); i++) {
    GXmlNode *food = gxml_node_list_nth (foods_list, i);
    printf ("  %d:%s\n", i, str = gxml_node_to_string (food, TRUE, 0));
    g_free (str);
  }

  /* TODO: foreach () */

  /* TODO: find_custom () */

  return 0;
}
