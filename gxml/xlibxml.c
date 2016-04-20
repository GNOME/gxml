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

gint gxml_validate_name (xmlChar* name, int space)
{
  g_return_val_if_fail (name != NULL, -1);
  return xmlValidateName (name, space);
}

/**
 * gxml_parser_context_get_last_error:
 *
 * Deprecated: Since 0.8.1
 */
xmlErrorPtr gxml_parser_context_get_last_error (void* ctx)
{
  return gxml_context_get_last_error (ctx);
}

xmlErrorPtr gxml_context_get_last_error (void* ctx)
{
  return xmlCtxtGetLastError (ctx);
}

void gxml_context_reset_last_error (void* ctx)
{
  xmlCtxtResetLastError (ctx);
}

xmlErrorPtr gxml_get_last_error ()
{
  return xmlGetLastError ();
}

void gxml_reset_last_error ()
{
  xmlResetLastError ();
}

xmlNsPtr* gxml_doc_get_ns_list (xmlDoc* doc, xmlNode* node)
{
  g_return_val_if_fail (doc != NULL, NULL);
  g_return_val_if_fail (node != NULL, NULL);
  return xmlGetNsList (doc, node);
}

xmlTextWriterPtr gxml_new_text_writer_doc (xmlDoc** doc)
{
  g_return_val_if_fail (doc != NULL, NULL);
  return xmlNewTextWriterDoc (doc, 0);
}

xmlTextWriterPtr gxml_new_text_writer_memory (xmlBufferPtr buffer, gint compression)
{
  g_return_val_if_fail (buffer != NULL, NULL);
  return xmlNewTextWriterMemory (buffer, compression);
}

gint gxml_text_writer_write_cdata (xmlTextWriterPtr tw, const xmlChar* text)
{
  g_return_val_if_fail (tw != NULL, -1);
  g_return_val_if_fail (text != NULL, -1);
  return xmlTextWriterWriteCDATA (tw, text);
}

gint gxml_text_writer_write_pi (xmlTextWriterPtr tw, const xmlChar* target, const xmlChar* data)
{
  g_return_val_if_fail (tw != NULL, -1);
  g_return_val_if_fail (target != NULL, -1);
  g_return_val_if_fail (data != NULL, -1);
  return xmlTextWriterWritePI (tw, target, data);
}

