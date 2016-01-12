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
 * 	Daniel Espinosa <esodan@gmail.com>
 */

#include<gxml/xlibxml.h>

void* gxml_doc_get_intsubset_entities (xmlDoc *doc)
{
  g_return_if_fail (doc != NULL);
  return doc->intSubset->entities;
}

int gxml_validate_name (xmlChar* name, int space)
{
  g_return_if_fail (name != NULL);
  return xmlValidateName (name, space);
}

xmlErrorPtr gxml_parser_context_get_last_error (void* ctx)
{
  return xmlCtxtGetLastError (ctx);
}

xmlErrorPtr gxml_get_last_error ()
{
  return xmlGetLastError ();
}

xmlNsPtr* gxml_doc_get_ns_list (xmlDoc* doc, xmlNode* node)
{
  g_return_if_fail (doc != NULL);
  g_return_if_fail (node != NULL);
  return xmlGetNsList (doc, node);
}

xmlTextWriterPtr gxml_new_text_writer_doc (xmlDoc** doc)
{
  g_return_if_fail (doc != NULL);
  return xmlNewTextWriterDoc (doc, 0);
}

xmlTextWriterPtr gxml_new_text_writer_memory (xmlBufferPtr buffer, gint compression)
{
  g_return_if_fail (buffer != NULL);
  return xmlNewTextWriterMemory (buffer, compression);
}

int gxml_text_writer_write_cdata (xmlTextWriterPtr tw, const xmlChar* text)
{
  g_return_if_fail (tw != NULL);
  g_return_if_fail (text != NULL);
  return xmlTextWriterWriteCDATA (tw, text);
}

int gxml_text_writer_write_pi (xmlTextWriterPtr tw, const xmlChar* target, const xmlChar* data)
{
  g_return_if_fail (tw != NULL);
  g_return_if_fail (target != NULL);
  g_return_if_fail (data != NULL);
  return xmlTextWriterWritePI (tw, target, data);
}
