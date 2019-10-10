/* -*- Mode: vala; indent-tabs-mode: tab; c-basic-offset: 0; tab-width: 2 -*- */
/*
 *
 * Copyright (C) 2017-2019  Yannick Inizan <inizan.yannick@gmail.com>
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
/**
 * Enumeration of identifiers, to combine selectors 
 */
public enum GXml.CssCombiner {
	NULL,
	NONE,
	INSIDE,
	AND,
	PARENT,
	AFTER,
	PRECEDED
}
/**
 * Enumeration of types for {@link GXml.CssSelector}
 */
public enum GXml.CssSelectorType {
	CLASS,
	ID,
	ALL,
	ELEMENT,
	ATTRIBUTE,
	ATTRIBUTE_EQUAL,
	ATTRIBUTE_CONTAINS,
	ATTRIBUTE_SUBSTRING,
	ATTRIBUTE_STARTS_WITH,
	ATTRIBUTE_STARTS_WITH_WORD,
	ATTRIBUTE_ENDS_WITH,
	PSEUDO_CLASS
}

/**
 * Error throwed during parsing 
 */
public errordomain GXml.CssSelectorError {
	NULL,
	EOF,
	NOT,
	PSEUDO,
	ATTRIBUTE,
	IDENTIFIER,
	COMBINER
}

/**
 * String container for parsing 
 */
internal class GXml.CssString : GLib.Object {
	public CssString (string text) {
		GLib.Object (text : text);
	}
	
	int position;
	
	public unichar peek() {
		int pos = this.position;
		unichar u = 0;
		if (!this.text.get_next_char (ref pos, out u))
			return 0;
		return u;
	}
	
	public unichar read() {
		unichar u = 0;
		if (!this.text.get_next_char (ref this.position, out u))
			return 0;
		return u;
	}
	
	public unichar read_r() {
		unichar u = 0;
		if (!this.text.get_prev_char (ref this.position, out u))
			return 0;
		return u;
	}
	
	public bool eof {
		get {
			return peek() == 0;
		}
	}
	
	public string text { get; construct; }
}
/**
 * delegate function needed for parsing identifier
 */
internal delegate bool GXml.CssStringFunc (GXml.CssString str);
/**
 * generic CSS selector, used by {@link GXml.CssSelectorParser}
 */
public class GXml.CssSelector : GLib.Object {
	public CssSelector (GXml.CssSelectorType t = GXml.CssSelectorType.ELEMENT, string name = "") {
		GLib.Object (selector_type : t, name : name, value : "");
	}
	
	public CssSelector.with_value (GXml.CssSelectorType t = GXml.CssSelectorType.ELEMENT, string name, string value) {
		GLib.Object (selector_type : t, name : name, value : value);
	}
	
	public GXml.CssSelectorType selector_type { get; set construct; }
	
	public string name { get; set construct; }
	
	public string value { get; set construct; }
	
	public GXml.CssCombiner combiner { get; set; }
}
/**
 * CssSelector for elements
 */
public class GXml.CssElementSelector : GXml.CssSelector {
	public CssElementSelector (string? prefix = null, string local_name = "") {
		base (GXml.CssSelectorType.ELEMENT);
		this.name = prefix;
		this.value = local_name;
	}
	
	public bool prefixed {
		get {
			return this.prefix != null;
		}
	}
	
	public string? prefix {
		owned get {
			return this.name;
		}
		set {
			this.name = value;
		}
	}
	
	public string local_name {
		owned get {
			return this.value;
		}
		set {
			this.value = value;
		}
	}
}
/**
 * CssSelector for attributes
 */
public class GXml.CssAttributeSelector : GXml.CssSelector {
	public CssAttributeSelector (string? prefix = null, string local_name = "") {
		base (GXml.CssSelectorType.ATTRIBUTE);
		this.prefix = prefix;
		this.local_name = local_name;
		this.name = (prefix == null) ? local_name : "%s|%s".printf (prefix, local_name);
	}
	
