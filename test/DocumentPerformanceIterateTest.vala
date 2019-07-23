/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GXmlDocumentPerformanceIterateTest.vala
 *
 * Copyright (C) 2019 Daniel Espinosa <esodan@gmail.com>
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
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using GXml;
class GXmlTest.Suite : GLib.Object
{
  static int main (string[] args)
  {
    GLib.Intl.setlocale (GLib.LocaleCategory.ALL, "");
    Test.init (ref args);
    Test.add_func ("/gxml/document/performance/iterate", () => {
    try {
      DomDocument d = new Document ();
      File dir = File.new_for_path (GXmlTestConfig.TEST_DIR);
      assert (dir.query_exists ());
      File f = File.new_for_uri (dir.get_uri ()+"/test-large.xml");
      assert (f.query_exists ());
      Test.timer_start ();
      d.read_from_file (f);
      var t = Test.timer_elapsed ();
      message ("Elapsed time: %g", t);
      Test.timer_start ();
      foreach (DomNode n in d.document_element.child_nodes) {
        assert (n.node_name != "");
      }
    } catch (GLib.Error e) {
      warning ("Error: %s", e.message);
      assert_not_reached ();
    }
  });
  return Test.run ();
}
}
