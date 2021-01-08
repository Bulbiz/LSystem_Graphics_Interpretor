.PHONY: all clean

all: lsystems limage lmain runtest

lsystems:
	cd lsystems && dune build

limage:
	cd limage && dune build

lmain:
	cd main && dune build main.exe

runtest:
	cd test && dune runtest

clean:
	dune clean
