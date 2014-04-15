-include $(top_srcdir)/git.mk

# Empty variable to be added elements later
CLEANFILES=


### Library

# Library to create
lib_LTLIBRARIES = libxom-0.4.la

# Vala source code
sources = \
	namespace-info.vala \
	Serializable.vala \
	Enumeration.vala \
	SerializableObjectModel.vala \
	SerializableGeeTreeMap.vala \
	SerializableGeeHashMap.vala \
	SerializableMapKey.vala \
	SerializableGeeDualKeyMap.vala \
	SerializableMapDualKey.vala \
	SerializableGeeArrayList.vala \
	SerializableContainer.vala \
	SerializableJson.vala \
	Serialization.vala


### General Compilation flags
AM_CPPFLAGS = \
	-include $(CONFIG_HEADER) \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DG_LOG_DOMAIN=\"gxml\" \
	$(NULL)

AM_CFLAGS = \
	-g \
	$(GLIB_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GEE_CFLAGS) \
	$(VALA_CFLAGS) \
	$(NULL)

# -Wall   # TODO: add this back when we can properly handle more libxml2/vala warnings


# library flags
AM_VALAFLAGS = \
	$(ERROR_VALAFLAGS) \
	--library=xom-0.4 \
	$(top_srcdir)/vapi/config.vapi \
	--vapidir=. \
	--vapidir=.. \
	--pkg gxml-0.4 \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--includedir gxml \
	--vapi xom-0.4.vapi \
	-H $(builddir)/../xom.h \
	-C \
	$(NULL)

libxom_0_4_la_LIBADD = \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS) \
	$(VALA_LIBS) \
	../libgxml-0.4.la \
	$(NULL)

libxom_0_4_la_LDFLAGS = \
	-version-info "$(LT_CURRENT)":"$(LT_REVISION)":"$(LT_AGE)"

xom_0_4_la_vala.stamp: $(sources)
	$(VALAC) $(AM_VALAFLAGS) $^

libxom_0_4_la_SOURCES=$(sources:.vala=.c)

# .h header file
xom.h: xom_0_4_la_vala.stamp
xomdir= $(includedir)/gxml-$(API_VERSION)/gxml
xom_HEADERS = $(builddir)/../xom.h

# .vapi Vala API file
xom-0.4.vapi: xom_0_4_la_vala.stamp
vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = \
	xom-0.4.vapi \
	xom-0.4.deps \
	$(NULL)

# .pc pkg-config file
pkgconfig_in = xom-0.4.pc.in
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = $(pkgconfig_in:.in=)

EXTRA_DIST = \
	$(sources) \
	$(pkgconfig_in) \
	$(NULL)

GITIGNOREFILES = \
	$(libxom_0_4_la_SOURCES:.vala=.c) \
	libxom_0_4_la_vala.stamp \
	$(NULL)



### GObject Introspection
# dlname:
#   Extract our dlname like libfolks does, see bgo#658002 and bgo#585116
#   This is what g-ir-scanner does.
libxom_dlname = \
        `$(SED) -n "s/^dlname='\([A-Za-z0-9.+-]\+\)'/\1/p" libxom-0.4.la`

# This makes GObject Introspection optional and requires to use --enable-instrospection switch on configure
if HAVE_INTROSPECTION

AM_VALAFLAGS += \
	--gir=Xom-$(API_VERSION).gir

INTROSPECTION_GIRS = Xom-$(API_VERSION).gir
INTROSPECTION_COMPILER_ARGS = --includedir=. -l $(libxom_dlname)

Xom-0.4.gir: libxom-0.4.la

Xom-0.4.typelib: $(INTROSPECTION_GIRS)
	$(INTROSPECTION_COMPILER) $(INTROSPECTION_COMPILER_ARGS)  $< -o $@

girdir = $(INTROSPECTION_GIRDIR)
gir_DATA = $(INTROSPECTION_GIRS)
typelibdir = $(INTROSPECTION_TYPELIBDIR)
typelib_DATA = Xom-0.4.typelib
CLEANFILES += $(gir_DATA) $(typelibs_DATA)
endif

if PLATFORM_WIN32
libxom_0_4_la_LDFLAGS += -export-symbols $(builddir)/libxom-0.4.def
libxom_0_4_la_DEPENDENCIES = libxom-0.4.def

libxom-0.4.def: xom.symbols
	(echo -e EXPORTS; $(CPP) -P $(DEF_FLAGS) - <$(srcdir)/xom.symbols | sed -e '/^$$/d' -e 's/^/ /' -e 's/G_GNUC_[^ ]*//g' | sort) > gxml.def.tmp && mv gxml.def.tmp libxom-0.4.def

libxom-0.4.lib: libxom-0.4.def
	$(DLLTOOL) --dllname libxom-0.4.a --def libxom-0.4.def --output-lib libxom-0.4.lib

libxom-0.4.lib: libxom-0.4.la
libxomlibdir=$(libdir)
libxomlib_DATA=libxom-0.4.lib

libxom-0.4.def: libxom-0.4.la
libxomdefdir=$(libdir)
libxomdef_DATA=libxom-0.4.def

endif



### Files to clean
BUILT_SOURCES = \
	xom_0_4_la_vala.stamp \
	$(builddir)/../xom.h \
	xom-0.4.vapi \
	$(NULL)

CLEANFILES += \
	$(pkgconfig_DATA) \
	namespace-info.vala \
	$(sources:.vala=.c) \
	xom-0.4.vapi \
	$(builddir)/../xom.h \
	$(gir_DATA) \
	$(typelib_DATA)

