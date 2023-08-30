.PHONY: build

all: build

build:
	ESMX_Builder -g esmxBuild.yaml -v --build-jobs=4

clean:
	rm -f *~

cleanall: clean
	rm -rf build install
