/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Node.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011,2014-2015  Daniel Espinosa <esodan@gmail.com>
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
 */

using GXml;
using Gee;

namespace GXml {
	/**
	 * A collection of elements with a named objects.
	 */
	public interface NamedNodeMap<T> : GLib.Object {
		// TODO: consider adding lookup, remove, etc from GLib.HashTable as convenience API
		// TODO: figure out how to let people do attributes["pie"] for attributes.get_named_item ("pie"); GLib HashTables can do it

		public abstract T get_named_item (string name);
		public abstract T set_named_item (T item);
		public abstract T remove_named_item (string name);
		public abstract T item (ulong index);
		public abstract ulong length { get; }
	}
}
