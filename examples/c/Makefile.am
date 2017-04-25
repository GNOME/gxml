
EXTRA_DIST = bookshelf.xml Makefile.example document_create.c document_new.c document_new_from_file.c document_new_from_path.c document_new_from_string.c document_new_minimal.c document_properties.c document_save_to_path.c document_save_to_stream.c node.c comment.c character_data.c text.c node_list.c element.c

noinst_PROGRAMS=document_new

document_new_SOURCES= document_new.c
document_new_CFLAGS= \
	$(GLIB_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GEE_CFLAGS) \
	-I$(top_builddir)

document_new_LDFLAGS= \
	$(GLIB_LDFLAGS) \
	$(LIBXML_LDFLAGS) \
	$(GIO_LDFLAGS) \
	$(GEE_LDFLAGS) \
	$(top_builddir)/gxml/libgxml-$(API_VERSION).la

document_new_LDADD=\
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS)
