#! /usr/bin/env python
# encoding: utf-8
# Jaap Haitsma, 2008

# /

# the following two variables are used by the target "waf dist"
VERSION = '0.0.1'
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
    conf.env['VALAFLAGS'] = '--vapi=gxml.vapi --deps gxml.deps' # --use-header --header=gxml.h --includedir=`pwd` '

def build(bld):
    bld.recurse('gxml test')
    bld(rule="cp ${SRC} ${TGT}", source="test/test.xml", target="build/test/");
