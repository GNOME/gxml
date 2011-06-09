/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	/* TODO: do we need an EntityReference? find out what it's used for */
	public class EntityReference : VirtualNode {
		internal EntityReference (Document doc) {
			base (NodeType.ENTITY_REFERENCE, doc); // TODO: what should we pass up?
		}
	}
}
