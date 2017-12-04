#  this file with autoconf to produce a configure script.

# Sections
#   Version numbers
#   Setup
#   Dependencies
#   Output


### Version numbers

# Release Version for API related changes
m4_define([project_major_version], [0])
m4_define([project_minor_version], [15])
m4_define([project_micro_version], [90])
m4_define([project_nano_version], [0])

# LT_VERSION for ABI related changes
# From: https://autotools.io/libtool/version.html
# Always increase revision value whenever an interface has been added, removed or changed.
# Increase the current value whenever an interface has been added, removed or changed.
# Increase the age value only if the changes made to the ABI are backward compatible.
# Reset current to 1 and revision and age to 0 if library's name is changed
m4_define([project_lt_current], [1])
m4_define([project_lt_revision], [0])
m4_define([project_lt_age], [0])

# Combine numbers to various version variables (different uses)
#   Display the nano_version only if it's not '0'
m4_define([project_base_version],
          project_major_version.project_minor_version.project_micro_version)
m4_define([project_full_version],
          [m4_if(project_nano_version, [0],
                 project_base_version, project_base_version.project_nano_version)])

# You should set project_released to one in order to mark this as a released version
# and to avoid date on version number
m4_define(project_released, [0])
m4_define([project_maybe_datestamp],
          m4_if(project_released, [1],
                [], [m4_esyscmd([date +.%Y%m%d | tr -d '\n\r'])]))

m4_define([project_version], project_full_version[]project_maybe_datestamp)
m4_define([project_major_minor_version], project_major_version.project_minor_version)
m4_define([project_module_version], project_lt_current)



### Setup

# Initialise autoconf with project details, version
AC_INIT([GXml], project_version,
        [https://bugzilla.gnome.org/browse.cgi?product=gxml], [gxml],
        [http://live.gnome.org/GXml])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_PREREQ([2.65])
AC_COPYRIGHT([Copyright (C) 2012 Richard Schwarting, 2013 - 2016 (C) Daniel Espinosa])

# Configure various files and settings for autoconf/automake
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_SRCDIR([configure.ac])
AM_INIT_AUTOMAKE([1.11 dist-xz no-define
                  no-dist-gzip tar-ustar -Wno-portability])
AM_MAINTAINER_MODE([enable])

AC_PROG_CC
AM_PROG_CC_C_O

# Initialise libtools (handles library creation) with stuff from above
LT_INIT(win32-dll)

PKG_PROG_PKG_CONFIG([0.21])
GLIB_GSETTINGS

AC_SUBST([CFLAGS])
AC_SUBST([CPPFLAGS])
AC_SUBST([LDFLAGS])

LT_CURRENT=project_lt_current
LT_REVISION=project_lt_revision
LT_AGE=project_lt_age
AC_SUBST([LT_CURRENT])
AC_SUBST([LT_REVISION])
AC_SUBST([LT_AGE])

PROJECT_MAJOR_MINOR_VERSION=project_major_minor_version
AC_SUBST([PROJECT_MAJOR_MINOR_VERSION])

# This is used to identify a set of API compatible beatween versions
# - If new versions are compatible with the actual one, just leave this untouched
# - If new version breaks API change it in order to allow paralled installations
#   with old versions. Change name of pc files to use a new API too.
API_VERSION=0.16
API_MAJOR_VERSION=0
API_MINOR_VERSION=16
AC_SUBST([API_VERSION])
AC_SUBST([API_UNDERSCORE_VERSION])
PROJECT_NAME=gxml
AC_SUBST(PROJECT_NAME)
CAMEL_CASE_NAME=GXml
AC_SUBST(CAMEL_CASE_NAME)

PROJECT_VERSION=project_base_version
AC_SUBST([PROJECT_VERSION])

IT_PROG_INTLTOOL([0.35.0])

GETTEXT_PACKAGE=GXml
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"],
                   [The domain to use with gettext])
AM_GLIB_GNU_GETTEXT

GXML_LOCALEDIR=[${datadir}/locale]
AC_SUBST(GXML_LOCALEDIR)

### Dependencies

# TODO: what do we do about libvala's versioning?  set it back to -0.18 and see what happens when we upgraded from Fedora 18 to 19

GLIB_REQUIRED=2.32.0
VALA_REQUIRED=0.34.7
VALA_API_REQUIRED=
LIBVALA_REQUIRED=
GEE_REQUIRED=0.18.0
LIBXML_REQUIRED=2.7
GIO_MODULES="gio-2.0 >= 2.32"
VALADOC_REQUIRED=0.30

PCDEPS="gee-0.8 gio-2.0 libxml-2.0"
AC_SUBST(PCDEPS)

# Check glib
PKG_CHECK_MODULES([GLIB],
                  [glib-2.0 >= $GLIB_REQUIRED
                   gobject-2.0 >= $GLIB_REQUIRED])

# Check for vala
VALAC_CHECK([$VALA_REQUIRED])
#VALA_PKG_CHECK([$VALA_API_REQUIRED],[$LIBVALA_REQUIRED])

# Check for libgee
PKG_CHECK_MODULES(GEE, gee-0.8 >= $GEE_REQUIRED)

# Check for libxml2
PKG_CHECK_MODULES(LIBXML, libxml-2.0 >= $LIBXML_REQUIRED)

# Check for GIO
PKG_CHECK_MODULES(GIO, $GIO_MODULES)

# Check for GObject Introspection
GOBJECT_INTROSPECTION_CHECK([1.32.0])

# Documentation with Valadoc
AC_PATH_PROG(YELP_BUILD, [yelp-build], [no])
AC_PATH_PROG([VALADOC], [valadoc], [no])


docs=yes
AC_ARG_ENABLE(docs,
	AS_HELP_STRING([--disable-docs], [Disable Docs option [default=yes]]),
        [docs=$enableval], [docs="yes"])

have_valadoc=no
if test "x$VALADOC" = "xno" -o "x$docs" = "xno"; then
	have_valadoc="no"
	docs="no"
else
	have_valadoc="yes"
fi
AM_CONDITIONAL([HAVE_VALADOC], [test x$have_valadoc = xyes])

build_gtkdoc=no
PKG_CHECK_MODULES([GTKDOC], gtk-doc,[
    found_gtk_docs=yes
    ],[
    found_gtk_docs=no
    ])
if test x$have_valadoc = xyes -a "x$docs" = "xyes"; then
  if test $found_gtk_docs=xyes; then
    build_gtkdoc=yes
  else
    build_gtkdoc=no
fi
fi
AM_CONDITIONAL([BUILD_GTK_DOCS], [ test "x$build_gtkdoc" = "xyes"])

build_devhelp=no
build_mallard_doc=no
build_gir_doc=no
if test x$have_valadoc = "xyes" -a "x$docs" = "xyes"; then
  if test x$YELP_BUILD != "xno"; then
    build_devhelp=yes
    YELP_HELP_INIT
    build_mallard_doc=yes;
  else
    build_devhelp=no;
  fi
fi
AM_CONDITIONAL([BUILD_DEVHELP_DOCS], [test "x$build_devhelp" = "xyes"])
AM_CONDITIONAL(BUILD_MALLARD_DOCS, [test "$build_mallard_doc" = "yes"])
# This conditional is not set, because a bug to create documented GIR
AM_CONDITIONAL(BUILD_GIR_DOCS, [test "$build_gir_doc" = "yes"])

debug=no
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug], [Enable Debug options [default=no]]),
        [debug=$enableval], [debug="no"])

