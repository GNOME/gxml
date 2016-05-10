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
#ifndef __GXML_H_XLIBXML__
#define __GXML_H_XLIBXML__

#include <libxml/tree.h>
#include <libxml/parser.h>
#include <libxml/xmlwriter.h>
#include <glib.h>

void*       gxml_doc_get_intsubset_entities    (xmlDoc *doc);
gint         gxml_validate_name                 (xmlChar* name, int space);
xmlErrorPtr gxml_parser_context_get_last_error (void* ctx);
xmlErrorPtr gxml_context_get_last_error        (void* ctx);
void        gxml_context_reset_last_error      (void* ctx);
xmlErrorPtr gxml_get_last_error                ();
void        gxml_reset_last_error              ();
xmlNsPtr*   gxml_doc_get_ns_list               (xmlDoc* doc, xmlNode* node);
xmlTextWriterPtr gxml_new_text_writer_doc      (xmlDoc** doc);
xmlTextWriterPtr gxml_new_text_writer_memory   (xmlBufferPtr buffer, gint compression);
gint         gxml_text_writer_write_cdata       (xmlTextWriter* tw, const xmlChar* text);
gint         gxml_text_writer_write_pi          (xmlTextWriter* tw, const xmlChar* target, const xmlChar* data);
void         gxml_copy_props                    (xmlNodePtr src, xmlNodePtr dst);

#endif
