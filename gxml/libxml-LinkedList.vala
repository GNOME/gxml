/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/* NodeList.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
 * Copyright (C) 2013-2015  Daniel Espinosa <esodan@gmail.com>
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
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Authors:
 *      Richard Schwarting <aquarichy@gmail.com>
 *      Daniel Espinosa <esodan@gmail.com>
 */


internal class GXml.LinkedList : Gee.LinkedList<GXml.xNode>, NodeList
{

	construct { Init.init (); }

  public GXml.xNode root;

	public ulong length {
	  get { return size; }
	  protected set {}
	}

	public LinkedList (GXml.xNode root)
	{
	  this.root = root;
	}

  public unowned xNode? insert_before (xNode new_child, xNode? ref_child)
  {
    int i = -1;
    if (contains (ref_child)) {
        i = index_of (ref_child);
        insert (i, new_child);
        return new_child;
    }
    return null;
  }

	public unowned xNode? replace_child (xNode new_child, xNode old_child)
	{
	  if (contains (old_child)) {
	    int i = index_of (old_child);
	    remove_at (i);
	    insert (i, new_child);
	    return new_child;
	  }
	  return null;
	}

	public unowned xNode? remove_child (xNode old_child)
	{
	  if (contains (old_child)) {
	    unowned xNode n = old_child;
	    remove_at (index_of (old_child));
	    return n;
	  }
	  return null;
	}

	public unowned xNode? append_child (xNode new_child)
	{
	  add (new_child);
	  return new_child;
	}

  public xNode item (ulong idx)
  {
    return @get((int) idx);
  }

  public string to_string (bool in_line) 
  {
    string str = "";
	  foreach (xNode node in this) {
		  str += node.stringify ();
	  }
	  return str;
  }
}
