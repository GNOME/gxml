using GXml;

void create_a_document () {
	string[] authors = { "John Green", "Jane Austen", "J.D. Salinger" };
	string[] titles = { "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" };

	Document doc = new Document ();
	Element root = doc.create_element ("Bookshelf");
	doc.append_child (root);
	Element owner = doc.create_element ("Owner");
	root.append_child (owner);
	owner.set_attribute ("fullname", "John Green");

	Element books = doc.create_element ("Books");
	root.append_child (books);

	for (int i = 0; i < authors.length; i++) {
		Element book = doc.create_element ("Book");
		book.set_attribute ("author", authors[i]);
		book.set_attribute ("title", titles[i]);
		books.append_child (book);
	}

	stdout.printf ("create_a_document:\n%s\n", doc.to_string (true, 8));
}

void create_a_document_from_a_string () {
	string xml;
	Document doc;

	xml = """<?xml version="1.0"?>
<Bookshelf>
<Owner fullname="John Green"/>
<Books>
<Book author="John Green" title="The Fault in Our Stars"/>
<Book author="Jane Austen" title="Pride &amp; Prejudice"/>
<Book author="J.D. Salinger" title="Nine Stories"/>
</Books>
</Bookshelf>""";

	doc = new Document.from_string (xml);
	stdout.printf ("create_a_document_from_a_string:\n%s\n", doc.to_string (true, 8));
}

void create_a_document_from_a_file () {
	File f = File.new_for_path ("bookshelf.xml");
	Cancellable can = new Cancellable ();
	Document doc;

	doc = new Document.from_gfile (f, can);
	stdout.printf ("create_a_document_from_a_file:\n%s\n", doc.to_string (true, 8));
}

void create_a_document_from_a_path () {
	Document doc;

	doc = new Document.from_path ("bookshelf.xml");
	stdout.printf ("create_a_document_from_a_path:\n%s\n", doc.to_string (true, 8));
}

void saving_a_document_to_a_path () {
	Document doc;

	doc = new Document.from_path ("bookshelf.xml");
	doc.save_to_path ("bookshelf2.xml");
}

int main (string[] args) {
	create_a_document ();
	create_a_document_from_a_string ();
	create_a_document_from_a_file ();
	create_a_document_from_a_path ();
	saving_a_document_to_a_path ();

	return 0;
}
