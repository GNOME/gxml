#! /usr/bin/env python
# encoding: utf-8
# Jaap Haitsma, 2008

# /

# the following two variables are used by the target "waf dist"
VERSION = '0.0.2'
SHORTVERSION= '0.0'
APPNAME = 'gxml'

# these variables are mandatory ('/' are converted automatically)
top = '.'
out = 'build'

def options(opt):
    opt.load('compiler_c')
    opt.load('vala')

def configure(conf):
    conf.load('compiler_c vala')
    conf.check_cfg(package='glib-2.0', uselib_store='GLIB', atleast_version='2.10.0', mandatory=1, args='--cflags --libs')
    conf.check_cfg(package='gtk+-2.0', uselib_store='GTK', atleast_version='2.10.0', mandatory=1, args='--cflags --libs')
    conf.check_cfg(package='gee-1.0', uselib_store='GEE', atleast_version='0.6.1', mandatory=1, args='--cflags --libs')
    conf.check_cfg(package='libxml-2.0', uselib_store='XML', atleast_version='2.7.8', mandatory=1, args='--cflags --libs')
    # will probably want mroe packages :D
    # conf.env['VALAFLAGS'] = '-g --vapi=gxml.vapi --deps gxml.deps' # --use-header --header=gxml.h --includedir=`pwd` '
    conf.env.CFLAGS = ['-g']

    conf.check_tool ('gcc vala') # do we need to do this?  only saw it in the valadoc example
    conf.check_tool ('valadoc')

def build(bld):
    bld.recurse('gxml test')
    bld(source="gxml.pc.in", install_path="${LIBDIR}/pkgconfig/", SHORTVERSION=SHORTVERSION, VERSION=VERSION)
    bld(rule="cp ${SRC} ${TGT}", source="test/test.xml", target="build/test/")
    bld(rule="rm -rf doc; valadoc --package-name=" + APPNAME + " --package-version=" + VERSION + " --pkg libxml-2.0 --pkg gio-2.0 --pkg gee-1.0 ../gxml/*.vala -o doc");

    ## want to call valadoc, but TypeError encountered by WAF, sigh
    # bld(features='valadoc',
    #     output_dir = './doc',
    #     package_name = APPNAME,
    #     package_version = VERSION,
    #     protected = True, # ?
    #     force = True, # ?
    #     files = bld.path.ant_glob (incl='**/*.vala', flat=False))
