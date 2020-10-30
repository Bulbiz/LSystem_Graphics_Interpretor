.PHONY: all clean

all: lib main run_test

lib:
	cd lib
	dune build

main:
	cd main
	dune build main.exe

run_test:
	dune runtest

byte: lib
	cd main
	dune build main.bc

clean:
	dune clean
