/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
/* Implementation.vala
 *
 * Copyright (C) 2011-2013  Richard Schwarting <aquarichy@gmail.com>
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
 *      Richard Schwarting <aquarichy@gmail.com>
 */

namespace GXml {
	internal class XmlUtils {
		private static bool validate_name_start_char (unichar ch) {
			// Check common ASCII characters
			if (('a' <= start && start <= 'z')
				|| ('A' <= start && start <= 'Z')
				|| start == ':' || start == '_') {
				return true;
			}

			/* Supporting these non-ASCII values
			   [#xC0-#xD6] |      192-214
			   [#xD8-#xF6] |      216-246
			   [#xF8-#x2FF] |     248-767
			   [#x370-#x37D] |    880-893
			   [#x37F-#x1FFF] |   895-8191
			   [#x200C-#x200D] |  8204-8205
			   [#x2070-#x218F] |  8304-8591
			   [#x2C00-#x2FEF] |  11264-12271
			   [#x3001-#xD7FF] |  12289-55295
			   [#xF900-#xFDCF] |  63744-64975
			   [#xFDF0-#xFFFD] |  65008-65533
			   [#x10000-#xEFFFF]  65536-983039
			*/

			if ((192 <= ch && ch <= 214) ||
				(192 <= ch && ch <= 214) ||
				(216 <= ch && ch <= 246) ||
				(248 <= ch && ch <= 767) ||
				(880 <= ch && ch <= 893) ||
				(895 <= ch && ch <= 8191) ||
				(8204 <= ch && ch <= 8205) ||
				(8304 <= ch && ch <= 8591) ||
				(11264 <= ch && ch <= 12271) ||
				(12289 <= ch && ch <= 55295) ||
				(63744 <= ch && ch <= 64975) ||
				(65008 <= ch && ch <= 65533) ||
				(65536 <= ch && ch <= 983039)) {
				return true;
			}

			return false;


		}

		private static bool validate_name_char (unichar ch) {
			// Check common ASCII characters (and for valid start characters)
			if (validate_name_start_char (ch)
				|| ch == '-' || ch == '.'
				|| ('0' <= ch && ch <= '9')) {
				return true;
			}

			/* Supporting these non-ASCII values
			    183      #xB7 |
			    768-871  [#x0300-#x036F] |
			   8255-8256 [#x203F-#x2040]
			*/

			// Do incremental range checks for others
			if (ch < 183)
				return false;
			else if (ch == 183)
				return true;
			else if (ch < 768)
				return false;
			else if (ch <= 871)
				return true;
			else if (ch < 8255)
				return false;
			else if (ch <= 8256)
				return true;
			else
				return false;
		}

		/**
		 * Verifies a name is a valid XML name.
		 *
		 * TODO: write tests for these.
		 *
		 * For more, see: [[http://www.w3.org/TR/REC-xml/#NT-Name]]
		 */
		internal bool validate_xml_name (string name) {
			int ci = 0;
			unichar ch = 0;

			if (name.length == 0) {
				return false;
			}

			// Test first character
			if (name.get_next_char (ref ci, out ch)) {
				if (! validate_name_start_char (ch)) {
					return false;
				}
			}

			// Test remaining characters

			while (name.get_next_char (ref ci, out ch)) {
				if (! validate_name_char (ch)) {
					return false;
				}
			}

			return true;
		}
	}
}