AM_CONDITIONAL(DEBUG, [test $debug = yes])

performance=no
AC_ARG_ENABLE(performance-tests,
	AS_HELP_STRING([--enable-performance-tests], [Enable Performance tests (slow down Unit Tests processing) [default=no]]),
        [performance=$enableval], [performance="no"])

AM_CONDITIONAL(ENABLE_PERFORMANCE_TESTS, [test $performance = yes])

dnl Check Cross Compile
dnl ******************************
dnl Check for Operating System
dnl ******************************
dnl linklibext is the shared link library extension, which varies by platform

#EXPORT_SYM_REGEX='-export-symbols-regex "^(gxml_|fnYM49765777344607__gxml).*"'
#AC_MSG_CHECKING([for platform])
#platform_win32=no
#linklibext=".so"
case "$host" in
*-mingw*)
#    AC_MSG_RESULT([Win32 - MinGW])
    platform_win32=yes
#    AC_DEFINE([USING_MINGW],[],[Using MinGW])
#    NO_UNDEFINED='-no-undefined'
#    LIBTOOL_EXPORT_OPTIONS=
#    linklibext=".dll"
#    AC_CHECK_TOOL(WINDRES, windres, windres)
#    AC_SUBST(WINDRES)
#    AC_CHECK_TOOL(DLLTOOL, dlltool, dlltool)
#    AC_SUBST(DLLTOOL)
    ;;
*)
#    AC_MSG_RESULT([Unix])
#    NO_UNDEFINED=''
#    LIBTOOL_EXPORT_OPTIONS=$EXPORT_SYM_REGEX
#    ;;
esac
AM_CONDITIONAL(PLATFORM_WIN32, [test x$platform_win32 = xyes])
#AC_SUBST(LIBTOOL_EXPORT_OPTIONS)
#AC_SUBST(NO_UNDEFINED)

### Autoconf generating Makefiles
AC_CONFIG_FILES([
Makefile
gxml/namespace-info.vala
gxml/gxml-$API_VERSION.pc:gxml/gxml.pc.in
gxml/Makefile
test/Makefile
examples/Makefile
examples/c/Makefile
examples/js/Makefile
examples/python/Makefile
examples/vala/Makefile
po/Makefile.in
debian/Makefile
debian/control
debian/copyright
debian/changelog
debian/gir1.2-gxml.install
debian/libgxml-0.install
debian/libgxml-dev.install
])
AC_OUTPUT



# Print configuration summary
echo ""
echo " Configuration summary for GXml-$PROJECT_VERSION"
echo "   Installation prefix:     $prefix"
echo "   GObject Introspection:   $found_introspection"
echo "   Documentation:           ${docs}"
echo "       DevHelp Docs:        ${build_devhelp}"
echo "   Enable Performance Test: $performance"
echo "   Debug:                   $debug"
echo "   Platform:                $host"
echo "   valac:                   $have_vala"
echo ""
