/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
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

/**
 * Base interface for all DOM4 implementations
 */
public interface GXml.DomNode : GLib.Object, GXml.DomEventTarget {
	public enum NodeType {
		INVALID = 0,
		ELEMENT_NODE = 1,
		ATTRIBUTE_NODE, // historical
		TEXT_NODE,
		CDATA_SECTION_NODE, // historical
		ENTITY_REFERENCE_NODE, // historical
		ENTITY_NODE, // historical
		PROCESSING_INSTRUCTION_NODE,
		COMMENT_NODE,
		DOCUMENT_NODE,
		DOCUMENT_TYPE_NODE,
		DOCUMENT_FRAGMENT_NODE,
		NOTATION_NODE // historical
	}
  public abstract NodeType node_type { get; }
  public abstract string node_name { owned get; }

  public abstract string? base_uri { get; }

  public abstract DomDocument? owner_document { get; construct set; }
  public abstract DomNode? parent_node { owned get; }
  public abstract DomElement? parent_element { owned get; }
  public abstract DomNodeList child_nodes { owned get; }
  public abstract DomNode? first_child { owned get; }
  public abstract DomNode? last_child { owned get; }
  public abstract DomNode? previous_sibling { owned get; }
  public abstract DomNode? next_sibling { owned get; }

	public abstract string? node_value { owned get; set; }
	public abstract string? text_content { owned get; set; }

  public abstract bool has_child_nodes ();
  public abstract void normalize ();

  public abstract bool is_equal_node (DomNode? node);

  [Flags]
  public enum DocumentPosition {
    NONE,
    DISCONNECTED,
    PRECEDING,
    FOLLOWING,
    CONTAINS,
    CONTAINED_BY,
    IMPLEMENTATION_SPECIFIC
  }
  public abstract DocumentPosition compare_document_position (DomNode other);
  public abstract bool contains (DomNode? other);

  public abstract string? lookup_prefix (string? nspace);
  public abstract string? lookup_namespace_uri (string? prefix);
  public abstract bool is_default_namespace (string? nspace);

  public abstract DomNode insert_before (DomNode node, DomNode? child) throws GLib.Error;
  public abstract DomNode append_child (DomNode node) throws GLib.Error;
  public abstract DomNode replace_child (DomNode node, DomNode child) throws GLib.Error;
  public abstract DomNode remove_child (DomNode child) throws GLib.Error;
  /**
   * Copy a {@link GXml.DomNode} relaying on {@link GXml.DomDocument} to other {@link GXml.DomNode}.
   *
   * {@link node} could belongs from different {@link GXml.DomDocument}, while source is a node
   * belonging to given document.
   *
   * Only {@link GXml.DomElement} objects are supported. For attributes, use
   * {@link GXml.DomElement.set_attribute} method, passing source's name and value as arguments.
   *
   * @param doc a {@link GXml.DomDocument} owning destiny node
   * @param node a {@link GXml.DomElement} to copy nodes to
   * @param source a {@link GXml.DomElement} to copy nodes from, it could be holded by different {@link GXml.DomDocument}
   */
  public static bool copy (GXml.DomDocument doc,
                          GXml.DomNode node,
                          GXml.DomNode source,
                          bool deep) throws GLib.Error
  {
#if DEBUG
    GLib.message ("Copying GXml.Node");
#endif
    if (node is GXml.DomDocument) return false;
    if (source is GXml.DomElement && node is GXml.DomElement) {
#if DEBUG
      GLib.message ("Copying source and destiny nodes are GXml.Elements... copying...");
      GLib.message ("Copying source's attributes to destiny node");
#endif
      foreach (GXml.DomNode p in ((DomElement) source).attributes.values) {
        ((GXml.DomElement) node).set_attribute (p.node_name, p.node_value); // TODO: Namespace
      }
      if (!deep) return true;
#if DEBUG
      GLib.message ("Copying source's child nodes to destiny node");
#endif
      foreach (DomNode c in source.child_nodes) {
        if (c is DomElement) {
          if (c.node_name == null) continue;
#if DEBUG
            GLib.message (@"Copying child Element node: $(c.node_name)");
#endif
          try {
            var e = doc.create_element (c.node_name); // TODO: Namespace
            node.child_nodes.add (e);
            copy (doc, e, c, deep);
          } catch {}
        }
        if (c is DomText) {
          if (((DomText) c).data == null) {
            GLib.warning (_("Text node with NULL string"));
            continue;
          }
          try {
            var t = doc.create_text_node (((DomText) c).data);
            node.child_nodes.add (t);
          } catch (GLib.Error e) {
            GLib.warning (_("Can't copy child text node"));
          }
#if DEBUG
          GLib.message (@"Copying source's Text node '$(source.node_name)' to destiny node with text: $(c.node_value) : Size= $(node.child_nodes.size)");
          GLib.message (@"Added Text: $(node.child_nodes.get (node.child_nodes.size - 1).node_value)");
#endif
        }
      }
    }
    return false;
  }
}
/**
 * DOM4 error codes.
 */
