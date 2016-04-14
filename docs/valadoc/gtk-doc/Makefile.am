-include $(top_srcdir)/git.mk
CLEANFILES=

VALADOC_FLAGS = \
	--driver $(VALAC_VERSION) \
	--force \
	--package-name=GXml-$(API_VERSION) \
	--package-version=$(PACKAGE_VERSION) \
	--pkg glib-2.0 \
	--pkg gio-2.0 \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--vapidir=$(top_srcdir)/gxml \
	--vapidir=$(top_srcdir)/vapi \
	$(top_srcdir)/vapi/xlibxml-1.0.vapi \
	$(top_srcdir)/vapi/config.vapi

sources= \
	$(top_srcdir)/gxml/*.vala

gxmlgtkdocdir=$(datadir)/gtk-doc/html/gxml
gxmlgtkdoc_DATA= \
	gtk-doc/gxml/*.txt \
	gtk-doc/gxml/*.xml \
	gtk-doc/gxml/xml/*.xml \
	gtk-doc/gxml/xml/*.top \
	gtk-doc/gxml/xml/*.bottom \
	gtk-doc/gxml/*.types \
	gtk-doc/gxml/sgml.stamp

$(gxmlgtkdoc_DATA): gxml-gtk-doc

gxml-gtk-doc:
	$(VALADOC) -o gtk-doc/gxml --doclet=gtkdoc \
	-X $(top_builddir)/gxml/gxml.h \
	$(VALADOC_FLAGS) $(sources)

all: gxml-gtk-doc

clean-local:
	rm -rf gtk-doc
	rm -rf gxml
