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
	$(top_srcdir)/vapi/config.vapi \
	$(top_srcdir)/vapi/xlibxml-1.0.vapi

sources= \
	$(top_srcdir)/gxml/*.vala


gxmldocdir=$(datadir)/devhelp/books/GXml-$(API_VERSION)
gxmldoc_DATA = \
	GXml/GXml-$(API_VERSION)/GXml-$(API_VERSION).devhelp2 \
	GXml/GXml-$(API_VERSION)/*.png \
	GXml/GXml-$(API_VERSION)/*.html \
	GXml/GXml-$(API_VERSION)/*.htm \
	GXml/GXml-$(API_VERSION)/*.css \
	GXml/GXml-$(API_VERSION)/*.js

gxmldocimgdir=$(datadir)/devhelp/books/GXml-$(API_VERSION)/img
gxmldocimg_DATA=\
	GXml/GXml-$(API_VERSION)/img/*

$(gxmldoc_DATA) $(gxmldocimg_DATA): gxml-doc

gxml-doc:
	$(VALADOC) -o GXml --doclet=devhelp $(VALADOC_FLAGS) $(sources)

clean-local: clean-local-gxml-doc
.PHONY: clean-local-gxml-doc
clean-local-gxml-doc:
	-rm -rf GXml
