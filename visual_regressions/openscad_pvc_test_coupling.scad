include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_coupling(p, ends=["fipt", "fipt"]) show_anchors(std=true);
    pvc_coupling(p, ends=["socket", "socket"]);
    pvc_coupling(p, ends=["spigot", "spigot"]);
    pvc_coupling(p, ends=["mipt", "mipt"]);
    pvc_coupling(p, ends=["fipt", "fipt"]);
}

