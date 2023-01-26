// LibFile: openscad_pvc.scad
//   Modules and functions to create PVC pipe models within OpenSCAD. Models have their 
//   dimensions and sizes pulled from existing specifications, organized by PVC schedule 
//   and size, so they should be sized the same as parts found in a hardware store.
//   PVC parts modeled here come with simple BOSL2 attachable endpoints, so joining parts 
//   together relatively easy when constructing pipe layouts or new component parts.
//
// Includes:
//   include <openscad_pvc.scad>
//
// CommonCode:
//   $fn = 100;
//   pvc_a = pvc_spec_lookup(schedule=40, dn="DN20");
//   pvc_b = pvc_spec_lookup(schedule=40, dn="DN10");
//

include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <object_common_functions.scad>


// Section: PVC Specification Selection
//   To get consistent dimensions for parts and components when modeling PVC, you have to 
//   know the diameter and threading information for the size of PVC you're working with. 
//   Those dimensions are driven not only by the diameter of the pipe you're using, but 
//   the schedule rating for that pipe. There's dozens of sizes across the PVC schedules, 
//   and rather than make you look it all up, *those dimensions are pre-compiled and 
//   provided here.*
//   .
//   Selecting the specification you want is made easy with `pvc_spec_lookup()`, which 
//   gives you a PVC object - a self-contained block of dimension information that you can 
//   pass to the part modules below as an argument. If you're working with multiple sizes 
//   of PVC pipe, that's ok: you can lookup and use as many different specifications within 
//   your .scad as you need. 
//   .
//   In its most common usage, you call `pvc_spec_lookup()` to get the specs for 
//   a pipe of a particular size and schedule, then use those specs to create one or 
//   more parts to join together, something akin to:
//   ```
//   pvc = pvc_spec_lookup(40, name="1/4");
//   pvc_elbow(pvc)
//      attach("A", "B")
//        pvc_pipe(pvc);
//   ```
// 
// Function: pvc_spec_lookup()
// Usage:
//   pvc = pvc_spec_lookup(schedule, <name=undef>, <dn=undef>, <od=undef>, <wall=undef>);
//
// Description:
//   Given a PVC schedule `schedule` and one or more named selectors, search through the `PVC_Specs` list
//   constant and find the PVC object whose attributes match the schedule and selectors, and 
//   return the PVC object `pvc`. 
//   .
//   The `pvc` object is then suitable for use throughout the modules in this library.
//   .
//   It is possible to call `pvc_spec_lookup()` with valid arguments and have no matching PVC object returned. 
//   For example, `pvc_spec_lookup(40, name="1/8")` should correctly return the schedule-40 pipe spec for DN8, 
//   a 1/8-inch-diameter pipe; however, `pvc_spec_lookup(120, name="1/8")` will return an error, because schedule-120
//   doesn't have a 1/8-inch-diameter pipe. In these cases, `pvc_spec_lookup()` will throw an assertion error. 
//   .
//   It may be possible to call `pvc_spec_lookup()` with valid arguments and have multiple matching PVC objects returned. 
//   For example, `pvc_spec_lookup(40, wall=2.4)` may return two different small-diameter piping specifications. 
//   In these cases, `pvc_spec_lookup()` will throw an assertion error.
//
// Arguments:
//   schedule = A PVC schedule, one of `PVC_KNOWN_SCHEDULES`, as a number. No default
//   ---
//   name = The nominal "name" of the PVC size (eg, `3/8`, `1`, `2 1/2`), as a character string. Default: `undef`
//   dn = The "DN" specifier of the PVC size (eg, `DN10`, `DN125`), as a character string. Default: `undef`
//   od = The outer-diameter of the PVC, in `mm` (eg, `10.3`). Default: `undef`
//   wall = The wall thickness of the PVC, in `mm` (eg, `2.41`). Default: `undef`
///   tl = The thread-length of the PVC specification, in `mm` (eg, `4.3`). Default: `undef`
///   pitch = The thread pitch of the PVC specification, in `mm` (eg, `1.1`). Default: `undef`
//
// Continues:
//   It is an error to call `pvc_spec_lookup()` with a schedule that isn't listed in `PVC_KNOWN_SCHEDULES`. 
//   .
//   It is an error to call `pvc_spec_lookup()` without at least *one* of `name`, `dn`, `od`, or `wall` defined.
//
// Example: a basic lookup example using the nominal PVC size 
//   pvc = pvc_spec_lookup(40, name="3/4");
//   echo( obj_debug_obj(pvc) );
//   // ...yields:
//   // ECHO: "0: _toc_: PVC
//   // 1: schedule (i): 40
//   // 2: name (s): 3/4
//   // 3: od (i): 26.7
//   // 4: wall (i): 2.87
//   // 5: dn (s): DN20
//   // 6: tl (i: 10): undef
//   // 7: pitch (i: 0.9407): undef"
//
// Example: a basic lookup example using the "DN" of the specification
//   pvc = pvc_spec_lookup(40, dn="DN20");
//   echo( obj_debug_obj(pvc) );
//   // ...yields:
//   // ECHO: "0: _toc_: PVC
//   // 1: schedule (i): 40
//   // 2: name (s): 3/4
//   // 3: od (i): 26.7
//   // 4: wall (i): 2.87
//   // 5: dn (s): DN20
//   // 6: tl (i: 10): undef
//   // 7: pitch (i: 0.9407): undef"
//
// Example(3D): lookup a basic specification, and use that object to make a pipe that is 30mm long:
//   pvc = pvc_spec_lookup(40, dn="DN20");
//   pvc_pipe(pvc, 30);
//
function pvc_spec_lookup(schedule, name=undef, dn=undef, od=undef, wall=undef, tl=undef, pitch=undef) = 
    assert(in_list(schedule, PVC_KNOWN_SCHEDULES),
        str("pvc_spec_lookup(): 'schedule' is a required argument, and must be one of ", PVC_KNOWN_SCHEDULES))
    assert(_defined([name, dn, od, wall, tl, pitch]),
        str("pvc_spec_lookup(): at least one of 'name', 'dn', 'od', or 'wall' must be specified."))
    let(
        selectors = list_remove_values(
            [
                ["schedule", schedule],
                (_defined(name))  ? ["name", str(name)] : undef,
                (_defined(dn))    ? ["dn", str(dn)]     : undef,
                (_defined(od))    ? ["od", od]          : undef,
                (_defined(wall))  ? ["wall", wall]      : undef,
                (_defined(tl))    ? ["tl", tl]          : undef,
                (_defined(pitch)) ? ["pitch", pitch]    : undef
                ],
            undef,
            all=true)
    )
    assert(len(selectors) > 1,
        str("pvc_spec_lookup(): no sufficent selectors could be gleaned."))
    let(
        speclist = obj_select_by_attrs_values(PVC_Specs, selectors)
    )
    assert(len(speclist) == 1,
        str("pvc_spec_lookup(): exactly one specification was expected, got ",
            len(speclist), 
            " instead. ",
            (len(speclist) < 1)
                ? "The specification you are looking for may not exist."
                : "If more than one spec was found, set additional selectors to narrow the return list."
            ))
    speclist[0];



// Section: PVC Component Part Modules
//   These are modules that produce PVC parts such as pipes, elbows, and tees.
//   .
//   All of the part modules require at least one PVC object. See the above function 
//   `pvc_spec_lookup()` for details on how to select a PVC object with which
//   to work.
//   .
//   In all cases, they provide BOSL2-attaching and positioning. If you're unfamiliar with how 
//   attachables and anchoring works within BOSL2, a good (but dense) starting point can 
//   be found at https://github.com/revarbat/BOSL2/wiki/Tutorial-Attachments .  The 
//   common module arguments `anchor`, `spin`, and `orient` all work the same way, and 
//   they work in the manner described in that attachments tutorial. 
//   .
//   In their most simple form, parts are joined by attaching one to another. For example, 
//   creating a simple flange-pipe-elbow-cap layout is as simple as:
//   ```
//   pvc = pvc_spec_lookup(schedule=40, dn="DN20");
//   pvc_flange(pvc)
//       attach("B", "A") 
//           pvc_pipe(pvc, 30)
//               attach("B", "A") 
//                   pvc_elbow(pvc, 90)
//                       attach("B", "A")
//                           pvc_cap(pvc);
//   ```
//   ...yielding something that looks like:
// Figure(3D): 
//   pvc_flange(pvc_a)
//       attach("B", "A") 
//           pvc_pipe(pvc_a, 30)
//               attach("B", "A") 
//                   pvc_elbow(pvc_a, 90)
//                       attach("B", "A")
//                           pvc_cap(pvc_a);
//