public errordomain GXml.DomError {
	INDEX_SIZE_ERROR = 1,
	DOMSTRING_SIZE_ERROR,//
	HIERARCHY_REQUEST_ERROR,//
	WRONG_DOCUMENT_ERROR,//
	INVALID_CHARACTER_ERROR,//
	NO_DATA_ALLOWED_ERROR,//
	NO_MODIFICATION_ALLOWED_ERROR,//
	NOT_FOUND_ERROR,//
	NOT_SUPPORTED_ERROR,//
	INUSE_ATTRIBUTE_ERROR,//
	// Introduced in DOM Level 2:
	INVALID_STATE_ERROR,//
	// Introduced in DOM Level 2:
	SYNTAX_ERROR,//
	// Introduced in DOM Level 2:
	INVALID_MODIFICATION_ERROR,//
	// Introduced in DOM Level 2:
	NAMESPACE_ERROR,//
	// Introduced in DOM Level 2:
	INVALID_ACCESS_ERROR,// 15
	VALIDATION_ERROR,//
	TYPE_MISMATCH_ERROR,// 17
	SECURITY_ERROR,// 18
	NETWORK_ERROR, //19
	ABORT_ERROR,//20
	URL_MISMATCH_ERROR,//21
	QUOTA_EXCEEDED_ERROR,//22
	TIME_OUT_ERROR,//23
	INVALID_NODE_TYPE_ERROR,//24
	DATA_CLONE_ERROR//25
}

public class GXml.DomErrorName : GLib.Object {
	private Gee.HashMap<string,int> names = new Gee.HashMap <string,int> ();
	construct {
		names.set ("IndexSizeError", 1);
		names.set ("HierarchyRequestError", 3);
		names.set ("WrongDocumentError", 4);
		names.set ("InvalidCharacterError", 5);
		names.set ("NoModificationAllowedError", 7);
		names.set ("NotFoundError", 8);
		names.set ("NotSupportedError", 9);
		names.set ("InvalidStateError", 11);
		names.set ("SyntaxError", 12);
		names.set ("InvalidModificationError", 13);
		names.set ("NamespaceError", 14);
		names.set ("InvalidAccessError", 15);
		names.set ("SecurityError", 18);
		names.set ("NetworkError", 19);
		names.set ("AbortError", 20);
		names.set ("URLMismatchError", 21);
		names.set ("QuotaExceededError", 22);
		names.set ("TimeoutError", 23);
		names.set ("InvalidNodeTypeError", 24);
		names.set ("DataCloneError", 25);
		names.set ("EncodingError", -1);
		names.set ("NotReadableError", -2);
	}
	public string get_name (int error_code) {
		foreach (string k in names.keys) {
			if (names.get (k) == error_code) return k;
		}
		return "";
	}
	public int get_code (string error_name) {
		if (!names.has_key (error_name)) return 0;
		return names.get (error_name);
	}
}



