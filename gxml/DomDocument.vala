/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/*
 *
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
 *      Daniel Espinosa <esodan@gmail.com>
 */

public interface GXml.DomDocument : GLib.Object, GXml.DomNode, GXml.DomParentNode, GXml.DomNonElementParentNode {
  public abstract DomImplementation implementation { get; }
  public abstract string url { get; }
  public abstract string document_uri { get; }
  public abstract string origin { get; }
  public abstract string compat_mode { get; }
  public abstract string character_set { get; }
  public abstract string content_type { get; }

  public abstract DomDocumentType? doctype { get; }
  public abstract DomElement? document_element { get; }

  public abstract DomHTMLCollection get_elements_by_tag_name (string local_name);
  public abstract DomHTMLCollection get_elements_by_tag_name_ns (string? namespace, string local_name);
  public abstract DomHTMLCollection get_elements_by_class_name(string classNames);

  public abstract DomElement create_element    (string localName);
  public abstract DomElement create_element_ns (string? namespace, string qualified_name);
  public abstract DomDocumentFragment create_document_fragment();
  public abstract DomText create_text_node (string data);
  public abstract DomComment create_comment (string data);
  public abstract DomProcessingInstruction create_processing_instruction (string target, string data);

  public abstract DomNode import_node (DomNode node, bool deep = false);
  public abstract DomNode adopt_node (DomNode node);

  public abstract DomEvent create_event (string interface);

  public abstract DomRange create_range();

  // NodeFilter.SHOW_ALL = 0xFFFFFFFF
  public abstract DomNodeIterator create_node_iterator (DomNode root, ulong whatToShow = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null);
  public abstract DomTreeWalker create_tree_walker (DomNode root, ulong what_to_show = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null);
}

public interface GXml.DomXMLDocument : GLib.Object, GXml.DomDocument {}

public interface GXml.DomImplementation : GLib.Object {
  public abstract DomDocumentType create_document_type (string qualified_name, string public_id, string system_id);
  public abstract DomXMLDocument create_document (string? namespace, string? qualified_name, DocumentType? doctype = null);
  public abstract Document create_html_document (string title);

  public virtual bool has_feature() { return true; } // useless; always returns true
}

public interface GXml.DomDocumentFragment : GLib.Object, GXml.DomNode, GXml.DomParentNode, GXml.DomNonElementParentNode {}

public interface GXml.DomDocumentType : GLib.Object, GXml.DomNode, GXml.DomChildNode {
  public abstract string name { get; }
  public abstract string public_id { get; }
  public abstract string system_id { get; }
}


