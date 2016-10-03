/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
 * Copyright (C) 2016  Yannick Inizan <inizan.yannick@gmail.com>
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
 *      Daniel Espinosa <esodan@gmail.com>
 *      Yannick Inizan <inizan.yannick@gmail.com>
 */

using GXml;

class GElementXPathTest : GXmlTest  {
  public static void add_tests () {
    Test.add_func ("/gxml/gelement/xpath", () => {
      var document = new GDocument.from_uri ("http://www.w3schools.com/xsl/books.xml");
      var object = document.evaluate ("/bookstore/book/title");
      assert (object.object_type == XPathObjectType.NODESET);
      var array = object.nodeset.to_array();
      assert (array.length == 4);
      assert (array[0].node_value == "Everyday Italian");
      assert (array[1].node_value == "Harry Potter");
      assert (array[2].node_value == "XQuery Kick Start");
      assert (array[3].node_value == "Learning XML");
      object = document.evaluate ("/bookstore/book[1]/title");
      assert (object.object_type == XPathObjectType.NODESET);
      array = object.nodeset.to_array();
      assert (array.length == 1);
      assert (array[0].node_value == "Everyday Italian");
      object = document.evaluate ("/bookstore/book/price[text()]");
      assert (object.object_type == XPathObjectType.NODESET);
      array = object.nodeset.to_array();
      assert (array.length == 4);
      assert (array[0].node_value == "30.00");
      assert (array[1].node_value == "29.99");
      assert (array[2].node_value == "49.99");
      assert (array[3].node_value == "39.95");
      object = document.evaluate ("/bookstore/book[price>35]/price");
      assert (object.object_type == XPathObjectType.NODESET);
      array = object.nodeset.to_array();
      assert (array.length == 2);
      assert (array[0].node_value == "49.99");
      assert (array[1].node_value == "39.95");
		});
	}
}
