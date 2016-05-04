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

public interface GXml.DomNode : GLib.Object, GXml.DomEventTarget {
  public const ushort ELEMENT_NODE = 1;
  public const ushort ATTRIBUTE_NODE = 2; // historical
  public const ushort TEXT_NODE = 3;
  public const ushort CDATA_SECTION_NODE = 4; // historical
  public const ushort ENTITY_REFERENCE_NODE = 5; // historical
  public const ushort ENTITY_NODE = 6; // historical
  public const ushort PROCESSING_INSTRUCTION_NODE = 7;
  public const ushort COMMENT_NODE = 8;
  public const ushort DOCUMENT_NODE = 9;
  public const ushort DOCUMENT_TYPE_NODE = 10;
  public const ushort DOCUMENT_FRAGMENT_NODE = 11;
  public const ushort NOTATION_NODE = 12; // historical
  public abstract ushort node_type { get; }
  public abstract string node_name { get; }

  public abstract string? baseURI { get; }

  public abstract Document? owner_document { get; }
  public abstract DomNode? parent_node { get; }
  public abstract DomElement? parent_element { get; }
  public abstract DomNodeList child_nodes { get; }
  public abstract DomNode? first_child { get; }
  public abstract DomNode? last_child { get; }
  public abstract DomNode? previous_sibling { get; }
  public abstract DomNode? next_sibling { get; }

	public abstract string? node_value { get; set; }
	public abstract string? text_content { get; set; }

  public abstract bool has_child_nodes ();
  public abstract void normalize ();

  public abstract DomNode clone_node (bool deep = false);
  public abstract bool is_equal_node (DomNode? node);

  public const ushort DOCUMENT_POSITION_DISCONNECTED = 0x01;
  public const ushort DOCUMENT_POSITION_PRECEDING = 0x02;
  public const ushort DOCUMENT_POSITION_FOLLOWING = 0x04;
  public const ushort DOCUMENT_POSITION_CONTAINS = 0x08;
  public const ushort DOCUMENT_POSITION_CONTAINED_BY = 0x10;
  public const ushort DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 0x20;
  public abstract ushort compare_document_position (DomNode other);
  public abstract bool contains (DomNode? other);

  public abstract string? lookup_prefix(string? namespace);
  public abstract string? lookup_namespace_uri (string? prefix);
  public abstract bool is_default_namespace(string? namespace);

  public abstract DomNode insert_before (DomNode node, DomNode? child);
  public abstract DomNode append_child (DomNode node);
  public abstract DomNode replace_child (DomNode node, DomNode child);
  public abstract DomNode remove_child(DomNode child);
}

public errordomain GXml.DomError {
	INDEX_SIZE_ERROR,
	HIERARCHY_REQUEST_ERROR,
	WRONG_DOCUMENT_ERROR,
	INVALID_CHARACTER_ERROR,
	NO_MODIFICATION_ALLOWED_ERROR,
	NOT_FOUND_ERROR,
	NOT_SUPPORTED_ERROR,
	INVALID_STATE_ERROR,
	SYNTAX_ERROR,
	INVALID_MODIFICATION_ERROR,
	NAMESPACE_ERROR,
	INVALID_ACCESS_ERROR,
	SECURITY_ERROR,
	NETWORK_ERROR,
	ABORT_ERROR,
	URL_MISMATCH_ERROR,
	QUOTA_EXCEEDED_ERROR,
	TIMEOUT_ERROR,
	INVALID_NODE_TYPE_ERROR,
	DATA_CLONE_ERROR,
	ENCODING_ERROR,
	NOT_READABLE_ERROR
}

public class GXml.DomErrorName : GLib.Object {
	private string[] names = new string [30];
	construct {
		names += "IndexSizeError";
		names += "HierarchyRequestError";
		names += "WrongDocumentError";
		names += "InvalidCharacterError";
		names += "NoModificationAllowedError";
		names += "NotFoundError";
		names += "NotSupportedError";
		names += "InvalidStateError";
		names += "SyntaxError";
		names += "InvalidModificationError";
		names += "NamespaceError";
		names += "InvalidAccessError";
		names += "SecurityError";
		names += "NetworkError";
		names += "AbortError";
		names += "URLMismatchError";
		names += "QuotaExceededError";
		names += "TimeoutError";
		names += "InvalidNodeTypeError";
		names += "DataCloneError";
		names += "EncodingError";
		names += "NotReadableError";
	}
	public string get_name (int error_code) {
		return names[error_code];
	}
}