	public string? prefix { get; set; }
	
	public string local_name { get; set; }
}
/**
 * CssSelector for 'not' pseudo class 
 */
public class GXml.CssNotSelector : GXml.CssSelector {
	public CssNotSelector() {
		GLib.Object (selector_type : GXml.CssSelectorType.PSEUDO_CLASS, name : "not");
	}
	
	Gee.ArrayList<GXml.CssSelector> list;
	
	construct {
		this.list = new Gee.ArrayList<GXml.CssSelector>();
	}
	
	/**
	 * a list of {@link GXml.CssSelector} that shouldn't match as a
	 * {@link Gee.List} of {@link GXml.CssSelector}
	 */
	public Gee.List<GXml.CssSelector> selectors {
		get {
			return this.list;
		}
	}
}
/**
 * CSS Selectors Level 3 parser. 
 */
public class GXml.CssSelectorParser : GLib.Object {
	static bool is_valid_char (unichar u) {
		unichar[] array = { 
			'=', '[', ']', '{', '}', 
			'$', '&', '#', '|', '`',
			'^', '@', '+', '~', '*',
			'%', '!', '?', '<', '>', 
			':', '.', '"', '\'', ','
		};
		return !(u in array);
	}
	
	static string parse_identifier (GXml.CssString str, GXml.CssStringFunc func) {
		var builder = new StringBuilder();
		while (!str.eof && func (str))
			builder.append_unichar (str.read());
		return builder.str;
	}
	
	static GXml.CssSelector parse_element (GXml.CssString str) throws GLib.Error {
		var builder = new StringBuilder();
		var extra_builder = new StringBuilder();
		while (!str.eof && (str.peek() == '*' || is_valid_char (str.peek())) && !str.peek().isspace())
			builder.append_unichar (str.read());
		if (builder.str.contains ("*") && builder.len > 1)
			throw new GXml.CssSelectorError.IDENTIFIER (_("Invalid identifier"));
		if (str.peek() == '|') {
			str.read();
			while (!str.eof && (str.peek() == '*' || is_valid_char (str.peek())) && !str.peek().isspace())
				extra_builder.append_unichar (str.read());
			if (extra_builder.len == 0)
				throw new GXml.CssSelectorError.IDENTIFIER (_("string value is empty"));
			if (extra_builder.str.contains ("*") && extra_builder.len > 1)
				throw new GXml.CssSelectorError.IDENTIFIER (_("Invalid identifier"));
			return new GXml.CssElementSelector (builder.str, extra_builder.str);
		}
		if (builder.len == 0)
			throw new GXml.CssSelectorError.IDENTIFIER (_("string value is empty"));
		return new GXml.CssElementSelector (null, builder.str);
	}
	
	static GXml.CssNotSelector parse_not_selector (GXml.CssString str) throws GLib.Error {
		if (str.read() != '(')
			throw new GXml.CssSelectorError.NOT (_("Cannot find start of 'not selector' value"));
		var selector = new GXml.CssNotSelector();
		while (str.peek().isspace())
			str.read();
		parse_selectors (str, selector.selectors, ')');
		if (str.read() != ')')
			throw new GXml.CssSelectorError.NOT (_("Cannot find end of 'not selector' value"));
		return selector;
	}
	
