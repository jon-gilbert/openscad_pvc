include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_tee(p) show_anchors(std=true);
    pvc_tee(p, ends=["socket", "socket", "socket"]);
    pvc_tee(p, ends=["spigot", "spigot", "spigot"]);
    pvc_tee(p, ends=["mipt", "mipt", "mipt", ]);
    pvc_tee(p, ends=["fipt", "fipt", "fipt"]);
}

