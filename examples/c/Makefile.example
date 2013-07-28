CC=gcc
CFLAGS=`pkg-config --cflags gxml gio-2.0` -g -Wall
LDFLAGS=`pkg-config --libs gxml gio-2.0`
PROGS=document_create document_create_minimal document_create_from_string document_create_from_file document_create_from_path document_save_to_path document_save_to_stream document_properties document_factory

all: $(PROGS)

clean:
	rm $(PROGS) *.o *~

