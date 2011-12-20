dnl Process this file with autoconf to produce a configure script.

AC_CONFIG_MACRO_DIR([m4])
m4_include(m4/introspection.m4)

AC_INIT(gxml, 0.2)

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])

AC_PROG_CC



dnl ***************************************************************************
dnl Internationalization
dnl ***************************************************************************
IT_PROG_INTLTOOL([0.35.0])

GETTEXT_PACKAGE=gxml
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [GETTEXT package name])
AM_GLIB_GNU_GETTEXT


LT_INIT

dnl Check for GLib
GLIB_REQUIRED=2.16.0

PKG_CHECK_MODULES(GLIB, glib-2.0 >= $GLIB_REQUIRED gobject-2.0 >= $GLIB_REQUIRED)
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

dnl Check for vala
VALA_MODULES="libvala-0.14 >= 0.14"

PKG_CHECK_MODULES(VALA, $VALA_MODULES)
AC_SUBST(VALA_CFLAGS)
AC_SUBST(VALA_LIBS)
VALA_BINDIR=`pkg-config $VALA_MODULES --variable=bindir`
AC_SUBST(VALA_BINDIR)
VALA_COMPILER="$VALA_BINDIR/valac"
AC_SUBST(VALA_COMPILER)
VALA_VAPIGEN=`pkg-config $VALA_MODULES --variable=vapigen`
AM_CONDITIONAL(HAVE_VAPIGEN, test x$VALA_VAPIGEN != x"")
VALA_VAPIDIR=`pkg-config $VALA_MODULES --variable=vapidir`
AC_SUBST(VALA_VAPIDIR)

dnl Check for libgee
GEE_REQUIRED="0.6.1"

PKG_CHECK_MODULES(GEE, gee-1.0 >= $GEE_REQUIRED)
AC_SUBST(GEE_CFLAGS)
AC_SUBST(GEE_LIBS)

dnl Check for libxml2
LIBXML_REQUIRED="2.7"

PKG_CHECK_MODULES(LIBXML, libxml-2.0 >= $LIBXML_REQUIRED)
AC_SUBST(LIBXML_CFLAGS)
AC_SUBST(LIBXML_LIBS)

dnl Check for GIO
GIO_MODULES="gio-2.0 >= 2.16"
PKG_CHECK_MODULES(GIO, $GIO_MODULES)
AC_SUBST(GIO_CFLAGS)
AC_SUBST(GIO_LIBS)

dnl Check for GObject Introspection
GOBJECT_INTROSPECTION_CHECK([0.6.7])

AC_ARG_ENABLE([gi-system-install],
    AS_HELP_STRING([--enable-gi-system-install], [Install GObject Introspection files along with system installed files [default=yes]]),
    [enable_gi_system_install=$enableval],[enable_gi_system_install=yes])
AM_CONDITIONAL(ENABLE_GI_SYSTEM_INSTALL, [test x"$enable_gi_system_install" = "xyes"])

AC_OUTPUT([
Makefile
gxml/libgxmldom-0.2.pc
gxml/Makefile
po/Makefile.in])

dnl Print configuration summary
echo ""
echo " Configuration summary for GXml"
echo "   Installation prefix = $prefix"
echo "   Enable GObject Introspection System Install: `if test x$enable_gi_system_install != xno; then echo yes; else echo no; fi`"
echo ""
