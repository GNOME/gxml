/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* NodeType.vala
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

// TODO: want a method to convert NodeType to a string

/**
 * DOM1 Enumerates possible NodeTypes.
 *
 * For more, see: [[http://www.w3.org/TR/DOM-Level-1/level-one-core.html#ID-1950641247]]
 */
public enum GXml.NodeType {
	INVALID = 0,
	ELEMENT = 1,
	ATTRIBUTE,
	TEXT,
	CDATA_SECTION,
	ENTITY_REFERENCE,
	ENTITY,
	PROCESSING_INSTRUCTION,
	COMMENT,
	DOCUMENT,
	DOCUMENT_TYPE,
	DOCUMENT_FRAGMENT,
	NOTATION;
}
