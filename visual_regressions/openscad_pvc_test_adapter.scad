include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_adapter(p, p2, ends=["spigot", "spigot"]) show_anchors(std=true);
    pvc_adapter(p, p2, ends=["socket", "socket"]);
    pvc_adapter(p, p2, ends=["spigot", "spigot"]);
    pvc_adapter(p, p2, ends=["mipt", "mipt"]);
    pvc_adapter(p, p2, ends=["fipt", "fipt"]);
}

