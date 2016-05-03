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

public interface GXml.DomRange {
  public abstract DomNode startContainer { get; }
  public abstract ulong startOffset { get; }
  public abstract DomNode endContainer { get; }
  public abstract ulong endOffset { get; }
  public abstract bool collapsed { get; }
  public abstract DomNode commonAncestorContainer { get; }

  public abstract void setStart(DomNode node, ulong offset);
  public abstract void setEnd(DomNode node, ulong offset);
  public abstract void setStartBefore(DomNode node);
  public abstract void setStartAfter(DomNode node);
  public abstract void setEndBefore(DomNode node);
  public abstract void setEndAfter(DomNode node);
  public abstract void collapse(bool toStart = false);
  public abstract void selectNode(DomNode node);
  public abstract void selectNodeContents(DomNode node);

  public const ushort START_TO_START = 0;
  public const ushort START_TO_END = 1;
  public const ushort END_TO_END = 2;
  public const ushort END_TO_START = 3;
  public abstract short compareBoundaryPoints(ushort how, DomRange sourceRange);

  public abstract void deleteContents();
  public abstract DomDocumentFragment extractContents();
  public abstract DomDocumentFragment cloneContents();
  public abstract void insertNode(DomNode node);
  public abstract void surroundContents(DomNode newParent);

  public abstract DomRange cloneRange();
  public abstract void detach();

  public abstract bool isPointInRange(DomNode node, ulong offset);
  public abstract short comparePoint(DomNode node, ulong offset);

  public abstract bool intersectsNode(DomNode node);

  public abstract string to_string ();
}
