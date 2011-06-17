# Need to learn some more autofoo

PKGS=--pkg gio-2.0 --pkg libxml-2.0 --pkg gee-1.0
OPTS=-c --vapi=gxml.vapi --use-header --header=gxml.h --includedir=`pwd` # want a better solution than that?
DBG= -g --save-temps 

debug:
	valac ${OPTS} ${PKGS} ${DBG} *.vala

all:
	valac ${OPTS} ${PKGS} *.vala

clean:
	rm *~ \#*\# *.c *.o gxml.vapi || true
