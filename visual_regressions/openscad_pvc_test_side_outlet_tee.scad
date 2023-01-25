include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_side_outlet_tee(p, ends=["socket", "socket", "socket", "socket"]) show_anchors(std=true);
    pvc_side_outlet_tee(p, ends=["socket", "socket", "socket", "socket"]);
    pvc_side_outlet_tee(p, ends=["spigot", "spigot", "spigot", "spigot"]);
    pvc_side_outlet_tee(p, ends=["mipt", "mipt", "mipt", "mipt"]);
    pvc_side_outlet_tee(p, ends=["fipt", "fipt", "fipt", "fipt"]);            
}

