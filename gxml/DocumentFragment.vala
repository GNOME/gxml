/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXmlDom {
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
	/**
	 * An incomplete portion of a Document. This is not restricted
	 * to having a root document element, or being completely
	 * valid. It can have multiple children, which, if the
	 * DocumentFragment is inserted as a child to another node,
	 * become that nodes' children, without the DocumentFragment
	 * itself existing as a child.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-B63ED1A3]]
	 */
	public class DocumentFragment : BackedNode {
		internal DocumentFragment (Xml.Node *fragment_node, Document doc) {
			base (fragment_node, doc);
		}
	}
}
