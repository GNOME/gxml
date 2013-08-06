/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml;

class TextTest : GXmlTest {
	public static void add_tests () {
		/* NOTE: GXml.Node name and node value behaviour tested by NodeTest */

		Test.add_func ("/gxml/text/split_text", () => {
				Document doc;
				Text txt1 = get_text_new_doc ("Constant vigilance!", out doc);
				Text txt2 = txt1.split_text (5);

				assert (txt1.node_value == "Const");
				assert (txt2.node_value == "ant vigilance!");

				/* TODO: libxml2 doesn't allow txt siblings, so for now
				   splitting text creates an unattached second Text
				   node.  It might still be useful if you wanted to insert
				   an element in between, like with HTML markup? */
				/*
				  assert (txt1.parent_node == txt2.parent_node);
				  assert (txt1.next_sibling == txt2);
				  assert (txt1 == txt2.previous_sibling);
				*/

				txt2 = txt1.split_text (0);
				assert (txt1.node_value == "");
				assert (txt2.node_value == "Const");

				txt1 = txt2.split_text (5);
				assert (txt1.node_value == "");
				assert (txt2.node_value == "Const");

				txt1 = txt2.split_text (-2);
				test_error (DomException.INDEX_SIZE);
				assert (txt1.node_value == ""); // TODO: decide if we want to return null instead
				assert (txt2.node_value == "Const");

				txt1 = txt2.split_text (10);
				test_error (DomException.INDEX_SIZE);
				assert (txt1.node_value == ""); // TODO: decide if we want to return null instead
				assert (txt2.node_value == "Const");
			});
	}
}
