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

// FIXME Range could be a set of nodes or a set of character data
/**
 * DOM4 Range implementation, powered by libxml2 library.
 */
public class GXml.Range : GLib.Object, GXml.DomRange {
	protected DomDocument _document;
	protected DomNode _start_container;
	protected int _start_offset;
	protected DomNode _end_container;
	protected int _end_offset;
	protected bool _collapse;
	protected DomNode _common_ancestor_container;
	public DomNode start_container { get { return _start_container; } }
	public int start_offset { get { return _start_offset; } }
	public DomNode end_container { get { return _end_container; } }
	public int end_offset { get { return _end_offset; } }
	public bool collapsed { get { return _collapse; } }
	public DomNode common_ancestor_container { get { return _common_ancestor_container; } }

	public Range (DomDocument doc) {
		_document = doc;
		_start_container = doc;
		_end_container = doc;
		_start_offset = 0;
		_end_offset = 0;
		_common_ancestor_container = doc; //FIXME: Check spec
	}

	public void set_start (DomNode node, int offset) throws GLib.Error {
		if (node is DomDocumentType)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start"));
		if (node is DomDocumentType)
			if (offset > 0)
				throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start: for document type"));
		else
			if (node is DomCharacterData)
				if (offset > ((DomCharacterData) node).length)
					throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start: for character data"));
			else
				if (offset > node.child_nodes.length)
					throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start: for children number"));
		if (_end_container != null) {
			if (node.parent_node != _end_container.parent_node) {
				_start_container = _end_container;
				_start_offset = _end_offset;
			} else {
				var ni = node.parent_node.child_nodes.index_of (node);
				if (ni > offset)
					_end_container = node;
				_start_container = node;
				_start_offset = offset;
			}
		}
		_start_container = node;
		_start_offset = offset;
	}
	public void set_end (DomNode node, int offset) throws GLib.Error {
		if (node is DomDocumentType)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start"));
		if (node is DomDocumentType)
			if (offset > 0)
				throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start: for document type"));
		else
			if (node is DomCharacterData)
				if (offset > ((DomCharacterData) node).length)
					throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start: for character data"));
			else
				if (offset > node.child_nodes.length)
					throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start: for children number"));
		if (_start_container != null) {
			if (node.parent_node != _start_container.parent_node) {
				_end_container = _start_container;
				_end_offset = _start_offset;
			} else {
				var ni = node.parent_node.child_nodes.index_of (node);
				if (ni > offset)
					_start_container = node;
			}
		}
		_end_container = node;
		_end_offset = offset;
	}
	public void set_start_before (DomNode node) throws GLib.Error {
		if (node.parent_node == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start before"));
		set_start (node.parent_node, node.parent_node.child_nodes.index_of (node));
	}
	public void set_start_after  (DomNode node) throws GLib.Error {
		if (node.parent_node == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start after"));
		var i = node.parent_node.child_nodes.index_of (node);
		if (i+1 < node.parent_node.child_nodes.size)
			set_start (node.parent_node, node.parent_node.child_nodes.index_of (node) + 1);
		else
			set_start (node.parent_node, node.parent_node.child_nodes.index_of (node));
	}
	public void set_end_before (DomNode node) throws GLib.Error {
		if (node.parent_node == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start before"));
		set_end (node.parent_node, node.parent_node.child_nodes.index_of (node));
	}
	public void set_end_after (DomNode node) throws GLib.Error {
		if (node.parent_node == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start after"));
		var i = node.parent_node.child_nodes.index_of (node);
		if (i+1 < node.parent_node.child_nodes.size)
			set_end (node.parent_node, node.parent_node.child_nodes.index_of (node) + 1);
		else
			set_end (node.parent_node, node.parent_node.child_nodes.index_of (node));
	}
	public void collapse (bool to_start = false) throws GLib.Error {
		if (to_start) {
			_end_container = _start_container;
			_end_offset = _start_offset;
		} else {
			_start_container = _end_container;
			_start_offset = _end_offset;
		}
	}
	public void select_node (DomNode node) throws GLib.Error {
		if (node.parent_node == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start after"));
		var i = node.parent_node.child_nodes.index_of (node);
		set_start (node.parent_node, i);
		if (i + 1 < node.parent_node.child_nodes.size)
			set_end (node.parent_node, i + 1);
		else
			set_end (node.parent_node, i);
	}
	public void select_node_contents (DomNode node) throws GLib.Error {
		if (node is DomDocumentType)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start"));
		set_start (node, 0);
		int length = 0;
		if (node is DomDocumentType) length = 0;
		else
			if (node is DomCharacterData) length = ((DomCharacterData) node).length;
				else
					length = node.child_nodes.length;
		set_end (node, length);
	}

	public int compare_boundary_points (GXml.DomRange.BoundaryPoints how,
                                      DomRange source_range) throws GLib.Error
	{
		if (_start_container.parent_node != source_range.start_container.parent_node)
			throw new DomError.WRONG_DOCUMENT_ERROR (_("Invalid root in the source range"));
		switch (how) {
			case BoundaryPoints.START_TO_START:
				set_start (_start_container, 0);
				set_end (source_range.start_container, 0);
				return 0;
			case BoundaryPoints.START_TO_END:
				set_start (_start_container, _start_container.child_nodes.size);
				set_end (source_range.end_container, 0);
				return -1;
			case BoundaryPoints.END_TO_END:
				set_start (_end_container, 0);
				set_end (source_range.end_container, 0);
				return 0;
			case BoundaryPoints.END_TO_START:
				set_start (_start_container, 0);
				set_end (source_range.end_container, 0);
				return 1;
		}
		return 0;
	}

	public void delete_contents () throws GLib.Error { return; }// FIXME:
	public DomDocumentFragment? extract_contents() { return null; }// FIXME:
	public DomDocumentFragment? clone_contents() { return null; }// FIXME:
	public void insert_node(DomNode node) { return; }// FIXME:
	public void surround_contents(DomNode newParent) { return; }// FIXME:

	public DomRange clone_range() { return (DomRange) this.ref (); }// FIXME:
	public void detach () { return; }// FIXME:

	public bool  is_point_in_range (DomNode node, int offset) { return false; }// FIXME:
	public short compare_point     (DomNode node, int offset) { return 0; }// FIXME:

	public bool  intersects_node   (DomNode node) { return false; }// FIXME:

	public string to_string ()  { return "DomRange"; }// FIXME:
}
