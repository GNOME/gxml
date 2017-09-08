/* -*- Mode: vala; indent-tabs-mode: tab; c-basic-offset: 0; tab-width: 2 -*- */
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
	ATTRIBUTE_START_WITH_HYPHEN,
	ATTRIBUTE_END_WITH,
	PSEUDO,
	AND,
	INSIDE,
	PARENT,
	AFTER,
	BEFORE
}
public class GXml.CssSelectorData : GLib.Object {
	public CssSelectorType selector_type { get; set; default = CssSelectorType.ALL; }
	public string data { get; set; default = ""; }
	public string value { get; set; default = ""; }
	public CssSelectorData.with_values (CssSelectorType t, string data, string val) {
		selector_type = t;
		this.data = data;
		value = val;
	}
}

public class GXml.CssSelectorParser : GLib.Object {
	Gee.ArrayList<CssSelectorData?> list;

	public Gee.List<CssSelectorData?> selectors {
		get {
			return list;
		}
	}

	construct {
		list = new Gee.ArrayList<CssSelectorData?>();
	}

	void parse_class (string css, ref int position) {
		CssSelectorData idata = new CssSelectorData.with_values (CssSelectorType.INSIDE, "", "");
		list.add (idata);
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.CLASS, sb.str, "");
		list.add (data);
	}

	void parse_id (string css, ref int position) {
		CssSelectorData idata = new CssSelectorData.with_values (CssSelectorType.INSIDE, "", "");
		list.add (idata);
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.ID, sb.str, "");
		list.add (data);
	}

	void parse_all (string css, ref int position) {
		position++;
		CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.ALL, "*", "");
		list.add (data);
	}

	void parse_element (string css, ref int position) {
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-'))
			sb.append_unichar (u);
		CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.ELEMENT, sb.str, "");
		list.add (data);
	}

	void parse_attribute (string css, ref int position) throws GLib.Error {
		CssSelectorData idata = new CssSelectorData.with_values (CssSelectorType.INSIDE, "", "");
		list.add (idata);
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		css.get_next_char (ref position, out u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (!u.isalnum())
			throw new CssSelectorError.ATTRIBUTE (_("Invalid attribute character"));
		sb.append_unichar (u);
		while (css.get_next_char (ref position, out u) && u.isalnum())
			sb.append_unichar (u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (u == ']') {
			CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.ATTRIBUTE, sb.str, "");
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
				throw new CssSelectorError.ATTRIBUTE (_("Invalid attribute selector character"));
			sb1.append_unichar (u);
			while (css.get_next_char (ref position, out u) && (u.isalnum() || u.isspace()))
				sb1.append_unichar (u);
			if (s != 0) {
				if (u != s)
					throw new CssSelectorError.STRING (_("Invalid end of attribute value"));
				css.get_next_char (ref position, out u);
			}
			while (u.isspace())
				css.get_next_char (ref position, out u);
			if (u != ']')
				throw new CssSelectorError.ATTRIBUTE (_("Invalid end of attribute selector"));
			CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.ATTRIBUTE_EQUAL, sb.str, sb1.str);
			if (s == 0)
				data.value = sb1.str.strip();
			list.add (data);
			return;
		}
		StringBuilder sb1 = new StringBuilder();
		CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.ATTRIBUTE, sb.str, "");
		if (u == '~')
			data.selector_type = CssSelectorType.ATTRIBUTE_CONTAINS;
		else if (u == '*')
			data.selector_type = CssSelectorType.ATTRIBUTE_SUBSTRING;
		else if (u == '^')
			data.selector_type = CssSelectorType.ATTRIBUTE_START_WITH;
		else if (u == '|')
			data.selector_type = CssSelectorType.ATTRIBUTE_START_WITH_HYPHEN;
		else if (u == '$')
			data.selector_type = CssSelectorType.ATTRIBUTE_END_WITH;
		else
			throw new CssSelectorError.ATTRIBUTE (_("Invalid attribute selector character"));
		css.get_next_char (ref position, out u);
		if (u != '=')
			throw new CssSelectorError.ATTRIBUTE (_("Invalid attribute selector character : can't find '=' character"));
		css.get_next_char (ref position, out u);
		while (u.isspace())
			css.get_next_char (ref position, out u);
		unichar s = 0;
		if (u == '"' || u == '\'') {
			s = u;
			css.get_next_char (ref position, out u);
		}
		if (!u.isalnum())
			throw new CssSelectorError.ATTRIBUTE (_("Invalid attribute selector character 2 (%s)").printf (u.to_string()));
		sb1.append_unichar (u);
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u.isspace()))
			sb1.append_unichar (u);
		if (s != 0) {
			if (u != s)
				throw new CssSelectorError.STRING (_("Invalid end of attribute value"));
			css.get_next_char (ref position, out u);
		}
		while (u.isspace())
			css.get_next_char (ref position, out u);
		if (u != ']')
			throw new CssSelectorError.ATTRIBUTE (_("Invalid end of attribute selector"));
		if (s == 0)
			data.value = sb1.str.strip();
		else
			data.value = sb1.str;
		list.add (data);
	}

	void parse_pseudo (string css, ref int position) throws GLib.Error {
		CssSelectorData idata = new CssSelectorData.with_values (CssSelectorType.INSIDE, "", "");
		list.add (idata);
		position++;
		StringBuilder sb = new StringBuilder();
		unichar u = 0;
		while (css.get_next_char (ref position, out u) && (u.isalnum() || u == '-' || u == ':'))
			sb.append_unichar (u);
		string[] valid_selectors = {
			"root",
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
			throw new CssSelectorError.INVALID (_("Invalid pseudo class selector %s").printf (sb.str));
		CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.PSEUDO, sb.str, "");
		list.add (data);
	}

	public void parse (string query) throws GLib.Error {
		string css = query.strip();
		if (css.length == 0)
			throw new CssSelectorError.LENGTH (_("Invalid string length."));
		int position = 0;
		unichar u = 0;
		while (position < css.length) {
			u = css.get_char (position);
			if (u.isspace()) {
				css.get_next_char (ref position, out u);
				while (u.isspace())
					css.get_next_char (ref position, out u);
				position--;
			}
			if (selectors.size > 0) {
			  var ps = selectors.get (selectors.size -1);
			  if (ps != null) {
					if (ps.selector_type == CssSelectorType.ELEMENT) {
						css.get_prev_char (ref position, out u);
						if (u == '.') {
							parse_class (css, ref position);
							continue;
						}
						else if (u == '#') {
							parse_id (css, ref position);
							continue;
						}
						else if (u == '[') {
							parse_attribute (css, ref position);
							continue;
						}
						else if (u == ':') {
							parse_pseudo (css, ref position);
							continue;
						}
						else
							throw new CssSelectorError.TYPE (_("Invalid '%s' character.").printf (css.substring (position, 1)));
					}
				}
			}
			if (u == '*')
				parse_all (css, ref position);
			else if (u == '.') {
				parse_class (css, ref position);
				continue;
			}
			else if (u.isalnum())
				parse_element (css, ref position);
			else if (u == ',') {
				position++;
				CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.AND, ",", "");
				list.add (data);
			}
			else if (u == '+') {
				position++;
				CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.AFTER, "+", "");
				list.add (data);
			}
			else if (u == '~') {
				position++;
				CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.BEFORE, "~", "");
				list.add (data);
			}
			else if (u == '>') {
				position++;
				CssSelectorData data = new CssSelectorData.with_values (CssSelectorType.PARENT, ">", "");
				list.add (data);
			}
