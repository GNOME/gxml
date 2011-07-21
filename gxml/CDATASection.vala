/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we really want a cdata section node, or just use strings? */
	/* TODO: check about casing in #vala */
	/**
	 * An XML CDATA section, which contains non-XML data that is
	 * stored in an XML document. An XML example would be like:
	 * {{{ <![CDATA[Here contains non-XML data, like code, or something that
	 * requires a lot of special XML entities.]]>. }}}
	 * It is a type of Text node. For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-667469212]]
	 */
	public class CDATASection : Text {
		internal CDATASection (Xml.Node *cdata_node, Document doc) {
			base (cdata_node, doc);
		}
		/**
		 * {@inheritDoc}
		 */
		public override string node_name {
			get {
				return "#cdata-section";
			}
			private set {
			}
		}
	}
}
