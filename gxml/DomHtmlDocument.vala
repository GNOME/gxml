/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Html.vala
 *
 * Copyright (C) 2017  Daniel Espinosa <esodan@gmail.com>
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
 *      Yannick Inizan <inizan.yannick@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */

/**
 * Interface for HTML handling implementation
 */
public interface GXml.DomHtmlDocument : GLib.Object, GXml.DomDocument {
	/**
	 * This method reads HTML documents using default parser
	 */
	public abstract void read_from_string (string str) throws GLib.Error;
	/**
	 * This method reads HTML documents using default a very tolerant parser
	 */
	public abstract void read_from_string_tolerant (string str) throws GLib.Error;
	/**
	 * This method dump to HTML string.
	 */
	public abstract string to_html () throws GLib.Error;
}
