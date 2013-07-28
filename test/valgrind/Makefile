VALAC=valac
VALAFLAGS=-g --save-temps --vapidir=../../gxml --pkg gxml
CC=gcc
CFLAGS=-g `pkg-config --cflags --libs glib-2.0 gobject-2.0 gxml gio-2.0`

all: unlink_unattached_nodes small2a small2b gobject document example attributes small small2 scope libxml2 supp

example: example.vala
	$(VALAC) $(VALAFLAGS) example.vala -o example

attributes: attributes.vala
	$(VALAC) $(VALAFLAGS) attributes.vala -o attributes

small: small.vala
	$(VALAC) $(VALAFLAGS) small.vala -o small

small2: small2.vala
	$(VALAC) $(VALAFLAGS) small2.vala -o small2

scope: scope.vala
	$(VALAC) $(VALAFLAGS) scope.vala -o scope

unlink_unattached_nodes: unlink_unattached_nodes.c

small2a: small2a.c

small2b: small2b.c

gfile: gfile.c

gobject: gobject.c

document: document.c

libxml2: libxml2.c

clean:
	rm example small small2 small2a small2b gobject document scope attributes unlink_unattached_nodes libxml2 *~ \#*\#

runnew:
	(cd ../.. && make && make install); make clean; make
	make run

run:
	G_SLICE=always-malloc valgrind --leak-check=full --show-reachable=yes --suppressions=libxml2.supp --suppressions=gio.supp --suppressions=gtype.supp --suppressions=glib.supp --num-callers=40 ./example

# we compile it for users of GXml
supp:
	cat *.supp > ../../gxml.supp
