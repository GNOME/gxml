/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	class DocumentType : Node {
		/* these 3 are read only */
		string name {
			get;
			private set;
		}

		/* using GHashTable for XML's NamedNodeMap */
		public HashTable<string,Entity> entities {
			get; /* const? */
			private set;
		}

		// private HashTable<string,Notation> _notations;
		public HashTable<string,Notation> notations {
			get; /* const? */
			private set;
		}
	}
}
