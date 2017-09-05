/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2017  Yannick Inizan <inizan.yannick@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Yannick Inizan <inizan.yannick@gmail.com>
 */
public errordomain GXml.SelectorError {
	NULL,
	ATTRIBUTE,
	INVALID,
	LENGTH,
	STRING,
	TYPE
}

public enum GXml.SelectorType {
	CLASS,
	ID,
	ALL,
	ELEMENT,
	ATTRIBUTE,
	ATTRIBUTE_EQUAL,
	ATTRIBUTE_CONTAINS,
	ATTRIBUTE_SUBSTRING,
	ATTRIBUTE_START_WITH,
	ATTRIBUTE_END_WITH,
	PSEUDO,
	AND,
	INSIDE,
	PARENT,
	AFTER,
	BEFORE
}

public struct GXml.SelectorData {
	public SelectorType selector_type;
	public string data;
	public string value;
}

public class GXml.SelectorParser : GLib.Object {
	Gee.ArrayList<SelectorData?> list;
	
	construct {
		list = new Gee.ArrayList<SelectorData?>();
	}
	
	void parse_class (string css, ref int position) {
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		SelectorData data = { SelectorType.CLASS, sb.str };
		list.add (data);
	}
	
	void parse_id (string css, ref int position) {
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		SelectorData data = { SelectorType.ID, sb.str };
		list.add (data);
	}
	
	void parse_all (string css, ref int position) {
		position++;
		SelectorData data = { SelectorType.ALL, "*" };
		list.add (data);
	}
	
	void parse_element (string css, ref int position) {
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		SelectorData data = { SelectorType.ELEMENT, sb.str };
		list.add (data);
	}
	
	void parse_attribute (string css, ref int position) throws GLib.Error {
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		css.get_next_char (ref position, out u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (!u.isalnum())
			throw new SelectorError.ATTRIBUTE ("invalid attribute character");
		sb.append_unichar (u);
		while (css.get_next_char (ref position, out u) && u.isalnum())
			sb.append_unichar (u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (u == ']') {
			SelectorData data = { SelectorType.ATTRIBUTE, sb.str };
			list.add (data);
			return;
		}
		if (u == '=') {
			StringBuilder sb1 = new StringBuilder();
			css.get_next_char (ref position, out u);
			while (u.isspace())
				css.get_next_char (ref position, out u);
			unichar s = 0;
			if (u == '"' || u == '\'') {
				s = u;
				css.get_next_char (ref position, out u);
			}
			if (!u.isalnum())
				throw new SelectorError.ATTRIBUTE ("invalid attribute selector character");
			sb1.append_unichar (u);
			while (css.get_next_char (ref position, out u) && (u.isalnum() || u.isspace()))
				sb1.append_unichar (u);
			if (s != 0) {
				if (u != s)
					throw new SelectorError.STRING ("invalid end of attribute value");
				css.get_next_char (ref position, out u);
			}
			while (u.isspace())
				css.get_next_char (ref position, out u);
			if (u != ']')
				throw new SelectorError.ATTRIBUTE ("invalid end of attribute selector");
			SelectorData data = {
				SelectorType.ATTRIBUTE_EQUAL,
				sb.str,
				sb1.str
			};
			if (s == 0)
				data.value = sb1.str.strip();
			list.add (data);
			return;
		}
		StringBuilder sb1 = new StringBuilder();
		SelectorData data = { SelectorType.ATTRIBUTE, sb.str, "" };
		if (u == '~')
			data.selector_type = SelectorType.ATTRIBUTE_CONTAINS;
		else if (u == '*')
			data.selector_type = SelectorType.ATTRIBUTE_SUBSTRING;
		else if (u == '|' || u == '^')
			data.selector_type = SelectorType.ATTRIBUTE_START_WITH;
		else if (u == '$')
			data.selector_type = SelectorType.ATTRIBUTE_END_WITH;
		else
			throw new SelectorError.ATTRIBUTE ("invalid attribute selector character");
		css.get_next_char (ref position, out u);
		if (u != '=')
			throw new SelectorError.ATTRIBUTE ("invalid attribute selector character : can't find '=' character");
		css.get_next_char (ref position, out u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		unichar s = 0;
		if (u == '"' || u == '\'') {
			s = u;
			css.get_next_char (ref position, out u);
		}
		if (!u.isalnum())
			throw new SelectorError.ATTRIBUTE ("invalid attribute selector character 2 (%s)".printf (u.to_string()));
		sb1.append_unichar (u);
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u.isspace()))
			sb1.append_unichar (u);
		if (s != 0) {
			if (u != s)
				throw new SelectorError.STRING ("invalid end of attribute value");
			css.get_next_char (ref position, out u);
		}
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (u != ']')
			throw new SelectorError.ATTRIBUTE ("invalid end of attribute selector");
		if (s == 0)
			data.value = sb1.str.strip();
		else
			data.value = sb1.str;
		list.add (data);
	}
	
	void parse_pseudo (string css, ref int position) throws GLib.Error {
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-' || u == ':'))
			sb.append_unichar (u);
		string[] valid_selectors = {
			"checked",
			"disabled",
			"empty",
			"enable",
			"first-child",
			":first-letter",
			":first-line",
			"first-of-type",
			"last-child",
			"last-of-type"
		};
		if (!(sb.str in valid_selectors))
			throw new SelectorError.INVALID ("invalid pseudo class selector");
		SelectorData data = { SelectorType.PSEUDO, sb.str };
		list.add (data);
	}
	
	public void parse (string query) throws GLib.Error {
		string css = query.strip();
		if (css.length == 0)
			throw new SelectorError.LENGTH ("invalid string length.");
		bool space = false;
		int position = 0;
		while (position < css.length) {
			print ("position : %d (%c)\n", position, css[position]);
			if (css[position] == '.')
				parse_class (css, ref position);
			else if (css[position] == '#')
				parse_id (css, ref position);
			else if (css[position] == '*')
				parse_all (css, ref position);
			else if (css[position] == '[')
				parse_attribute (css, ref position);
			else if (css[position] == ':')
				parse_pseudo (css, ref position);
			else if (css[position].isalnum())
				parse_element (css, ref position);
			else if (css[position] == ',') {
				position++;
				SelectorData data = { SelectorType.AND, "," };
				list.add (data);
			}
			else if (css[position] == '+') {
				position++;
				SelectorData data = { SelectorType.AFTER, "+" };
				list.add (data);
			}
			else if (css[position] == '~') {
				position++;
				SelectorData data = { SelectorType.BEFORE, "~" };
				list.add (data);
			}
			else if (css[position] == '>') {
				position++;
				SelectorData data = { SelectorType.PARENT, ">" };
				list.add (data);
			}
			else if (css[position].isspace()) {
				unichar u = 0;
				css.get_next_char (ref position, out u);
				while (u.isspace())
					css.get_next_char (ref position, out u);
				position--;
				if (list.size > 0 && list[list.size - 1].selector_type != SelectorType.AND && list[list.size - 1].selector_type != SelectorType.PARENT
					&& list[list.size - 1].selector_type != SelectorType.BEFORE && list[list.size - 1].selector_type != SelectorType.AFTER)
				{
					SelectorData data = { SelectorType.INSIDE, " " };
					list.add (data);
				}
			}
			else
				throw new SelectorError.TYPE ("invalid '%c' character.".printf (css[position]));
		}
		
		foreach (var data in list)
			print ("%s\n", data.selector_type.to_string());
	}

	public Gee.List<SelectorData?> selectors {
		get {
			return list;
		}
	}
}
