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

/**
 * DOM4 An event handler, powered by libxml2 library.
 */
public class GXml.Event : GLib.Object, GXml.DomEvent {
	protected string _etype;
	protected DomEventTarget _event_target;
	protected DomEventTarget _current_target;
	protected bool _bubbles;
	protected bool _cancelable;
	public string etype { get { return _etype; } }
	public DomEventTarget? event_target { get { return _event_target; } }
	public DomEventTarget? current_target { get { return _current_target; } }
	public bool bubbles { get { return _bubbles; } }
	public bool cancelable { get { return _cancelable; } }

	protected bool _is_trusted = false;
	public bool is_trusted { get { return _is_trusted; } }
	protected DomTimeStamp _time_stamp = new DomTimeStamp ();
	public DomTimeStamp time_stamp { get { return _time_stamp; } }

	protected bool _default_prevented;
	public bool default_prevented { get { return _default_prevented; } }

	protected  DomEvent.Phase _event_phase;
	public DomEvent.Phase event_phase { get { return _event_phase; } }

	protected GXml.DomEvent.Flags _flags;
	public void stop_propagation () {
		_flags = _flags & GXml.DomEvent.Flags.STOP_PROPAGATION_FLAG;
	}
	public void stop_immediate_propagation () {
		_flags = _flags & GXml.DomEvent.Flags.STOP_IMMEDIATE_PROPAGATION_FLAG;
	}

	public void prevent_default () {
		if (cancelable)
			_flags = _flags & GXml.DomEvent.Flags.CANCELED_FLAG;
	}
	public void init_event (string type, bool bubbles, bool cancelable) {
		_etype = type;
		_bubbles = bubbles;
		_cancelable = cancelable;
	}
}

/**
 * Custom event handler, powered by libxml2 library.
 */
public class GXml.CustomEvent : GXml.Event {
	protected GLib.Value _detail;
	public GLib.Value detail { get { return _detail; } }

	public void init_custom_event (string type, bool bubbles, bool cancelable, GLib.Value? detail)
	{
		_etype = type;
		_bubbles = bubbles;
		_cancelable = cancelable;
		_detail = detail;
	}
}
