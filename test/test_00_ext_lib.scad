include <BOSL2/std.scad>
assert(BOSL_VERSION);

include <object_common_functions.scad>
o = Object("Test", [["k", "i"]], ["k", 1]);
assert(obj_is_obj(o));

