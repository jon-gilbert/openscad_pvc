#!/bin/bash

echo -n "$1: ";

# run whatever openscad is set to, specifying an 'echo' format and dumping the output of the script and anything sent to 
# STDERR to STDOUT. 
# From that, exclude lines that are '^include <$' and '^use <$' - developer build 2022.04.10 dumps these and no idea why
# Then, remove any trailing whitespace characters from the full output with a `sed -z`, so we can accurately get the 
# character count of a null-output run. 
openscad -o - -D"LOG_LEVEL=4" --export-format echo --hardwarnings --check-parameters true --check-parameter-ranges false "$1" 2>&1 \
    | egrep -v "^(include|use) <" \
    | sed -ze 's/\s*$//' > testrun_out.txt

# capture openscad's exit status
_es=$?

# default this invocation of run-test.sh to failure 
stat=1

# now check the output: if openscad exited non-zero, or if 
# there's any output from the test run, consider that a failure.
# otherwise, assume success. 
if [ ${_es} -ne 0 -o -s testrun_out.txt ]; then
    echo " FAIL: ";
    echo ">> exit status: ${_es}";
    cat testrun_out.txt;
else 
    echo " OK";
    stat=0
fi

rm testrun_out.txt
exit ${stat}
