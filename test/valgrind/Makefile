VALAC=valac
VALAFLAGS=-g --save-temps --vapidir=../../gxml --pkg gxml
CC=gcc
CFLAGS=-g `pkg-config --cflags --libs glib-2.0 gobject-2.0 gxml gio-2.0`
C_PROGS=unlink_unattached_nodes small2a small2b gfile gobject document document_create_minimal libxml2 document_create_minimal_2 message

all: $(C_PROGS) example attributes small small2 scope supp

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

clean:
	rm example small small2 scope attributes $(C_PROGS) *~ \#*\#

runnew:
	(cd ../.. && make && make install); make clean; make
	make run

# we compile it for users of GXml
supp: *.supp
	cat *.supp > ../../gxml.supp

run: all
	G_SLICE=always-malloc valgrind --leak-check=full --show-reachable=yes --suppressions=libxml2.supp --suppressions=gio.supp --suppressions=gtype.supp --suppressions=glib.supp --num-callers=40 ./document_create_minimal_2

run_nosupp:
	G_SLICE=always-malloc valgrind --leak-check=full --show-reachable=yes --num-callers=40 ./document
