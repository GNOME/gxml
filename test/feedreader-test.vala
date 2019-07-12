/**
 * Copyright (C) 2017 Daniel Espinosa <esodan@gmail.com>
 * This is a GPL software
 *
 * To compile use:
 * valac --pkg gxml-0.14 --pkg gio-2.0 -o ./feedreader feedreader-test.vala
 *
 * To run:
 * ./feedreader
 */

using GXml;

public class FeedReader : GLib.Object {

  public static int main (string[] args) {
    try {
      var f = GLib.File.new_for_uri ("http://www.omgubuntu.co.uk/2017/05/kde-neon-5-10-available-download-comes-plasma-5-10");
      var ostream = new MemoryOutputStream.resizable ();
      ostream.splice (f.read (), GLib.OutputStreamSpliceFlags.CLOSE_SOURCE);
      //message ("Checkout source file:\n=================\n"+(string) ostream.data+"\n=================\n");
      var d = new XHtmlDocument.from_uri ("http://www.omgubuntu.co.uk/2017/05/kde-neon-5-10-available-download-comes-plasma-5-10");
      message (d.to_string ()+"\n=================\n");
      message (d.document_element.node_name+"\n=================\n");
    } catch (GLib.Error e) {
      warning ("Error: "+e.message);
      return 1;
    }
    return 0;
  }

}