//			if (list.size > 0 && list[list.size - 1].selector_type != CssSelectorType.AND && list[list.size - 1].selector_type != CssSelectorType.PARENT
//				&& list[list.size - 1].selector_type != CssSelectorType.BEFORE && list[list.size - 1].selector_type != CssSelectorType.AFTER
//				&& list[list.size - 1].selector_type == CssSelectorType.ELEMENT && position < css.length)
//			{
//				
//			}
		}
		
		foreach (var data in list)
			message ("%s\n", data.selector_type.to_string());
	}
	public bool match (DomElement element) throws GLib.Error {
		bool is_element = false;
		for (int i = 0; i < selectors.size; i++) {
			CssSelectorData s = selectors.get (i);
			if (s.selector_type == CssSelectorType.ALL) return true;
			if (s.selector_type == CssSelectorType.INSIDE) continue;
			if (s.selector_type == CssSelectorType.ELEMENT) {
				if (element.node_name.down () != s.data.down ()) return false;
				is_element = true;
				if ((i+1) >= selectors.size) return true;
				continue;
			}
			if (is_element && s.selector_type == CssSelectorType.ATTRIBUTE) {
				var p = element.get_attribute (s.data);
				if (p != null) return true;
			}
			if (is_element && s.selector_type == CssSelectorType.ATTRIBUTE_EQUAL) {
				var p = element.get_attribute (s.data);
				if (p == null) return false;
				if (p == s.value) return true;
			}
			if (is_element && s.selector_type == CssSelectorType.ATTRIBUTE_CONTAINS) {
				var p = element.get_attribute (s.data);
				if (p == null) return false;
				var tl = new GDomTokenList (element, s.data);
				if (tl.contains (s.value)) return true;
			}
			if (is_element && s.selector_type == CssSelectorType.ATTRIBUTE_START_WITH) {
				var p = element.get_attribute (s.data);
				if (p == null) return false;
				if (p.has_prefix (s.value)) return true;
			}
			if (is_element && s.selector_type == CssSelectorType.ATTRIBUTE_END_WITH) {
				var p = element.get_attribute (s.data);
				if (p == null) return false;
				if (p.has_suffix (s.value)) return true;
			}
			if (is_element && s.selector_type == CssSelectorType.ATTRIBUTE_START_WITH_HYPHEN) {
				var p = element.get_attribute (s.data);
				if (p == null) return false;
				if (p.has_suffix (s.value+"-")) return true;
			}
			if (is_element && s.selector_type == CssSelectorType.PSEUDO) {
				if (s.data.down () == "root") {
					if (element is GomElement)
						if (element != element.owner_document.document_element) return false;
					if (element is GElement)
						if ((element as GNode).get_internal_node () 
									!= (element.owner_document.document_element as GNode).get_internal_node ()) return false;
					if (element.node_name.down () == element.owner_document.document_element.node_name.down ()) return true;
				}
				if (s.data.down () == "checked") {
					if (!(element.owner_document is DomHtmlDocument)) return false;
					// FIXME: check for tags UI allowed to have this state you can use E[checked="true"] instead
				}
				if (s.data.down () == "enable") {
					if (!(element.owner_document is DomHtmlDocument)) return false;
					// FIXME: check for tags UI allowed to have this state you can use E[enable="true"] instead
				}
				if (s.data.down () == "disabled") {
					if (!(element.owner_document is DomHtmlDocument)) return false;
					// FIXME: check for tags UI allowed to have this state you can use E[disable="true"] instead
				}
			}
			if (s.selector_type == CssSelectorType.CLASS) {
				var p = element.get_attribute ("class");
				if (p == null) return false;
				var lc = element.class_list;
				if (lc.contains (s.data)) return true;
				if (p=="warning") warning ("Not found");
			}
		}
		return false;
	}

}
