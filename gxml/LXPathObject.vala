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

/**
 * An {@link GXml.XPathObject} implementation using
 * libxml2 engine.
 */
public class GXml.LXPathObject : GLib.Object, GXml.XPathObject {
  private GXml.HTMLCollection _collection;
  private GXml.XPathObjectType _object_type;
  private Xml.XPath.Object* _pointer = null;
  private bool _boolean_value;
  private string _string_value;
  private double _number_value;

  public LXPathObject (GXml.XDocument document, Xml.XPath.Object* pointer) {
    _collection = new GXml.HTMLCollection();
    _pointer = pointer;

    _object_type = (GXml.XPathObjectType) _pointer->type;

    if (_object_type == GXml.XPathObjectType.NODESET) {
      for (var i = 0; i < _pointer->nodesetval->length(); i++) {
        _collection.add (new GXml.XElement (document, _pointer->nodesetval->item (i)));
      }
    } else if (_object_type == GXml.XPathObjectType.BOOLEAN) {
      _boolean_value = _pointer->boolval == 1;
    } else if (_object_type == GXml.XPathObjectType.STRING) {
      _string_value = _pointer->stringval;
    } else if (object_type == GXml.XPathObjectType.NUMBER) {
      _number_value = _pointer->floatval;
    }
  }
  
  ~ LXPathObject () {
    if (_pointer != null) {
      delete _pointer;
      _pointer = null;
    }
  }

  public GXml.XPathObjectType object_type { get { return _object_type; } }

  public bool boolean_value { get { return _boolean_value; } }

  public string string_value { get { return _string_value; } }

  public double number_value { get { return _number_value; } }

  public GXml.DomHTMLCollection nodeset { get { return _collection; } }
}