// Module: pvc_pipe()
// Usage:
//   pvc_pipe(pvc, length);
//   pvc_pipe(pvc, length, <ends=["spigot", "spigot"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc` and a length `length`, create a PVC pipe `length` long, with the 
//   dimensions provided in the `pvc` object. 
//   .
//   The pipe model will have two named anchors, `A`, and `B`. When oriented `UP` (the default), 
//   `A` will be the endpoint at the bottom of the pipe, and `B` will be at its top. 
//   Anchors are inset one-half of the PVC's thread-length, making joining with other 
//   parts simple (eg, `pvc_pipe(p, 10) attach("A", "A") pvc_elbow(pvc)`).
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_pipe(pvc_a, 30);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   length = The length of the pipe
//   ---
//   ends = A list of the two end types, `A` and `B`. Default: `["spigot", "spigot"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the pipe, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the pipe, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_pipe(pvc_a, 30) show_anchors(std=false, s=40);
//
// Continues:
//   It is not an error to specify end types other than "spigot" for pipes; however, it's 
//   not really a thing that happens a lot in the real world, y'know? You don't really 
//   see a lot of threaded pipes: you see pipes that are mated to parts that have threads. 
//   `pvc_pipe()` won't throw an error if one of your ends isn't a spigot, but I'd try to avoid it.
//
// Example: a basic pipe
//   pvc_pipe(pvc_a, 30);
//
// Todo:
//   When the merge at https://github.com/openscad/openscad/pull/4185 is released to general-availability, reenable the animated spin of the model in Figure-1 here, and throughout the other part modules in this library.
//
module pvc_pipe(pvc, length, ends=[], 
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    od = pvc_od(pvc);
    id = pvc_id(pvc);
    tl = pvc_tl(pvc);
    wall = pvc_wall(pvc);
    transition_len = tl * 0.1;

    truncated_len = length - (tl * 2);
    assert(truncated_len >= 0,
        str("pvc_pipe(): the length of the pipe is too short: ", 
            truncated_len));

    ends_ = list_apply_defaults(ends, ["spigot", "spigot"]);

    ep_a_od = (ends_[0] == "socket") ? pvc_socket_od(pvc) : pvc_od(pvc);
    ep_b_od = (ends_[1] == "socket") ? pvc_socket_od(pvc) : pvc_od(pvc);
    ep_a_id = (ends_[0] == "socket") ? pvc_socket_id(pvc) : pvc_id(pvc);
    ep_b_id = (ends_[1] == "socket") ? pvc_socket_id(pvc) : pvc_id(pvc);
    
    anchors = [
        named_anchor("A", apply(up(tl/2) * down(length/2), CENTER), DOWN, 0),
        named_anchor("B", apply(down(tl/2) * up(length/2), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=od, h=length, anchors=anchors) {
        diff("pvc_rem__full")
            tube(od=od, wall=wall, l=truncated_len, anchor=CENTER) {
                attach(BOTTOM, "_j_down")
                    pvc_part_component(pvc, end=ends_[0], length=0);  // A
                attach(TOP, "_j_down")
                    pvc_part_component(pvc, end=ends_[1], length=0);  // B
                attach(CENTER, CENTER)
                    tag("pvc_rem__full")
                        cylinder(d=id, h=length);
            }
        children();
    }
}


// Module: pvc_elbow()
// Usage:
//   pvc_elbow(pvc, angle);
//   pvc_elbow(pvc, angle, <ends=["socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
// 
// Description:
//   Given a PVC object `pvc`, and a bending number of degrees `angle`, create a 
//   PVC elbow component. `angle` can be any reasonable number of degrees including `180`, 
//   though beyond that and the viability of the elbow is questionable. 
//   .
//   The elbow will have two named anchors `A` and `B`. When oriented `UP` (the default), 
//   `A` will be the endpoint at the bottom of the elbow, and `B` will be at whatever 
//   angle the elbow outputs. 
//   The `ends` list argument specifies what endtypes will be created for the `A` and `B` 
//   pipe ends, respectively. If `ends` is unspecified, or if any of the positional 
//   list elements are `undef`, then those unspecified ends will be a socket. 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_elbow(pvc_a, 45);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   angle = The angle in degrees to bend the elbow
//   ---
//   ends = A list of the two end types, `A` and `B`. Default: `["socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the pipe, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the pipe, angled to the right, oriented at `angle` degrees
// Figure: Available named anchors
//   expose_anchors() pvc_elbow(pvc_a, 45) show_anchors(std=false, s=40);
//
// Continues:
//   Because of the odd shape for this model, the cardinal anchoring points for `pvc_elbow` won't 
//   reflect the full envelope of the model; don't assume anchoring `RIGHT` or `TOP` will be at the models 
//   rightmost or topmost position.
//
// Example: a basic elbow
//   pvc_elbow(pvc_a, 45);
//
// Example: an 90-degree elbow with female threads
//   pvc_elbow(pvc_a, 90, ends=["fipt", "fipt"]);
//
module pvc_elbow(pvc, angle, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket"]);
    od = pvc_od(pvc);
    id = pvc_id(pvc);
    tl = pvc_tl(pvc);
    segment_len = tl + 1;
    curved_region = right(od/2, p=difference( circle(d=od), circle(d=id) ));
    
    anchors = [
        named_anchor("A", [0, 0, -1 * segment_len/2 + tl/2], DOWN, 0),
        // translating the anchor point for 'B' looks a bit nuts; here's whats happening:
        // we start at the center of the lower pipe segment, and move up() half the length of the 
        // segment to the center of the top of the pipe (or, the center of the bottom of the 
        // sweep'd segment). From there, we rotate `angle` degrees, using a pivot point that 
        // that is the right+top edge of the lower pipe. That rotation puts us at the center 
        // of the bottom of the upper pipe. From there, we move up() half the length of the segment 
        // again. To get the anchor in the center of the threaded length, we have to then rotate 
        // using the base of the upper pipe as a pivot: so, we re-calculate all those moves 
        // again to get the yrot() `cp`, and rotate `angle` degrees again. 
        // For those of you asking "why don't you just create a sphere and angle pipes and 
        // and anchors from that?", my answer is, because it's hella ugly. 
        named_anchor("B", 
            apply(
                    yrot(angle, cp=apply(
                        yrot(angle, cp=apply(up(segment_len/2) * right(od/2), CENTER))
                        * up(segment_len/2),
                        CENTER))
                    * up(segment_len/2)
                    * yrot(angle, cp=apply(up(segment_len/2) * right(od/2), CENTER)) 
                    * up(segment_len/2),
                CENTER), 
            apply(yrot(angle), UP), 0),
    ];
    attachable(anchor, spin, orient, d=od, h=segment_len, anchors=anchors) {
        diff("pvc_rem__full")
            union() {
                pvc_part_component(pvc, end=ends_[0], length=1, anchor=CENTER, orient=DOWN);
                    right(od/2)
                        zrot(180)
                            up(segment_len/2)
                                rotate_sweep(curved_region, angle, spin=0, orient=FWD, anchor=CENTER);
                up(segment_len/2)
                    right(od/2)
                        yrot(angle)
                            tag("pvc_rem__full")
                                sphere(d=0.0001) 
                                    attach(TOP, "_j_down")
                                        left(od/2)
                                            tag("")
                                                pvc_part_component(pvc, length=1, end=ends_[1]); 
            }
        children();
    }
}



// Module: pvc_wye()
// Usage:
//   pvc_wye(pvc);
//   pvc_wye(pvc, <ends=["socket", "socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object, create a wye PVC part: essentially, a pipe with two endpoints, and a 
//   segment of pipe jutting out at 45-degrees from the center ending in a third endpoint. 
//   .
//   The wye will have three named anchors, `A`, `B`, `C`. When oriented `UP` (the default),
//   `A` will be the endpoint at the bottom of the wye, `B` will be at its top, and `C` will 
//   be the extension angling to the right. 
//   The `ends` list argument specifies what endtypes will be created for `A`, `B`, `C` endtypes, 
//   respectively. Absent endtypes from `ends` will default to "socket". 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_wye(pvc_a);
// 
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the three end types, `A`, `B`, & `C`. Default: `["socket", "socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the main pipe, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the main pipe, positioned at its top, oriented upwards
//   C = The right-hand out-jutting endpoint, angled to the right, oriented upwards at 45-degrees
// Figure: Available named anchors
//   expose_anchors() pvc_wye(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   Because of the odd shape for this model, the cardinal anchoring points for `pvc_wye()` won't 
//   reflect the full envelope of the model; don't assume anchoring `RIGHT` or `TOP` will be at the models 
//   rightmost or topmost position.
//
// Example: a simple wye
//   pvc_wye(pvc_a);
//
module pvc_wye(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket", "socket"]);
    od = pvc_od(pvc);
    id = pvc_id(pvc);
    tl = pvc_tl(pvc);
    part_addl = tl * 4; 
    segment_len = tl + part_addl;
    total_part_height = sum([ 
        segment_len,
        tl,
        part_addl - tl * 2
        ]);

    anchors = [
        named_anchor("A", apply(up(tl/2) * down(part_addl - tl) * down(tl), CENTER), DOWN, 0),
        named_anchor("B", apply(up(part_addl + tl/2) * down(tl), CENTER), UP, 0),
        named_anchor("C", apply(yrot(45, cp=apply(down(tl), CENTER)) * up(part_addl + tl/2) * down(tl), CENTER), UP+RIGHT, 0),
    ];
    attachable(anchor, spin, orient, d=od, h=total_part_height, anchors=anchors) {
        down(tl)
        diff("pvc_rem__full") {
            tag("pvc_rem__full")
                sphere(d=0.001, anchor=CENTER) {
                    attach(BOTTOM, "_j_down")
                        tag("") pvc_part_component(pvc, length=part_addl - tl * 2, end=ends_[0]); // A
                    attach(TOP, "_j_down")
                        tag("") pvc_part_component(pvc, length=part_addl, end=ends_[1]); // B
                    attach(RIGHT+TOP, "_j_down")
                        tag("") pvc_part_component(pvc, length=part_addl, end=ends_[2]); // C
                }
        }
        children();
    }
}


// Module: pvc_tee()
// Usage:
//   pvc_tee(pvc);
//   pvc_tee(pvc, <ends=["socket", "socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a PVC tee component. A tee is essentially a length of pipe
//   with a outspout extending to the right at 90-degrees. 
//   .
//   The tee will have three named anchors, `A`, `B`, `C`. When oriented `UP` (the default),
//   `A` will be the endpoint at the bottom of the tee, `B` will be at its top, and `C` will 
//   be the extension to the right. 
//   The `ends` list argument specifies what endtypes will be created for `A`, `B`, `C` endtypes, 
//   respectively. Absent endtypes from `ends` will default to "socket". 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_tee(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the three end types, `A`, `B`, & `C`. Default: `["socket", "socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the main pipe, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the main pipe, positioned at its top, oriented upwards
//   C = The right-hand out-jutting endpoint, angled to the right, oriented rightwards
// Figure: Available named anchors
//   expose_anchors() pvc_tee(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   Because of the odd shape for this model, the cardinal anchoring points for `pvc_tee()` won't 
//   reflect the full envelope of the model; don't assume anchoring `RIGHT` or `LEFT` will be at the models 
//   rightmost or leftmost position.
//
// Example: a simple tee
//   pvc_tee(pvc_a);
//
// Example: a tee with a variety of end types
//   pvc_tee(pvc_a, ends=["socket", "mipt", "fipt"]);
//
module pvc_tee(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket", "socket"]);
    od = pvc_od(pvc);
    id = pvc_id(pvc);
    tl = pvc_tl(pvc);
    tee_pipe_len = sum([ tl,  pvc_socket_od(pvc) ]);
    total_pipe_len = tee_pipe_len * 2;
    total_tee_height = sum([ tl, od/2, od/2, tl ]);

    anchors = [
        named_anchor("A", [0, 0, -1 * total_tee_height/2 + tl/2], DOWN, 0),
        named_anchor("B", [0, 0, total_tee_height/2 - tl/2], UP, 0),
        named_anchor("C", [tl/2 + od/2, 0, 0], RIGHT, 0)
    ];
    attachable(anchor, spin, orient, d=od, h=total_tee_height, anchors=anchors) {
        diff("pvc_rem__full", "pvc_keep__full")
            pvc_part_component(pvc, end=ends_[0], length=od/2, anchor=BOTTOM) { // A
                attach("_j_down", "_j_down")
                    pvc_part_component(pvc, end=ends_[1], length=od/2); // B
                attach("_j_right", "_j_down")
                    pvc_part_component(pvc, length=od/2, end=ends_[2]); // C
            }
        children();
    }
}


// Module: pvc_corner()
// Usage:
//   pvc_corner(pvc);
//   pvc_corner(pvc, <ends=["socket", "socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object, create a corner part. A corner is three endpoints at 90-degrees from 
//   each other, pointing forward, upwards, and rightwards. 
//   .
//   The corner will have three named anchors, `A`, `B`, `C`. When oriented `UP` (the default),
//   `A` will be the endpoint at the front of the corner, `B` will be at its top, and `C` will 
//   be pointing to the right. 
//   The `ends` list argument specifies what endtypes will be created for `A`, `B`, `C` endtypes, 
//   respectively. Absent endtypes from `ends` will default to "socket". 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_corner(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the three end types, `A`, `B`, & `C`. Default: `["socket", "socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the three endpoints of the corner, positioned at its front, oriented forwards
//   B = One of the three endpoints of the corner, positioned at its top, oriented upwards
//   C = One of the three endpoints of the corner, position to the right, oriented rightwards
// Figure: Available named anchors
//   expose_anchors() pvc_corner(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   Because of the odd shape for this model, the cardinal anchoring points for `pvc_corner()` won't 
//   reflect the full envelope of the model; don't assume anchoring `RIGHT` or `TOP` will be at the models 
//   rightmost or topmost position.
//
// Example: a simple corner
//   pvc_corner(pvc_a);
//
module pvc_corner(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket", "socket"]);
    od = pvc_od(pvc);
    id = pvc_id(pvc);
    tl = pvc_tl(pvc); 
    tee_pipe_len = sum([ tl, od/2 ]);
    total_pipe_height = sum([ tee_pipe_len, od/2 ]);

    anchors = [
        named_anchor("A", 
            apply( back(tl/2) * fwd(tee_pipe_len) * up(od/2) * down(total_pipe_height/2), CENTER),
            FWD, 0),
        named_anchor("B",   // NOTE: 'B' is not perfect, because total_pipe_height is not 100% accurate. 
            apply( down(tl/2) * up(total_pipe_height/2), CENTER),
            UP, 0),
        named_anchor("C", 
            apply( left(tl/2) * right(tee_pipe_len) * up(od/2) * down(total_pipe_height/2), CENTER), 
            RIGHT, 0)
    ];
    attachable(anchor, spin, orient, d=od, h=total_pipe_height, anchors=anchors) {
        down(total_pipe_height/2)
            diff("pvc_rem__full") {
                sphere(d=od, anchor=BOTTOM) {
                    attach(CENTER, CENTER)
                        tag("pvc_rem__full") 
                            sphere(d=id);
                    attach(TOP, "_j_down", overlap=od/2)
                        pvc_part_component(pvc, length=od/2, end=ends_[1]); // B
                    attach(RIGHT, "_j_down", overlap=od/2)
                        pvc_part_component(pvc, length=od/2, end=ends_[2]); // C
                    attach(FWD, "_j_down", overlap=od/2)
                        pvc_part_component(pvc, length=od/2, end=ends_[0]); // A
                }
            }
        children();
    }
}


// Module: pvc_side_outlet_tee()
// Usage:
//   pvc_side_outlet_tee(pvc);
//   pvc_side_outlet_tee(pvc, <ends=["socket", "socket", "socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a PVC tee component. A tee is essentially a length of pipe
//   with a out-spout extending to the right at 90-degrees; a side outlet tee is a tee with an 
//   out-spout extending forward at 90-degrees. 
//   .
//   The tee will have four named anchors, `A`, `B`, `C`, `D`. When oriented `UP` (the default),
//   `A` will be the endpoint at the bottom of the tee, `B` will be at its top, and `C` will 
//   be the extension to the right, and `D` will be the extension facing forward. 
//   The `ends` list argument specifies what endtypes will be created for `A`, `B`, `C`, `D` endtypes, 
//   respectively. Absent endtypes from `ends` will default to "socket". 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_side_outlet_tee(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the four end types, `A`, `B`, `C`, & `D`. Default: `["socket", "socket", "socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the main pipe, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the main pipe, positioned at its top, oriented upwards
//   C = The right-hand out-jutting endpoint, angled to the right, oriented rightwards
//   D = The forwad-facing out-jutting endpoint, angled to forward, oriented forwards
// Figure: Available named anchors
//   expose_anchors() pvc_side_outlet_tee(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   Because of the odd shape for this model, the cardinal anchoring points for `pvc_side_outlet_tee()` won't 
//   reflect the full envelope of the model; don't assume anchoring `RIGHT` or `FWD` will be at the models 
//   rightmost or foremost position.
//
// Example: a simple tee
//   pvc_side_outlet_tee(pvc_a);
//
// Example: a tee with a variety of end types
//   pvc_side_outlet_tee(pvc_a, ends=["socket", "mipt", "fipt"]);
//
module pvc_side_outlet_tee(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket", "socket", "socket"]);
    od = pvc_socket_od(pvc);
    id = pvc_socket_id(pvc);
    tl = pvc_tl(pvc);
    h_tl = tl/2;
    tee_pipe_len = sum([ tl, od/2 ]);
    total_pipe_height = tee_pipe_len * 2;

    anchors = [
        named_anchor("A", apply(down(tee_pipe_len - h_tl), CENTER), DOWN, 0),
        named_anchor("B", apply(up(tee_pipe_len - h_tl), CENTER), UP, 0),
        named_anchor("C", apply(right(tee_pipe_len - h_tl), CENTER), RIGHT, 0),
        named_anchor("D", apply(fwd(tee_pipe_len - h_tl), CENTER), FWD, 0)
    ];
    attachable(anchor, spin, orient, d=od, h=total_pipe_height, anchors=anchors) {
        up(total_pipe_height/2)
        diff("pvc_rem__full") 
            pvc_part_component(pvc, length=od/2, end=ends_[1], anchor=TOP) {   // B
                attach("_j_down", "_j_down")
                    pvc_part_component(pvc, length=od/2, end=ends_[0]);  // A
                attach("_j_right", "_j_down")
                    pvc_part_component(pvc, length=od/2, end=ends_[2]);  // C
                attach("_j_fwd", "_j_down")
                    pvc_part_component(pvc, length=od/2, end=ends_[3]);  // D
            }
        children();
    }
}


// Module: pvc_cross()
// Usage:
//   pvc_cross(pvc);
//   pvc_cross(pvc, <ends=["socket", "socket", "socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a PVC cross component. A cross is essentially two lengths of pipe
//   joined together in their center at right angles, with four outlets.
//   .
//   The cross will have four named anchors, `A`, `B`, `C`, `D`. When oriented `UP` (the default),
//   `A` will be the endpoint at the bottom of the cross, `B` will be at its top, and `C` will 
//   be to the right, and `D` will be to the left. 
//   The `ends` list argument specifies what endtypes will be created for `A`, `B`, `C`, `D` endtypes, 
//   respectively. Absent endtypes from `ends` will default to "socket". 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_cross(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the four end types, `A`, `B`, `C`, & `D`. Default: `["socket", "socket", "socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the main pipe, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the main pipe, positioned at its top, oriented upwards
//   C = The right-hand out-jutting endpoint, angled to the right, oriented rightwards
//   D = The left-hand out-jutting endpoint, angled to the left, oriented leftwards
// Figure: Available named anchors
//   expose_anchors() pvc_cross(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   Because of the odd shape for this model, the cardinal anchoring points for `pvc_cross()` won't 
//   reflect the full envelope of the model; don't assume anchoring `RIGHT` or `FWD` will be at the models 
//   rightmost or foremost position.
//
// Example: a simple tee
//   pvc_cross(pvc_a);
//
// Example: a tee with a variety of end types
//   pvc_cross(pvc_a, ends=["socket", "mipt", "fipt", "spigot"]);
//
module pvc_cross(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket", "socket", "socket"]);
    od = pvc_od(pvc);
    tl = pvc_tl(pvc);
    h_tl = tl / 2;
    tee_pipe_length = sum([ tl, od/2 ]);
    total_pipe_height = tee_pipe_length * 2;
    h_total_pipe_height = total_pipe_height / 2;
    
    anchors = [
        named_anchor("A", apply(down(h_total_pipe_height - h_tl), CENTER), DOWN, 0),
        named_anchor("B", apply(up(h_total_pipe_height - h_tl), CENTER), UP, 0), 
        named_anchor("C", apply(right(h_total_pipe_height - h_tl), CENTER), RIGHT, 0),
        named_anchor("D", apply(left(h_total_pipe_height - h_tl), CENTER), LEFT, 0)
    ];
    attachable(anchor, spin, orient, d=od, h=total_pipe_height, anchors=anchors) {
        up(total_pipe_height/2)
        diff("pvc_rem__full")
            pvc_part_component(pvc, length=od/2, end=ends_[1], anchor=TOP) {   // B
                attach("_j_down", "_j_down")
                    pvc_part_component(pvc, length=od/2, end=ends_[0]); // A
                attach("_j_right", "_j_down")
                    pvc_part_component(pvc, length=od/2, end=ends_[2]);  // C
                attach("_j_left", "_j_down")
                    pvc_part_component(pvc, length=od/2, end=ends_[3]);  // D
            }
        children();
    }
}


// Module: pvc_six_way_joint()
// Usage:
//   pvc_six_way_joint(pvc);
//   pvc_six_way_joint(pvc, <ends=["socket", ...]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a PVC six-way joint component. A six-way is essentially three lengths of pipe
//   joined together in their center at right angles, with six outlets.
//   .
//   The cross will have four named anchors, `A`, `B`, `C`, `D`, `E`, `F`. When oriented `UP` (the default),
//   `A` will be the endpoint at the bottom of the cross, `B` will be at its top, `C` will 
//   be to the right, `D` will be to the left, `E` will be facing forwards, and `F` will be facing backwards.
//   The `ends` list argument specifies what endtypes will be created for `A`, `B`, `C`, `D`, `E`, `F` endtypes, 
//   respectively. Absent endtypes from `ends` will default to "socket". 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_six_way_joint(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the six end types, `A`, `B`, `C`, `D`, `E`, & `F`. Default: `["socket", ...]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the six endpoints of the joint, positioned at its bottom, oriented downwards
//   B = One of the six endpoints of the joint, positioned at its top, oriented upwards
//   C = The right-hand out-jutting endpoint, angled to the right, oriented rightwards
//   D = The left-hand out-jutting endpoint, angled to the left, oriented leftwards
//   E = The foward-facing out-jutting endpoint, oriented forwards
//   F = The backward-facing out-jutting endpoint, oriented backwards
// Figure: Available named anchors
//   expose_anchors() pvc_six_way_joint(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   Because of the odd shape for this model, the cardinal anchoring points for `pvc_six_way_joint()` won't 
//   reflect the full envelope of the model; don't assume anchoring `RIGHT` or `FWD` will be at the models 
//   rightmost or foremost position.
//
// Example: a simple tee
//   pvc_six_way_joint(pvc_a);
//
// Example: a tee with a variety of end types
//   pvc_six_way_joint(pvc_a, ends=["socket", "mipt", "fipt", "spigot"]);
//
module pvc_six_way_joint(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket", "socket", "socket", "socket", "socket"]);
    od = pvc_od(pvc);
    tl = pvc_tl(pvc);
    part_len_addl = od/2 + 2;
    tee_pipe_len = tl + part_len_addl;
    total_pipe_len = tee_pipe_len * 2;

    anchors = [
        named_anchor("A", apply(up(tl/2) * down(tee_pipe_len), CENTER), DOWN, 0),
        named_anchor("B", apply(down(tl/2) * up(tee_pipe_len), CENTER), UP, 0), 
        named_anchor("C", apply(left(tl/2) * right(tee_pipe_len), CENTER), RIGHT, 0),
        named_anchor("D", apply(right(tl/2) * left(tee_pipe_len), CENTER), LEFT, 0),
        named_anchor("E", apply(back(tl/2) * fwd(tee_pipe_len), CENTER), FWD, 0),
        named_anchor("F", apply(fwd(tl/2) * back(tee_pipe_len), CENTER), BACK, 0),
    ];
    attachable(anchor, spin, orient, d=od, h=total_pipe_len, anchors=anchors) {
        diff("pvc_rem__full")
            pvc_part_component(pvc, length=part_len_addl, end=ends_[1], anchor="_j_down") {   // B
                attach("_j_down", "_j_down")
                    pvc_part_component(pvc, length=part_len_addl, end=ends_[0]);  // A
                attach("_j_down", "_j_right")
                    pvc_part_component(pvc, length=part_len_addl, end=ends_[2]);  // C
                attach("_j_down", "_j_left")
                    pvc_part_component(pvc, length=part_len_addl, end=ends_[3]);  // D
                attach("_j_down", "_j_fwd")
                    pvc_part_component(pvc, length=part_len_addl, end=ends_[4]);  // E
                attach("_j_down", "_j_back")
                    pvc_part_component(pvc, length=part_len_addl, end=ends_[5]);  // F
            }
        children();
    }
}


// Module: pvc_coupling()
// Usage:
//   pvc_coupling(pvc);
//   pvc_coupling(pvc, <ends=["socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a PVC coupler. A coupler is a part that joins two 
//   lengths of pipes or two parts, usually with socket or fipt ends.
//   .
//   The coupler will have two named anchors `A` and `B`. When oriented `UP` (the default), 
//   `A` will be the endpoint at the bottom of the coupler, and `B` will be at its top. 
//   The `ends` list argument specifies what endtypes will be created for the `A` and `B` 
//   pipe ends, respectively. If `ends` is unspecified, or if any of the positional 
//   list elements are `undef`, then those unspecified ends will be a socket. 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_coupling(pvc_a);
// 
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the two end types, `A` and `B`. Default: `["socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the coupling, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the coupling, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_coupling(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   It's not an error to specify end types other than "socket" or "fipt" for couplers; however, 
//   it's not really a thing that happens a lot in the real world. A coupler with two "mipt" 
//   ends is a nipple (see `pvc_nipple()` below); and a coupler with two "spigot" ends is 
//   just a short length of pipe with no special ends. `pvc_coupler()` won't throw an error if 
//   the ends aren't a socket or fipt, but I'd try to avoid it. 
//
// Example: a basic coupling
//   pvc_coupling(pvc_a);
//
// Example: a coupling with female threading on each end
//   pvc_coupling(pvc_a, ends=["fipt", "fipt"]);
//
module pvc_coupling(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    // should we perhaps warn the caller if the coupler isn't socket/fipt? 
    ends_ = list_apply_defaults(ends, ["socket", "socket"]);
    od = pvc_od(pvc);
    tl = pvc_tl(pvc);
    pipe_addl = 3;
    pipe_len = sum([ tl, pipe_addl ]);
    total_pipe_len = pipe_len * 2;
    
    anchors = [
        named_anchor("A", apply(up(tl/2) * down(pipe_len), CENTER), DOWN, 0),
        named_anchor("B", apply(down(tl/2) * up(pipe_len), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=od, h=total_pipe_len, anchors=anchors) {
        diff("pvc_rem__full")
            pvc_part_component(pvc, length=pipe_addl, end=ends_[1], anchor=BOTTOM) // B
                attach("_j_down", "_j_down")
                    pvc_part_component(pvc, length=pipe_addl, end=ends_[0]); // A
        children();
    }
}


// Module: pvc_cap()
// Usage:
//   pvc_cap(pvc);
//   pvc_cap(pvc, <ends=["socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a cap for a PVC endpoint. A cap covers an ending of pipe or other PVC part, 
//   wraping around the outside of the ending. 
//   .
//   The cap model will have one named anchor, `A`. When oriented `UP` (the default), `A` will be the oriented 
//   upwards at the top of the cap. 
//   Anchors are inset on-half of the PVC's thread-lengh, making joining with other parts simple
//   (eg, `pvc_pipe(pvc) attach("A", "A") pvc_cap(pvc)`). 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_cap(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the single end type, `A`. Default: `["socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = The endpoint of the cap, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_cap(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   It is an error to specify an end type other than "fipt" or "socket" for caps. If you need 
//   something to block a pipe or part ending that doesn't fit outside of the pipe's outer-diameter, 
//   look at `pvc_plug()`. 
//   .
//   The argument `ends` accepts a list-argument of end types, keeping the argument type 
//   consistent with other PVC part modules, though it only considers the first element in 
//   that list.
//
// Example: a basic cap
//   pvc_cap(pvc_a);
//
// Example: capping a pipe
//   pvc_pipe(pvc_a, 30) 
//     attach("B", "A")
//       pvc_cap(pvc_a);
//
// Todo:
//   a cap perhaps doesn't need to have the same wall thickness as the pipe it's being attached to.
//   caps probably also have a slightly domed top. :shrug:
//
module pvc_cap(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {

    ends_ = list_apply_defaults(ends, ["socket"]);
    assert(in_list(ends_[0], ["fipt", "socket"]), 
        "pvc_cap(): Only 'fipt' and 'socket' are allowable end types for PVC caps");

    od = (ends_[0] == "socket") ? pvc_od(pvc) + (pvc_wall(pvc)/3)*2 : pvc_od(pvc); 
    tl = pvc_tl(pvc);
    pipe_addl = 1;
    wall = pvc_wall(pvc);
    total_pipe_len = sum([ tl, pipe_addl, wall ]);
    
    anchors = [
        named_anchor("A", apply(down(tl/2) * up(total_pipe_len/2), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=od, h=total_pipe_len, anchors=anchors) {
        up(total_pipe_len/2)
        diff("pvc_rem__full")
            pvc_part_component(pvc, length=pipe_addl, end=ends_[0], anchor=TOP)  // A
                attach(BOTTOM, TOP)
                    cylinder(d=od, h=wall);
        children();
    }
}


// Module: pvc_plug()
// Usage:
//   pvc_plug(pvc);
//   pvc_plug(pvc, <ends=["spigot"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a plug for a PVC endpoint. A plug covers an ending of pipe or other PVC part, 
//   sitting within the inside of the ending.
//   .
//   The plug model will have one named anchor, `A`. When oriented `UP` (the default), `A` will be the oriented 
//   upwards at the top of the plug. 
//   Anchors are inset on-half of the PVC's thread-lengh, making joining with other parts simple
//   (eg, `pvc_pipe(pvc) attach("A", "A") pvc_plug(pvc)`). 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_plug(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the single end type, `A`. Default: `["ispigot"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = The endpoint of the cap, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_plug(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   It is an error to specify an end type other than "mipt" or "spigot" for plugs. If you need 
//   something to block a pipe or part ending that doesn't fit inside of the pipe's inner-diameter, 
//   look at `pvc_cap()`. 
//   .
//   The argument `ends` accepts a list-argument of end types, keeping the argument type 
//   consistent with other PVC part modules, though it only considers the first element in 
//   that list.
//
// Example: a basic cap
//   pvc_plug(pvc_a);
//
// Example: plugging a threaded pipe
//   pvc_pipe(pvc_a, 30, ends=["fipt", "fipt"]) 
//     attach("B", "A")
//       pvc_plug(pvc_a, ends=["mipt"]);
//
// Todo: 
//   the top of the plug needs a way to tool-tighten, especially if the plug is threaded
//   should the bottom of the plug be solid?
//   plugs are meant for parts, not pipes; is this sizing too small?   
//
module pvc_plug(pvc, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {

    ends_ = list_apply_defaults(ends, ["ispigot"]);
    assert(in_list(ends_[0], ["mipt", "spigot", "ispigot"]), 
        "pvc_plug(): Only 'mipt' and 'spigot' are allowable end types for PVC caps");

    id = pvc_id(pvc);
    socket_od = pvc_socket_od(pvc);
    tl = pvc_tl(pvc);
    wall = pvc_wall(pvc);
    total_pipe_len = sum([tl, wall]);
    slot = [ id, wall/2, wall/2 ];

    anchors = [
        named_anchor("A", apply(down(tl/2) * up(total_pipe_len/2), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=socket_od, h=total_pipe_len, anchors=anchors) {
        down(total_pipe_len/2)
            diff("_rem__plug")
                cylinder(d=socket_od, h=wall, anchor=BOTTOM) {
                    attach(TOP, BOTTOM)
                        pvc_part_component(pvc, length=0, end=ends_[0])   // A
                            attach(TOP, BOTTOM, overlap=wall)
                                cylinder(d=id, h=wall);
                    attach(BOTTOM, TOP, overlap=wall/2 - 0.1)
                        tag("_rem__plug")
                            cuboid(slot);
                }
        children();
    }
}


// Module: pvc_adapter()
// Usage:
//   pvc_adapter(pvc1, pvc2);
//   pvc_adapter(pvc1, pvc2, <ends=["socket", "socket"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given two PVC objects `pvc1`, `pvc2`, create a PVC adapter that marries the two PVC 
//   objects. An adapter is a part that joins pipes or parts of two different PVC sizes. 
//   .
//   The adapter will have two named anchors `A` and `B`. When oriented `UP` (the default), 
//   `A` will be the endpoint at the bottom of the adapter, attached to `pvc1`; and, `B` will 
//   be the endpoint at the top of the adapter, attached to `pvc2`. 
//   The `ends` list argument specifies what endtypes will be created for the `A` and `B` 
//   pipe ends, respectively. If `ends` is unspecified, or if any of the positional 
//   list elements are `undef`, then those unspecified ends will be a socket. 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_adapter(pvc_a, pvc_b);
//
// Arguments:
//   pvc1 = An instantiated PVC specification
//   pvc2 = An instantiated PVC specification
//   ---
//   ends = A list of the two end types, `A` and `B`. Default: `["socket", "socket"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the adapter, for `pvc1`, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the adapter, for `pvc2`, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_adapter(pvc_a, pvc_b) show_anchors(std=false, s=40);
//
// Continues:
//   It is not an error to specify PVC objects that have identical dimensions (eg, 
//   `pvc1` and `pvc2` both set to a schedule-40 DIM20); however, it's unclear why 
//   you'd do that in the first place. 
//
// Todo: 
//   I kind of dislike the socket_overlap used here within pvc_part_component()
//
// Example: a basic adapter
//   pvc_adapter(pvc_a, pvc_b);
//
module pvc_adapter(pvc1, pvc2, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    ends_ = list_apply_defaults(ends, ["socket", "socket"]);
    segment_len = pvc_tl(pvc1) + 1;
    trans_len = 2;
    total_n_len = sum([ pvc_tl(pvc1), pvc_tl(pvc2), trans_len, 2]);
    max_od = max([ pvc_socket_od(pvc1), pvc_socket_od(pvc2) ]);
    
    anchors = [
        named_anchor("A", apply(up(pvc_tl(pvc1)/2) * down(total_n_len/2), CENTER), DOWN, 0),
        named_anchor("B", apply(down(pvc_tl(pvc2)/2) * up(total_n_len/2), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=max_od, h=total_n_len, anchors=anchors) {
        diff("pvc_rem__full")
            tube(od2=pvc_od(pvc2), od1=pvc_od(pvc1), id2=pvc_id(pvc2), id1=pvc_id(pvc1), l=trans_len, anchor=CENTER) {
                attach(TOP, BOTTOM)
                    pvc_part_component(pvc2, length=1, end=ends_[1], socket_overlap=1); // B
                attach(BOTTOM, BOTTOM)
                    pvc_part_component(pvc1, length=1, end=ends_[0], socket_overlap=1); // A
            }
        children();
    }
}


// Module: pvc_bushing()
// Usage:
//   pvc_bushing(pvc1, pvc2);
//   pvc_bushing(pvc1, pvc2, <ends=["fipt", "mipt"]>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given two PVC objects `pvc1`, `pvc2`, create a bushing that joins the two objects. 
//   A bushing fits two dissimilar sized ends, fitting one inside the other. 
//   .
//   The PVC objects may be supplied in any order: `pvc_bushing()` examines the diameters 
//   of the two objects and determines which is larger or smaller, and places them 
//   accordinging. 
//   .
//   The bushing will have two named anchors `A` and `B`. When oriented `UP` (the default), 
//   `A` will be the endpoint at the bottom of the bushing, attached to the smaller of the 
//   two PVC objects; `B` will be the endpoint at the top of the bushing, attached to the 
//   larger of the two PVC objects. 
//   The `ends` list argument specifies what endtypes will be created for the `A` and `B` 
//   pipe ends, respectively. If `ends` is unspecified, or if any of the positional 
//   list elements are `undef`, then the smaller of the objects (the `A`, downward endpoint) 
//   will be set to "fipt", and the larger of the objects (the `B`, upward endpoint) will 
//   be set to "mipt". 
//   .
//   While the placement of the endtypes in relation to the overall bushing model is not in 
//   your control, it's easiest to remember: `A` comes before `B`; *smaller* elements come 
//   before *larger* elements, say, when counting; the *smaller* of the PVC objects will be 
//   positioned at the `A` anchor, and the larger PVC object will be positioned at the `B` 
//   anchor.
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_bushing(pvc_a, pvc_b);
//
// Arguments:
//   pvc1 = An instantiated PVC specification
//   pvc2 = An instantiated PVC specification
//   ---
//   ends = A list of the two end types, `A` and `B`, corresponding to the smaller and larger PVC objects, respectively. Default: `["fipt", "mipt"]`
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the bushing, for the larger of the PVC objects, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the bushing, for the smaller of the PVC objects, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_bushing(pvc_a, pvc_b) show_anchors(std=false, s=40);
//
// Continues:
//   It is an error to specify two PVC objects that have identical dimensions, or 
//   two PVC objects that cannot nest. 
//   .
//   It is an error to specify an endtype for the smaller PVC object (the downwards, `A`, anchor) that 
//   is neither "fipt" nor "socket". 
//   .
//   It is an error to specify an endtype for the larger PVC object (the upwards, `B`, anchor) that 
//   is neither "mipt" nor "spigot". 
//
// Example: a basic bushing
//   pvc_bushing(pvc_a, pvc_b);
//
// Todo:
//   This has some artifact extruding out of the top of the model; not sure what it is yet.
//   When `B` anchor (the larger) is a spigot, there needs to be a flare at the base of the bushing to keep it from sliding in too far.
//   Have a bounds check on the resulting wall thickness. If it's too little, then throw. 
//   I just know that the lack of ordering in PVC objects, versus the specific ordering of `ends`, is gonna come back to bite me. 
//
module pvc_bushing(pvc1, pvc2, ends=[],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    assert(pvc_socket_od(pvc1) != pvc_socket_od(pvc2), "pvc_bushing(): outer diameters can't match");
    assert(pvc_socket_id(pvc1) != pvc_socket_id(pvc2), "pvc_bushing(): inner diameters can't match");

    // need a bounds check here
    pvc_larger = (pvc_socket_od(pvc1) > pvc_socket_od(pvc2)) ? pvc1 : pvc2;
    pvc_smaller = (pvc_socket_od(pvc1) < pvc_socket_od(pvc2)) ? pvc1 : pvc2;
    assert(pvc_socket_id(pvc_larger) > pvc_socket_od(pvc_smaller), 
        "pvc_bushing(): the ID and OD of the larger and smaller pips have to be complementary");
    
    ends_ = list_apply_defaults(ends, ["fipt", "mipt"]);
    end_smaller = ends_[0];
    end_larger  = ends_[1];
    assert(in_list(end_smaller, ["fipt", "socket"]), 
        "pvc_bushing(): The smaller endpoint designation must be one of 'fipt' or 'socket'.");
    assert(in_list(end_larger, ["mipt", "spigot"]),
        "pvc_bushing(): The larger endpoint designation must be one of 'mipt' or 'spigot'.");

    max_tl = max([ pvc_tl(pvc_smaller), pvc_tl(pvc_larger) ]);
    segment_len = max_tl + 1;
    h_segment_len = segment_len / 2;
    
    anchors = [
        named_anchor("A", apply(up(pvc_tl(pvc_smaller) / 2) * down(h_segment_len), CENTER), DOWN, 0),
        named_anchor("B", apply(down(pvc_tl(pvc_larger) / 2) * up(h_segment_len), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=pvc_socket_id(pvc_larger), h=segment_len, anchors=anchors) {
        union() {
            diff("pvc_rem__full") 
                pvc_part_component(pvc_larger, end=end_larger, length=1, anchor=CENTER);   // B
            diff("pvc_rem__full") 
                pvc_part_component(pvc_smaller, end=end_smaller, length=1, orient=DOWN, anchor=CENTER);   // A
            tube(od=pvc_id(pvc_larger), id=pvc_od(pvc_smaller), l=max_tl + 1, anchor=CENTER);
        }
        children();
    }
}


// Module: pvc_nipple()
// Usage:
//   pvc_nipple(pvc);
//   pvc_nipple(pvc, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a PVC nipple joint model. A nipple is a length of pipe 
//   with mipt-threads on both ends, used to join two fipt-threaded parts. 
//   .
//   The nipple will have two named anchors `A` and `B`. When oriented `UP` (the default), 
//   `A` will be the endpoint at the bottom of the nipple, and `B` will be at its top. 
//   
/// Figure(Spin,Anim,NoAxes):
///   pvc_nipple(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = One of the two endpoints of the nipple, positioned at its bottom, oriented downwards
//   B = One of the two endpoints of the nipple, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_nipple(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   Nipples are not for changing pipe diameters. If you need a part that has two mipt ends for 
//   different sizes of pipe, see `pvc_adapter()`. 
//   .
//   I dislike the name "nipple" for this PVC part, but it's what they call it at Home Depot, so it stays. 
//
// Example: a basic coupling
//   pvc_nipple(pvc_a);
//
module pvc_nipple(pvc,
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    o_pvc = PVC(["od", pvc_id(pvc), "dn", undef], mutate=pvc); // this may mess with the wall thickness, and we should rethink this mutate
    tl = pvc_tl(pvc);
    total_n_len = sum([ tl * 2, 2 ]);
    
    anchors = [
        named_anchor("A", apply(down(tl/2 + 1/2), CENTER), DOWN, 0),
        named_anchor("B", apply(up(tl/2 + 1/2), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=pvc_socket_od(o_pvc), h=total_n_len, anchors=anchors) {
        diff("pvc_rem__full")
            pvc_part_component(pvc, end="mipt", length=1, anchor=BOTTOM) // B
                attach(BOTTOM, BOTTOM)
                    pvc_part_component(pvc, end="mipt", length=1); // A
        children();
    }
}


// Module: pvc_flange()
// Usage:
//   pvc_flange(pvc);
//   pvc_flange(pvc, <ends=[undef, "socket"]>, <mounts=4>, <mount_diam=0>, <anchor=CENTER>, <spin=0>, <orient=UP>);
//
// Description:
//   Given a PVC object `pvc`, create a flange part suitable for mounting to other flanges. A flange in 
//   this context is a circular disk with a pipe endpoint on one side, and a flat surface on the other. 
//   Arrayed around the pipe ending are mounting holes through which bolts may be inserted, joining the 
//   flange to another flange that is flush-mounted.
//   .
//   The flange will have a `mount` number of mounting holes created. If `mount` is unspecified, it will 
//   default to `4`. The diameter of those holes can be adjusted using `mount_diam`: if it is a positive 
//   non-zero number, the mounting holes will be that diameter. Note that if `mount_diam` is  
//   larger than a safe value between the outer diameter of the flange and the outer diameter of 
//   the endtype at anchor `B`, the specified diameter will be reduced to the safe diameter.
//   .
//   The flange will have two named anchors `A` and `B`. When oriented `UP` (the default),
//   `A` will be the flush surface at the bottom of the flange, and `B` will be the endpoint on
//   its top, oriented upwards.  
//   The `ends` list argument specifies what endtypes will be created for the `A` and `B` 
//   pipe ends, respectively: only the `B` endtype is considered. If `ends` is unspecified, or if 
//   any of the positional list elements are `undef`, then those unspecified ends will be a socket. 
//
/// Figure(Spin,Anim,NoAxes):
///   pvc_flange(pvc_a);
//
// Arguments:
//   pvc = An instantiated PVC specification
//   ---
//   ends = A list of the two end types, `A` and `B`. Default: `[undef, "socket"]`
//   mounts = The number of mounting holes to array around the piping ending in the flange. Default: `4`
//   mount_diam = The diameter of the mounting holes. Default: `0` (to let `pvc_flange()` specify the maximum safe diameter)
//   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
//   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
//   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
//
// Named Anchors:
//   A = The flat, underside portion of the flange, positioned at its bottom, oriented downwards
//   B = The pipe endpoint of the flange, positioned at its top, oriented upwards
// Figure: Available named anchors
//   expose_anchors() pvc_flange(pvc_a) show_anchors(std=false, s=40);
//
// Continues:
//   The `A` anchor is less of a "part-joining placement" as it is a "flat surface". While 
//   other PVC parts produced by this library place the part anchors inset in the part threading, 
//   there is nothing like that here: just smush the flat `A` surface up against another flange's 
//   `A` surface and you're all set. **As such,** the end type for `A` is ignored (but, it's 
//   still part of the `ends` argument, to keep things consistent with the other modules here).
//   .
//   While mounting holes for joining hardware are placed into the flange, mounting 
//   hardware is not modeled with this module; that is left as an exercise to the 
//   user. 
//
// Example: a basic flange
//   pvc_flange(pvc_a);
//
// Example: two flanges and a pipe. A visual gap of 0.2mm is introduced between the flanges, to show their placement.
//   pvc_pipe(pvc_a, 30)
//       attach("A", "B")
//           pvc_flange(pvc_a)
//               attach("A", "A", overlap=-0.2)
//                   pvc_flange(pvc_a);
//
module pvc_flange(pvc, ends=[], mounts=4, mount_diam=0,
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    // the pipe generally fits *into* the extruded flange surface (ref: "internet")
    ends_ = list_apply_defaults(ends, [undef, "socket"]);
    tl = pvc_tl(pvc);
    mount_len = sum([ tl, 1 ]);
    flange_diam = pvc_socket_od(pvc) * 1.5;
    flange_height = mount_len / 3;
    safe_mount_diam = (flange_diam - pvc_socket_od(pvc) - 2 - 1) / 2; 
    flange_mount_diam = (mount_diam > 0 && mount_diam <= safe_mount_diam) ? mount_diam : safe_mount_diam; 
    part_height = sum([tl, flange_height]);
    
    anchors = [
        named_anchor("A", apply(down(part_height/2), CENTER), DOWN, 0),
        named_anchor("B", apply(down(tl/2) * up(mount_len/2), CENTER), UP, 0)
    ];
    attachable(anchor, spin, orient, d=flange_diam, h=part_height, anchors=anchors) {
        down(part_height/2)
        diff("pvc_rem__full") {
            cylinder(d=flange_diam, h=flange_height, anchor=BOTTOM);   // A
            pvc_part_component(pvc, end=ends_[1], length=flange_height, anchor=BOTTOM); // B
            tag("pvc_rem__full")
                down(0.01)
                    cylinder(d=pvc_id(pvc), h=flange_height, anchor=BOTTOM);
            tag("pvc_rem__full")
                zrot_copies(n=mounts, r=(flange_diam / 2) - (flange_mount_diam / 2) - 1)
                    cylinder(d=flange_mount_diam, h=flange_height + 0.01, anchor=BOTTOM);
        }
        children();
    }
}


// anchor check: ?
// named anchor check: ?
module pvc_side_outlet_elbow(pvc, angle, ends=["socket", "socket"], outlet="socket",
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    assert(false, "not yet supported");
}


// anchor check: ?
// named anchor check: ?
module pvc_saddle(pvc, ends=["socket"],
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    assert(false, "not yet supported");
}


// anchor check: ?
// named anchor check: ?
module pvc_union(pvc,
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    assert(false, "not yet supported");
}


// Section: Constants
//
// Constant: PVC_KNOWN_SCHEDULES
// Description: 
//   A list of known PVC "schedules". In this context, "schedule" is what 
//   classifies the material weight, size, and maximum pressure of PVC 
//   part and pipe.
//   .
//   This list is generated dynamicaly at runtime, by scanning through 
//   all known specifications within `_PVC_specs_raw` to extract the 
//   unique schedules.
///   **NOTE:** this dynamic assignment is below in this LibFile, *after* the declaration of _PVC_specs_raw.

// Constant: PVC_ENDTYPES
// Description:
//   A list of supported endtypes for PVC parts: `spigot`, `socket`, `mipt`, & `fipt`.
//   Spigots and sockets are smooth, allowing spigots to slide inside sockets. 
//   mipt and fipt are male- and female-threaded endpoints. 
//   .
//   Elements are position-dependent, because we use their position in the 
//   `PVC_ENDTYPES` list as indicators as to whether they are "innies" or "outies". 
//   *(ETA: yeah, um... do we?)*
//   .
//   *(Note: "mipt" and "fipt" are industry names. I don't like them, because they're gendered and 
//   imply people characteristics that are assumed, and often not correct.
//   I'm not about to go up against the PVC industry in this .scad today, though,
//   no matter how much fun it'd be.)*
PVC_ENDTYPES = [
    "spigot",   // smooth inner join; should be the same as the od
    "ispigot",  // smooth inner join; its od should be the same as the PVC object's id
    "socket",   // smooth outer join; larger than the OD
    "mipt",     // male-iron-pipe-thread; threading on the outside of the pipe
    "fipt"      // female-iron-pipe-thread; threading on the inside of the pipe
    ];

// Constant: PVC_DEFAULT_ANCHOR
// Description: The default anchor position for creating PVC parts. Currently: `CENTER`
PVC_DEFAULT_ANCHOR = CENTER;

// Constant: PVC_DEFAULT_SPIN
// Description: Default spin value used when creating PVC parts. Currently: `0` (for no spin)
PVC_DEFAULT_SPIN = 0;

// Constant: PVC_DEFAULT_ORIENT
// Description: Default orientation for PVC parts. Currently: `UP`
PVC_DEFAULT_ORIENT = UP;



/// Section: PVC Component Construction Modules
///

/// Module: pvc_part_component()
/// Usage:
///   pvc_part_component(pvc);
///   pvc_part_component(pvc, <end="socket">, <length=undef>, <socket_overlap=3>, <anchor=CENTER>, <spin=0>, <orient=UP>);
///
/// Description:
///   This is an internal module, and isn't intended to be used outside of already-constructed PVC part modules.
///   .
///   This is a base model module to rapidly and consistently create PVC parts. It's not a PVC
///   part *per se*, but a building block for parts. 
///   .
///   Given a PVC object `pvc`, models a PVC endpoint specifed by `end`, with an optional 
///   length of pipe `length`. With the default orientation of `UP`, the endpoint of the 
///   component (the "meet-end", for lack of a better term) is pointed upwards, and the pipe amount 
///   specified by `length` is attached below that (the "pipe-end").  
///   .
///   If `length` is unspecifed (the default), then `length` will be the same as the PVC object's 
///   `tl` (thread-length) attribute. If `length` is `0` (zero), then there will be no piping 
///   at the base of the endpoint. If `length` is a positive number, the piping will be that 
///   value in length. It is an error to specify a negative value for `length`.
///   .
///   The `end` option specifies what the endpoint will be. `end` must be one of 
///   the types listed in `PVC_ENDTYPES`.
///   .
///   Models produced with `pvc_part_component()` have six named anchors at their 
///   base to make joining with other components simple. The anchors are prefixed 
///   with `_j_` (to indicate these are internal joining anchors), and are one of 
///   the six basic cardinal directions (fwd, back, left, right, up, down). 
///   .
///   Models produced with `pvc_part_component()` come with a negative-space 
///   portion that **must** be `diff()`'d away before presenting the model to 
///   to the scene. The diff tag is `pvc_rem__full`, and should be done within 
///   the part construction. 
///
/// Arguments:
///   pvc = An instantiated PVC specification
///   ---
///   length = The length of the pipe. Default: `undef`
///   end = The endtype of the part component. Default: `socket`
///   socket_overlap = The amount of overlap provided, when `end` is set to `socket`. Default: `3`
///   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
///   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
///   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
///   
/// Named Anchors:
///   _j_up = Joining anchor at the center-base of the componet, oriented upwards
///   _j_down = Joining anchor at the center-base of the componet, oriented downwards
///   _j_left = Joining anchor at the center-base of the componet, oriented leftwards
///   _j_right = Joining anchor at the center-base of the componet, oriented rightwards
///   _j_fwd = Joining anchor at the center-base of the componet, oriented forwards
///   _j_back = Joining anchor at the center-base of the componet, oriented backwards
/// Figure:
///   expose_anchors() pvc_part_component(pvc_a, end="mipt") show_anchors(std=false, s=40);
///
module pvc_part_component(pvc, end="socket", length=undef, socket_overlap=3,
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {

    assert(in_list(end, PVC_ENDTYPES), 
        str( "pvc_part_component(): specified end '", end, 
            "' must be listed in PVC_ENDTYPES" ));

    tl = pvc_tl(pvc);
    od = pvc_od(pvc);
    id = pvc_id(pvc);
    wall = pvc_wall(pvc);

    pipe_len = (length == 0)
        ? 0.0001  // to silence truncation errors
        : (!_defined(length))
            ? tl
            : (length > 0)
                ? length
                : assert(length >= 0, "pvc_part_component(): specified 'length' can't be negative");

    max_od = max([ od, (end == "socket") ? sum([ od, (wall/3) * 2 ]) : pvc_od(pvc) ]);
    od2 = (end == "socket") 
        ? pvc_od(pvc) + (pvc_wall(pvc) / 3 * 2)
        : (in_list(end, ["mipt"]))
            ? od - (od - id) / 2
            : od;
    id2 = (end == "socket") 
        ? pvc_socket_id(pvc)
        : (in_list(end, ["mipt"]))
            ? id 
            : id;

    total_len = sum([ tl, pipe_len ]);

    anchors = [
        named_anchor("_j_up",    [0, 0, -1 * total_len/2], UP,    0),
        named_anchor("_j_down",  [0, 0, -1 * total_len/2], DOWN,  0),
        named_anchor("_j_left",  [0, 0, -1 * total_len/2], LEFT,  0),
        named_anchor("_j_right", [0, 0, -1 * total_len/2], RIGHT, 0),
        named_anchor("_j_fwd",   [0, 0, -1 * total_len/2], FWD,   0),
        named_anchor("_j_back",  [0, 0, -1 * total_len/2], BACK,  0),
    ];
    // because we're passing negative removal space along with the 
    // pipe model, we have to perform the double-attachable() movement
    // here:
    tag("pvc_rem__full")
        attachable(anchor, spin, orient, d=max_od, l=total_len, anchors=anchors) {
            down(total_len/2)
                cylinder(d=id, l=pipe_len, anchor=BOTTOM)
                    attach(TOP, BOTTOM, overlap=0.001)
                        pvc_endpoint_negative(pvc, end);
            union() {}
        }
    attachable(anchor, spin, orient, d=max_od, l=total_len, anchors=anchors) {
        down(total_len/2)
            tube(od=od, wall=wall, l=pipe_len, anchor=BOTTOM)
                attach(TOP, BOTTOM, overlap=(end == "socket") ? socket_overlap + 0.001 : 0.001)
                    pvc_endpoint(pvc, end);
       children();
    }
}


/// Module: pvc_endpoint_negative()
/// Usage:
///   pvc_endpoint_negative(pvc);
///   pvc_endpoint_negative(pvc, <type="spigot">, <length=undef>, <anchor=CENTER>, <spin=0>, <orient=UP>);
/// 
/// Description:
///   This is an internal module, and isn't intended to be used outside of `pvc_part_component()`.
///   .
///   Given a PVC object `pvc`, model the negative space for an endpoint sized for that PVC spec. The endpoint 
///   type is defined by the `type` argument; it defaults to "spigot". If the optional 
///   `length` argument is defined and non-zero, the endpoint will be that value in length;
///   the default will be to use the PVC's `tl` attribute value, which defines the thread-length
///   of the PVC spec. 
///   .
///   The negative space provided by `pvc_endpoint_negative()` is used upstream to ensure 
///   joined components don't overlap into the open piping space needed to make a PVC pipe, you know,
///   work. It's used in conjunction with `pvc_endpoint()` and `diff()` within `pvc_part_component()` 
///   to provide clean inside piping. 
///
/// Arguments:
///   pvc = An instantiated PVC specification
///   ---
///   type = The endpoint type to model. Default: `spigot`
///   length = The length of the endpoint to create. Default: `undef` (meaning the value of the PVC object's `tl` attribute will be used)
///
/// Continues:
///   It is an error to call `pvc_endpoint_negative()` with a `type` that isn't listed in `PVC_ENDTYPES`.
///   .
///   There are no attachable or anchoring options for `pvc_endpoint_negative()`.
///
module pvc_endpoint_negative(pvc, type="spigot", length=undef) {
    if (_defined(type)) {
        assert(in_list(type, PVC_ENDTYPES), str("pvc_endpoint_negative(): specified type ", type, " not known"));

        od = (type == "socket" || type == "fipt") ? pvc_socket_od(pvc) : pvc_od(pvc);
        id = (type == "socket" || type == "fipt") ? pvc_socket_id(pvc) : pvc_id(pvc);
        l = (_defined(length) && length > 0) ? length : pvc_tl(pvc);
        a_diam = (type == "socket") ? od : id;

        attachable(CENTER, 0, UP, d=a_diam, l=l) {
            if (type == "spigot") {
                cylinder(d=id, l=l, anchor=CENTER);
            } else if (type == "mipt") {
                cylinder(d=id, l=l, anchor=CENTER);
            } else if (type == "socket") {
                cylinder(d=id, l=l, anchor=CENTER);
            } else if (type == "fipt") {
                // check this, we don't want to run into the threads, but we don't want to 
                // re-thread the whole thing just yet
                // Todo - this inline calc for `d` is ridiculous.
                cylinder(d=pvc_od(pvc) - (pvc_od(pvc) - pvc_id(pvc)) / 2 - 1, l=l, anchor=CENTER);
            }
            children();
        }
    }
}


/// Module: pvc_endpoint()
/// Usage:
///   pvc_endpoint(pvc);
///   pvc_endpoint(pvc, <type="spigot">, <length=undef>, <anchor=CENTER>, <spin=0>, <orient=UP>);
/// 
/// Description:
///   This is an internal module, and isn't intended to be used outside of `pvc_part_component()`.
///   .
///   Given a PVC object `pvc`, model an endpoint sized for that PVC spec. The endpoint 
///   type is defined by the `type` argument; it defaults to "spigot". If the optional 
///   `length` argument is defined and non-zero, the endpoint will be that value in length;
///   the default will be to use the PVC's `tl` attribute value, which defines the thread-length
///   of the PVC spec. 
///
/// Arguments:
///   pvc = An instantiated PVC specification
///   ---
///   type = The endpoint type to model. Default: `spigot`
///   length = The length of the endpoint to create. Default: `undef` (meaning the value of the PVC object's `tl` attribute will be used)
///   anchor = Translate so anchor point is at origin `[0,0,0]`. Default: `PVC_DEFAULT_ANCHOR`
///   spin = Rotate this many degrees around the Z axis after anchoring. Default: `PVC_DEFAULT_SPIN`
///   orient = Vector direction to which the model should point after spin. Default: `PVC_DEFAULT_ORIENT`
///
/// Continues:
///   It is an error to call `pvc_endpoint()` with a `type` that isn't listed in `PVC_ENDTYPES`.
///
module pvc_endpoint(pvc, type="spigot", length=undef,
        anchor=PVC_DEFAULT_ANCHOR, spin=PVC_DEFAULT_SPIN, orient=PVC_DEFAULT_ORIENT) {
    if (_defined(type)) {
        assert(in_list(type, PVC_ENDTYPES), str("pvc_endpoint(): specified type ", type, " not known"));
        od = pvc_od(pvc);
        id = pvc_id(pvc);
        wall = pvc_wall(pvc);
        attachable_od = (type == "socket") ? sum([od, (wall/3) * 2]) : od;

        overlap = (type == "socket") ? 3 : 0;
        l = sum([ 
            (_defined(length) && length > 0) ? length : pvc_tl(pvc),
            overlap
            ]);

        attachable(anchor, spin, orient, d=attachable_od, l=l) {
            if (type == "spigot") {
                tube(od=od, wall=wall, l=l, anchor=CENTER);

            } else if (type == "ispigot") {
                tube(od=id, wall=wall, l=l, anchor=CENTER);

            } else if (type == "mipt") {
                difference() {
                    threaded_rod(d=id + wall, l=l,
                        pitch=pvc_pitch(pvc), 
                        bevel=true, 
                        internal=false, 
                        anchor=CENTER);
                    cylinder(d=id, l=l + 0.001, anchor=CENTER);
                }

            } else if (type == "socket") {
                tube(id=od, wall=wall / 3, l=l, anchor=CENTER);

            } else if (type == "fipt") {
                difference() {
                    tube(od=od, wall=wall, l=l, anchor=CENTER);
                    threaded_rod(d=id + wall, l=l + 0.001,
                        pitch=pvc_pitch(pvc),
                        bevel=true,
                        internal=true,
                        anchor=CENTER);
                }

            }
            children();
        }
    }
}


/// Section: PVC Objects
///
/// Subsection: Object Creation
///
/// Function: PVC()
/// Description:
///   Creates a new `pvc` object given a variable list of `[attribute, value]` lists. 
///   Attribute pairs can be in any order. Unspecified attributes will be set to `undef`. 
///   `PVC()` returns a new list that should be treated as an opaque object.
///   .
///   Optionally, an existing `pvc` object can be provided via the `mutate` argument: that 
///   existing `pvc` will be used as the original set of object attribute values, and any 
///   new values provided in `vlist` will take precedence.
/// Usage:
///   pvc_obj = PVC(vlist);
///   pvc_obj = PVC(vlist, mutate=pvc);
/// Arguments:
///   vlist = Variable list of attributes and values: `[ ["length", 10], ["style", "none"] ]`. 
///   ---
///   mutate = An existing `pvc` object on which to pre-set base values. Default: `[]`
/// 
function PVC(vlist=[], mutate=[]) = Object("PVC", PVC_attributes, vlist=vlist, mutate=mutate);

/// Constant: PVC_attributes
/// Description:
///   A list of all available `pvc` attributes.
/// Attributes:
///   schedule = i = The schedule spec, one of `PVC_KNOWN_SCHEDULES`. No default.
///   name = s = The nominal size, the name of size of the outer pipe in inches. This is NOT a measurement, but a string identifier. No default.
///   od = i = The outer diameter of the pipe, in `mm`. No default.
///   wall = i = The wall thickness of the pipe, in `mm`. No default.
///   dn = s = The DN, or diameter name, of the pipe. This is NOT a measurement, but a string identifier. No default.
///   tl = i=10 = The thread length: the minimum distance to make a connection between components, threaded or not. This varies by schedule and dimension; will be put into the raw as soon as I find that info. Current default: `10`
///   pitch = i=0.9407 = The thread pitch, for threaded connections. This varies by schedule and dimension, and will be put into the raw as soon as I find that info. Current default: `0.9407`
///
PVC_attributes = [ "schedule=i", "name=s", "od=i", "wall=i", "dn=s", 
                    "tl=i=10", "pitch=i=0.9407" ];

/// Subsection: PVC Object Attribute Accessor Functions
///   Each of the attributes listed in `PVC_attributes` has an accessor built 
///   for it. For example, a PVC's `schedule` is accessed via 
///   `pvc_schedule()`. These attribute-specific functions are 
///   convienence, and all have the same form. They are listed below, and all have 
///   the same function definition as `pvc_schedule()`, also documented below.
/// Listing:
///   pvc_schedule() 
///   pvc_name() 
///   pvc_od() 
///   pvc_wall() 
///   pvc_dn() 
///   pvc_tl() 
///   pvc_pitch() 
///
/// Function: pvc_schedule()
/// Description: 
///   Mutatable object accessor specific to the `schedule` attribute. 
/// Usage:
///   schedule = pvc_schedule(pvc, <default=undef>);
///   new_pvc = pvc_schedule(pvc, <nv=undef>);
/// Arguments:
///   pvc = A PVC object
///   ---
///   default = If provided, and if there is no existing value for `schedule` in the object `pvc`, returns the value of `default` instead. 
///   nv = If provided, `pvc_schedule()` will update the value of the `schedule` attribute and return a new PVC object. *The existing PVC object is unmodified.*
function pvc_schedule(pvc, default=undef, nv=undef)     = obj_accessor(pvc, "schedule", default=default, nv=nv);
function pvc_name(pvc, default=undef, nv=undef)         = obj_accessor(pvc, "name", default=default, nv=nv);
function pvc_od(pvc, default=undef, nv=undef)           = obj_accessor(pvc, "od", default=default, nv=nv);
function pvc_wall(pvc, default=undef, nv=undef)         = obj_accessor(pvc, "wall", default=default, nv=nv);
function pvc_dn(pvc, default=undef, nv=undef)           = obj_accessor(pvc, "dn", default=default, nv=nv);
function pvc_tl(pvc, default=undef, nv=undef)           = obj_accessor(pvc, "tl", default=default, nv=nv);
function pvc_pitch(pvc, default=undef, nv=undef)        = obj_accessor(pvc, "pitch", default=default, nv=nv);


/// Subsection: Derived Attribute Functions
///   These are functions that calculate and return properties of PVC objects derived from the PVC's attributes. 
///   They're not values pulled directly from the PVC object. 
///
/// Function: pvc_id()
/// Usage:
///   id = pvc_id(pvc);
/// Description:
///   Given a PVC object `pvc`, return the calculated inner diameter `id`. 
function pvc_id(pvc) = pvc_od(pvc) - (pvc_wall(pvc) * 2);
/// Function: pvc_socket_od()
/// Usage:
///   diam = pvc_socket_od(pvc);
/// Description:
///   Given a PVC object `pvc`, return the calculated outer socket diameter `diam`. 
///   The outer socket diameter is the minimum outer diameter for a part component 
///   that needs a socket to fit the PVC spec. 
function pvc_socket_od(pvc) = pvc_socket_id(pvc) + (pvc_wall(pvc) * 2);
/// Function: pvc_socket_id()
/// Usage:
///   diam = pvc_socket_id(pvc);
/// Description:
///   Given a PVC object `pvc`, return the calculated inner socket diameter `diam`. 
///   The inner socket diameter is the minimum inner diameter for a part component 
///   that needs a socket to fit the PVC spec.
function pvc_socket_id(pvc) = pvc_od(pvc);


/// Subsection: Miscellaneous Help Functions
///
/// Function: list_apply_defaults()
/// Usage:
///   new_list = list_apply_defaults(l, defaults);
///
/// Description:
///   Given a list of values `l` and a list of defaults `defaults`, 
///   positionally apply elements in `defaults` to the same position in `l` 
///   if that positional element within `l` is not defined, and return a
///   new list of elements as `new_list`. In other words, 
///   if an value is missing from the list `l`, use the value from `defaults`. 
///   .
///   If `defaults` has more elements than `l`, the returned `new_list` will be
///   the same length as `defaults`. 
///   .
///   If `l` is not a list, it will be internally converted to one, with a singular 
///   defined value at `0` as the value of `l` and the remaining `len(defaults)` 
///   elements set to `undef`, before the defaults from `defaults` are applied.
///
/// Arguments:
///   l = A list of values
///   defaults = A list of values
///
function list_apply_defaults(l, defaults) =
    let(
        // coerce whatever `l` is to an actual list:
        coerced_list = (is_list(l)) ? l : force_list(l, len(defaults), fill=undef),
        // make sure our list of elements is the correct size:
        padded_list = (len(coerced_list) >= len(defaults)) ? coerced_list : list_pad(coerced_list, len(defaults), undef)
    )
    // default-merge the two lists, padded_list and defaults:
    [ for (i=idx(padded_list)) (_defined(padded_list[i])) ? padded_list[i] : defaults[i] ];


/// Constant: _PVC_specs_raw
/// Description:
///   This is the raw detail data of PVC specifications. Each element within `_PVC_specs_raw` 
///   is a seven-element list that describes the size and dimensions of PVC parts. 
///   The element layout is as follows:
///   `[ schedule, name, outer-diameter, wall-thickness, DN-name, thread-length, pitch ]`.
///   .
///   The detail is roughly organized by schedule, ordered by nominal-size (name). 
///   .
///   This data is sourced from a variety of places (list of sources forthcoming).
///   .
///   PVC modules do not use `_PVC_specs_raw` directly: instead, they do lookups for 
///   PVC objects from the `PVC_Specs` listing, which is generated dynamically at runtime.
///   .
///   **NOTE:** thread-len and pitch values pulled from online
///   have not every size for sched-40 & sched-80; a best-effort
///   fill-in-the-gaps is done here.
///   .
///   Data throughout this table was assembled from various places
///   and dropped into this public Google sheet: https://docs.google.com/spreadsheets/d/16uJ9TI1HDpMDmowM9_0UBDWN-NWQXJ5RcD7DOoRFrvU/edit#gid=0 
///   Sources - as much as they're known - are listed there. 
///
/// Todo:
///   Get the final two columns of data for Schedule 120: thread-length & pitch
///
_PVC_specs_raw = [
    // 40
    [ 40, "1/8", 10.3, 1.73, "DN8", 6.70306, 0.940816],
    [ 40, "1/4", 13.7, 2.24, "DN12", 10.20572, 1.411224],
    [ 40, "3/8", 17.1, 2.31, "DN10", 10.35812, 1.411224],
    [ 40, "1/2", 21.3, 2.77, "DN15", 13.55598, 1.814322],
    [ 40, "3/4", 26.7, 2.87, "DN20", 13.86078, 1.814322],
    [ 40, "1", 33.4, 3.38, "DN25", 17.34312, 2.208784],
    [ 40, "1 1/4", 42.2, 3.56, "DN32", 17.95272, 2.208784],
    [ 40, "1 1/2", 48.3, 3.68, "DN40", 18.3769, 2.208784],
    [ 40, "2", 60.3, 3.91, "DN50", 19.2151, 2.208784],
    [ 40, "2 1/2", 73, 5.16, "DN65", 28.8925, 3.175],
    [ 40, "3", 88.9, 5.49, "DN80", 30.48, 3.175],
    [ 40, "3 1/2", 101.6, 5.74, "DN90", 30.48, 3.175],
    [ 40, "4", 114.3, 6.02, "DN100", 33.02, 3.175],
    [ 40, "5", 141.3, 6.55, "DN125", 35.72002, 3.175],
    [ 40, "6", 168.3, 7.11, "DN150", 38.4175, 3.175],
    [ 40, "8", 219.1, 8.18, "DN200", 43.4975, 3.175],
    [ 40, "10", 273, 9.27, "DN250", 43.4975, 3.175],
    [ 40, "12", 323.8, 10.31, "DN300", 43.4975, 3.175],
    [ 40, "14", 355.6, 11.1, "DN350", 43.4975, 3.175],
    [ 40, "16", 406.4, 12.7, "DN400", 43.4975, 3.175],
    [ 40, "18", 457, 14.27, "DN450", 43.4975, 3.175],
    [ 40, "20", 508, 15.08, "DN500", 43.4975, 3.175],
    [ 40, "24", 610, 17.45, "DN600", 43.4975, 3.175],

    // 80
    [ 80, "1/8", 10.3, 2.41, "DN8", 6.70306, 0.940816],
    [ 80, "1/4", 13.7, 3.02, "DN12", 10.20572, 1.411224],
    [ 80, "3/8", 17.1, 3.2, "DN10", 10.35812, 1.411224],
    [ 80, "1/2", 21.3, 3.73, "DN15", 13.55598, 1.814322],
    [ 80, "3/4", 26.7, 3.91, "DN20", 13.86078, 1.814322],
    [ 80, "1", 33.4, 4.55, "DN25", 17.34312, 2.208784],
    [ 80, "1 1/4", 42.2, 4.85, "DN32", 17.95272, 2.208784],
    [ 80, "1 1/2", 48.3, 5.08, "DN40", 18.3769, 2.208784],
    [ 80, "2", 60.3, 5.54, "DN50", 19.2151, 2.208784],
    [ 80, "2 1/2", 73, 7.01, "DN65", 28.8925, 3.175],
    [ 80, "3", 88.9, 7.62, "DN80", 30.48, 3.175],
    [ 80, "3 1/2", 101.6, 8.08, "DN90", 30.48, 3.175],
    [ 80, "4", 114.3, 8.56, "DN100", 33.02, 3.175],
    [ 80, "5", 141.3, 9.52, "DN125", 35.72002, 3.175],
    [ 80, "6", 168.3, 10.97, "DN150", 38.4175, 3.175],
    [ 80, "8", 219.1, 12.7, "DN200", 43.4975, 3.175],
    [ 80, "10", 273, 15.06, "DN250", 43.4975, 3.175],
    [ 80, "12", 323.8, 17.45, "DN300", 43.4975, 3.175],
    [ 80, "14", 355.6, 19.05, "DN350", 43.4975, 3.175],
    [ 80, "16", 406.4, 21.41, "DN400", 43.4975, 3.175],
    [ 80, "18", 457, 23.8, "DN450", 43.4975, 3.175],
    [ 80, "20", 508, 26.19, "DN500", 43.4975, 3.175],
    [ 80, "24", 610, 30.94, "DN600", 43.4975, 3.175],

    // 120
    [ 120, "1/2", 21.3, 4.32, "DN15", undef, undef ],
    [ 120, "3/4", 26.7, 4.32, "DN20", undef, undef ],
    [ 120, "1", 33.4, 5.08, "DN25", undef, undef ],
    [ 120, "1 1/4", 42.2, 5.46, "DN32", undef, undef ],
    [ 120, "1 1/2", 48.3, 5.72, "DN40", undef, undef ],
    [ 120, "2", 60.3, 6.35, "DN50", undef, undef ],
    [ 120, "2 1/2", 73, 7.62, "DN65", undef, undef ],
    [ 120, "3", 88.9, 8.89, "DN80", undef, undef ],
    [ 120, "3 1/2", 101.6, 8.89, "DN90", undef, undef ],
    [ 120, "4", 114.3, 11.1, "DN100", undef, undef ],
    [ 120, "5", 141.3, 12.7, "DN125", undef, undef ],
    [ 120, "6", 168.3, 14.27, "DN150", undef, undef ],
    [ 120, "8", 219.1, 18.24, "DN200", undef, undef ],
    [ 120, "10", 273, 21.41, "DN250", undef, undef ],
    [ 120, "12", 323.8, 25.4, "DN300", undef, undef ],
];

/// Constant: PVC_Specs
/// Description: 
///   A list of all know PVC specifications as instantiated PVC objects.
///   .
///   It's possible to access the PVC specification you're looking for by manually 
///   looping through the `PVC_Specs` list, but it's more highly recommended to use 
///   the `pvc_spec_lookup()` function, defined below.
///   .
///   Note: This list is generated dynamically at runtime from an inline data listing.
PVC_Specs = [ for (e=_PVC_specs_raw) PVC(["schedule", e[0], "name", e[1], "od", e[2], "wall", e[3], "dn", e[4]]) ];

/// PVC_KNOWN_SCHEDULES is publicly documented above, in the "Constants" section.
PVC_KNOWN_SCHEDULES = sort( unique( [for (p=_PVC_specs_raw) p[0]] ) );

