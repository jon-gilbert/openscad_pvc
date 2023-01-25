include <openscad_pvc.scad>

// perhaps unnecessary test now, since this constant is dynamically created at runtime
module test_pvc_schedules_list() {
    schedules = sort( unique( [for (p=_PVC_specs_raw) p[0]] ) );
    for (s=schedules) assert(in_list(s, PVC_KNOWN_SCHEDULES));
    for (s=PVC_KNOWN_SCHEDULES) assert(in_list(s, schedules));
}
test_pvc_schedules_list();

module test_pvc_raw_specs() {
    // each item in the list must be a list
    // each sub-item must have seven elements
    // element 1, 4 are strings 
    // element 1 must be unique within each schedule
    // element 4 must be unique within each schedule
    assert(len(_PVC_specs_raw) > 0, "_PVC_specs_raw must be a list with non-zero len");
    
    islist_bool_list = [ for (i=_PVC_specs_raw) is_list(i) ];
    assert(is_homogeneous(islist_bool_list), "all elements in _PVC_specs_raw must be individual lists");
    
    assert(list_shape(_PVC_specs_raw, 1) == 7,
        "all elements in _PVC_specs_raw must have the same number of elements, and it must be 7");
    
    elems1and4 = flatten( [ for (i=_PVC_specs_raw) [i[1], i[4]] ] );
    assert(is_homogenous(elems1and4), "elements 1 and 4 for each spec listing must be a string");

    function list_is_unique(list) = 
        let(
            deduped = deduplicate(sort(list)),
            v = compare_lists(sort(list), deduped) == 0
        ) v;

    assert(list_is_unique(
        obj_select_values_from_obj_list( obj_select_by_attr_value(PVC_Specs, "schedule", 40), "name")
        ), "schedule 40 names must be unique");
    assert(list_is_unique(
        obj_select_values_from_obj_list( obj_select_by_attr_value(PVC_Specs, "schedule", 40), "dn")
        ), "schedule 40 DNs must be unique");
    assert(list_is_unique(
        obj_select_values_from_obj_list( obj_select_by_attr_value(PVC_Specs, "schedule", 80), "name")
        ), "schedule 80 names must be unique");
    assert(list_is_unique(
        obj_select_values_from_obj_list( obj_select_by_attr_value(PVC_Specs, "schedule", 80), "dn")
        ), "schedule 80 DNs must be unique");
    assert(list_is_unique(
        obj_select_values_from_obj_list( obj_select_by_attr_value(PVC_Specs, "schedule", 120), "name")
        ), "schedule 120 names must be unique");
    assert(list_is_unique(
        obj_select_values_from_obj_list( obj_select_by_attr_value(PVC_Specs, "schedule", 120), "dn")
        ), "schedule 120 DNs must be unique");
}
test_pvc_raw_specs();

