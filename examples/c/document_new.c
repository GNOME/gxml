#include <gxml/gxml.h>
#include <stdio.h>

int main () {
  GXmlDomDocument *doc;
  GXmlDomElement *root;
  GXmlDomElement *owner;
  GXmlDomElement *books;
  GXmlDomElement *book;
  GError *error = NULL;
  int i;
  char *str;

  char *authors[] = { "John Green", "Jane Austen", "J.D. Salinger" };
  char *titles[] = { "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" };

  doc = (GXmlDomDocument*) gxml_document_new ();

  // Add a root node
  root = gxml_dom_document_create_element (doc, "Bookshelf", &error);
  if (error != NULL) {
    printf ("Error creating root node: %s", error->message);
    exit (1);
  }

  gxml_dom_node_append_child (GXML_DOM_NODE (doc), GXML_DOM_NODE (root), &error);
  if (error != NULL) {
    printf ("Error appending root to document: %s", error->message);
    exit (1);
  }

  // Add an owner node
  owner = gxml_dom_document_create_element (doc, "Owner", &error);
  if (error != NULL) {
    printf ("Error creating a new element node: %s", error->message);
    exit (1);
  }
  gxml_dom_node_append_child (GXML_DOM_NODE (root), GXML_DOM_NODE (owner), &error);
  if (error != NULL) {
    printf ("Error appending child to root: %s", error->message);
    exit (1);
  }
  gxml_dom_element_set_attribute (owner, "fullname", "John Green", &error);
  if (error != NULL) {
    printf ("Error setting attribute to Owner element node: %s", error->message);
    exit (1);
  }

  // Add a collection of books
  books = gxml_dom_document_create_element (doc, "Books", &error);
  if (error != NULL) {
    printf ("Error creating Books element node: %s", error->message);
    exit (1);
  }
  gxml_dom_node_append_child (GXML_DOM_NODE (root), GXML_DOM_NODE (books), &error);
  if (error != NULL) {
    printf ("Error appending Books node to root: %s", error->message);
    exit (1);
  }

  for (i = 0; i < sizeof (authors) / sizeof (char*); i++) {
    book = gxml_dom_document_create_element (doc, "Book", &error);
    if (error != NULL) {
      printf ("Error creating %i element node: %s", i, error->message);
      exit (1);
    }
    gxml_dom_element_set_attribute (book, "author", authors[i], &error);
    if (error != NULL) {
      printf ("Error setting author attribute to %i element: %s", i, error->message);
      exit (1);
    }
    gxml_dom_element_set_attribute (book, "title", titles[i], &error);
    if (error != NULL) {
      printf ("Error setting title attribute to %i eleemnt: %s", i, error->message);
      exit (1);
    }
    gxml_dom_node_append_child (GXML_DOM_NODE (books), GXML_DOM_NODE (book), &error);
    if (error != NULL) {
      printf ("Error appending %i child node to Books node: %s", i, error->message);
      exit (1);
    }
    g_object_unref (book);
  }

  str = gxml_dom_element_write_string (GXML_DOM_ELEMENT (root), NULL, &error);
  if (error != NULL) {
    printf ("Error writing string from root: %s", error->message);
    exit (1);
  }
  printf ("%s:\n%s\n", __FILE__, str);
  g_free (str);

  g_object_unref (owner);
  g_object_unref (books);
  g_object_unref (root);
  g_object_unref (doc);

  return 0;
}
