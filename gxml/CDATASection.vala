/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* CDataSection.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011  Daniel Espinosa <esodan@gmail.com>
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
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

namespace GXml {
	/* TODO: do we really want a cdata section node, or just use strings? */
	/* TODO: check about casing in #vala */
	/**
	 * An XML CDATA section, which contains non-XML data that is
	 * stored in an XML document.
	 *
	 * To create one, use {@link GXml.Document.create_cdata_section}.
	 *
	 * An XML example would be like:
	 * {{{ <![CDATA[Here contains non-XML data, like code, or something that
	 * requires a lot of special XML entities.]]>. }}}
	 * It is a type of Text node. For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-667469212]]
	 */
	public class CDATASection : Text {
		internal CDATASection (Xml.Node *cdata_node, Document doc) {
			base (cdata_node, doc);
		}
		/**
		 * {@inheritDoc}
		 */
		public override string node_name {
			get {
				return "#cdata-section";
			}
			private set {
			}
		}
	}
}
