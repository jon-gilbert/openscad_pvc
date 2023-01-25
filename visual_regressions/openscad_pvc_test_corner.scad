include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_corner(p, ends=["socket", "socket", "socket"]) show_anchors(std=true);
    pvc_corner(p, ends=["socket", "socket", "socket"]);
    pvc_corner(p, ends=["spigot", "spigot", "spigot"]);
    pvc_corner(p, ends=["mipt", "mipt", "mipt"]);
    pvc_corner(p, ends=["fipt", "fipt", "fipt"]);
}

