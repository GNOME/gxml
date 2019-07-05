/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2016  Yannick Inizan <inizan.yannick@gmail.com>
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
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
 *     Yannick Inizan <inizan.yannick@gmail.com>
 *     Daniel Espinosa <esodan@gmail.com>
 */

public class GXml.LXPathObject : GLib.Object, GXml.XPathObject {
  private GXml.HTMLCollection _collection;
  private GXml.XPathObjectType _object_type;
  private bool _boolean_value;
  private string _string_value;
  private double _number_value;

  public LXPathObject (GXml.XDocument document, Xml.XPath.Object* pointer) {
    _collection = new GXml.HTMLCollection();

    _object_type = (GXml.XPathObjectType) pointer->type;

    if (_object_type == GXml.XPathObjectType.NODESET)
      for (var i = 0; i < pointer->nodesetval->length(); i++)
        _collection.add (new GXml.XElement (document, pointer->nodesetval->item (i)));
    else if (_object_type == GXml.XPathObjectType.BOOLEAN)
      _boolean_value = pointer->boolval == 1;
    else if (_object_type == GXml.XPathObjectType.STRING)
      _string_value = pointer->stringval;
    else if (object_type == GXml.XPathObjectType.NUMBER)
      _number_value = pointer->floatval;
  }

  public GXml.XPathObjectType object_type { get { return _object_type; } }

  public bool boolean_value { get { return _boolean_value; } }

  public string string_value { get { return _string_value; } }

  public double number_value { get { return _number_value; } }

  public GXml.DomHTMLCollection nodeset { get { return _collection; } }
}
