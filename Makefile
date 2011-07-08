

# Need to learn some more autofoo

debug:
	cd gxml/ && make debug
	cd test/ && make debug

all:
	cd gxml/ && make all
	cd test/ && make all

clean:
	cd gxml/ && make clean
	cd test/ && make clean
	rm -rf build
	rm *~