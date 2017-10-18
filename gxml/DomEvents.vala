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

public interface GXml.DomEventTarget : GLib.Object {
  public abstract void add_event_listener (string type, DomEventListener? callback, bool capture = false);
  public abstract void remove_event_listener (string type, DomEventListener? callback, bool capture = false);
  public abstract bool dispatch_event (DomEvent event) throws GLib.Error;
}

public interface GXml.DomEventListener : GLib.Object {
  public abstract void handle_event (DomEvent event);
}

public interface GXml.DomEvent : GLib.Object {
  public abstract string etype { get; }
  public abstract DomEventTarget? event_target { get; }
  public abstract DomEventTarget? current_target { get; }
  public abstract bool bubbles { get; }
  public abstract bool cancelable { get; }


  public abstract bool is_trusted { get; }
  public abstract DomTimeStamp time_stamp { get; }

  public abstract bool default_prevented { get; }

  public abstract Phase event_phase { get; }


  public abstract void stop_propagation ();
  public abstract void stop_immediate_propagation ();

  public abstract void prevent_default ();
  public abstract void init_event (string type, bool bubbles, bool cancelable);

	public enum Phase {
		NONE = 0,
		CAPTURING_PHASE,
		AT_TARGET,
		BUBBLING_PHASE
	}

  [Flags]
  public enum Flags {
		STOP_PROPAGATION_FLAG,
		STOP_IMMEDIATE_PROPAGATION_FLAG,
		CANCELED_FLAG,
		INITIALIZED_FLAG,
		DISPATCH_FLAG
  }
}

public class GXml.DomEventInit : GLib.Object {
  public bool bubbles { get; set; default = false; }
  public bool cancelable { get; set; default = false; }
}

public interface GXml.DomCustomEvent : GLib.Object, GXml.DomEvent {
  public abstract GLib.Value detail { get; }

  public abstract void init_custom_event (string type, bool bubbles, bool cancelable, GLib.Value detail);
}

public class GXml.DomCustomEventInit : GXml.DomEventInit {
  public GLib.Value detail { get; set; }
}


public class GXml.DomTimeStamp : GLib.Object {
	public GLib.DateTime time { get; set; }
	public string to_string () {
		return time.format ("%y-%m-%dT%T");
	}
}


