/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* NamespaceAttr.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011,2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

namespace GXml {
	/**
	 * Represents an XML Namespace for a {@link GXml.Node} node.
	 *
	 * These represent
	 * prefix=uri pairs that define namespaces for XML {@link GXml.xElement}
	 * and {@link GXml.xAttr}.
	 */
	public class NamespaceAttr : xNode, GXml.Namespace {
		/** Private properties */
		private Xml.Ns *ns; // XPATH:TODO: do they extend us?

		/** Constructors */
		internal NamespaceAttr (Xml.Ns *ns, xDocument doc) {
			// TODO: wish valac would warn against using this. before calling base()
			base (NodeType.ATTRIBUTE, doc); // TODO: want something other than ATTRIBUTE?
			this.ns = ns;
		}

		/* Public properties (Node general) */


		/**
		 * The prefix that this xmlns attribute defines. So,
		 * if the element was like {{{&lt;Fish xmlns:foods="http://fishies.org/foods" />}}}, the
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
		 * if the element was like {{{&lt;Fish xmlns:foods="http://fishies.org/foods" />}}}, the
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
		public override string? namespace_prefix {
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
				return this.ns->prefix;
			}
			internal set {
			}
		}
		/**
		 * {@inheritDoc}
		 */
		public override string? node_value {
			get {
				return this.ns->href;
			}
			internal set {
			}
		}
		// GXml.Namespace interface implementations
		public string uri {
			get {
				return defined_namespace_uri;
			}
		}
		public string prefix {
			get {
				return defined_prefix;
			}
		}
	}
}
