include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_cap(p, ends=["socket"]) show_anchors(std=false);
    pvc_cap(p, ends=["socket"]);
    //pvc_cap(p, ends=["spigot"]);
    //pvc_cap(p, ends=["mipt"]);
    pvc_cap(p, ends=["fipt"]);
}

