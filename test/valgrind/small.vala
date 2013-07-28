using GXml;

void create_a_document () {
	try {
		Document doc = new Document ();

		// Element root = doc.create_element ("Bookshelf");
		// doc.append_child (root);

		// Element owner = doc.create_element ("Owner");
		// root.append_child (owner);
		// owner.set_attribute ("fullname", "John Green");

		stdout.printf ("create_a_document:\n%s\n", doc.to_string (true, 8));
	} catch (GLib.Error e) {
		stderr.printf ("%s\n", e.message);
	}
}

int main (string[] args) {
	create_a_document ();

	return 0;
}
