include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_cross(p, ends=["socket", "socket", "socket", "socket"]) show_anchors(std=true);
    pvc_cross(p, ends=["socket", "socket", "socket", "socket"]);
    pvc_cross(p, ends=["spigot", "spigot", "spigot", "spigot"]);
    pvc_cross(p, ends=["mipt", "mipt", "mipt", "mipt"]);
    pvc_cross(p, ends=["fipt", "fipt", "fipt", "fipt"]);
    pvc_cross(p, ends=["socket", "spigot", "mipt", "fipt"]);
}

