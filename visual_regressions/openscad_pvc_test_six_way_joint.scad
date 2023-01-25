include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_six_way_joint(p, ends=["socket", "socket", "socket", "socket", "socket", "socket"]) show_anchors(std=true);
    pvc_six_way_joint(p, ends=["socket", "socket", "socket", "socket", "socket", "socket"]);
    pvc_six_way_joint(p, ends=["spigot", "spigot", "spigot", "spigot", "spigot", "spigot"]);
    pvc_six_way_joint(p, ends=["mipt", "mipt", "mipt", "mipt", "mipt", "mipt"]);
    pvc_six_way_joint(p, ends=["fipt", "fipt", "fipt", "fipt", "fipt", "fipt"]);
    pvc_six_way_joint(p, ends=["socket", "spigot", "mipt", "fipt", "socket", "spigot"]);
}

