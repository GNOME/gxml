using GXml;

void create_a_document () throws GLib.Error {
	string[] authors = { "John Green", "Jane Austen", "J.D. Salinger" };
	string[] titles = { "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" };

	DomDocument doc = new GXml.Document ();
	DomElement root = doc.create_element ("Bookshelf");
	doc.append_child (root);
	DomElement owner = doc.create_element ("Owner");
	root.append_child (owner);
	owner.set_attribute ("fullname", "John Green");

	DomElement books = doc.create_element ("Books");
	root.append_child (books);

	for (int i = 0; i < authors.length; i++) {
		DomElement book = doc.create_element ("Book");
		book.set_attribute ("author", authors[i]);
		book.set_attribute ("title", titles[i]);
		books.append_child (book);
	}

	stdout.printf ("create_a_document:\n%s\n", ((GXml.Document) doc).write_string ());
}

void create_a_document_from_a_string () throws GLib.Error {
	string xml;
	DomDocument doc;

	xml = """<?xml version="1.0"?>
<Bookshelf>
<Owner fullname="John Green"/>
<Books>
<Book author="John Green" title="The Fault in Our Stars"/>
<Book author="Jane Austen" title="Pride &amp; Prejudice"/>
<Book author="J.D. Salinger" title="Nine Stories"/>
</Books>
</Bookshelf>""";

	doc = new GXml.Document.from_string (xml);
	stdout.printf ("create_a_document_from_a_string:\n%s\n", ((GXml.Document) doc).write_string ());
}

void create_a_document_from_a_file (string uri) throws GLib.Error {
	File f = File.new_for_uri (uri+"/bookshelf2.xml");
	stdout.printf (uri+"\n");
	DomDocument doc;

	doc = new GXml.Document.from_file (f);
	stdout.printf ("create_a_document_from_a_file:\n%s\n", ((GXml.Document) doc).write_string ());
}

void create_a_document_from_a_path (string uri) throws GLib.Error {
	DomDocument doc;
	GLib.File f = GLib.File.new_for_uri (uri+"/bookshelf2.xml");

	doc = new GXml.Document.from_path (f.get_path ());
	stdout.printf ("create_a_document_from_a_path:\n%s\n", ((GXml.Document) doc).write_string ());
}

void saving_a_document_to_a_path (string uri) throws GLib.Error {
	string xml;
	DomDocument doc;

	xml = """<?xml version="1.0"?>
<Bookshelf>
<Owner fullname="John Green"/>
<Books>
<Book author="John Green" title="The Fault in Our Stars"/>
<Book author="Jane Austen" title="Pride &amp; Prejudice"/>
<Book author="J.D. Salinger" title="Nine Stories"/>
</Books>
</Bookshelf>""";
	GLib.File f = GLib.File.new_for_uri (uri+"/bookshelf2.xml");
	stdout.printf (f.get_path ()+"\n");
	doc = new GXml.Document.from_string (xml);
	if (f.query_exists ()) f.delete ();
	((GXml.Document) doc).write_file (f);
	if (!f.query_exists ()) stdout.printf ("Can't save file bookshelf2.xml");
}

int main (string[] args) {
	GLib.File ex = GLib.File.new_for_path (args[0]);
	GLib.File fex = ex.get_parent ();
	
	try {
		create_a_document ();
		create_a_document_from_a_string ();
		saving_a_document_to_a_path (fex.get_uri ());
		create_a_document_from_a_path (fex.get_uri ());
		create_a_document_from_a_file (fex.get_uri ());
		GLib.File f = GLib.File.new_for_uri (fex.get_uri ()+"/bookshelf2.xml");
		if (f.query_exists ()) f.delete ();
	} catch (GLib.Error e) {
		warning ("Error: "+e.message);
	}

	return 0;
}