	static GXml.CssSelector parse_pseudo (GXml.CssString str) throws GLib.Error {
		string[] pseudo_strv = { "checked", "enabled", "disabled", "root", "empty", "first-child", "last-child", "only-child", "first-of-type", "last-of-type", "only-of-type" };
		string[] pseudo_value_strv = { "nth-child", "nth-last-child", "nth-of-type", "nth-last-of-type" };
		
		str.read();
		var builder = new StringBuilder();
		while (str.peek().isalpha() || str.peek() == '-')
			builder.append_unichar (str.read());
		if (builder.str == "not")
			return parse_not_selector (str);
		if (!(builder.str in pseudo_strv) && !(builder.str in pseudo_value_strv))
			throw new GXml.CssSelectorError.PSEUDO (_("Invalid '%s' pseudo class").printf (builder.str));
		if (builder.str in pseudo_strv)
			return new GXml.CssSelector (GXml.CssSelectorType.PSEUDO_CLASS, builder.str);
		if (builder.str in pseudo_value_strv && str.read() != '(')
			throw new GXml.CssSelectorError.PSEUDO (_("Invalid '%s' pseudo class : cannot find value").printf (builder.str));
		var vbuilder = new StringBuilder();
		while (str.peek().isalnum() || str.peek() == '-')
			vbuilder.append_unichar (str.read());
		if (str.read() != ')')
			throw new GXml.CssSelectorError.PSEUDO (_("Cannot find end of pseudo class value"));
		if (builder.str == "lang")
			return new GXml.CssSelector.with_value (GXml.CssSelectorType.PSEUDO_CLASS, "lang", vbuilder.str);
		uint64 val = 0;
		if (vbuilder.str != "odd" && vbuilder.str != "even" && (!uint64.try_parse (vbuilder.str, out val) || val == 0))
			throw new GXml.CssSelectorError.PSEUDO (_("Pseudo class value isn't a valid number"));
		return new GXml.CssSelector.with_value (GXml.CssSelectorType.PSEUDO_CLASS, builder.str, vbuilder.str);
	}
	
	static GXml.CssSelector parse_class (GXml.CssString str) throws GLib.Error {
		str.read();
		var builder = new StringBuilder();
		if (!str.peek().isalpha())
			throw new GXml.CssSelectorError.ATTRIBUTE (_("current class doesn't start with letter"));
		while (!str.eof && is_valid_char (str.peek()) && !str.peek().isspace())
			builder.append_unichar (str.read());
		return new GXml.CssSelector (GXml.CssSelectorType.CLASS, builder.str);
	}
	
	static GXml.CssSelector parse_id (GXml.CssString str) throws GLib.Error {
		str.read();
		var builder = new StringBuilder();
		if (!str.peek().isalpha())
			throw new GXml.CssSelectorError.ATTRIBUTE (_("current id doesn't start with letter"));
		while (!str.eof && is_valid_char (str.peek()) && !str.peek().isspace())
			builder.append_unichar (str.read());
		return new GXml.CssSelector (GXml.CssSelectorType.ID, builder.str);
	}
	
