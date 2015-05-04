/**
 * Copyright 2015, Daniel Espinosa <esodan@gmail.com>
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
 * Author:
 * Daniel Espinosa <esodan@gmail.com>
 */

/**
 * Utility functions not present in libxml-2.0 bindings to be used internaly.
 *
 * Don't use this namespace's functions in your code. Instead, use GXml's public API.
 */
[CCode (cheader_filename = "gxml/xlibxml.h")]
namespace Xmlx {
  [CCode (cname = "gxml_doc_get_intsubset_entities", cheader_filename = "gxml/xlibxml.h")]
  public static Xml.HashTable doc_get_dtd_entities (Xml.Doc *doc);
  [CCode (cname = "gxml_validate_name", cheader_filename = "gxml//xlibxml.h")]
  public static int validate_name (string name, int space);
  [CCode (cname = "gxml_parser_context_get_last_error", cheader_filename = "gxml/xlibxml.h")]
  public static Xml.Error* parser_context_get_last_error (Xml.ParserCtxt ctx);
  [CCode (cname = "gxml_get_last_error", cheader_filename = "gxml/xlibxml.h")]
  public static Xml.Error* get_last_error ();
  [CCode (cname = "gxml_doc_get_ns_list", array_null_terminated = true, cheader_filename = "gxml/xlibxml.h")]
  public static Xml.Ns*[] doc_get_ns_list (Xml.Doc* doc, Xml.Node* node);
}
