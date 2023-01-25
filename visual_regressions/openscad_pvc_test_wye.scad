include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_wye(p, ends=["spigot", "spigot", "spigot"]) show_anchors(std=true);
    pvc_wye(p, ends=["socket", "socket", "socket"]);
    pvc_wye(p, ends=["spigot", "spigot", "spigot"]);
    pvc_wye(p, ends=["mipt", "mipt", "mipt"]);
    pvc_wye(p, ends=["fipt", "fipt", "fipt"]);
}

