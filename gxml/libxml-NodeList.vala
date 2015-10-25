/* NodeList.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2013-2015  Daniel Espinosa <esodan@gmail.com>
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

using Gee;

namespace GXml {
	/**
	 * DOM API. Interface to access a list of nodes.
   *
   * A live list used to store {@link GXml.xNode}s.
	 *
	 * Usually contains the children of a {@link GXml.xNode}, or
	 * the results of {@link GXml.xElement.get_elements_by_tag_name}.
	 * {@link GXml.NodeList} implements both the DOM Level 1 Core API for
	 * a NodeList, as well as the {@link GLib.List} API, to make
	 * it more accessible and familiar to GLib programmers.
	 * Implementing classes also implement {@link Gee.Iterable}, to make
	 * iteration in supporting languages (like Vala) nice and
	 * easy.
	 *
	 * Version: DOM Level 1 Core<<BR>>
	 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-536297177]]
	 */
	public interface NodeList : GLib.Object, Gee.Iterable<xNode>, Gee.Collection<xNode>
	{
		/* NOTE:
		 * children should define constructors like:
		 *     internal NodeList (Xml.Node* head, xDocument owner);
		 */

		/**
		 * The number of nodes contained within this list
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#attribute-length]]
		 */
		public abstract ulong length {
			get; protected set;
		}


		/* ** NodeList methods ** */

		/**
		 * Access the idx'th item in the list.
		 *
		 * Version: DOM Level 1 Core<<BR>>
		 * URL: [[http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#method-item]]
		 */
		public abstract xNode item (ulong idx);

		/* These exist to support management of a node's children */
		public abstract unowned xNode? insert_before (xNode new_child, xNode? ref_child);
		public abstract unowned xNode? replace_child (xNode new_child, xNode old_child);
		public abstract unowned xNode? remove_child (xNode old_child);
		public abstract unowned xNode? append_child (xNode new_child);

		/**
		 * Creates an XML string representation of the nodes in the list.
		 *
		 * #todo: write a test
		 *
		 * @param in_line Whether to parse and expand entities or not
		 *
		 * @return The list as an XML string
		 */
		/*
		 * @todo: write a test
		 */
		public abstract string to_string (bool in_line);

		/**
		 * Retrieve the first node in the list.  Like {@link GLib.List.first}.
		 */
		public abstract xNode first ();

		/**
		 * Retrieve the last node in the list.  Like {@link GLib.List.last}.
		 */
		public abstract xNode last ();
		/**
		 * Obtain the n'th item in the list. Like {@link GLib.List.nth}.
		 *
		 * @param n The index of the item to access
		 */
		public abstract new xNode @get (int n);
	}
}
