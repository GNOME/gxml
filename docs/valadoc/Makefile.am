-include $(top_srcdir)/git.mk

VALADOC_FLAGS = \
	--force \
	--package-name=GXml \
	--package-version=$(PACKAGE_VERSION) \
	$(top_srcdir)/vapi/libxml-2.0.vapi \
	--pkg glib-2.0 \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--vapidir=$(top_srcdir)/gxml \
	--vapidir=$(top_srcdir)/vapi \
	--wiki=$(top_srcdir)/docs/valadoc/wiki

gxml_wiki_pages = \
	concepts \
	glossary \
	debugging

WIKI_FILES = \
	$(top_srcdir)/docs/valadoc/wiki/*.valadoc

sources= \
	$(top_srcdir)/gxml/*.vala

gxmldocdir=$(datadir)/devhelp/books/gxml-$(API_VERSION)
gxmldoc_DATA = \
	gxml/GXml/GXml.devhelp2 \
	gxml/GXml/*.png \
	gxml/GXml/*.html \
	gxml/GXml/*.htm

gxmldocimgdir=$(datadir)/devhelp/books/gxml-$(API_VERSION)/img
gxmldocimg_DATA=\
	gxml/GXml/img/*

gxml-doc:
	$(VALADOC) -o gxml/ --doclet=devhelp $(VALADOC_FLAGS) $(sources)


gxmlgtkdocdir=$(datadir)/gtk-doc/html/gxml
gxmlgtkdoc_DATA= \
	gtk-doc/gxml/html/*

$(gxmldoc_DATA): gxml-doc
$(gxmlgtkdoc_DATA): gxml-gtk-doc

gxml-gtk-doc:
	$(VALADOC) -o gtk-doc/gxml --doclet=gtkdoc \
	-X $(top_builddir)/gxml/gxml.h \
	$(VALADOC_FLAGS) $(sources)

all: gxml-doc gxml-gtk-doc

distclean_dirs = \
	gxml \
	gtk-doc

clean:
	rm -rf $(distclean_dirs)

EXTRA_DIST = \
	$(WIKI_FILES)
