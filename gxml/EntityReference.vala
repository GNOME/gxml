/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we need an EntityReference? find out what it's used for */
	public class EntityReference : XNode {
		internal EntityReference (string refname, Document doc) {
			// TODO: may want to handle refname differently
			base (NodeType.ENTITY_REFERENCE, doc); // TODO: what should we pass up?
			this.node_name = refname;
		}
		public override string node_name {
			get;
			private set;
		}
	}
}
