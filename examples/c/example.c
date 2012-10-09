#include <gxml/gxml.h>
#include <stdio.h>

int handle_error (GError *error) {
  // TODO: better way to check whether it was set?
  if (error != NULL) {
    g_error (error->message);
    return 1;
  }

  return 0;
}

int create_a_document () {
  GError *error = NULL;
  GXmlDocument *doc;
  GXmlElement *root;
  GXmlElement *owner;
  GXmlElement *books;
  GXmlElement *book;
  int i;
  char *str;

  char *authors[] = { "John Green", "Jane Austen", "J.D. Salinger" };
  char *titles[] = { "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" };

  doc = gxml_document_new (&error);
  handle_error (error);

  // Add a root node
  root = gxml_document_create_element (doc, "Bookshelf", &error);
  handle_error (error);

  gxml_dom_node_append_child (GXML_DOM_NODE (doc), GXML_DOM_NODE (root), &error);
  handle_error (error);
  // if we tried to add a second one, it would fail and GError would be set :)

  // Add an owner node
  owner = gxml_document_create_element (doc, "Owner", &error);
  handle_error (error);
  gxml_dom_node_append_child (GXML_DOM_NODE (root), GXML_DOM_NODE (owner), &error);
  handle_error (error);
  gxml_element_set_attribute (owner, "fullname", "John Green", &error);
  // TODO: need to figure out what sort of errors these would return,
  // want the devhelp pages to describe meaningful possible errors
  handle_error (error);

  // Add a collection of books
  books = gxml_document_create_element (doc, "Books", &error);
  handle_error (error);
  gxml_dom_node_append_child (GXML_DOM_NODE (root), GXML_DOM_NODE (books), &error);

  for (i = 0; i < sizeof (authors) / sizeof (char*); i++) {
    book = gxml_document_create_element (doc, "Book", &error);
    handle_error (error);
    gxml_element_set_attribute (book, "author", authors[i], &error);
    handle_error (error);
    gxml_element_set_attribute (book, "title", titles[i], &error);
    handle_error (error);
    gxml_dom_node_append_child (GXML_DOM_NODE (books), GXML_DOM_NODE (book), &error);
    handle_error (error);
  }

  // TODO: want a "gxml_dom_node_from_string ()"; make sure document ownership transfer properly

  str = gxml_dom_node_to_string (GXML_DOM_NODE (doc), TRUE, 2);
  printf ("create_a_document:\n%s\n", str);
  g_free (str);

  g_object_unref (doc); 
  g_object_unref (root); // TODO: figure out what happens to root if you deallocate doc?! */
  // TODO: perhaps see whether we can make it that all the nodes that are returned are weak references
  g_object_unref (owner);
  g_object_unref (books);
  g_object_unref (book);
  /* In util/ there's a small programme that tells you when ownership
     is transfered (that is, you are given a return value that you own
     and must free. */

  return 0;
}

int create_a_document_minimal () {
  GXmlDocument *doc;
  GXmlElement *root;
  GXmlElement *owner;
  GXmlElement *books;
  GXmlElement *book;
  int i;
  char *str;

  char *authors[] = { "John Green", "Jane Austen", "J.D. Salinger" };
  char *titles[] = { "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" };

  doc = gxml_document_new (NULL);

  // Add a root node
  root = gxml_document_create_element (doc, "Bookshelf", NULL);
  gxml_dom_node_append_child (GXML_DOM_NODE (doc), GXML_DOM_NODE (root), NULL);
  // if we tried to add a second one, it would fail and GError would be set :)

  // Add an owner node
  owner = gxml_document_create_element (doc, "Owner", NULL);
  gxml_dom_node_append_child (GXML_DOM_NODE (root), GXML_DOM_NODE (owner), NULL);
  gxml_element_set_attribute (owner, "fullname", "John Green", NULL);
  // TODO: need to figure out what sort of errors these would return,
  // want the devhelp pages to describe meaningful possible errors

  // Add a collection of books
  books = gxml_document_create_element (doc, "Books", NULL);
  gxml_dom_node_append_child (GXML_DOM_NODE (root), GXML_DOM_NODE (books), NULL);
  for (i = 0; i < sizeof (authors) / sizeof (char*); i++) {
    book = gxml_document_create_element (doc, "Book", NULL);
    gxml_element_set_attribute (book, "author", authors[i], NULL);
    gxml_element_set_attribute (book, "title", titles[i], NULL);
    gxml_dom_node_append_child (GXML_DOM_NODE (books), GXML_DOM_NODE (book), NULL);
  }

  str = gxml_dom_node_to_string (GXML_DOM_NODE (doc), TRUE, 2);
  printf ("create_a_document_minimal:\n%s\n", str);
  g_free (str);

  g_object_unref (doc);
  g_object_unref (root);
  g_object_unref (owner);
  g_object_unref (books);
  g_object_unref (book);

  // TODO: how do we clean them up?

  return 0;
}

