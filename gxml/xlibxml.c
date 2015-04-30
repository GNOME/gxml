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
  return doc->intSubset->entities;
}

int gxml_validate_name (xmlChar* name, int space)
{
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