	static GXml.CssSelector parse_attribute (GXml.CssString str) throws GLib.Error {
		str.read();
		while (str.peek().isspace())
			str.read();
		var builder = new StringBuilder();
		var extra_builder = new StringBuilder();
		bool prefixed = false;
		while (!str.eof && (str.peek() == '*' || is_valid_char (str.peek())) && !str.peek().isspace())
			builder.append_unichar (str.read());	
		if (builder.str.contains ("*") && builder.len > 1)
			throw new GXml.CssSelectorError.ATTRIBUTE (_("Invalid attribute"));
		if (str.peek() == '|') {
			str.read();
			if (str.peek() == '=')
				str.read_r();
			else {
				prefixed = true;
				while (!str.eof && (str.peek() == '*' || is_valid_char (str.peek())) && !str.peek().isspace())
					extra_builder.append_unichar (str.read());
				if (extra_builder.len == 0)
					throw new GXml.CssSelectorError.ATTRIBUTE (_("string value is empty"));
				if (extra_builder.str.contains ("*") && extra_builder.len > 1)
					throw new GXml.CssSelectorError.ATTRIBUTE (_("Invalid attribute"));
			}
		}
		string? prefix = prefixed ? builder.str : null;
		string local_name = prefixed ? extra_builder.str : builder.str;
		var selector = new GXml.CssAttributeSelector (prefix, local_name);
		while (str.peek().isspace())
			str.read();
		if (str.peek() == ']') {
			str.read();
			return selector;
		}
		var ct = GXml.CssSelectorType.CLASS;
		if (str.peek() == '=')
			ct = GXml.CssSelectorType.ATTRIBUTE_EQUAL;
		else if (str.peek() == '|')
			ct = GXml.CssSelectorType.ATTRIBUTE_STARTS_WITH_WORD;
		else if (str.peek() == '^')
			ct = GXml.CssSelectorType.ATTRIBUTE_STARTS_WITH;
		else if (str.peek() == '$')
			ct = GXml.CssSelectorType.ATTRIBUTE_ENDS_WITH;
		else if (str.peek() == '~')
			ct = GXml.CssSelectorType.ATTRIBUTE_CONTAINS;
		else if (str.peek() == '*')
			ct = GXml.CssSelectorType.ATTRIBUTE_SUBSTRING;
		if (ct == GXml.CssSelectorType.CLASS)
			throw new GXml.CssSelectorError.ATTRIBUTE (_("Invalid attribute selector"));
		selector.selector_type = ct;
		if (ct != GXml.CssSelectorType.ATTRIBUTE_EQUAL)
			str.read();
		if (str.peek() != '=')
			throw new GXml.CssSelectorError.ATTRIBUTE (_("Invalid attribute selector. '=' expected but '%s' was found").printf (str.peek().to_string()));
		str.read();
		while (str.peek().isspace())
			str.read();
		unichar quote = 0;
		if (str.peek() == '"' || str.peek() == '\'')
			quote = str.read();
		var attr_value = parse_identifier (str, s => {
			return quote == 0 && !s.peek().isspace() && is_valid_char (s.peek()) || quote > 0 && s.peek() != quote;
		});
		selector.value = attr_value;
		if (quote > 0 && quote != str.read())
			throw new GXml.CssSelectorError.ATTRIBUTE (_("Cannot find end of attribute value"));
		while (str.peek().isspace())
			str.read();
		if (str.read() != ']')
			throw new GXml.CssSelectorError.ATTRIBUTE (_("Cannot find end of attribute selector"));
		
		// TODO : CSS Selectors level 4 : case sensitivity.
		
		return selector;
	}
	
	static void parse_selectors (GXml.CssString str, Gee.List<GXml.CssSelector> list, unichar stop_char = 0) throws GLib.Error {
		while (!str.eof && str.peek() != stop_char) {
			if (str.peek().isalpha() || str.peek() == '*' || str.peek() == '|')
				list.add (parse_element (str));
			else if (str.peek() == '.')
				list.add (parse_class (str));
			else if (str.peek() == '#')
				list.add (parse_id (str));
			else if (str.peek() == ':')
				list.add (parse_pseudo (str));
			else if (str.peek() == '[')
				list.add (parse_attribute (str));
			if (list[list.size - 1] is GXml.CssElementSelector) {
				var sel = list[list.size - 1] as GXml.CssElementSelector;
				if (!sel.prefixed && sel.local_name == "*")
					list[list.size - 1] = new GXml.CssSelector (GXml.CssSelectorType.ALL);
			}
			
			GXml.CssCombiner combiner = 0;
			if (str.peek().isspace())
				combiner = GXml.CssCombiner.INSIDE;
			while (str.peek().isspace())
				str.read();
			if (str.peek() == ',')
				combiner = GXml.CssCombiner.AND;
			else if (str.peek() == '>')
				combiner = GXml.CssCombiner.PARENT;
			else if (str.peek() == '+')
				combiner = GXml.CssCombiner.AFTER;
			else if (str.peek() == '~')
				combiner = GXml.CssCombiner.PRECEDED;
			else if (combiner == 0)
				combiner = GXml.CssCombiner.NONE;
			if (combiner != GXml.CssCombiner.NONE && combiner != GXml.CssCombiner.INSIDE)
				str.read();
			list[list.size - 1].combiner = combiner;
			while (str.peek().isspace())
				str.read();
		}
		if (list.size == 0)
			throw new GXml.CssSelectorError.NULL (_("No selectors found"));
		if (list[list.size - 1].combiner == GXml.CssCombiner.NONE)
			list[list.size - 1].combiner = GXml.CssCombiner.NULL;
		if (list[list.size - 1].combiner != GXml.CssCombiner.NULL)
			throw new GXml.CssSelectorError.COMBINER (_("Last selector has combiner assigned (%s)").printf (list[list.size - 1].combiner.to_string()));
	}
	/**
	 * parse selectors string. If data isn't valid, error is throwed
	 * 
	 * @param selectors CSS selectors Level 3 string 
	 */
	public void parse (string selectors) throws GLib.Error {
		this.list.clear();
		var str = new GXml.CssString (selectors);
		parse_selectors (str, this.list);
	}

