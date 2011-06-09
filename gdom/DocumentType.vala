/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class DocumentType : VirtualNode {
		/** Constructor */
		internal DocumentType (Document doc) {
			base (NodeType.DOCUMENT_TYPE, doc);
		}


		/** Public properties */
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
