/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml {
	// TODO: see if we can actually support these via libxml2, I can't seem to get to them through Xml.DTD
	/**
	 * Used collectively in defining DocumentTypes. A Notation can
	 * declare the format of unparsed entities or
	 * ProcessingInstruction targets.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-5431D1B9]]
	 */
	public class Notation : XNode {
		// private Xml.Notation *notation; // TODO: wrap libxml's xmlNotation

		/**
		 * The declared name for the notation.
		 */
		public override string node_name {
			get {
				// TODO: needs to be set to the declared name of the notation
				return ""; // notation->name;
			}
			private set {
			}
		}
		/**
		 * The public identifier for the notation, or null if not set.
		 */
		public string? public_id {
			get {
				return null; // notation->public_id;
			}
			private set {
			}
		}
		/**
		 * The system identifier for the notation, or null if not set.
		 */
		public string? system_id {
			get {
				return null; // notation->system_id;
			}
			private set {
			}
		}
		internal Notation (/* Xml.Notation *notation, */ Document doc) {
			base (NodeType.NOTATION, doc); // STUB
			//this.notation = notation;
		}
	}

}
