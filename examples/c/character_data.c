#include <gxml/gxml.h>

int main () {
  /* Setup */
  printf ("CharacterData isn't directly instantiable, but its subclasses Text and Comment are!  Go see them for more additional examples.\n");

  GXmlDocument *doc;
  GXmlNodeList *books_list;
  GXmlNode *book;

  doc = gxml_document_new_from_path ("bookshelf_node.xml");
  books_list = gxml_element_get_elements_by_tag_name (gxml_document_get_document_element (doc), "Book");
  book = gxml_node_list_nth (books_list, 0);

  GXmlCharacterData *text;
  GXmlCharacterData *comment;
  text = GXML_CHARACTER_DATA (gxml_document_create_text_node (doc, "Some infinities are bigger than other infinities"));
  comment = GXML_CHARACTER_DATA (gxml_document_create_comment (doc, "As he read, I fell in love the way you fall asleep:"));

  gchar *str;
  gchar *str2;
  
  /* Data representation */

  printf ("Stringifying Text:\n%s\n\n"
	  "Text's CharacterData's data:\n%s\n\n"
	  "Text's CharacterData's length:\n%lu\n\n"
	  "Stringifying Comment:\n%s\n\n"
	  "Comment's CharacterData's data:\n%s\n\n"
	  "Comment's CharacterData's length:\n%lu\n\n",
	  str = gxml_node_to_string (GXML_NODE (text), TRUE, 0),
	  gxml_character_data_get_data (text),
	  gxml_character_data_get_length (text),
	  str2 = gxml_node_to_string (GXML_NODE (comment), TRUE, 0),
	  gxml_character_data_get_data (comment),
	  gxml_character_data_get_length (comment));
  g_free (str);
  g_free (str2);
	  
  /* CharacterData operations */

  gxml_node_append_child (book, GXML_NODE (text));
  printf ("Book with our Text as its child (its content):\n%s\n\n",
	  str = gxml_node_to_string (book, TRUE, 0));
  g_free (str);

  gxml_node_replace_child (book, GXML_NODE (comment), GXML_NODE (text));
  printf ("Book with our Comment as its child (its content):\n%s\n\n",
	  str = gxml_node_to_string (book, TRUE, 0));
  g_free (str);
  
  gxml_character_data_append_data (comment, " slowly, and then all at once");
  printf ("Book after appending more data to Comment:\n%s\n\n",
	  str = gxml_node_to_string (book, TRUE, 0));
  g_free (str);
  
  gxml_character_data_replace_data (comment, 3, 2, "Gus");
  printf ("Book after replacing 'he' with 'Gus':\n%s\n\n",
	  str = gxml_node_to_string (book, TRUE, 0));
  g_free (str);
  
  gxml_character_data_delete_data (comment, 20, 8);
  printf ("Book after deleting 'in love ':\n%s\n\n",
	  str = gxml_node_to_string (book, TRUE, 0));
  g_free (str);

  gxml_character_data_insert_data (comment, 20, "in love ");
  printf ("Book after inserting 'in love ':\n%s\n",
	  str = gxml_node_to_string (book, TRUE, 0));
  g_free (str);  
 
  g_object_unref (doc);
  return 0;
}