	Gee.ArrayList<GXml.CssSelector> list;
	
	construct {
		this.list = new Gee.ArrayList<GXml.CssSelector>();
	}
	/**
	 * a list of parsed {@link GXml.CssSelector}  as a
	 * {@link Gee.List} of {@link GXml.CssSelector}
	 */
	public Gee.List<GXml.CssSelector> selectors {
		get {
			return this.list;
		}
	}
	
	static bool match_pseudo (GXml.DomElement element, GXml.CssSelector selector) throws GLib.Error {
		if (selector.name == "root")
			return element == element.owner_document.document_element;
		if (selector.name == "empty")
			return element.children.length == 0;
		if (selector.name == "checked") {
			if (element.local_name != "input")
				return false;
			return element.attributes.get_named_item ("checked") != null;
		}
		if (selector.name == "enabled" || selector.name == "disabled") {
			if (element.local_name != "input")
				return false;
			if (selector.name == "disabled")
				return element.attributes.get_named_item ("disabled") != null;
			return element.attributes.get_named_item ("disabled") == null;
		}
		if (selector.name == "first-child")
			return element.previous_element_sibling == null;
		if (selector.name == "last-child")
			return element.next_element_sibling == null;
		if (selector.name == "only-child")
			return element.previous_element_sibling == null && element.next_element_sibling == null;
		if (selector.name == "first-of-type") {
			var e = element.previous_element_sibling;
			bool res = true;
			while (e != null) {
				if (e.local_name == element.local_name)
					res = false;
				e = e.previous_element_sibling;
			}
			return res;
		}
		if (selector.name == "last-of-type") {
			var e = element.next_element_sibling;
			bool res = true;
			while (e != null) {
				if (e.local_name == element.local_name)
					res = false;
				e = e.next_element_sibling;
			}
			return res;
		}
		if (selector.name == "only-of-type") {
			var e = element.previous_element_sibling;
			var f = element.next_element_sibling;
			bool eres = true;
			bool fres = true;
			while (e != null) {
				if (e.local_name == element.local_name)
					eres = false;
				e = e.previous_element_sibling;
			}
			while (f != null) {
				if (f.local_name == element.local_name)
					fres = false;
				f = f.next_element_sibling;
			}
			return eres && fres;
		}
		if (selector.name == "nth-child") {
			if (element.parent_element == null)
				return false;
			if (selector.value == "even" || selector.value == "odd") {
				for (var i = (selector.value == "even" ? 1 : 0); i < element.parent_element.children.length; i += 2) {
					var child = element.parent_element.children.item (i);
					if (child == element)
						return true;
				}
				return false;
			}
			var index = int.parse (selector.value) - 1;
			if (index >= element.parent_element.children.length)
				return false;
			return element == element.parent_element.children.item (index);
		}
		if (selector.name == "nth-last-child") {
			if (element.parent_element == null)
				return false;
			if (selector.value == "even" || selector.value == "odd") {
				for (var i = (selector.value == "even" ? 1 : 0); i < element.parent_element.children.length; i += 2) {
					var child = element.parent_element.children.item (element.parent_element.children.length - 1 - i);
					if (child == element)
						return true;
				}
				return false;
			}
			var index = int.parse (selector.value) - 1;
			if (index >= element.parent_element.children.length)
				return false;
			return element == element.parent_element.children.item (element.parent_element.children.length - 1 - index);
		}
		if (selector.name == "nth-of-type") {
			if (element.parent_element == null)
				return false;
			var list = new Gee.ArrayList<GXml.DomElement>();
			foreach (var child in element.parent_element.children)
				if (child.local_name == element.local_name)
					list.add (child);
			if (selector.value == "even" || selector.value == "odd") {
				for (var i = (selector.value == "even" ? 1 : 0); i < list.size; i += 2) {
					var child = list[i];
					if (child == element)
						return true;
				}
				return false;
			}
			var index = int.parse (selector.value) - 1;
			if (index >= list.size)
				return false;
			return list[index] == element;
		}
		if (selector.name == "nth-last-of-type") {
			if (element.parent_element == null)
				return false;
			var list = new Gee.ArrayList<GXml.DomElement>();
			foreach (var child in element.parent_element.children)
				if (child.local_name == element.local_name)
					list.add (child);
			if (selector.value == "even" || selector.value == "odd") {
				for (var i = (selector.value == "even" ? 1 : 0); i < list.size; i += 2) {
					var child = list[list.size - 1 - i];
					if (child == element)
						return true;
				}
				return false;
			}
			var index = int.parse (selector.value) - 1;
			if (index >= list.size)
				return false;
			if (list[list.size - 1 - index] == element)
				return true;
		}
		return false;
	}
	
