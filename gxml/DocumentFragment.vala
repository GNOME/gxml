/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* Lightweight Document object for fragments

	   has a root for the fragment, the fragment of the document is a child to this root
	   if you insert the fragment into a node, the fragment's root is lost and replaced by the receiving node

	   TODO: look into inserting DocumentFragments into nodes
	   * do not insert this node itself, but instead insert its children!
	   * libxml2 might handle this for us already
	   * need to test it
	   TODO: lookup libxml2's support for DocumentFragments

	   [0,inf) children

	 */
	public class DocumentFragment : BackedNode {
		internal DocumentFragment (Xml.Node *fragment_node, Document doc) {
			base (fragment_node, doc);
		}
	}
}