int create_a_document_from_a_string () {
  char *xml;
  char *str;
  GXmlDocument *doc;

  xml = "<?xml version=\"1.0\"?><Bookshelf><Owner fullname=\"John Green\"/><Books><Book author=\"John Green\" title=\"The Fault in Our Stars\"/><Book author=\"Jane Austen\" title=\"Pride &amp; Prejudice\"/><Book author=\"J.D. Salinger\" title=\"Nine Stories\"/></Books></Bookshelf>";

  doc = gxml_document_new_from_string (xml, NULL);

  str = gxml_dom_node_to_string (GXML_DOM_NODE (doc), TRUE, 2);
  printf ("create_a_document_from_a_string:\n%s\n", str);
  g_free (str);

  g_object_unref (doc);

  return 0;
}

int create_a_document_from_a_file () {
  GXmlDocument *doc;
  GFile *file;
  char *str;
  GCancellable *can = g_cancellable_new ();
  GError *error = NULL;

  file = g_file_new_for_path ("bookshelf.xml");
  doc = gxml_document_new_from_gfile (file, can, &error); // TODO: want to change this function name to "from file"
  handle_error (error);

  str = gxml_dom_node_to_string (GXML_DOM_NODE (doc), TRUE, 2);
  printf ("create_a_document_from_a_file:\n%s\n", str);
  g_free (str);

  g_object_unref (doc);
  // TODO: how do you free a GFile?  g_object_unref ()? 
  

  return 0;
}

int create_a_document_from_a_path () {
  GXmlDocument *doc;
  char *str;

  doc = gxml_document_new_from_path ("bookshelf.xml", NULL); 
  str = gxml_dom_node_to_string (GXML_DOM_NODE (doc), TRUE, 2);
  printf ("create_a_document_from_a_file:\n%s\n", str);
  g_free (str);

  g_object_unref (doc);

  return 0;
}

int saving_a_document_to_a_path () {
  GXmlDocument *doc;

  doc = gxml_document_new_from_path ("bookshelf.xml", NULL);

  gxml_document_save_to_path (doc, "bookshelf2.xml");

  g_object_unref (doc);

  return 0;
}

int saving_a_document_to_a_stream () {
  GXmlDocument *doc;
  GFile *outfile;
  GFileOutputStream *outstream;
  GCancellable *can = g_cancellable_new ();
  GError *error = NULL;

  doc = gxml_document_new_from_path ("bookshelf.xml", &error);

  outfile = g_file_new_for_path ("bookshelf3.xml");
  outstream = g_file_replace (outfile, NULL, FALSE, G_FILE_CREATE_REPLACE_DESTINATION, can, &error);
  gxml_document_save_to_stream (doc, G_OUTPUT_STREAM (outstream), can, &error);

  g_object_unref (doc);
  // TODO: figure out how to close/unref outstream and outfile

  return 0;
}

int main (void) {
  g_type_init ();

  create_a_document (); // has token error checking
  create_a_document_minimal ();
  create_a_document_from_a_string ();
  create_a_document_from_a_file ();
  create_a_document_from_a_path ();
  
  saving_a_document_to_a_path ();
  saving_a_document_to_a_stream ();

  /* TODO: add these examples */
  // find_nodes_of_given_tag ();
  // find_nodes_matching_an_attribute ();

  // accessing_attributes ();

  // find_

  return 0;
}
