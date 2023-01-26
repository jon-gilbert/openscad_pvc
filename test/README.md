# test subdir

A collection of basic tests for `openscad_pvc`

## Running tests

From the project root directory, run `make tests`. You should see output akin to:

```
jong@GILBERT-SAYS-WINDOWS-IS-THE-WORST:~/src/openscad_pvc$ pwd
~/src/openscad_pvc
jong@GILBERT-SAYS-WINDOWS-IS-THE-WORST:~/src/openscad_pvc$ make tests
for f in test/test_00_bosl2.scad test/test_00_object_common_functions.scad test/test_00_openscad_pvc.scad test/test_01_rawspecs.scad test/test_02_list_apply_defaults.scad; do OPENSCADPATH=~/src/openscad_pvc test/run-test.sh ${f} || exit ; done
test/test_00_bosl2.scad:  OK
test/test_00_object_common_functions.scad:  OK
test/test_00_openscad_pvc.scad:  OK
test/test_01_rawspecs.scad:  OK
test/test_02_list_apply_defaults.scad:  OK
jong@GILBERT-SAYS-WINDOWS-IS-THE-WORST:~/src/openscad_pvc$
```

