#include <gxml/gxml.h>
#include <assert.h>

int main () {
  /* Setup */
  GXmlDocument *doc;
  GXmlNode *bookshelf;
  doc = gxml_document_new_from_path ("bookshelf_node.xml");
  bookshelf = GXML_NODE (gxml_document_get_document_element (doc));


  /* Stringification */
  gchar *str;
  printf ("Stringifying bookshelf:\n%s\n\n", str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);


  /* Appending a child */
  GXmlNode *date_today;
  GXmlNode *date_today_text; 

  date_today = GXML_NODE (gxml_document_create_element (doc, "Date"));
  gxml_node_append_child (bookshelf, date_today);

  date_today_text = GXML_NODE (gxml_document_create_text_node (doc, "Today"));
  gxml_node_append_child (date_today, date_today_text);

  printf ("Bookshelf after appending a new element:\n%s\n\n", str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);


  /* Adding clones */
  GXmlNode *date_clone_shallow = gxml_node_clone_node (date_today, FALSE);
  GXmlNode *date_clone_deep = gxml_node_clone_node (date_today, TRUE);

  gxml_node_append_child (bookshelf, date_clone_shallow);
  gxml_node_append_child (bookshelf, date_clone_deep);

  printf ("Bookshelf after adding clones:\n%s\n\n",
	  str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);


  /* Checking whether children exist */
  printf ("Does Bookshelf have child nodes? %s\n", gxml_node_has_child_nodes (bookshelf) ? "yes" : "no");
  printf ("Does the shallow Date clone have child nodes? %s\n", gxml_node_has_child_nodes (date_clone_shallow) ? "yes" : "no");
  printf ("\n");


  /* Accessing the first child */
  GXmlNode *bookshelf_first_child = gxml_node_get_first_child (bookshelf);
  printf ("Bookshelf's first child:\n%s\n\n",
	  str = gxml_node_to_string (bookshelf_first_child, TRUE, 0));
  g_free (str);

  GXmlNode *date_clone_cur_text = gxml_node_get_first_child (date_clone_deep);
  printf ("Our deep clone's first child:\n%s\n\n",
	  str = gxml_node_to_string (date_clone_cur_text, TRUE, 0));
  g_free (str);


  /* Replacing a child */
  GXmlNode *date_clone_new_text = GXML_NODE (gxml_document_create_text_node (doc, "Tomorrow"));
  gxml_node_replace_child (date_clone_deep, date_clone_new_text, date_clone_cur_text);

  printf ("Bookshelf after replacing the Text of our deep clone of Date:\n%s\n\n",
	  str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);


  /* Inserting a new child before an existing child */
  GXmlNode *date_yesterday = GXML_NODE (gxml_document_create_element (doc, "Date"));
  GXmlNode *date_yesterday_text = GXML_NODE (gxml_document_create_text_node (doc, "Yesterday"));
  gxml_node_append_child (date_yesterday, date_yesterday_text);

  gxml_node_insert_before (bookshelf, date_yesterday, date_today);

  printf ("Bookshelf after inserting Date Yesterday before Date Today:\n%s\n\n", str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);


  /* Removing a child */
  gxml_node_remove_child (bookshelf, date_clone_shallow);

  printf ("Bookshelf after removing the shallow date clone:\n%s\n\n",
	  str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);


  /* Accessing the last child */
  GXmlNode *last_child = gxml_node_get_last_child (bookshelf);
  printf ("Bookshelf's last child:\n%s\n\n",
	  str = gxml_node_to_string (last_child, TRUE, 0));
  g_free (str);


  /* Traversing children via next and previous sibling */
  int i;
  GXmlNode *cur_child;

  i = 0;
  printf ("Bookshelf's children, using next_sibling from the first_child:\n");
  for (cur_child = gxml_node_get_first_child (bookshelf);
       cur_child != NULL; cur_child = gxml_node_get_next_sibling (cur_child)) {
    printf ("  Child %d\n    %s\n", i, str = gxml_node_to_string (cur_child, TRUE, 2));
    g_free (str);
    i++;
  }
  printf ("\n");

  printf ("Bookshelf's children, using previous_sibling from the last_child:\n");
  for (cur_child = gxml_node_get_last_child (bookshelf);
       cur_child != NULL; cur_child = gxml_node_get_previous_sibling (cur_child)) {
    i--;
    printf ("  Child %d\n    %s\n", i, str = gxml_node_to_string (cur_child, TRUE, 2));
    g_free (str);
  }
  printf ("\n");


  /* Traversing children through its GXmlNodeList of child nodes */
  GXmlNodeList *children = gxml_node_get_child_nodes (bookshelf);

  /* TODO: consider adding a memory to list, to ease traversal (expect pting to next one)*/
  int len = gxml_node_list_get_length (children);
  printf ("Bookshelf's children, using get_child_nodes and incrementing by index:\n");
  for (i = 0; i < len; i++) {
    GXmlNode *child = gxml_node_list_nth (children, i);
    printf ("  Child %d\n    %s\n", i, str = gxml_node_to_string (child, TRUE, 2));
    g_free (str);
  }
  printf ("\n");  


  /* Access the node's attributes map - note that this only applies to Elements
     http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1841493061 */
  GXmlNodeList *book_list = gxml_document_get_elements_by_tag_name (doc, "Book");
  GXmlNode *first_book = gxml_node_list_first (book_list);
  GHashTable *attrs;
  GList *attrs_keys;

  attrs = gxml_node_get_attributes (first_book);

  printf ("List attributes from element: %s\n", str = gxml_node_to_string (first_book, FALSE, 0));
  g_free (str);
  for (attrs_keys = g_hash_table_get_keys (attrs); attrs_keys != NULL; attrs_keys = attrs_keys->next) {
    GXmlAttr *attr = g_hash_table_lookup (attrs, (gchar*)attrs_keys->data);
    printf ("  %10s => %s  (%s)\n",
	    gxml_attr_get_name (attr), gxml_attr_get_value (attr),
	    gxml_attr_get_specified (attr) ? "specified" : "not specified");
  }
  printf ("\n");


  /* Access the parent node from a node */
  gchar *str2;
  GXmlNode *first_book_parent = gxml_node_get_parent_node (first_book);
  printf ("The parent of %s looks like:\n  %s\n\n", str = gxml_node_to_string (first_book, TRUE, 0), str2 = gxml_node_to_string (first_book_parent, TRUE, 1));
  g_free (str);
  g_free (str2);


  /* Access the owner document from the node */
  GXmlDocument *owner_document;

  owner_document = gxml_node_get_owner_document (bookshelf);

  printf ("The owner document for Bookshelf looks like:\n%s\n\n",
	  str = gxml_node_to_string (GXML_NODE (owner_document), FALSE, 0));
  g_free (str);


  /* Check node types */
  GEnumClass *nodetype_class = G_ENUM_CLASS (g_type_class_ref (GXML_TYPE_NODE_TYPE));
  GXmlAttr *author_attr = g_hash_table_lookup (attrs, "author");

  GXmlNodeType nodetype;
  GEnumValue *nodetype_value;

  nodetype = gxml_node_get_node_type (GXML_NODE (doc));
  nodetype_value = g_enum_get_value (nodetype_class, nodetype);
  printf ("Document is of type: %s\n", nodetype_value->value_name);

  nodetype = gxml_node_get_node_type (bookshelf);
  nodetype_value = g_enum_get_value (nodetype_class, nodetype);
  printf ("Bookshelf is of type: %s\n", nodetype_value->value_name);

  nodetype = gxml_node_get_node_type (GXML_NODE (author_attr));
  nodetype_value = g_enum_get_value (nodetype_class, nodetype);
  printf ("author is of type: %s\n", nodetype_value->value_name);

  // TODO: find out why first_child on doc doesn't get <?xml ...?>

  g_type_class_unref (nodetype_class);
  
  
  return 0;
  
}
