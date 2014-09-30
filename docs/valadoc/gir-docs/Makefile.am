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

distclean_dirs=

docgirdir = $(INTROSPECTION_GIRDIR)
docgir_DATA = GXml-$(API_VERSION).gir

$(docgir_DATA): girdoc

girdoc:
	$(VALADOC) -o . $(VALADOC_FLAGS) \
	--gir $(top_builddir)/gxml/GXml-$(API_VERSION).gir $(sources)

CLEANFILES+= $(gxmldocgir_DATA)

#endif


