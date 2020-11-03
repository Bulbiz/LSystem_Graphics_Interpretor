.PHONY: all clean

all: lsystems main run_test

lsystems:
	cd lsystems
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
