/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml {
	/**
	 * Defines a Document, such as the entities that it can use.
	 * 
	 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-412266927]]
	 */
	public class DocumentType : DomNode {
		private Xml.Dtd *int_subset;
		private Xml.Dtd *ext_subset;

		/** Constructor */
		internal DocumentType (Xml.Dtd *int_subset, Xml.Dtd *ext_subset, Document doc) {
			// TODO: for name, we want a real name of the doc type
			base (NodeType.DOCUMENT_TYPE, doc);

			this.int_subset = int_subset;
			this.ext_subset = ext_subset;
		}


		/* Public properties */

		/**
		 * That which follows DOCTYPE, like 'xml' or 'html', For example, the name
		 * 'html' exists for a document with the XML doctype
		 * declaration of {{{ &lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> }}}
		*/
		public string name {
			get {
				// TODO: is it possible for int_subset and ext_subset to have different names?
				return this.int_subset->name;
			}
			private set {
			}
		}

		/* TODO: make more static methods internal instead of public, if possible */
		internal static void myScannerFull (void *payload, void *userdata, string name1, string name2, string name3) {
			GLib.message ("scanner found [%s,%s,%s]", name1, name2, name3);
		}

		/* using GHashTable for XML's NamedNodeMap */
		/**
		 * A HashTable of entities defined for this DocumentType.
		 */
		// TODO: provide examples
		public HashTable<string,Entity>? entities {
			get {
				// TODO: need to create a HashTable<string,Entity> uniting these two
				//       discard duplicates
				// TODO: what type of hashtable is Xml.Dtd*'s entities?
				Xml.HashTable *table = this.int_subset->entities;

				GLib.message ("About to scan for entities");
				table->scan_full ((Xml.HashScannerFull)myScannerFull, null);
				return null;
				// TODO: nuisance: libxml2 doesn't have entities wrapped
			}
			private set {
			}
		}
		/**
		 * A HashTable of notations defined for this DocumentType.
		 */
		// TODO: provide examples
		public HashTable<string,Notation>? notations {
			get {
				// TODO: need to create a HashTable<string,Notation> uniting the two
				//       discard duplicates
				// TODO: what type of hashtable is Xml.Dtd*'s notations?
				//Xml.HashTable *table =  this.int_subset->notations;
				return null;
				// TODO: nuisance: libxml2 doesn't have notations wrapped
			}
			private set {
			}
		}

	}
}
