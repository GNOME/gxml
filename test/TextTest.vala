/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXmlDom;

class TextTest : GXmlTest {
	public static void add_tests () {
		/* NOTE: Node name and node value behaviour tested by DomNodeTest */

		Test.add_func ("/gxml/text/split_text", () => {
				try {
					Text txt1 = get_text_new_doc ("Constant vigilance!");
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

					try {
						txt2.split_text (-1);
						assert (false);
					} catch (DomError.INDEX_SIZE e) {
						assert (true);
					}
					try {
						txt2.split_text (10);
						assert (false);
					} catch (DomError.INDEX_SIZE e) {
						assert (true);
					}
					assert (txt2.node_value == "Const");


				} catch (GXmlDom.DomError e) {
					GLib.warning ("%s", e.message);
					assert (false);
				}
			});
	}
}
