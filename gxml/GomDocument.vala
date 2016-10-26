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

using GXml;

public class GXml.GomDocument : GomNode,
                              DomParentNode,
                              DomNonElementParentNode
{
  protected
  // DomDocument implementation
  protected DomImplementation _implementation = new GomImplementation ();
  protected string _url = "about:blank";
  protected string _origin = "";
  protected string _compat_mode = "";
  protected string _character_set = "utf-8";
  protected string _content_type = "application/xml";
  public DomImplementation implementation { get { return _implementation; } }
  public string url { get { return _url; } }
  public string document_uri { get { return _url; } }
  public string origin { get { return _origin; } }
  public string compat_mode { get { return _compat_mode; } }
  public string character_set { get { return _character_set; } }
  public string content_type { get { return _content_type; } }

  public DomDocumentType? doctype {
    owned get {
      foreach (DomNode n in child_nodes) {
        if (n is DomDocumentType) return (DomDocumentType) n;
      }
      return null;
    }
  }
  public DomElement? document_element {
    owned get {
      if (child_nodes.size == 0) return null;
      child_nodes[0];
    }
  }

  public DomElement GXml.DomDocument.create_element (string local_name) throws GLib.Error {
      var e = new GomElement ();
      e._document = this;
      e._local_name = local_name;
  }
  public DomElement GXml.DomDocument.create_element_ns (string? ns, string qualified_name) throws GLib.Error
  {
    string n = "";
    string nsp = "";
    if (":" in qualified_name) {
      var s = qualified_name.split (":");
      if (s.length != 2)
        throw new DomError.NOT_SUPPORTED_ERROR (_("Invalid node name"));
      nsp = s[0];
      n = s[1];
    } else
      n = qualified_name;
    if (nsp == "" && ns == null)
      throw new DomError.NAMESPACE_ERROR (_("Invalid namespace"));
      // TODO: check for xmlns https://www.w3.org/TR/dom/#dom-document-createelementns
    var e = create_element (n);
    e._namespaces.set (ns, nsp);
    e._prefix = nsp;
    e._namespace_uri = ns;
  }

  public DomHTMLCollection get_elements_by_tag_name (string local_name) {
      var l = new GDomHTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_tag_name (local_name));
      return l;
  }
  public DomHTMLCollection get_elements_by_tag_name_ns (string? ns, string local_name) {
      var l = new GDomHTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_tag_name_ns (ns, local_name));
      return l;
  }
  public DomHTMLCollection get_elements_by_class_name(string class_names) {
      var l = new GDomHTMLCollection ();
      if (document_element == null) return l;
      l.add_all (document_element.get_elements_by_class_name (class_names));
      return l;
  }

  public DomDocumentFragment create_document_fragment() {
    return new GDocumentFragment (this);
  }
  public DomText create_text_node (string data) throws GLib.Error {
    var t = new GomText ();
    t._document = this;
    t.data = data;
  }
  public DomComment GXml.DomDocument.create_comment (string data) throws GLib.Error {
    var t = new GomComment ();
    t._document = this;
    t.data = data;
  }
  public DomProcessingInstruction create_processing_instruction (string target, string data) throws GLib.Error {
    var pi = new GomProcessingInstruction ();
    pi._document = this;
    pi.data = data;
    pi._target = target;
  }

  public DomNode import_node (DomNode node, bool deep = false) throws GLib.Error {
      if (node is DomDocument)
        throw new GXml.DomError.NOT_SUPPORTED_ERROR (_("Can't import a Document"));
      if (!(node is DomElement) && this.document_element == null)
        throw new GXml.DomError.HIERARCHY_REQUEST_ERROR (_("Can't import a non Element type node to a Document"));
      GXml.DomNode dst = null;
      if (node is DomElement) {
        dst = (this as DomDocument).create_element (node.node_name);
        GXml.DomNode.copy (this, dst, node, deep);
        if (document_element == null) {
          this.append_child (dst);
          return dst;
        }
      }
      if (node is DomText)
        dst = this.create_text_node ((node as DomText).data);
      if (node is DomComment)
        dst = (this as DomDocument).create_comment ((node as DomComment).data);
      if (node is DomProcessingInstruction)
        dst = this.create_processing_instruction ((node as DomProcessingInstruction).target, (node as DomProcessingInstruction).data);
      if (dst != null) {
        document_element.append_child (dst as DomNode);
        return dst;
      }
      return node;
  }
  public DomNode adopt_node (DomNode node) throws GLib.Error {
      if (node is DomDocument)
        throw new GXml.DomError.NOT_SUPPORTED_ERROR (_("Can't adopt a Document"));
      if (this == node.owner_document) return node;
      var dst = this.create_element (node.node_name);
      GXml.DomNode.copy (this, dst, node, true);
      if (node.parent_node != null)
        node.parent_node.child_nodes.remove_at (node.parent_node.child_nodes.index_of (node));
      if (this.document_element == null)
        this.append_child (dst as DomNode);
      else
        document_element.append_child (dst as DomNode);
      return (DomNode) dst;
  }

  protected GXml.DomEvent _constructor;
  public DomEvent create_event (string iface) {
      var s = iface.down ();
      if (s == "customevent") _constructor = new GXml.GDomCustomEvent ();
      if (s == "event") _constructor = new GXml.GDomCustomEvent ();
      if (s == "events") _constructor = new GXml.GDomCustomEvent ();
      if (s == "htmlevents") _constructor = new GXml.GDomCustomEvent ();
      if (s == "keyboardevent") _constructor = null;
      if (s == "keyevents") _constructor = null;
      if (s == "messageevent") _constructor = null;
      if (s == "mouseevent") _constructor = null;
      if (s == "mouseevents") _constructor = null;
      if (s == "touchevent") _constructor = null;
      if (s == "uievent") _constructor = null;
      if (s == "uievents") _constructor = null;
      return _constructor;
  }

  public DomRange create_range() {
      return new GDomRange (this);
  }

  // NodeFilter.SHOW_ALL = 0xFFFFFFFF
  public DomNodeIterator create_node_iterator (DomNode root, ulong what_to_show = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null)
  {
    return new GDomNodeIterator (root, what_to_show, filter);
  }
  public DomTreeWalker create_tree_walker (DomNode root, ulong what_to_show = (ulong) 0xFFFFFFFF, DomNodeFilter? filter = null) {
      return new GDomTreeWalker (root, what_to_show, filter);
  }
  // DomParentNode
  public DomHTMLCollection children { owned get { return (DomHTMLCollection) children_nodes; } }
  public DomElement? first_element_child {
    owned get { return (DomElement) (this as Document).children_nodes.first (); }
  }
  public DomElement? last_element_child {
    owned get { return (DomElement) (this as Document).children_nodes.last (); }
  }
  public ulong child_element_count { get { return (ulong) children_nodes.size; } }

  public DomElement? query_selector (string selectors) throws GLib.Error {
    return null; // FIXME
  }
  public DomNodeList query_selector_all (string selectors) throws GLib.Error  {
    return null; // FIXME
  }
  // DomNonElementParentNode
  public DomElement? get_element_by_id (string element_id) throws GLib.Error {
    var l = this.get_elements_by_property_value ("id", element_id);
    if (l.size > 0) return (DomElement) l[0];
    return null;
  }
}
