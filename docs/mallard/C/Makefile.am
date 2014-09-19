
sources = \
	index.page \
	gxml-serializable.page

JS_FILES= \
	C.css \
	jquery.js \
	jquery.syntax.js \
	jquery.syntax.brush.clang.js \
	jquery.syntax.layout.yelp.js \
	jquery.syntax.core.js \
	yelp.js \
	yelp-note-tip.png

$(JS_FILES): htmldoc

all: htmldoc

htmldoc: $(sources)
	$(YELP_BUILD) html $^

#htmldocdir=$(HTML_DIR)/gxml-$(API_VERSION)

#htmldoc_DATA = \
#	$(sources:.page=.html) \
#	$(JS_FILES)

$(sources:.page=.html): htmldoc

CLEANFILES = \
	$(sources:.page=.html) \
	$(JS_FILES)
