using GXml;

int main (string[] args) {
	// string[] authors = { "John Green", "Jane Austen", "J.D. Salinger" };
	// string[] titles = { "The Fault in Our Stars", "Pride & Prejudice", "Nine Stories" };

	try {
		Document doc = new Document ();
		Element root = doc.create_element ("Bookshelf");
		doc.append_child (root);

		Element owner = doc.create_element ("Owner");
		root.append_child (owner);
		owner.set_attribute ("fullname", "John Green");

		// Element books = doc.create_element ("Books");
		// root.append_child (books);

		//stdout.printf ("create_a_document:\n%s\n", doc.to_string (true, 8));
	} catch (GLib.Error e) {
		stderr.printf ("%s\n", e.message);
	}

	return 0;
}
