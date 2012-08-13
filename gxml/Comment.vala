/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

/* TODO: do we really want a comment node, or just use strings? */
/**
 * An XML comment.
 *
 * An XML example looks like: {{{
 * <someNode>
 *    &lt;!-- this is a comment -->
 *    text in the node
 *  </someNode> }}}
 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1728279322]]
 */
public class GXml.Comment : GXml.CharacterData {
	// TODO: Can I make this only accessible from within the GXml.Dom namespace (e.g. from GXml.Dom.Document?)
	internal Comment (Xml.Node *comment_node, Document doc) {
		base (comment_node, doc);
	}
	public override string node_name {
		get {
			return "#comment";
		}
		private set {
		}
	}

}
