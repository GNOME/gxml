/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
namespace GXml {
	/**
	 * Represents an XML Namespace Attr node. These represent
	 * prefix=uri pairs that define namespaces for XML Elements
	 * and Attrs.
	 */
	public class NamespaceAttr : XNode {
		/** Private properties */
		private Xml.Ns *node;

		/** Constructors */
		internal NamespaceAttr (Xml.Ns *node, Document doc) {
			// TODO: wish valac would warn against using this. before calling base()
			base (NodeType.ATTRIBUTE, doc); // TODO: want something other than ATTRIBUTE?
			this.node = node;
		}

		/* Public properties (Node general) */


		/**
		 * The prefix that this xmlns attribute defines. So,
		 * if the element was like {{{<Fish xmlns:foods="http://fishies.org/foods" />}}}, the
		 * defined prefix would be foods.
		 */
		public string defined_prefix {
			get {
				return this.node_name;
			}
			internal set {
			}
		}

		/**
		 * The namespace uri that this xmlns attribute defines. So,
		 * if the element was like {{{<Fish xmlns:foods="http://fishies.org/foods" />}}}, the
		 * defined namespace uri would be [[http://fishies.org/foods/]].
		 */
		public string defined_namespace_uri {
			get {
				return this.node_value;
			}
			internal set {
			}
		}


		/**
		 * {@inheritDoc}
		 */
		public override string? namespace_uri {
			get {
				return null; // TODO: figure out the uri for 'xmlns'
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? prefix {
			get {
				return "xmlns";
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? local_name {
			get {
				return this.node_name;
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string node_name {
			get {
				return this.node->prefix;
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? node_value {
			get {
				return this.node->href;
			}
			internal set {
			}
		}
	}
}
