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
  public abstract void addEventListener(string type, DomEventListener? callback, bool capture = false);
  public abstract void removeEventListener(string type, DomEventListener? callback, bool capture = false);
  public abstract bool dispatchEvent(DomEvent event);
}

public interface GXml.DomEventListener : GLib.Object {
  public abstract void handleEvent(DomEvent event);
}

public interface GXml.DomEvent : GLib.Object {
  public abstract string etype { get; }
  public abstract DomEventTarget? target { get; }
  public abstract DomEventTarget? currentTarget { get; }
  public abstract bool bubbles { get; }
  public abstract bool cancelable { get; }

  public const ushort NONE = 0;
  public const ushort CAPTURING_PHASE = 1;
  public const ushort AT_TARGET = 2;
  public const ushort BUBBLING_PHASE = 3;
  public abstract ushort eventPhase { get; }


  public abstract void stopPropagation();
  public abstract void stopImmediatePropagation();

  public abstract void preventDefault();
  public abstract bool defaultPrevented { get; }

  public abstract bool isTrusted { get; }
  public abstract DomTimeStamp timeStamp { get; }

  public abstract void initEvent(string type, bool bubbles, bool cancelable);

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
  public abstract GLib.Value? detail { get; }

  public abstract void initCustomEvent (string type, bool bubbles, bool cancelable, GLib.Value? detail);
}

public class GXml.DomCustomEventInit : GXml.DomEventInit {
  public GLib.Value? detail { get; set; default = null; }
}


public class GXml.DomTimeStamp : GLib.Object {
	public GLib.DateTime time { get; set; }
	public string to_string () {
		return time.format ("%y-%m-%dT%T");
	}
}


