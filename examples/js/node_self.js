#!/usr/bin/gjs

/* https://bugzilla.gnome.org/show_bug.cgi?id=706907
   Sadly, we can't handle GHashTables as properties in gjs yet :( */
var bug_706907_bypass = true;

const GXml = imports.gi.GXml;

/* Setup */
var doc = GXml.Document.from_path ("bookshelf_node.xml");
var bookshelf = doc.document_element;
var date_today = doc.create_element ("Date");
date_today.append_child (doc.create_text_node ("Today"));


/* Stringification */
print ("Stringifying bookshelf:\n" + bookshelf.to_string (true, 0) + "\n\n");

/* Adding clones */
var date_clone_shallow = date_today.clone_node (false);
var date_clone_deep = date_today.clone_node (true);

bookshelf.append_child (date_clone_shallow);
bookshelf.append_child (date_clone_deep);

print ("Bookshelf after adding clones:\n" + bookshelf.to_string (true, 0) + "\n\n");

/* Access the node's attributes map - note that this only applies to Elements
   http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1841493061 */
var book_list = doc.get_elements_by_tag_name ("Book");
var first_book = book_list.first ();

if (! bug_706907_bypass) {
    var attrs = first_book.attributes;
    
    print ("List attributes from element: " + first_book.to_string (false, 0) + "\n");
    for (attrs_keys = attrs.get_keys (); attrs_keys != null; attrs_keys = attrs_keys.next) {
	var attr = attrs.lookup (attrs_keys.data);
	print ("  " + attr.name + " => " + attr.value +
	       "  (" + (attr.specified ? "specified" : "not specified") + ")\n");
    }
    print ("\n");
}

/* Access the owner document from the node */
var owner_document = bookshelf.owner_document;

print ("The owner document for Bookshelf looks like:\n" + owner_document.to_string (false, 0) + "\n\n");

/* Check node types */
var author_attr = first_book.get_attribute ("author");

print ("A:");
for (x in GXml.NodeType) {
    print (x);
}
var test = GXml.NodeType['DOCUMENT'];
print (test);
print (GXml.NodeType.DOCUMENT);

print ("\nGet class");
print (GXml.NodeType);

print ("Document is of type: " + doc.node_type); // .to_string ());
/* How do we support macro wrappers from C in JS? 
print ("Bookshelf is of type: %s\n", bookshelf.node_type.to_string ());
print ("Bookshelf is of type: %s\n", author_attr.node_type.to_string ());
*/

