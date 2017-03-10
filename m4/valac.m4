dnl vapigen.m4
dnl
dnl Copyright 2014 Daniel Espinosa
dnl
dnl This library is free software; you can redistribute it and/or
dnl modify it under the terms of the GNU Lesser General Public
dnl License as published by the Free Software Foundation; either
dnl version 2.1 of the License, or (at your option) any later version.
dnl
dnl This library is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl Lesser General Public License for more details.
dnl
dnl You should have received a copy of the GNU Lesser General Public
dnl License along with this library; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

# VALAC_CHECK([VERSION])
# --------------------------------------
# Check valac existence, sets VAPIDIR, VAPIDIR_UNVERSIONED and HAVE_VALA
m4_define([_VALAC_CHECK_INTERNAL],
[
  AC_REQUIRE([PKG_PROG_PKG_CONFIG])
  AM_PROG_VALAC([$1],[
    VALA_API_VERSION=`$VALAC --api-version`
    VAPIDIR=$datarootdir/vala-$VALAC_API_VERSION/vapi
    VAPIDIR_UNVERSIONED=$datadir/vala/vapi
    have_vala=yes
  ],[
    have_vala=no
    AC_MSG_WARN([No suitable Vala compiler version found])
  ])
  AM_CONDITIONAL([HAVE_VALA],[ test "x$have_vala" = "xyes"])
  AC_SUBST([VAPIDIR])
  AC_SUBST([VAPIDIR_UNVERSIONED])
  AC_SUBST([VALA_API_VERSION])
])

# _VALAC_PKG_CHECK_INTERNAL([API_VERSION], [PKG_VERSION])
# --------------------------------------
m4_define([_VALA_PKG_CHECK_INTERNAL],
[
  AC_REQUIRE([PKG_PROG_PKG_CONFIG])
  AM_PROG_VALAC([$2],[
    VALA_API_VERSION=`$VALAC --api-version`
    have_vala=yes
  ],[
    have_vala=no
    AC_MSG_WARN([No suitable Vala compiler version found])
  ])
  AS_IF([ test "x$2" = "x"], [
        vala_pkg="libvala-$1"
      ], [
        vala_pkg="libvala-$1 >= $2"
      ])
  PKG_CHECK_EXISTS([ $vala_pkg ], [
        VAPIDIR=`$PKG_CONFIG --variable=vapidir libvala-$2`
        VAPIDIR_UNVERSIONED=$vala_datadir/vala/vapi
        VAPIGEN=`$PKG_CONFIG --variable=vapigen libvala-$2`
        VAPIGEN_MAKEFILE=`$PKG_CONFIG --variable=datadir libvala-$2`/vala/Makefile.vapigen
        GEN_INTROSPECT=`$PKG_CONFIG --variable=gen_introspect libvala-$2`
        VALA_GEN_INTROSPECT=`$PKG_CONFIG --variable=vala_gen_introspect libvala-$2`
        vala_datadir=`$PKG_CONFIG --variable=datadir libvala-$2`
        VALA_API_VERSION=`$VALAC --api-version`
        have_vala_gen_introspect=yes
    ], [
      have_vala_gen_introspect=no
      AC_MSG_WARN([libvala package not found. You can't generate vala introspection])
      if test "x$have_vala" = "xyes"; then
        AC_MSG_WARN([VAPI installation directory is not defined'])
      fi
    ])
  AM_CONDITIONAL([HAVE_VALA],[ test "x$have_vala" = "xyes"])
  AM_CONDITIONAL([HAVE_VALA_GEN_INTROSPECT],[ test "x$have_vala" = "xyes"])
  AC_SUBST([VAPIDIR])
  AC_SUBST([VAPIDIR_UNVERSIONED])
  AC_SUBST([VAPIGEN])
  AC_SUBST([VAPIGEN_VAPIDIR])
  AC_SUBST([VAPIGEN_MAKEFILE])
  AC_SUBST([GEN_INTROSPECT])
  AC_SUBST([VALA_GEN_INTROSPECT])
  AC_SUBST([VALA_API_VERSION])
])

# VALAC_CHECK([VERSION])
# --------------------------------------
# Check valac version existence, vapi installation directory
# sets VALAC, VAPIDIR, VAPIDIR_UNVERSIONED, VALAC_API_VERSION, HAVE_VALA
AC_DEFUN([VALAC_CHECK],
[
  _VALAC_CHECK_INTERNAL($1,$2,$3)
]
)
# VALA_PKG_CHECK([API_VERSION],[VERSION])
# Check vala API package and version, sets VALAC, VAPIGEN, VAPIGEN_MAKEFILE
# VAPIGEN_VAPIDIR, VALA_GEN_INTROSPECT, VALA_API_VERSION and HAVE_VALA
AC_DEFUN([VALA_PKG_CHECK], [
  _VALA_PKG_CHECK_INTERNAL($1,$2)
])
