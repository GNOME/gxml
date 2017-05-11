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
/**
 * gxml_doc_get_intsubset_entities:
 *
 * Deprecated: 0.15
 */
void* gxml_doc_get_intsubset_entities (xmlDoc *doc)
{
  g_return_val_if_fail (doc != NULL, NULL);
  return doc->intSubset->entities;
}

/**
 * gxml_validate_name:
 *
 * Deprecated: 0.15
 */
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
  g_return_val_if_fail (ctx != NULL, NULL);
  return gxml_context_get_last_error (ctx);
}

/**
 * gxml_context_get_last_error:
 *
 * Deprecated: 0.15
 */
xmlErrorPtr gxml_context_get_last_error (void* ctx)
{
  g_return_val_if_fail (ctx != NULL, NULL);
  return xmlCtxtGetLastError (ctx);
}

/**
 * gxml_context_reset_last_error:
 *
 * Deprecated: 0.15
 */
void gxml_context_reset_last_error (void* ctx)
{
  xmlCtxtResetLastError (ctx);
}

/**
 * gxml_get_last_error:
 *
 * Deprecated: 0.15
 */
xmlErrorPtr gxml_get_last_error ()
{
  return xmlGetLastError ();
}

/**
 * gxml_reset_last_error:
 *
 * Deprecated: 0.15
 */
void gxml_reset_last_error ()
{
  xmlResetLastError ();
}

/**
 * gxml_doc_get_ns_list:
 *
 * Deprecated: 0.15
 */
xmlNsPtr* gxml_doc_get_ns_list (xmlDoc* doc, xmlNode* node)
{
  g_return_val_if_fail (doc != NULL, NULL);
  g_return_val_if_fail (node != NULL, NULL);
  return xmlGetNsList (doc, node);
}

/**
 * gxml_new_text_writer_doc:
 *
 * Deprecated: 0.15
 */
xmlTextWriterPtr gxml_new_text_writer_doc (xmlDoc** doc)
{
  g_return_val_if_fail (doc != NULL, NULL);
  return xmlNewTextWriterDoc (doc, 0);
}

/**
 * gxml_new_text_writer_memory:
 *
 * Deprecated: 0.15
 */
xmlTextWriterPtr gxml_new_text_writer_memory (xmlBufferPtr buffer, gint compression)
{
  g_return_val_if_fail (buffer != NULL, NULL);
  return xmlNewTextWriterMemory (buffer, compression);
}

/**
 * gxml_text_writer_write_cdata:
 *
 * Deprecated: 0.15
 */
gint gxml_text_writer_write_cdata (xmlTextWriterPtr tw, const xmlChar* text)
{
  g_return_val_if_fail (tw != NULL, -1);
  g_return_val_if_fail (text != NULL, -1);
  return xmlTextWriterWriteCDATA (tw, text);
}

/**
 * gxml_text_writer_write_pi:
 *
 * Deprecated: 0.15
 */
gint gxml_text_writer_write_pi (xmlTextWriterPtr tw, const xmlChar* target, const xmlChar* data)
{
  g_return_val_if_fail (tw != NULL, -1);
  g_return_val_if_fail (target != NULL, -1);
  g_return_val_if_fail (data != NULL, -1);
  return xmlTextWriterWritePI (tw, target, data);
}


/**
 * gxml_copy_props:
 *
 * Deprecated: 0.15
 */
void gxml_copy_props (xmlNodePtr src, xmlNodePtr dst)
{
	g_return_if_fail (src != NULL);
	g_return_if_fail (dst != NULL);
	xmlCopyProp (dst, src->properties);
}
