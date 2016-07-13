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

public class GXml.GDomRange : Object, GXml.DomRange {
	protected DomNode _start_container;
	protected ulong _start_offset;
	protected DomNode _end_container;
	protected ulong _end_offset;
	protected bool _collapse;
	protected DomNode _common_ancestor_container;
	public DomNode start_container { get { return _start_container; } }
	public ulong start_offset { get { return _start_offset; } }
	public DomNode end_container { get { return _end_container; } }
	public ulong end_offset { get { return _end_offset; } }
	public bool collapsed { get { return _collapse; } }
	public DomNode common_ancestor_container { get { return _common_ancestor_container; } }

	public void set_start (DomNode node, ulong offset) throws GLib.Error {
		if (node is DomDocumentType)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start"));
		if (offset > node.length)
			throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start"));
		if (_end_container != null) {
			if (node.parent != _end_container.parent) {
				_start_container = _end_container;
				_start_offset = _end_offset;
			} else {
				var ni = node.parent.children.index_of (node);
				var ei = node.parent.children.index_of (_end_offset);
				if (ni > ei)
					_end_container = node;
				_start_container = node;
				_start_offset = offset;
			}
		}
		_start_container = node;
		_start_offset = offset;
	}
	public void set_end          (DomNode node, ulong offset) throws GLib.Error {
		if (node is DomDocumentType)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start"));
		if (offset > node.length)
			throw new DomError.INDEX_SIZE_ERROR (_("Invalid offset for node to start"));
		if (_start_container != null) {
			if (node.parent != _start_container.parent) {
				_end_container = _start_container;
				_end_offset = _start_offset;
			} else {
				var ni = node.parent.children.index_of (node);
				var ei = node.parent.children.index_of (_start_offset);
				if (ni > ei)
					_start_container = node;
			}
		}
		_end_container = node;
		_end_offset = offset;
	}
	public void set_start_before (DomNode node) throws GLib.Error {
		if (node.parent == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start before"));
		set_start (node.parent, node.parent.children.index_of (node));
	}
	public void set_start_after  (DomNode node) throws GLib.Error {
		if (node.parent == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start after"));
		var i = node.parent.children.index_of (node);
		if (i+1 < node.parent.children.size)
			set_start (node.parent, node.parent.children.index_of (node) + 1);
		else
			set_start (node.parent, node.parent.children.index_of (node));
	}
	public void set_end_before (DomNode node) throws GLib.Error {
		if (node.parent == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start before"));
		set_end (node.parent, node.parent.children.index_of (node));
	}
	public void set_end_after (DomNode node) throws GLib.Error {
		if (node.parent == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start after"));
		var i = node.parent.children.index_of (node);
		if (i+1 < node.parent.children.size)
			set_end (node.parent, node.parent.children.index_of (node) + 1);
		else
			set_end (node.parent, node.parent.children.index_of (node));
	}
	public abstract void collapse (bool to_start = false) throws GLib.Error {
		if (to_start) {
			_end_container = _start_container;
			_end_offset = _start_offset;
		} else {
			_start_container = _end_container;
			_start_offset = _end_offset;
		}
	}
	public void select_node (DomNode node) throws GLib.Error {
		if (node.parent == null)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start after"));
		var i = node.parent.children.index_of (node);
		set_start (node.parent, i);
		if (i + 1 < node.parent.children.size)
			set_end (node.parent, i + 1);
		else
			set_end (node.parent, i);
	}
	public void select_node_contents (DomNode node) throws GLib.Error {
		if (node is DomDocumentType)
			throw new DomError.INVALID_NODE_TYPE_ERROR (_("Invalid node type to start"));
		set_start (node, 0);
		set_end (node, node.length);
	}

	public abstract int compare_boundary_points (BoundaryPoints how, DomRange source_range) throws GLib.Error {
		if (_start_container.parent != source_range.start_container.parent)
			throw new DomError.WRONG_DOCUMENT_ERROR (_("Invalid root's in range"));
		switch (how) {
			case BoundaryPoints.START_TO_START:
				set_start (_start_container, 0);
				set_end (source_range.start_container, 0);
				return 0;
				break;
			case BoundaryPoints.START_TO_END:
				set_start (_start_container, _start_container.children.size);
				set_end (source_range.end_container, 0);
				return -1;
				break;
			case BoundaryPoints.END_TO_END:
				set_start (_end_container, 0);
				set_end (source_range.end_container, 0);
				return 0;
				break;
			case BoundaryPoints.END_TO_START:
				set_start (_start_container, 0);
				set_end (source_range.end_container, 0);
				return 1;
				break;
		}
		return 0;
	}

	public void delete_contents () { return; // FIXME: }
	public DomDocumentFragment extract_contents() { return null; // FIXME:
	}
	public DomDocumentFragment clone_contents() { return null; // FIXME: }
	public void insertNode(DomNode node) { return null; // FIXME: }
	public void surroundContents(DomNode newParent) { return null; // FIXME: }

	public DomRange clone_range() { return this; // FIXME: }
	public void detach () { return; // FIXME: }

	public bool  is_point_in_range (DomNode node, ulong offset) { return false; // FIXME: }
	public short compare_point     (DomNode node, ulong offset) { return 0; // FIXME: }

	public bool  intersects_node   (DomNode node) { return false; // FIXME: }

	public string to_string ()  { return "DomRange"; // FIXME: }
}
