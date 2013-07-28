CC=gcc
CFLAGS=`pkg-config --cflags gxml gio-2.0` -g -Wall
LDFLAGS=`pkg-config --libs gxml gio-2.0`
PROGS=create_document create_document_minimal create_document_from_string create_document_from_file create_document_from_path save_document_to_path save_document_to_stream

all: $(PROGS)

clean:
	rm $(PROGS) *.o *~

