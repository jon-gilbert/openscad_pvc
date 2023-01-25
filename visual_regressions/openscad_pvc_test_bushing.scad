include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    pvc_bushing(p, p2) show_anchors(std=true);
    pvc_bushing(p, p2);
    pvc_bushing(p2, p, ends=["socket"]);
    pvc_bushing(p, p2, ends=["socket", "spigot"]);
    //pvc_bushing(p, p2, ends=["spigot", "spigot"]);
    //pvc_bushing(p, p2, ends=["mipt", "mipt"]);
    //pvc_bushing(p, p2, ends=["fipt", "fipt"]);
}

