include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_plug(p, ends=["spigot"]) show_anchors(std=true);
    //pvc_plug(p, ends=["socket"]);
    pvc_plug(p, ends=["spigot"]);
    pvc_plug(p, ends=["mipt"]);
    //pvc_plug(p, ends=["fipt"]);
}

