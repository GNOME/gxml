/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXmlDom {
	// TODO: libxml2 doesn't seem to have PI objects, but does
	//       have a function to call when one is parsed.  Let's not
	//       worry about supporting this for right now.

	/**
	 * Stores processor-specific information with the document in
	 * a textual format. For example, with XML stylesheets:
	 * {{{<?xml-stylesheet href="style.xsl" type="text/xml"?>}}}
	 * The general form is
	 * {{{<?pi_target processing instruction data?>}}}
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1004215813]]
	 */
	public class ProcessingInstruction : XNode {
		internal ProcessingInstruction (string target, string data, Document doc) {
			base (NodeType.PROCESSING_INSTRUCTION, doc); // TODO: want to pass a real Xml.Node* ?
			this.target = target;
			this.data = data;
		}

		/**
		 * The target for the processing instruction, like "xml-stylesheet".
		 */
		public string target {
			get;
			private set;
		}
		/**
		 * The data used by the target, like {{{href="style.xsl" type="text/xml"}}}
		 */
		// TODO: confirm that data here is freeform attributes
		public string data /* throws DomError (not supported yet) */ {
			get;
			set;	//throw new DomError.DOM ("Error");
		}
		/**
		 * The target name.
		 */
		public override string node_name {
			get {
				return this.target;
			}
			private set {
			}
		}
		/**
		 * The target's data.
		 */
		public override string? node_value {
			get {
				return this.data;
			}
			private set {
			}
		}

	}
}
