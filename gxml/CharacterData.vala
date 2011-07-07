/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class CharacterData : XNode {
		public string data;
		public ulong length {
			get {
				return data.length;
			}
			private set {
			}
		}
		
		internal CharacterData (Xml.Node *char_node, Document doc) {
			this (char_node, doc);
		}

		public string substringData(ulong offset, 
					    ulong count) { // throws DomError 
			// STUB
			return "";
		}

		public void appendData(string arg) /* throws DomError */ {
			// STUB
		}
		public void insertData(ulong offset, string arg) /* throws DomError */ {
			// STUB
		}
		public void deleteData(ulong offset, ulong count) /* throws DomError */ {
			// STUB
		}
		public void replaceData(ulong offset, ulong count, string arg) /* throws DomError */ {
			// STUB
		}
	}
}
