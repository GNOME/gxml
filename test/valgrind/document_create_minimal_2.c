#include <gxml/gxml.h>
#include <stdio.h>


int main () {
  GXmlDocument *doc;
  GXmlElement *root;
  GXmlElement *owner;
  GXmlElement *books;
  GXmlElement *book;
  int i;
  char *str;

  char *authors[] = { "John Green", "Jane Austen", "J.D. Salinger" };
  char *titles[] = { "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" };

  doc = gxml_document_new ();

  // Add a root node
  root = gxml_document_create_element (doc, "Bookshelf");
  gxml_node_append_child (GXML_NODE (doc), GXML_NODE (root));
  // if we tried to add a second one, it would fail and a g_warning would be printed :)

  // Add an owner node
  owner = gxml_document_create_element (doc, "Owner");
  gxml_node_append_child (GXML_NODE (root), GXML_NODE (owner));
  gxml_element_set_attribute (owner, "fullname", "John Green");
  /* // TODO: need to figure out what sort of errors these would return, */
  /* // want the devhelp pages to describe meaningful possible errors */

  /* // Add a collection of books */
  books = gxml_document_create_element (doc, "Books");
  /* gxml_node_append_child (GXML_NODE (root), GXML_NODE (books)); */
  /* for (i = 0; i < sizeof (authors) / sizeof (char*); i++) { */
  /*   book = gxml_document_create_element (doc, "Book"); */
  /*   gxml_element_set_attribute (book, "author", authors[i]); */
  /*   gxml_element_set_attribute (book, "title", titles[i]); */
  /*   gxml_node_append_child (GXML_NODE (books), GXML_NODE (book)); */
  /* } */

  /* str = gxml_node_to_string (GXML_NODE (doc), TRUE, 2); */
  /* printf ("%s:\n%s\n", __FILE__, str); */
  /* g_free (str); */

  /* g_object_unref (doc); */
  /* g_object_unref (root); */
  /* g_object_unref (owner); */
  /* g_object_unref (books); */
  /* g_object_unref (book); */

  //g_object_unref (owner);
  //g_object_unref (root);
  g_object_unref (doc);

  // TODO: how do we clean them up?

  return 0;
}

