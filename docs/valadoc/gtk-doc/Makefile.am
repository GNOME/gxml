-include $(top_srcdir)/git.mk
CLEANFILES=

VALADOC_FLAGS = \
	--driver $(VALAC_VERSION) \
	--force \
	--package-name=gxml-$(API_VERSION) \
	--package-version=$(PACKAGE_VERSION) \
	--pkg glib-2.0 \
	--pkg gio-2.0 \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--vapidir=$(top_srcdir)/gxml \
	--vapidir=$(top_srcdir)/vapi \
	$(top_srcdir)/vapi/xlibxml-1.0.vapi

sources= \
	$(top_srcdir)/gxml/*.vala

gxmlgtkdocdir=$(datadir)/gtk-doc/html/gxml
gxmlgtkdoc_DATA= \
	gtk-doc/gxml/*.txt \
	gtk-doc/gxml/html/*.bak \
	gtk-doc/gxml/html/*.types \
	gtk-doc/gxml/html/sgml.stamp

$(gxmlgtkdoc_DATA): gxml-gtk-doc

gxml-gtk-doc:
	$(VALADOC) -o gtk-doc/gxml --doclet=gtkdoc \
	-X $(top_builddir)/gxml/gxml.h \
	$(VALADOC_FLAGS) $(sources)

all: gxml-gtk-doc

clean-local: clean-local-gtk-doc
.PHONY: clean-local-gtk-doc
clean-local-gtk-doc:
	-rm -rf gtk-doc
