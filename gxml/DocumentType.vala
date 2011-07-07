/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class DocumentType : XNode {
		private Xml.Dtd *int_subset;
		private Xml.Dtd *ext_subset;

		/** Constructor */
		internal DocumentType (Xml.Dtd *int_subset, Xml.Dtd *ext_subset, Document doc) {
			// TODO: for name, we want a real name of the doc type
			base (NodeType.DOCUMENT_TYPE, doc);

			this.int_subset = int_subset;
			this.ext_subset = ext_subset;
		}


		/** Public properties */

		/* That which follows DOCTYPE, e.g. xml */
		public string name {
			get {
				// TODO: is it possible for int_subset and ext_subset to have different names?
				return this.int_subset->name;
			}
			private set {
			}
		}

		/* using GHashTable for XML's NamedNodeMap */
		public HashTable<string,Entity>? entities {
			get {
				// TODO: need to create a HashTable<string,Entity> uniting these two
				//       discard duplicates
				// TODO: what type of hashtable is Xml.Dtd*'s entities?
				//return this.int_subset->entities;
				// TODO: nuisance: libxml2 doesn't have entities wrapped
				return null;
			}
			private set {
			}
		}

		public HashTable<string,Notation>? notations {
			get {
				// TODO: need to create a HashTable<string,Notation> uniting the two
				//       discard duplicates
				// TODO: what type of hashtable is Xml.Dtd*'s notations?
				//return this.int_subset->notations;
				// TODO: nuisance: libxml2 doesn't have notations wrapped
				return null;
			}
			private set {
			}
		}

	}
}
