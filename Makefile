current_dir = $(shell pwd)
testdir = test
docsdir = docs
test_names = $(sort $(wildcard $(testdir)/test_*.scad))
srcs = openscad_pvc.scad

all: externals test

doc:
	openscad-docsgen --force --gen-files --project-name "openscad_pvc" --docs-dir $(docsdir) $(srcs)

tests:
	for f in $(test_names); do OPENSCADPATH=$(current_dir) $(testdir)/run-test.sh $${f} || exit $?; done

