/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Serializable.vala
 *
 + Copyright (C) 2013  Daniel Espinosa <esodan@gmail.com>
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

using GXml;

namespace GXml {
	public class Enumeration
	{
		/**
		 * Introspect an enumeration to get value's nick name.
		 *
		 * Returns: an string representing an enumeration's value.
		 *
		 * @enumeration: a {@link GLib.Type} of type {@link GLib.Type.ENUM}
		 * @val: an integer to parse an enum value of type @enumeration.
		 */
		public static string get_nick (Type enumeration, int val) throws GLib.Error
		{
			return get_string (enumeration, val, true);
		}
		/**
		 * Introspect an enumeration to get value's nick name and transform
		 * to camel case representation.
		 *
		 * Returns: an string representing an enumeration's value.
		 *
		 * @enumeration: a {@link GLib.Type} of type {@link GLib.Type.ENUM}
		 * @val: an integer to parse an enum value of type @enumeration.
		 */
		public static string get_nick_camelcase (Type enumeration, int val) throws GLib.Error
		{
			return get_string (enumeration, val, false, true);
		}
		/**
		 * Transform enumeration's value to its string representation.
		 *
		 * Returns: an string representing an enumeration's value.
		 *
		 * @enumeration: a {@link GLib.Type} of type {@link GLib.Type.ENUM}
		 * @val: an integer to parse an enum value of type @enumeration.
		 * @use_nick: makes to returns value's nick name in {@link GLib.EnumClass}
		 * @camelcase: makes to returns value's nick name in {@link GLib.EnumClass}
		 * as camel case representation. If @use_nick is set this take no effect.
		 */
		public static string get_string (Type enumeration, int val, 
		                                 bool use_nick = false,
		                                 bool camelcase = false)
		                                 throws GLib.Error
		                                 requires (enumeration.is_a (Type.ENUM))
		{
			string camel = "";
			EnumClass enumc = (EnumClass) enumeration.class_ref ();
			EnumValue? enumv = enumc.get_value (val);
			if (enumv == null)
				throw new EnumerationError.INVALID_VALUE ("value is invalid");
			if (use_nick && enumv.value_nick != null)
				return enumv.value_nick;
			if (camelcase && enumv.value_nick != null) {
				string[] sp = enumv.value_nick.split ("-");
				foreach (string s in sp) {
					camel += @"$(s[0])".up () + @"$(s[1:s.length])";
				}
			}
			else
				camel = enumv.value_name;
			return camel;
		}
		/**
		 * Parse @val to an enumeration's value.
		 *
		 * Returns: an {@link GLib.EnumValue} representing an enumeration's value.
		 *
		 * @enumeration: a {@link GLib.Type} of type {@link GLib.Type.ENUM}
		 * @val: a string to parse an enum value of type @enumeration.
		 * @camelcase: makes to returns value's nick name in {@link GLib.EnumClass}
		 * as camel case representation. If @use_nick is set this take no effect.
		 */
		public static EnumValue? parse (Type enumeration, string val)
		                  throws GLib.Error
		                  requires (enumeration.is_a (Type.ENUM))
		{
			EnumClass enumc = (EnumClass) enumeration.class_ref ();
			EnumValue? enumv = null;
			foreach (EnumValue ev in enumc.values) {
				if (val == ev.value_name)
					enumv = ev;
				if (val == ev.value_nick)
					enumv = ev;
				string nick = get_nick_camelcase (enumeration, ev.value);
				if (val == nick)
					enumv = ev;
				if (val.down () == nick.down ())
					enumv = ev;
			}
			if (enumv == null)
				throw new EnumerationError.INVALID_TEXT ("text is not valid");
			return enumv;
		}
		/**
		 * Transform an enumeration in an array of {@link GLib.EnumValue}.
		 *
		 * Returns: an array of {@link GLib.EnumValue} representing an enumeration.
		 *
		 * @enumeration: a {@link GLib.Type} of type {@link GLib.Type.ENUM}
		 * @val: a string to parse an enum value of type @enumeration.
		 * @camelcase: makes to returns value's nick name in {@link GLib.EnumClass}
		 * as camel case representation. If @use_nick is set this take no effect.
		 */
		public static unowned EnumValue[] to_array (Type enumeration)
		                               requires (enumeration.is_a (Type.ENUM))
		{
			EnumClass enumc = (EnumClass) enumeration.class_ref ();
			return enumc.values;
		}
		/**
		 * Converts a string to a value in a {@link GLib.EnumValue}
		 *
		 * Returns: a value in a {@link GLib.EnumValue
		 */
	}
	public errordomain EnumerationError
	{
		/**
		 * Given value is invalid in enumeration, when transform to string.
		 */
		INVALID_VALUE,
		/**
		 * Given text to transform to an enumeration's value.
		 */
		INVALID_TEXT
	}
}
