using GXml;

void create_a_document () {
	try {
		Element owner;

		{
			Document doc = new Document ();
			Element root = doc.create_element ("Bookshelf");
			doc.append_child (root);
			owner = doc.create_element ("Owner");
			root.append_child (owner);
			// owner.set_attribute ("fullname", "John Green");
		}
		stdout.printf ("Element owner:\n%s\n", owner.to_string (true, 8));
	} catch (GLib.Error e) {
		stderr.printf ("%s\n", e.message);
	}
}

int main (string[] args) {
	create_a_document ();

	return 0;
}
