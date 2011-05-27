/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 8; tab-width: 8 -*- */
using GXml.Dom;

class Main {
	public static int main (string[] args) {
		Document doc = new Document.for_path ("test.xml");

		// TODO: want to change Node to something less generic, conflicts with GLib
		// TODO: stop having Attribute and DomNode implement the same iface

		print_node (doc);

		return 1;
	}
	public static void print_node (DomNode node) {
		List<GXml.Dom.DomNode> children = (List<GXml.Dom.DomNode>)node.child_nodes;

		if (node.node_type != 3)
			GLib.stdout.printf ("<%s", node.node_name);
		HashTable<string, Attr> attrs = node.attributes;
		foreach (string key in attrs.get_keys ()) {
			Attr attr = attrs.lookup (key);
			GLib.stdout.printf (" %s=\"%s\"", attr.name, attr.value);
		}

		GLib.stdout.printf (">");
		if (node.node_value != null)
			GLib.stdout.printf ("%s", node.node_value);
		foreach (GXml.Dom.DomNode child in children) {
			// TODO: want a stringification method for Nodes?
			print_node (child);
		}
		if (node.node_type != 3)
			GLib.stdout.printf ("</%s>", node.node_name);
	}
}