	static bool match_attribute (GXml.DomElement element, GXml.CssAttributeSelector selector) throws GLib.Error {
		var list = new Gee.ArrayList<GXml.DomNode>();
		if (selector.prefix != null) {
			if (selector.prefix == "") {
				for (var i = 0; i < element.attributes.length; i++) {
					if (element.attributes.item (i) == null)
						continue;
					if (element.attributes.item (i).node_name == selector.local_name || selector.local_name == "*")
						list.add (element.attributes.item (i));
				}
			}
			else if (selector.prefix == "*") {
				for (var i = 0; i < element.attributes.length; i++) {
					if (element.attributes.item (i) == null)
						continue;
					var attr_name = element.attributes.item (i).node_name;
					if (attr_name.split (":").length == 2 && (attr_name.split (":")[1] == selector.local_name || selector.local_name == "*"))
						list.add (element.attributes.item (i));
				}
			}
			else {
				for (var i = 0; i < element.attributes.length; i++) {
					if (element.attributes.item (i) == null)
						continue;
					var attr_name = element.attributes.item (i).node_name;
					if (attr_name.split (":").length == 2 && attr_name.split (":")[0] == selector.prefix && (attr_name.split (":")[1] == selector.local_name || selector.local_name == "*"))
						list.add (element.attributes.item (i));
				}
			}
		}
		else {
			var attr = element.attributes.get_named_item (selector.local_name);
			if (attr != null)
				list.add (attr);
		}
		if (list.size == 0)
			return false;
		foreach (var attr in list) {
			if (selector.selector_type == GXml.CssSelectorType.ATTRIBUTE)
				return true;
			if (selector.selector_type == GXml.CssSelectorType.ATTRIBUTE_EQUAL && attr.node_value == selector.value)
				return true;
			if (selector.selector_type == GXml.CssSelectorType.ATTRIBUTE_CONTAINS && attr.node_value != null && (selector.value in attr.node_value.split (" ")))
				return true;
			if (selector.selector_type == GXml.CssSelectorType.ATTRIBUTE_SUBSTRING && attr.node_value != null && attr.node_value.contains (selector.value))
				return true;
			if (selector.selector_type == GXml.CssSelectorType.ATTRIBUTE_STARTS_WITH_WORD && attr.node_value != null && attr.node_value.split ("-")[0] == selector.value)
				return true;
			if (selector.selector_type == GXml.CssSelectorType.ATTRIBUTE_STARTS_WITH && attr.node_value != null && attr.node_value.index_of (selector.value) == 0)
				return true;
			if (selector.selector_type == GXml.CssSelectorType.ATTRIBUTE_ENDS_WITH && attr.node_value != null && attr.node_value.last_index_of (selector.value) == attr.node_value.length - selector.value.length)
				return true;
		}
		return false;
	}
			
