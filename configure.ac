#  this file with autoconf to produce a configure script.

# Sections
#   Version numbers
#   Setup
#   Dependencies
#   Output


### Version numbers

# Release Version
m4_define([project_major_version], [0])
m4_define([project_minor_version], [6])
m4_define([project_micro_version], [0])
m4_define([project_nano_version], [0])

# LT_VERSION
#   If library source has changed since last release, increment revision
#   If public symbols have been added, removed or changed since last release,
#     increment current and set revision to 0
#   If public symbols have been added since last release, increment age
#   If public symbols have been removed since last release, set age to 0
m4_define([project_lt_current], [6])
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
AC_COPYRIGHT([Copyright (C) 2012 Richard Schwarting, 2013, 2014 (C) Daniel Espinosa])

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
API_VERSION=0.6
AC_SUBST([API_VERSION])

GXML_VERSION=project_base_version
AC_SUBST([GXML_VERSION])

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
VALA_REQUIRED=0.26.0
LIBVALA_REQUIRED=0.26
GEE_REQUIRED=0.10.5
LIBXML_REQUIRED=2.7
GIO_MODULES="gio-2.0 >= 2.16"
VALADOC_REQUIRED=0.3.1

# Check glib
PKG_CHECK_MODULES([GLIB],
                  [glib-2.0 >= $GLIB_REQUIRED
                   gobject-2.0 >= $GLIB_REQUIRED])

# Check for vala
VALAC_CHECK

# Check for libgee
PKG_CHECK_MODULES(GEE, gee-0.8 >= $GEE_REQUIRED)

# Check for libxml2
PKG_CHECK_MODULES(LIBXML, libxml-2.0 >= $LIBXML_REQUIRED)

# Check for GIO
PKG_CHECK_MODULES(GIO, $GIO_MODULES)


# Check for GObject Introspection
GOBJECT_INTROSPECTION_CHECK([1.32.0])

# Documentation with Valadoc
AC_ARG_ENABLE([docs],
              AS_HELP_STRING([--enable-docs],[Enable documentation generation]),
        [enable_docs=$enableval], [enable_docs=no])
AM_CONDITIONAL([ENABLE_DOCS], [test x$enable_docs = xyes])

have_valadoc=no
if test x$enable_docs = xyes; then
  # make sure the library is new enough and the program exists
  AC_PATH_PROG([VALADOC], [valadoc], [no])
  if test "x$VALADOC" = "xno";
  then
      AC_MSG_RESULT([valadoc documentation not build because not found])
  else
      VAPIDIR=`$PKG_CONFIG --variable=vapidir libvala-$LIBVALA_REQUIRED`
      have_valadoc="yes"
      AC_SUBST(VALADOC)
  fi
fi
AM_CONDITIONAL([HAVE_VALADOC], [test x$have_valadoc = xyes])


AC_ARG_ENABLE([devhelp-docs],
              AS_HELP_STRING([--enable-devhelp-docs],[Enable DevHelp documentation generation]),
        [enable_devhelp_docs=$enableval], [enable_devhelp_docs=no])

AC_ARG_ENABLE([gtk-docs],
              AS_HELP_STRING([--enable-gtk-docs],[Enable gtk-doc documentation generation]),
        [enable_gtk_docs=$enableval], [enable_gtk_docs=no])

AC_ARG_ENABLE([gir-docs],
              AS_HELP_STRING([--enable-gir-docs],[Enable documented GIR generation]),
        [enable_gir_docs=$enableval], [enable_gir_docs=no])

have_gtkdoc=no
if test x$enable_gtk_docs = xyes; then
  if test x$have_valadoc = xyes; then
    PKG_CHECK_MODULES([GTKDOC], gtk-doc)
    have_gtkdoc=yes
  else
    AC_MSG_ERROR([valadoc is required, to generate gtk-doc documentation. Use --enable-valadoc])
  fi
fi


if test x$enable_devhelp_docs = xyes; then
  if test x$have_valadoc = xno -o x$have_gtkdoc = xno; then
    AC_MSG_ERROR([valadoc and gtk-doc is required, to generate devhelp documentation. Use --enable-valadoc and --enable-gtk-doc])
  fi
fi

if test x$enable_gir_docs = xyes; then
  if test x$have_valadoc = xno; then
    AC_MSG_ERROR([valadoc is required, to generate GIR documentation. Use --enable-valadoc and --enable-gtk-doc])
  fi
fi

dnl Find yelp-build program
enable_mallard_doc="no"
girdocs=no
devhelpdocs=no
gtkdocs=no
if test x$enable_docs = xyes; then
  AC_PATH_PROG(YELP_BUILD, [yelp-build], [no])
  if test "x$YELP_BUILD" = "xno";
  then
      AC_MSG_RESULT([Mallard documentation not build because yelp-build has not been found])
  else
      YELP_HELP_INIT
      AC_SUBST(YELP_BUILD)
      enable_mallard_doc="yes"
  fi
  if test x$enable_devhelp_docs = xyes; then
    devhelpdocs=yes
  fi
  if test x$enable_gtk_docs = xyes; then
    gtkdocs=yes
  fi
  if test x$enable_gir_docs = xyes; then
    if test x$found_introspection = xyes; then
      girdocs=yes
    else
      girdocs="no, use --enable-introspection"
    fi
  fi
fi
AM_CONDITIONAL(ENABLE_MALLARD_DOC, [test "$enable_mallard_doc" = "yes"])
AM_CONDITIONAL([ENABLE_GIR_DOCS], [test "x$girdocs" = "xyes"])
AM_CONDITIONAL([ENABLE_DEVHELP_DOCS], [test "x$devhelpdocs" = "xyes"])
AM_CONDITIONAL([ENABLE_GTK_DOCS], [test "x$gtkdocs" = "xyes"])

debug=no
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug], [Enable Debug options [default=no]]),
        [debug=$enableval], [debug="no"])

AM_CONDITIONAL(DEBUG, [test $debug = yes])

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
gxml/gxml-0.6.pc
gxml/Makefile
test/Makefile
test/test.xml
test/test-large.xml
test/test_invalid.xml
test/test_out_path_expected.xml
test/test_out_stream_expected.xml
test/test_with_ns.xml
test/tests-config.vala
docs/Makefile
docs/valadoc/Makefile
docs/valadoc/devhelp/Makefile
docs/valadoc/gtk-doc/Makefile
docs/valadoc/gir-docs/Makefile
docs/mallard/Makefile
docs/mallard/C/Makefile
examples/Makefile
examples/c/Makefile
examples/js/Makefile
examples/python/Makefile
examples/vala/Makefile
po/Makefile.in
])
AC_OUTPUT



# Print configuration summary
echo ""
echo " Configuration summary for GXml-$GXML_VERSION"
echo "   Installation prefix:   $prefix"
echo "   GObject Introspection: $found_introspection"
echo "   Documentation:         ${enable_docs}"
echo "       DevHelp Doc:       `if test x${devhelpdocs} = xyes; then echo yes; else echo no; fi`"
echo "       Gtk-Doc:           `if test x${gtkdocs} = xyes; then echo yes; else echo no; fi`"
echo "       GIR Documented:    $girdocs"
echo "   Platform:              $host"
echo ""
