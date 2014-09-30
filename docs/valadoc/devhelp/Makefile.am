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
	--vapidir=$(top_srcdir)/vapi

sources= \
	$(top_srcdir)/gxml/*.vala


gxmldocdir=$(datadir)/devhelp/books/gxml-$(API_VERSION)
gxmldoc_DATA = \
	gxml/gxml-$(API_VERSION)/gxml-$(API_VERSION).devhelp2 \
	gxml/gxml-$(API_VERSION)/*.png \
	gxml/gxml-$(API_VERSION)/*.html \
	gxml/gxml-$(API_VERSION)/*.htm \
	gxml/gxml-$(API_VERSION)/*.css \
	gxml/gxml-$(API_VERSION)/*.js

gxmldocimgdir=$(datadir)/devhelp/books/gxml-$(API_VERSION)/img
gxmldocimg_DATA=\
	gxml/gxml-$(API_VERSION)/img/*

$(gxmldoc_DATA) $(gxmldocimg_DATA): gxml-doc

gxml-doc:
	$(VALADOC) -o gxml --doclet=devhelp $(VALADOC_FLAGS) $(sources)

clean-local: clean-local-gxml-doc
.PHONY: clean-local-gxml-doc
clean-local-gxml-doc:
	-rm -rf gxml
