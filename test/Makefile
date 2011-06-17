# Need to learn some more autofoo

PKGS=--pkg gio-2.0 --pkg gdom --pkg libxml-2.0 --pkg gee-1.0 --vapidir=../gxml
OPTS= -c -v
DBG= -g --save-temps
LOPTS= `pkg-config --libs glib-2.0 --libs gobject-2.0 --libs libxml-2.0 --libs gee-1.0`

debug:
	valac --disable-warnings ${OPTS} ${PKGS} ${DBG} *.vala
	gcc -o gxml_test -g ${LOPTS} *.o ../gxml/*.o

all: 
	valac ${OPTS} ${PKGS} *.vala 
	gcc -o gxml_test ${LOPTS} *.o ../gxml/*.o

clean:
	rm *~ \#*\# *.c *.o gxml_test || true
