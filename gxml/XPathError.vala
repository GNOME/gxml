/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* XPathError.vala
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
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */
namespace GXml.XPath {
	/* XPATH:TODO: can we do subnamespaces and have it work in C well?  I was told no when I started GXml */

	/**
	 * Describes various error states. For more, see
	 * [[http://www.w3.org/TR/2004/NOTE-DOM-Level-3-XPath-20040226/xpath.html#XPathException]]
	 */
	public errordomain Error {
		/**
		 * If the expression has a syntax error or otherwise is not a legal expression
		 * according to the rules of the specific XPathEvaluator or contains specialized
		 * extension functions or variables not supported by this implementation.
		 */
		INVALID_EXPRESSION,
		/**
		 * If the expression cannot be converted to return the specified type.
		 */
		TYPE
	}
}
