/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* GXmlTest.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2011-2019  Daniel Espinosa <esodan@gmail.com>
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
using GXml;

class GXmlTest {
	public static int main (string[] args) {


		// Sets 29 as fatal flags, 16 + 8 + 4 + 1; bits 0,2,3,4, recursion,error,critical,warning; we'll want to undo that warning one so we can catch it
		Test.init (ref args);
		ElementTest.add_tests ();
		SerializationTest.add_tests ();
		GomSchemaTest.add_tests ();
		CssSelectorTest.add_tests ();

		Test.run ();

		return 0;
	}
}
