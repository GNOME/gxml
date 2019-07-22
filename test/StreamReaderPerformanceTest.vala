/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 2 -*- */
/* GomDocumentPerformanceTest.vala
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
    Test.add_func ("/gxml/stream-reader/performance", () => {
    try {
      File dir = File.new_for_path (GXmlTestConfig.TEST_DIR);
      assert (dir.query_exists ());
      File f = File.new_for_uri (dir.get_uri ()+"/test-large.xml");
      assert (f.query_exists ());
      var sr = new GXml.StreamReader (f.read ());
      sr.read ();
    } catch (GLib.Error e) {
      warning ("Error: %s", e.message);
      assert_not_reached ();
    }
  });
  return Test.run ();
}
}
