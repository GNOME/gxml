/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class DocumentType : XNode {
		private Xml.Dtd *dtd;

		/** Constructor */
		internal DocumentType (Xml.Dtd *dtd, Document doc) {
			// TODO: for name, we want a real name of the doc type
			base (NodeType.DOCUMENT_TYPE, doc);

			this.dtd = dtd;
		}


		/** Public properties */

		/* That which follows DOCTYPE, e.g. xml */
		string name {
			get {
				return this.dtd->name;
			}
			private set;
		}

		/* using GHashTable for XML's NamedNodeMap */
		public HashTable<string,Entity> entities {
			get {
				// TODO: what type of hashtable is Xml.Dtd*'s entities?
				return this.dtd->entities;
			}
			private set;
		}

		public HashTable<string,Notation> notations {
			get {
				// TODO: what type of hashtable is Xml.Dtd*'s notations?
				return this.dtd->notations;
			}
			private set;
		}

	}
}
