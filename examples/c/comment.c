#include <gxml/gxml.h>

int main () {
  /* Setup */
  GXmlDocument *doc;
  GXmlNode *bookshelf;
  gchar *str;
  GXmlComment *comment;

  doc = gxml_document_new_from_path ("bookshelf_node.xml");
  bookshelf = GXML_NODE (gxml_document_get_document_element (doc));

  printf ("Bookshelf, without any comments:\n%s\n",
	  str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);

  /* Placing comments in the tree */

  comment = gxml_document_create_comment (doc, "this bookshelf is small");
  gxml_node_insert_before (GXML_NODE (doc), GXML_NODE (comment), bookshelf);
  printf ("\nAfter trying to insert a comment before our root element:\n%s\n",
	  str = gxml_node_to_string (GXML_NODE (doc), TRUE, 0));
  g_free (str);

  GXmlNode *owner;
  comment = gxml_document_create_comment (doc, "its owner is an important author");
  owner = gxml_node_get_first_child (bookshelf);
  gxml_node_insert_before (bookshelf, GXML_NODE (comment), owner);
  printf ("\nAfter inserting a comment before our <owner>:\n%s\n",
	  str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);

  GXmlNode *books;
  comment = gxml_document_create_comment (doc, "I should buy more books");
  books = gxml_node_get_next_sibling (owner);
  gxml_node_append_child (books, GXML_NODE (comment));
  printf ("\nAfter appending a comment in <books>:\n%s\n",
	  str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);

  GXmlNode *book;
  book = gxml_node_get_first_child (books);
  comment = gxml_document_create_comment (doc, "this pretty cool book will soon be a pretty cool movie");
  gxml_node_append_child (book, GXML_NODE (comment));
  printf ("\nAfter adding a comment to an empty <book> node:\n%s\n",
	  str = gxml_node_to_string (bookshelf, TRUE, 0));
  g_free (str);

  /* Comments as CharacterData */
  printf ("\nStringified Comments have <!-- -->, like this one:\n%s\n",
	  str = gxml_node_to_string (GXML_NODE (comment), TRUE, 0));
  g_free (str);

  GXmlCharacterData *chardata = GXML_CHARACTER_DATA (comment);
  
  printf ("\nComments are CharacterData, so previous comment's data:\n%s\n",
	  gxml_character_data_get_data (chardata));
  
  printf ("\nComments are CharacterData, so previous comment's length:\n%lu\n",
	  gxml_character_data_get_length (chardata));

  gxml_character_data_append_data (chardata, ".  Did you read it?");
  printf ("\nComment after using CharacterData's append_data ():\n  %s\n",
	  str = gxml_node_to_string (GXML_NODE (comment), TRUE, 0));
  g_free (str);
	  
  gxml_character_data_replace_data (chardata, 12, 4, "awesome");
  printf ("\nComment after using CharacterData's replace_data () (cool -> awesome).\n" 
	 "Note that this affects the data as seen in CharacterData's .data property, excluding the comment's surrounding <!-- and -->:\n  %s\n",
	 str = gxml_node_to_string (GXML_NODE (comment), TRUE, 0));
  g_free (str);

  g_object_unref (doc);

  return 0;
}
