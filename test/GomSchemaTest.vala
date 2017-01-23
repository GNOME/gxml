/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* GomSchema.vala
 *
 * Copyright (C) 2017  Daniel Espinosa <esodan@gmail.com>
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

class GomSchemaTest : GXmlTest  {
	public static void add_tests () {
		Test.add_func ("/gxml/gom-schema/read", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR+"/schema-test.xsd");
				assert (f.query_exists ());
				var sch = new GomXsdSchema ();
				message ("XSD Empty: "+sch.write_string ());
				message ("XSD node name: "+sch.node_name);
				assert (sch.local_name == "schema");
				sch.read_from_file (f);
				message ("XSD: "+sch.write_string ());
				assert (sch.simple_type_definitions != null);
				var st = sch.simple_type_definitions.get_item (0) as GomXsdSimpleType;
				assert (st != null);
				assert (st.restriction != null);
				assert (st.restriction.base != null);
				assert (st.restriction.base == "xs:string");
				assert (st.restriction.enumerations != null);
				assert (st.restriction.enumerations.length == 20);
				var enumt1 = st.restriction.enumerations.get_item (0) as GomXsdTypeRestrictionEnumeration;
				assert (enumt1 != null);
				assert (enumt1.value != null);
				assert (enumt1.value == "01");
				var enumt20 = st.restriction.enumerations.get_item (19) as GomXsdTypeRestrictionEnumeration;
				assert (enumt20 != null);
				assert (enumt20.value != null);
				assert (enumt20.value == "99");
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/xsd-array-string/attribute-enumeration", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR+"/schema-test.xsd");
				assert (f.query_exists ());
				var ars = new GomXsdArrayString ();
				ars.simple_type = "MethodCode";
				ars.source = f;
				assert (ars.search ("01"));
				assert (ars.search ("02"));
				assert (ars.search ("03"));
				assert (ars.search ("04"));
				assert (ars.search ("05"));
				assert (ars.search ("06"));
				assert (!ars.search ("07"));
				assert (ars.search ("99"));
			} catch (GLib.Error e) {
				GLib.message ("Error: "+e.message);
				assert_not_reached ();
			}
		});
	}
}
