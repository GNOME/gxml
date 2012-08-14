/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml {
	/* TODO: do we need an EntityReference? find out what it's used for */
	// TODO: figure out some way to represent this from libxml2, or handle it ourselves
	//       may not even need it while based on libxml2
	// It's possible that libxml2 already expands entity references and that this class
	// won't be used

	/**
	 * A reference to an unparsed {@link GXml.Entity}, like "&apos;" for an apostrophe.
	 *
	 * To create one, use {@link GXml.Document.create_entity_reference}.
	 *
	 * The entity name, e.g. "apos", is stored as the EntityReference's `node_name`.
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-11C98490]]
	 */
	// TODO: make sure that character entity references (like the one used in the example above, are valid
	public class EntityReference : DomNode {
		internal EntityReference (string refname, Document doc) {
			// TODO: may want to handle refname differently
			base (NodeType.ENTITY_REFERENCE, doc); // TODO: what should we pass up?
			this.node_name = refname;
		}
		/**
		 * Stores the reference entity's name ("apos" for &apos;).
		 */
		// TODO: not sure if that's correct ^
		public override string node_name {
			get;
			private set;
		}
	}
}
