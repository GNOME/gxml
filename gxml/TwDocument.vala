/* Element.vala
 *
 * Copyright (C) 2015  Daniel Espinosa <esodan@gmail.com>
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
 *      Daniel Espinosa <esodan@gmail.com>
 */

using Gee;
using Xml;

/**
 * Class implemeting {@link GXml.Document} interface, not tied to libxml-2.0 library.
 *
 * This class use {@link Xml.TextWriter} to write down XML documents using
 * its contained {@link GXml.Node} childs or other XML structures.
 */
public class GXml.TwDocument : GXml.TwNode, GXml.Document
{
  GXml.Element _root = null;
  Xml.Buffer _buffer;
  construct {
    _name = "#document";
  }
  public TwDocument () {}
  public TwDocument.for_path (string file)
  {
    var f = File.new_for_path (file);
    this.file = f;
  }
  // GXml.Node
  /**
   * {@inheritDoc}
   *
   * All namespaces are stored at {@link GXml.Node.namespaces} owned by
   * this {@link GXml.TwDocument}.
   *
   * First namespace at list, is considered default one for the document. If
   * you haven't declared a namespace for this document or for its root element,
   * and you define one for a child node, this one is added for the first time
   * to document's namespaces, then this becomes the default namespace. To avoid
   * this, you should set a namespace for documento or its root, then childs.
   *
   * Default {@link GXml.Namespace} for a document is the first
   */
  public override bool set_namespace (string uri, string? prefix)
  {
    _namespaces.add (new TwNamespace (this, uri, prefix));
    return true;
  }
  public override GXml.Document document { get { return this; } }
  // GXml.Document
  public bool indent { get; set; default = false; }
  public bool ns_top { get; set; default = false; }
  public bool prefix_default_ns { get; set; default = false; }
  public GLib.File file { get; set; }
  public GXml.Node root {
    get {
      if (_root == null) {
        int found = 0;
        for (int i = 0; i < childs.size; i++) {
          GXml.Node n = childs.get (i);
          if (n is GXml.Element) {
            found++;
            if (found == 1)
              _root = (GXml.Element) n;
          }
        }
        if (found > 1) {
          GLib.warning ("Document have more than one root GXmlElement. Using first found");
        }
      }
      return _root;
    }
  }
  public GXml.Node create_comment (string text)
  {
    var c = new TwComment (this, text);
    return c;
  }
  public GXml.Node create_pi (string target, string data)
  {
    var pi = new TwProcessingInstruction (this, target, data);
    return pi;
  }
  public GXml.Node create_element (string name)
  {
    return new TwElement (this, name);
  }
  public GXml.Node create_text (string text)
  {
    var t = new TwText (this, text);
    return t;
  }
  public GXml.Node create_cdata (string text)
  {
    var t = new TwCDATA (this, text);
    return t;
  }
  public bool save (GLib.Cancellable? cancellable = null)
    throws GLib.Error
  {
    if (file == null) return false;
    return save_to (file, cancellable);
  }
  public bool save_to (GLib.File f, GLib.Cancellable? cancellable = null)
  {
    file = f;
    var buf = new Xml.Buffer ();
    var tw = Xmlx.new_text_writer_memory (buf, 0);
    GLib.Test.message ("Writing down to buffer");
    write_document (tw);
    GLib.Test.message ("Writing down to file");
    GLib.Test.message ("TextWriter buffer:\n"+buf.content ());
    var s = new GLib.StringBuilder ();
    s.append (buf.content ());
    try {
      GLib.Test.message ("Writing down to file: Creating input stream");
      var b = new GLib.MemoryInputStream.from_data (s.data, null);
      GLib.OutputStream ostream;
      if (file.query_exists ()) {
      GLib.Test.message ("Writing down to file: Replacing with backup");
        ostream = file.replace (null, true, GLib.FileCreateFlags.NONE, cancellable);
        ostream.splice (b, GLib.OutputStreamSpliceFlags.NONE);
        ostream.close ();
      } else {
        GLib.Test.message ("Writing down to file: Creating a new File");
        ostream = file.create (GLib.FileCreateFlags.NONE, cancellable);
        ostream.splice (b, GLib.OutputStreamSpliceFlags.NONE);
        ostream.close ();
      }
    } catch (GLib.Error e) {
      GLib.warning ("Error on Save to file: "+e.message);
      return false;
    }
    return true;
  }
  public virtual void write_document (Xml.TextWriter tw)
  {
    tw.start_document ();
    tw.set_indent (indent);
    // Root
    if (root == null) {
      tw.end_document ();
    }
    var dns = new ArrayList<string> ();
#if DEBUG
    GLib.message ("Starting writting Document Root node");
#endif
    start_node (tw, root, true, ref dns);
#if DEBUG
    GLib.message ("Ending writting Document Root node");
#endif
    tw.end_element ();
#if DEBUG
    GLib.message ("Ending Document");
#endif
    tw.end_document ();
    tw.flush ();
  }
  public virtual void start_node (Xml.TextWriter tw, GXml.Node node, bool root, ref Gee.ArrayList<string> declared_ns)
  {
    int size = 0;
#if DEBUG
    GLib.message (@"Starting Node: start Node: '$(node.name)'");
#endif
    if (node is GXml.Element) {
#if DEBUG
    GLib.message (@"Starting Element... '$(node.name)'");
    GLib.message (@"Element Document is Null... '$((node.document == null).to_string ())'");
    GLib.message (@"Namespaces in Element... '$(node.namespaces.size)'");
#endif
      if (root) {
        if (node.document.namespaces.size > 0) {
          var dns = node.document.namespaces.get (0);
          assert (dns != null);
          if (prefix_default_ns) {
            tw.start_element_ns (dns.prefix, node.name, dns.uri);
            declared_ns.add (dns.uri);
#if DEBUG
              GLib.message (@"Declared NS: '$(dns.uri)' Total declared = $(declared_ns.size.to_string ())");
#endif
          }
          else {
            tw.start_element (node.name);
            if (dns.prefix == null)
              tw.write_attribute ("xmlns",dns.uri);// Write default namespace no prefix
            else
              tw.write_attribute ("xmlns:"+dns.prefix,dns.uri);
            // Add to declared namespaces
            declared_ns.add (dns.uri);
#if DEBUG
              GLib.message (@"Declared NS: $(dns.uri) Total declared = $(declared_ns.size.to_string ())");
#endif
          }
          if (node.document.namespaces.size > 1 && node.document.ns_top) {
            for (int i = 1; i < node.document.namespaces.size; i++) {
              GXml.Namespace ns = node.document.namespaces.get (i);
              if (ns.prefix == null) continue;
              tw.write_attribute ("xmlns:"+ns.prefix, ns.uri);
              declared_ns.add (ns.uri);
#if DEBUG
              GLib.message (@"Declared NS: '$(ns.uri)' Total declared = $(declared_ns.size.to_string ())");
#endif
            }
          }
        }
        else
          tw.start_element (node.name);
      }
      else {
        if (node.namespaces.size > 0) {
#if DEBUG
      GLib.message (@"Starting Element: '$(node.name)' start with NS");
#endif
          if (node.document.ns_uri () == node.ns_uri ()) {
#if DEBUG
      GLib.message (@"Node '$(node.name)' Have Default NS");
#endif
            if (node.document.prefix_default_ns)  // Default NS at root element
              tw.start_element_ns (node.ns_prefix (), node.name, null);
            else // Don't prefix. Using default namespace and prefix_default_ns = false
              tw.start_element (node.name);
          }
          else {
#if DEBUG
      GLib.message (@"No default NS in use for Node '$(node.name)'. Ns = '$(node.ns_uri ())'");
#endif
            if (node.ns_prefix () == null && !declared_ns.contains (node.ns_uri ())) {// Its a default ns for children
              tw.start_element_ns (node.ns_prefix (), node.name, node.ns_uri ());
              declared_ns.add (node.ns_uri ());
#if DEBUG
              GLib.message (@"Declared NS: '$(node.ns_uri ())' Total declared = $(declared_ns.size.to_string ())");
#endif
            }
            else {
              if (node.document.ns_top || declared_ns.contains (node.ns_uri ()))
                tw.start_element_ns (node.ns_prefix (), node.name, null);
              else {
                tw.start_element_ns (node.ns_prefix (), node.name, node.ns_uri ());
                declared_ns.add (node.ns_uri ());
#if DEBUG
              GLib.message (@"Declared NS: $(node.ns_uri ()) Total declared = $(declared_ns.size.to_string ())");
#endif
              }
            }
          }
        } else {
#if DEBUG
      GLib.message (@"Starting Element: '$(node.name)' : start no NS: Check for default prefix_default_ns enabled");
#endif
          if (node.document.prefix_default_ns)
            tw.start_element_ns (node.document.ns_prefix (), node.name, null);
          else
            tw.start_element (node.name);
        }
      }
#if DEBUG
    GLib.message (@"Starting Element '$(node.name)': writting attributes");
#endif
      foreach (GXml.Node attr in node.attrs.values) {
        if (attr.namespaces.size > 0) {
#if DEBUG
    GLib.message (@"Starting Element '$(node.name)': write attribute '$(attr.name)' with NS");
#endif
          if (!declared_ns.contains (attr.ns_uri ())) {
            size += tw.write_attribute_ns (attr.ns_prefix (), attr.name, attr.ns_uri (), attr.value);
            declared_ns.add (attr.ns_uri ());
#if DEBUG
              GLib.message (@"Declared NS: $(attr.ns_uri ()) Total declared = $(declared_ns.size.to_string ())");
#endif
          }
          else
            size += tw.write_attribute_ns (attr.ns_prefix (), attr.name, null, attr.value);
        }
        else {
#if DEBUG
    GLib.message (@"Starting Element '$(node.name)': write attribute '$(attr.name)' no NS");
#endif
          size += tw.write_attribute (attr.name, attr.value);
        }
        if (size > 1500)
          tw.flush ();
      }
#if DEBUG
    GLib.message (@"Starting Element: writting Node '$(node.name)' childs");
#endif
      foreach (GXml.Node n in node.childs) {
#if DEBUG
    GLib.message (@"Child Node is: $(n.get_type ().name ())");
#endif
        if (n is GXml.Element) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting Node '$(n.name)'");
#endif
          if (node.namespaces.size > 0) {
            if (node.document.namespaces.size > 0)
              if (node.ns_uri () != node.document.ns_uri ())
                if (n.namespaces.size == 0 && node.ns_prefix == null) // Apply parent ns
                  n.set_namespace (node.ns_uri (), node.ns_prefix ());
          }
          start_node (tw, n, false, ref declared_ns);
          size += tw.end_element ();
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.Text) {
          //GLib.message ("Writting Element's contents");
          size += tw.write_string (node.value);
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.Comment) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting Comment '$(n.value)'");
#endif
          size += tw.write_comment (n.value);
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.CDATA) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting CDATA '$(n.value)'");
#endif
          size += Xmlx.text_writer_write_cdata (tw, n.value);
          if (size > 1500)
            tw.flush ();
        }
        if (n is GXml.ProcessingInstruction) {
#if DEBUG
    GLib.message (@"Starting Child Element: writting ProcessingInstruction '$(n.value)'");
#endif
          size += Xmlx.text_writer_write_pi (tw, ((ProcessingInstruction) n).target, ((ProcessingInstruction) n).data);
          if (size > 1500)
            tw.flush ();
        }
      }
    }
  }
  public override string to_string ()
  {
#if DEBUG
    GLib.message ("TwDocument: to_string ()");
#endif
    Xml.Doc doc = new Xml.Doc ();
    Xml.TextWriter tw = Xmlx.new_text_writer_doc (ref doc);
    write_document (tw);
    string str;
    int size;
    doc.dump_memory (out str, out size);
    return str;
  }
}
