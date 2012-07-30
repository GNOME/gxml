# inspired by folks' documentation Makefile.am

# distclean_dirs? 
# phony_deps? 

gxml_wiki_pages = \
	concepts \
	glossary \
	debugging \
	$(NULL)

# Huh, gxml_wiki_files isn't defined for a while down below
EXTRA_DIST = $(gxml_wiki_files)

# ---------------------------------------------------------

gxmldocdir=$(datadir)/devhelp/references/gxml
gxmlimgdir=$(datadir)/devhelp/references/gxml/img

gxmlgtkdocdir=$(datadir)/gtk-doc/html/gxml
# gxmlgtkimgdir=$(datadir)/gtk-doc/html/gxml/img

common_doc_files = \
	*.css \
	*.png \
	*.js \
	index.htm \
	*.html \
	$(NULL)

$(gxmldoc_DATA): gxml-docs
# $(gxmldoc_DATA) ($gxmlimg_DATA): gxml-docs
$(gxmlgtkdoc_DATA): gxml-gtk-doc


# -------------------------------------------------------

# to define:
# top_builddir AM_V_GEN VALADOC top_srcdir addprefix? PACKAGE_VERSION

valadoc_flags = \
	--force \
	--package-version $(PACKAGE_VERSION) \
	$(NULL)

#	$(top_srcdir)/gxml/internal.vala 
gxml_doc_files_blacklist = \
	$(NULL)

gxml_doc_files_all = \
	$(wildcard $(top_srcdir)/folks/*.vala) \
	$(NULL)

gxml_wiki_files = \
	$(addprefix wiki/,$(addsuffix .valadoc,$(folks_wiki_pages))) \
	$(NULL)

# TODO: Fix this.  Sorting done to "work around the native doclet portino of bgo#662784" - folks
gxml_doc_files = \
	$(sort \
	$(filter-out $(gxml_doc_files_blacklist),$(gxml_doc_files_all)))

# todo: find out what dependencies I want/need to set
gxml_doc_deps = \
	$(NULL)

valadoc_flags_gxml = \
	$(valadoc_flags) \
	-X $(top_srcdir)/gxml/gxml.h \
	$(addprefix --pkg=,$(gxml_doc_deps)) \
	--vapidir=$(top_srcdir)/gxml \
	--wiki=$(top_srcdir)/docs/wiki \
	$(gxml_doc_files) \
	$(NULL)

gxml-doc: $(gxml_doc_files) $(gxml_wiki_files)
	$(AM_V_GEN)$(VALADOC) \
		-o gxml/ \
		--doclet=devhelp \
		$(valadoc_flags_gxml) \
		$(NULL)


gxml-gtk-doc: $(gxml_doc_files) $(gxml_wiki_files)
	$(AM_V_GEN)$(VALADOC) \
		-X -l -X $(top_builddir)/gxml/.libs/libgxml.so \
		-o gtk-doc/gxml \
		--doclet=gtkdoc \
		$(valadoc_flags_gxml) \
		$(NULL)
