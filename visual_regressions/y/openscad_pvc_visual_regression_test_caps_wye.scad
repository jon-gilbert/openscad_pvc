include <../openscad_pvc.scad>

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

spacing = 80;

xdistribute(spacing=spacing) {

    ydistribute(spacing=spacing) {
        pvc_wye(p) show_anchors(std=false);
        pvc_wye(p, ends=["socket", "socket", "socket"]);
        pvc_wye(p, ends=["spigot", "spigot", "spigot"]);
        pvc_wye(p, ends=["mipt", "mipt", "mipt"]);
        pvc_wye(p, ends=["fipt", "fipt", "fipt"]);

    }

    ydistribute(spacing=spacing) {
        zdistribute(spacing=spacing) {
            pvc_cap(p) show_anchors(std=false);
            pvc_cap(p, ends=["socket"]);
            //pvc_cap(p, ends=["spigot"]);
            //pvc_cap(p, ends=["mipt"]);
            pvc_cap(p, ends=["fipt"]);
        }

        zdistribute(spacing=spacing) {
            pvc_plug(p) show_anchors(std=false);
            //pvc_plug(p, ends=["socket"]);
            pvc_plug(p, ends=["spigot"]);
            pvc_plug(p, ends=["mipt"]);
            //pvc_plug(p, ends=["fipt"]);
        }
    }

}

