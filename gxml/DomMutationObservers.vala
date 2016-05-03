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
using Gee;

/**
 * Implementators should use constructor with one argument {@link GXml.DomMutationCallback}
 * to use internally.
 */
public interface GXml.DomMutationObserver : GLib.Object {
  public abstract void observe(Node target, DomMutationObserverInit options);
  public abstract void disconnect();
  public abstract Gee.List<DomMutationRecord> takeRecords();
}

public delegate void GXml.DomMutationCallback (Gee.List<DomMutationRecord> mutations, DomMutationObserver observer);

public class GXml.DomMutationObserverInit : GLib.Object {
  public bool childList { get; set; default = false; }
  public bool attributes { get; set; }
  public bool characterData { get; set; }
  public bool subtree { get; set; default = false; }
  public bool attributeOldValue { get; set; }
  public bool characterDataOldValue { get; set; }
  public Gee.List<string> attributeFilter { get; set; }
}

public interface GXml.DomMutationRecord : GLib.Object {
  public abstract string mtype { get; }
  public abstract DomNode target { get; }
  public abstract DomNodeList addedNodes { get; set; }
  public abstract DomNodeList removedNodes { get; set; }
  public abstract DomNode? previousSibling { get; }
  public abstract DomNode? nextSibling { get; }
  public abstract string? attributeName { get; }
  public abstract string? attributeNamespace { get; }
  public abstract string? oldValue { get; }
}
