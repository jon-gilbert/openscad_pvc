include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_pipe(p, 50) show_anchors();
    pvc_pipe(p, 50, ends=["spigot", "spigot"]);
    pvc_pipe(p, 50, ends=["socket", "socket"]);
    pvc_pipe(p, 50, ends=["mipt", "mipt"]);
    pvc_pipe(p, 50, ends=["fipt", "fipt"]);
}

