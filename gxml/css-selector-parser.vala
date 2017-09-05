/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 0; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2017  Yannick Inizan <inizan.yannick@gmail.com>
 * Copyright (C) 2017  Daniel Espinosa <esodan@gmail.com>
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
 *      Daniel Espinosa <esodan@gmail.com>
 */
public errordomain GXml.CssSelectorError {
	NULL,
	ATTRIBUTE,
	INVALID,
	LENGTH,
	STRING,
	TYPE
}

public enum GXml.CssSelectorType {
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

public struct GXml.CssSelectorData {
	public CssSelectorType selector_type;
	public string data;
	public string value;
}

public class GXml.CssCssSelectorParser : GLib.Object {
	Gee.ArrayList<CssSelectorData?> list;
	
	construct {
		list = new Gee.ArrayList<CssSelectorData?>();
	}
	
	void parse_class (string css, ref int position) {
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		CssSelectorData data = { CssSelectorType.CLASS, sb.str };
		list.add (data);
	}
	
	void parse_id (string css, ref int position) {
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		CssSelectorData data = { CssSelectorType.ID, sb.str };
		list.add (data);
	}
	
	void parse_all (string css, ref int position) {
		position++;
		CssSelectorData data = { CssSelectorType.ALL, "*" };
		list.add (data);
	}
	
	void parse_element (string css, ref int position) {
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		CssSelectorData data = { CssSelectorType.ELEMENT, sb.str };
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
			throw new CssSelectorError.ATTRIBUTE ("invalid attribute character");
		sb.append_unichar (u);
		while (css.get_next_char (ref position, out u) && u.isalnum())
			sb.append_unichar (u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (u == ']') {
			CssSelectorData data = { CssSelectorType.ATTRIBUTE, sb.str };
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
				throw new CssSelectorError.ATTRIBUTE ("invalid attribute selector character");
			sb1.append_unichar (u);
			while (css.get_next_char (ref position, out u) && (u.isalnum() || u.isspace()))
				sb1.append_unichar (u);
			if (s != 0) {
				if (u != s)
					throw new CssSelectorError.STRING ("invalid end of attribute value");
				css.get_next_char (ref position, out u);
			}
			while (u.isspace())
				css.get_next_char (ref position, out u);
			if (u != ']')
				throw new CssSelectorError.ATTRIBUTE ("invalid end of attribute selector");
			CssSelectorData data = {
				CssSelectorType.ATTRIBUTE_EQUAL,
				sb.str,
				sb1.str
			};
			if (s == 0)
				data.value = sb1.str.strip();
			list.add (data);
			return;
		}
		StringBuilder sb1 = new StringBuilder();
		CssSelectorData data = { CssSelectorType.ATTRIBUTE, sb.str, "" };
		if (u == '~')
			data.selector_type = CssSelectorType.ATTRIBUTE_CONTAINS;
		else if (u == '*')
			data.selector_type = CssSelectorType.ATTRIBUTE_SUBSTRING;
		else if (u == '|' || u == '^')
			data.selector_type = CssSelectorType.ATTRIBUTE_START_WITH;
		else if (u == '$')
			data.selector_type = CssSelectorType.ATTRIBUTE_END_WITH;
		else
			throw new CssSelectorError.ATTRIBUTE ("invalid attribute selector character");
		css.get_next_char (ref position, out u);
		if (u != '=')
			throw new CssSelectorError.ATTRIBUTE ("invalid attribute selector character : can't find '=' character");
		css.get_next_char (ref position, out u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		unichar s = 0;
		if (u == '"' || u == '\'') {
			s = u;
			css.get_next_char (ref position, out u);
		}
		if (!u.isalnum())
			throw new CssSelectorError.ATTRIBUTE ("invalid attribute selector character 2 (%s)".printf (u.to_string()));
		sb1.append_unichar (u);
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u.isspace()))
			sb1.append_unichar (u);
		if (s != 0) {
			if (u != s)
				throw new CssSelectorError.STRING ("invalid end of attribute value");
			css.get_next_char (ref position, out u);
		}
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (u != ']')
			throw new CssSelectorError.ATTRIBUTE ("invalid end of attribute selector");
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
			throw new CssSelectorError.INVALID ("invalid pseudo class selector");
		CssSelectorData data = { CssSelectorType.PSEUDO, sb.str };
		list.add (data);
	}
	
	public void parse (string query) throws GLib.Error {
		string css = query.strip();
		if (css.length == 0)
			throw new CssSelectorError.LENGTH ("invalid string length.");
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
				CssSelectorData data = { CssSelectorType.AND, "," };
				list.add (data);
			}
			else if (css[position] == '+') {
				position++;
				CssSelectorData data = { CssSelectorType.AFTER, "+" };
				list.add (data);
			}
			else if (css[position] == '~') {
				position++;
				CssSelectorData data = { CssSelectorType.BEFORE, "~" };
				list.add (data);
			}
			else if (css[position] == '>') {
				position++;
				CssSelectorData data = { CssSelectorType.PARENT, ">" };
				list.add (data);
			}
			else if (css[position].isspace()) {
				unichar u = 0;
				css.get_next_char (ref position, out u);
				while (u.isspace())
					css.get_next_char (ref position, out u);
				position--;
				if (list.size > 0 && list[list.size - 1].selector_type != CssSelectorType.AND && list[list.size - 1].selector_type != CssSelectorType.PARENT
					&& list[list.size - 1].selector_type != CssSelectorType.BEFORE && list[list.size - 1].selector_type != CssSelectorType.AFTER)
				{
					CssSelectorData data = { CssSelectorType.INSIDE, " " };
					list.add (data);
				}
			}
			else
				throw new CssSelectorError.TYPE ("invalid '%c' character.".printf (css[position]));
		}
		
		foreach (var data in list)
			print ("%s\n", data.selector_type.to_string());
	}

	public Gee.List<CssSelectorData?> selectors {
		get {
			return list;
		}
	}
}