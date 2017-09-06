#!/usr/bin/gjs

const GXml = imports.gi.GXml;

/* Setup */
var doc = GXml.GomDocument.from_path ("bookshelf_node.xml");
var bookshelf = doc.document_element;
var date_today = doc.create_element ("Date");
date_today.append_child (doc.create_text_node ("Today"));
bookshelf.append_child (date_today);
var date_clone_shallow = date_today.clone_node (false);
bookshelf.append_child (date_clone_shallow);
var date_clone_deep = date_today.clone_node (true);
bookshelf.append_child (date_clone_deep);
if (!bookshelf.child_nodes.contains (date_clone_deep)) print ("Date Clone Deep not present!");

var date_today_text = doc.create_text_node ("Today");
date_today.append_child (date_today_text);

print ("Bookshelf after appending a new element:\n" + bookshelf.write_string () + "\n\n");

/* Checking whether children exist */
print ("Does Bookshelf have child nodes? " + bookshelf.has_child_nodes () + "\n");
print ("Does the shallow Date clone have child nodes? " +
       date_clone_shallow.has_child_nodes () + "\n\n");

/* Accessing the first child */
var bookshelf_first_child = bookshelf.first_child;
print ("Bookshelf's first child:\n" + bookshelf_first_child.write_string () + "\n\n");

var date_clone_cur_text = date_clone_deep.child_nodes.item (0);
print ("Our deep clone's first child:\n" + date_clone_cur_text.data + "\n\n");

/* Replacing a child */
var date_clone_new_text = doc.create_text_node ("Tomorrow");
date_clone_deep.replace_child (date_clone_new_text, date_clone_cur_text);

print ("Bookshelf after replacing the Text of our deep clone of Date:\n" +
       bookshelf.write_string () + "\n\n");

/* Inserting a new child before an existing child */
var date_yesterday = doc.create_element ("Date");
var date_yesterday_text = doc.create_text_node ("Yesterday");
date_yesterday.append_child (date_yesterday_text);

bookshelf.insert_before (date_yesterday, date_today);

print ("Bookshelf after inserting Date Yesterday before Date Today:\n" +
       bookshelf.write_string () + "\n\n");

/* Removing a child */
bookshelf.remove_child (date_clone_shallow);

print ("Bookshelf after removing the shallow date clone:\n" +
	bookshelf.write_string () + "\n\n");

/* Accessing the last child */
var last_child = bookshelf.last_child;
print ("Bookshelf's last child:\n" + last_child.write_string () + "\n\n");

/* Traversing children via next and previous sibling */
var cur_child = null;
var i = 0;

print ("Bookshelf's children, using next_sibling from the first_child:\n");
for (cur_child = bookshelf.first_child; cur_child != null;
     cur_child = cur_child.next_sibling) {
    print ("  Child " + i + "\n    " + cur_child.write_string () + "\n");
    i++;
}

print ("Bookshelf's children, using previous_sibling from the last_child:\n");
for (cur_child = bookshelf.last_child; cur_child != null;
     cur_child = cur_child.previous_sibling) {
    i--;
    print ("  Child " + i + "\n    " + cur_child.write_string () + "\n");
}
print ("\n");

/* Traversing children through its GXmlNodeList of child nodes */
var children = bookshelf.child_nodes;

var len = children.length;
print ("Bookshelf's children, using get_child_nodes and incrementing by index:\n");
for (i = 0; i < len; i++) {
    var child = children.item (i);
    print ("  Child " + i + "\n    " + child.write_string () + "\n");
}
print ("\n");  


/* Access the parent node from a node */
var ln = bookshelf.get_elements_by_tag_name ("Book");
var first_book = ln.get_element (0);
var first_book_parent = first_book.parent_node;
print ("The parent of " + first_book.write_string () + " looks like:\n  " +
       first_book_parent.write_string () + "\n\n");


