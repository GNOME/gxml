/* GXmlProcessingInstruction.vala
 *
 * Copyright (C) 2016  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;

/**
 * Class implemeting {@link GXml.ProcessingInstruction} interface, not tied to libxml-2.0 library.
 */
public class GXml.GProcessingInstruction : GXml.GNode,
              GXml.ProcessingInstruction, GXml.DomCharacterData,
              GXml.DomProcessingInstruction
{
  public GProcessingInstruction (GDocument doc, Xml.Node *node)
  {
    _node = node;
    _doc = doc;
  }
  // GXml.ProcessingInstruction
  public string GXml.ProcessingInstruction.target { owned get { return name; } }
  public string GXml.ProcessingInstruction.data { owned get { return base.value; } }
  // GXml.DomCharacterData
  public string GXml.DomCharacterData.data {
    get {
      return (this as GXml.ProcessingInstruction).value;
    }
    set {
      (this as GXml.ProcessingInstruction).value = value;
    }
  }
  // GXml.DomProcessingInstruction
  public string GXml.DomProcessingInstruction.target {
    owned get { return (this as GXml.ProcessingInstruction).name; }
  }
}
