/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */

namespace GXml.Dom {
	public class CharacterData : BackedNode {
		public string data {
			get {
				return this.node_value;
			}
			internal set {
				// TODO: should this not be private?
				this.node_value = value;
			}
		}
		public ulong length {
			get {
				return data.length;
			}
			private set {
			}
		}
		
		internal CharacterData (Xml.Node *char_node, Document doc) {
			base (char_node, doc);
			// TODO: if this was this (), it would recurse infinitely, maybe valac could detect that
		}

		public string substring_data (ulong offset, ulong count) { // throws DomError
			// TODO: handle out of bounds
			return this.data.substring ((long)offset, (long)count);
		}

		public void append_data (string arg) /* throws DomError */ {
			this.data = this.data.concat (arg);
		}
		public void insert_data (ulong offset, string arg) /* throws DomError */ {
			// TODO: complain about boundaries
			this.data = this.data.substring (0, (long)offset).concat (arg, this.data.substring ((long)offset));

		}
		public void delete_data (ulong offset, ulong count) /* throws DomError */ {
			this.data = this.data.substring (0, (long)offset).concat (this.data.substring ((long)(offset + count)));
		}
		public void replace_data (ulong offset, ulong count, string arg) /* throws DomError */ {
			// TODO: bounds
			this.data = this.data.substring (0, (long)offset).concat (arg, this.data.substring ((long)(offset + count)));
		}
	}
}