	static bool match_node (GXml.DomElement element, GXml.CssSelector selector) throws GLib.Error {
		if (selector.selector_type == GXml.CssSelectorType.ALL)
			return true;
		if (selector.selector_type == GXml.CssSelectorType.CLASS && element.get_attribute ("class") != null && element.class_list.contains (selector.name))
			return true;
		if (selector.selector_type == GXml.CssSelectorType.ID && element.id == selector.name)
			return true;
		if (selector is GXml.CssAttributeSelector)
			return match_attribute (element, selector as GXml.CssAttributeSelector);
		if (selector is GXml.CssElementSelector) {
			var sel = selector as GXml.CssElementSelector;
			if (sel.local_name == "*" && (!sel.prefixed || sel.prefix == "*"))
				return true;
			if (sel.prefixed && sel.prefix == "") {
				if (element.prefix != null && element.prefix.length > 0)
					return false;
				return sel.local_name == "*" || element.local_name == sel.local_name;
			}
			if (sel.prefix == "*")
				return sel.local_name == element.local_name;
			return sel.local_name == element.local_name && sel.prefix == element.prefix;
		}
		if (selector is GXml.CssNotSelector)
			return !match_element (element, element, ((GXml.CssNotSelector) selector).selectors);
		if (selector.selector_type == GXml.CssSelectorType.PSEUDO_CLASS)
			return match_pseudo (element, selector);
		return false;
	}
	
	static bool match_element (GXml.DomElement root, GXml.DomElement element, Gee.Collection<GXml.CssSelector> selectors) throws GLib.Error {
		var list = new Gee.ArrayList<GXml.CssSelector>();
		list.add_all (selectors);
		var selector = list.remove_at (list.size - 1);
		if (list.size == 0)
			return match_node (element, selector);
		if (list[list.size - 1].combiner == GXml.CssCombiner.AND)
			return match_node (element, selector) || match_element (root, root, list);
		if (list[list.size - 1].combiner == GXml.CssCombiner.NONE)
			return match_node (element, selector) && match_element (root, element, list);
		if (list[list.size - 1].combiner == GXml.CssCombiner.AFTER) {
			if (element.previous_element_sibling == null)
				return false;
			return match_node (element, selector) && match_element (root, element.previous_element_sibling, list);
		}
		if (list[list.size - 1].combiner == GXml.CssCombiner.PRECEDED) {
			bool res = match_node (element, selector);
			var prev = element.previous_element_sibling;
			while (prev != null) {
				if (res && match_element (root, prev, list))
					return true;
				prev = prev.previous_element_sibling;
			}
		}
		if (list[list.size - 1].combiner == GXml.CssCombiner.PARENT)
			return match_node (element, selector) && match_element (root, element.parent_element, list);
		if (list[list.size - 1].combiner == GXml.CssCombiner.INSIDE) {
			var parent = element.parent_element;
			bool res = match_node (element, selector);
			while (parent != null) {
				if (res && match_element (root, parent, list))
					return true;
				parent = parent.parent_element;
			}
		}
		return false;
	}
	/**
	 * Test if provided {@link GXml.DomElement} match with parsed selectors
	 * @param element a {@link GXml.DomElement} to match
	 * @return true if element match, or false 
	 */
	public bool match (GXml.DomElement element) throws GLib.Error {
		return match_element (element, element, this.list);
	}
	/**
	 * Retrieve children and descendent nodes that match parsed selectors.
	 * @param element a {@link GXml.DomElement}
	 * @return a {@link GXml.DomNodeList} of selected nodes
	 */
	public GXml.DomNodeList query_selector_all (GXml.DomElement element) throws GLib.Error {
		var list = new GXml.NodeList();
		foreach (GXml.DomElement child in element.children) {
			if (match (child))
				list.add (child);
			list.add_all (query_selector_all (child));
		}
		return list;
	}
}
