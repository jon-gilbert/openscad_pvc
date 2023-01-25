include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    back_half() pvc_flange(p, ends=["socket"]) show_anchors(std=true);
    pvc_flange(p, ends=["socket"]);
    pvc_flange(p, ends=["spigot"]);
    pvc_flange(p, ends=["mipt"]);
    pvc_flange(p, ends=["fipt"]);
}

