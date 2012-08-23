#!/bin/sh

# Run this to generate all the initial makefiles, etc.  You'll want to
# make sure that you have Makefile.am and configure.ac already.

test -n "$srcdir" || srcdir=`dirname "$0"`
test -n "$srcdir" || srcdir=.

OLDDIR=`pwd`
cd $srcdir

# Set paths if GNOME2_DIR is set
if [ -n "$GNOME2_DIR" ]; then
	ACLOCAL_FLAGS="-I $GNOME2_DIR/share/aclocal $ACLOCAL_FLAGS"
	LD_LIBRARY_PATH="$GNOME2_DIR/lib:$LD_LIBRARY_PATH"
	PATH="$GNOME2_DIR/bin:$PATH"
	export PATH
	export LD_LIBRARY_PATH
fi

# TODO: consider adding specifying automake and aclocal version here ala libfolks

AUTORECONF=`which autoreconf`
if test -z $AUTORECONF; then
        echo "*** No autoreconf found, please intall it ***"
        exit 1
fi

INTLTOOLIZE=`which intltoolize`
if test -z $INTLTOOLIZE; then
        echo "*** No intltoolize found, please install the intltool package ***"
        exit 1
fi

mkdir -p m4

autoreconf -i -f
intltoolize --force --copy --automake
# presumably, this will obvious our tests for:
#   srcdir, autoconf, intltool, xml-i18n-toolize (opt), libtool, glib (gettext), automake, aclocal
#   TODO: test that disabling any of these results in autoreconf and intltoolize handling it
#         gracefully or re-add checks

cd $OLDDIR

# Run ./configure
if [ -z "$NOCONFIGURE" ]; then
    echo Running $srcdir/configure "$@" ...
    $srcdir/configure "$@" \
    && echo Now type \`make\' to compile. || exit 1
else
  echo Skipping configure process.
fi
