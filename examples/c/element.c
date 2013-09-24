#include <gxml/gxml.h>

int main () {
  GXmlDocument *doc;
  GXmlElement *tree;

/* Elements are a type of Node.  To see more of what you can do with an Element,
   view the node examples */

// Setup 1
  doc = gxml_document_new_from_string ("<Tree type='leafy' wisdom='great'>Yggdrasil</Tree>");
  tree = gxml_document_get_document_element (doc);

  gchar *str;

  printf ("Stringify Tree element:\n%s\n\n",
	  str = gxml_node_to_string (GXML_NODE (tree), TRUE, 0));
  g_free (str);

  /* TODO: verify memory handling for these */
  printf ("Get Tree element's tag name:\n  %s\n\n", gxml_element_get_tag_name (tree));
  printf ("Get Tree element's content:\n  %s\n\n", gxml_element_get_content (tree));
  printf ("Get Tree element's 'type' attribute:\n  %s\n\n", gxml_element_get_attribute (tree, "type"));

  gxml_element_set_attribute (tree, "type", "lush");
  printf ("Change Tree element's 'type' to something else:\n  %s\n\n",
	  str = gxml_node_to_string (GXML_NODE (tree), TRUE, 0));
  g_free (str);

  gxml_element_set_attribute (tree, "roots", "abundant");
  printf ("Set a new attribute, 'roots':\n  %s\n\n",
	  str = gxml_node_to_string (GXML_NODE (tree), TRUE, 0));
  g_free (str);

  gxml_element_remove_attribute (tree, "type");
  printf ("Remove attribute 'type':\n  %s\n\n",
	  str = gxml_node_to_string (GXML_NODE (tree), TRUE, 0));
  g_free (str);

  GXmlAttr *new_attr = gxml_document_create_attribute (doc, "height");
  gxml_attr_set_value (new_attr, "109m");
  gxml_element_set_attribute_node (tree, new_attr);
  printf ("Set a new attribute node:\n  %s\n\n",
	  str = gxml_node_to_string (GXML_NODE (tree), TRUE, 0));
  g_free (str);

  GXmlAttr *old_attr = gxml_element_get_attribute_node (tree, "wisdom");
  printf ("Get an existing attr as a node:\n  %s\n\n",
	  str = gxml_node_to_string (GXML_NODE (old_attr), TRUE, 0));
  g_free (str);

  gxml_element_remove_attribute_node (tree, old_attr);
  printf ("Remove wisdom attr by its node:\n  %s\n\n",
	  str = gxml_node_to_string (GXML_NODE (tree), TRUE, 0));
  g_free (str);

// Setup 2
  GXmlDocument *leaves_doc = gxml_document_new_from_string ("<Leaves><Leaf name='Aldo' /><Leaf name='Drona' /><Leaf name='Elma' /><Leaf name='Hollo' /><Leaf name='Irch' /><Leaf name='Linder' /><Leaf name='Makar' /><Leaf name='Oakin' /><Leaf name='Olivio' /><Leaf name='Rown' /></Leaves>");
  GXmlElement *leaves = gxml_document_get_document_element (leaves_doc);

 printf ("Our second example:\n%s\n\n",
	 str = gxml_node_to_string (GXML_NODE (leaves_doc), TRUE, 0));
 g_free (str);
 GXmlNodeList *leaf_list;
 leaf_list = gxml_element_get_elements_by_tag_name (leaves, "Leaf");
 printf ("Show element descendants of Leaves with the tag name Leaf:\n  %s\n",
	 str = gxml_node_list_to_string (leaf_list, TRUE));
 g_free (str);

/* TODO: when we support sibling text nodes (that is, when we're not
 * using libxml2), then we can add a normalize () example */

 return 0;
}
